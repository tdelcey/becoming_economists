############################ Functions to Run and Check a Country Pipeline ############################
#
# Goal: shared tools to (1) run the cleaning scripts of a country in order, by
#   default on a test copy of the data, and (2) compare the tables produced with
#   the current ones (in "phd_data"), so that every change in the data is known
#   and can be written in the changelog (news.qmd) before a new
#   version is uploaded to Zenodo.
#
# Used by: <COUNTRY>/R/run_pipeline.R (e.g. FR/R/run_pipeline.R).
#
# Main choices:
#   - Each step runs in a fresh R process (Rscript): the scripts rely on objects
#     created by `source("paths_and_packages.R")` and must not see leftovers of
#     the previous step, as when they are run one by one.
#   - Test mode sets the environment variable PHD_DATA_PATH (read by
#     paths_and_packages.R) to a test copy whose raw_data/ is a symbolic link to
#     the real one: raw data are read, never written, by the cleaning scripts,
#     and the shared intermediate and cleaned files are not overwritten.
#   - The comparison masks temporary ids (temp_*) on request: before November
#     2026 they were random, so they cannot be compared with older files.

pacman::p_load(here, cli, data.table, purrr, stringr, fs, glue)

#' Create a test copy of the data folder
#'
#' @param data_path The real data folder ("phd_data").
#' @param test_root Folder in which the test copy "phd_data" is created.
#' @param subfolders Folders to create empty (outputs of the steps), relative to
#'   the data folder, e.g. "intermediate_data/FR/sudoc".
#' @return The path of the test copy.
create_test_copy <- function(data_path, test_root, subfolders) {
  test_path <- path(test_root, "phd_data") # named "phd_data" to pass the check in paths_and_packages.R
  if (dir_exists(test_path)) dir_delete(test_path)
  dir_create(path(test_path, subfolders))
  link_create(path(data_path, "raw_data"), path(test_path, "raw_data"))
  cli_alert_info("Test copy of the data in {.path {test_path}} (raw_data/ linked to the real one).")
  test_path
}

#' Run pipeline steps in order, each in a fresh R process
#'
#' @param scripts Paths of the scripts, relative to the project root, in order.
#' @param data_path Data folder to use (a test copy, or the real "phd_data").
#' @param log_dir Folder for one log file per step.
#' @return Invisibly, a data.table with the duration of each step. Stops at the
#'   first failing step and prints the end of its log.
run_steps <- function(scripts, data_path, log_dir) {
  dir_create(log_dir)
  timings <- map_dfr(scripts, \(script) {
    log_file <- path(log_dir, paste0(path_ext_remove(path_file(script)), ".log"))
    cli_progress_step("Running {.file {script}}")
    start <- Sys.time()
    status <- withr::with_envvar(
      c(PHD_DATA_PATH = data_path),
      system2("Rscript", c("-e", shQuote(glue("source('{script}')"))),
              stdout = log_file, stderr = log_file)
    )
    if (status != 0) {
      cli_progress_done(result = "failed")
      cli_abort(c("{.file {script}} failed.", "i" = "End of {.path {log_file}}:",
                  set_names(tail(readLines(log_file), 15), rep(" ", 15))))
    }
    data.table(script = script, seconds = round(as.numeric(difftime(Sys.time(), start, units = "secs")), 1))
  })
  cli_progress_done()
  invisible(timings)
}

#' Replace temporary ids by their prefix (temp_<source>_<type>), in all columns
mask_temp_ids <- function(dt) {
  dt <- copy(as.data.table(dt))
  pattern <- "^temp_(sudoc|thesefr|thesesfr)_([a-z]+)_\\w+$"
  for (col in names(dt)) {
    if (is.list(dt[[col]])) {
      dt[, (col) := map_chr(get(col), \(x) paste(sort(str_replace(as.character(unlist(x)), pattern, "temp_\\1_\\2")), collapse = "|"))]
    } else if (is.character(dt[[col]])) {
      dt[, (col) := str_replace(get(col), pattern, "temp_\\1_\\2")]
    }
  }
  dt
}

#' Compare one table produced by a run with the current one
#'
#' @return A one-row data.table: rows in each version, columns added/removed,
#'   rows only in the new or the old version, and the number of changed values
#'   per column for records (same key) present in both.
compare_table <- function(new_file, old_file, mask_temp = TRUE) {
  new <- as.data.table(readRDS(new_file))
  old <- as.data.table(readRDS(old_file))
  if (mask_temp) {
    new <- mask_temp_ids(new)
    old <- mask_temp_ids(old)
  } else {
    # list columns cannot be compared row by row: flatten them
    flatten <- \(dt) dt[, names(.SD) := map(.SD, \(x) map_chr(x, \(y) paste(sort(as.character(unlist(y))), collapse = "|"))), .SDcols = is.list]
    new <- flatten(new); old <- flatten(old)
  }
  common <- intersect(names(new), names(old))
  only_new <- fsetdiff(unique(new[, ..common]), unique(old[, ..common]))
  only_old <- fsetdiff(unique(old[, ..common]), unique(new[, ..common]))
  key <- intersect(c("thesis_id", "entity_id"), common)[1]
  changed <- ""
  # Value-by-value comparison for tables with one row per key (not edge tables),
  # on records whose key is still unique once temporary ids are masked
  one_row_per_key <- !is.na(key) && mean(duplicated(new[[key]])) < 0.5
  if (one_row_per_key && nrow(only_new) > 0 && nrow(only_old) > 0) {
    unique_key <- \(dt) dt[!(get(key) %in% get(key)[duplicated(get(key))])]
    both <- merge(unique_key(only_new), unique_key(only_old), by = key, suffixes = c(".new", ".old"))
    counts <- map_int(setdiff(common, key), \(col) {
      a <- both[[paste0(col, ".new")]]; b <- both[[paste0(col, ".old")]]
      sum(xor(is.na(a), is.na(b)) | (!is.na(a) & !is.na(b) & a != b))
    }) |> set_names(setdiff(common, key))
    counts <- counts[counts > 0]
    changed <- paste0(names(counts), " (", counts, ")", collapse = ", ")
  }
  data.table(
    rows_new = nrow(new), rows_old = nrow(old),
    columns_added = paste(setdiff(names(new), names(old)), collapse = ", "),
    columns_removed = paste(setdiff(names(old), names(new)), collapse = ", "),
    rows_only_new = nrow(only_new), rows_only_old = nrow(only_old),
    changed_values = changed
  )
}

#' Compare all .rds tables of a run with the current ones and write a report
#'
#' @param new_root,old_root Data folders of the run and of the current data.
#' @param subfolders Folders to compare, relative to the data folders.
#' @param report_file Markdown report, committed in the repository so that the
#'   history of the data changes is kept (e.g. FR/pipeline_log/2026-11-24.md).
#' @return The comparison table (invisibly).
compare_runs <- function(new_root, old_root, subfolders, report_file, mask_temp = TRUE) {
  files <- map(subfolders, \(f) dir_ls(path(new_root, f), recurse = TRUE, glob = "*.rds")) |> unlist()
  comparison <- map_dfr(files, \(file) {
    rel <- path_rel(file, new_root)
    old_file <- path(old_root, rel)
    if (!file_exists(old_file)) return(data.table(table = rel, rows_new = NA, rows_old = NA, columns_added = "new table"))
    cbind(data.table(table = rel), compare_table(file, old_file, mask_temp))
  }, .id = NULL)
  identical_tables <- comparison[rows_only_new == 0 & rows_only_old == 0 & columns_added == "" & columns_removed == "", .N]
  cli_alert_info("{identical_tables} of {nrow(comparison)} table{?s} identical{if (mask_temp) ' (temporary ids masked)' else ''}.")
  dir_create(path_dir(report_file))
  writeLines(c(
    glue("# Pipeline run of {Sys.Date()}"), "",
    glue("Comparison of the tables produced by the run with the current files in phd_data{if (mask_temp) ', temporary ids masked' else ''}."),
    "Changes listed here must be described in news.qmd (section \"Unreleased\").", "",
    knitr::kable(comparison, format = "pipe")
  ), report_file)
  cli_alert_success("Report written in {.file {report_file}}.")
  print(comparison[, .(table, rows_new, rows_old, rows_only_new, rows_only_old, changed_values)])
  invisible(comparison)
}
