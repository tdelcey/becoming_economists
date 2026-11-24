############################ Running the French Cleaning Pipeline ############################
#
# Goal: rerun every cleaning step of the French database, from the raw data
#   (Sudoc, theses.fr, IdRef, INSEE first names) to the .csv files published on
#   Zenodo, and compare the result with the current tables.
#
# Inputs: raw_data/FR/ and raw_data/insee_prénoms_2023.csv in "phd_data".
#   The collection scripts (scraping_sudoc_*.R, scraping_idref_*.R,
#   downloading_theses_fr.R) are NOT run: they query external services and
#   change the raw data; run them by hand when the sources must be updated.
#
# Outputs:
#   - test mode (default): all tables in a test copy of the data (see
#     `test_root`), the shared files in phd_data are untouched;
#   - a comparison report in FR/pipeline_log/<date>.md (commit it), listing what
#     changed with respect to the current tables: describe these changes in
#     news.qmd ("Unreleased" section of the French database);
#   - production mode (`test_mode <- FALSE` and `confirm_overwrite <- TRUE`): the
#     shared intermediate and cleaned files in phd_data are overwritten. Do it
#     only after checking the report of a test run.
#
# Duration: about 3 minutes (most of it in cleaning_metadata.R, language detection).
#
# Run from the project root, line by line or with source("FR/R/run_pipeline.R").

source(file.path("paths_and_packages.R"))
source(file.path("functions_pipeline.R"))

#### SETTINGS ####

test_mode <- TRUE
confirm_overwrite <- FALSE # must be TRUE to overwrite the shared files (production mode)

# Where the test copy is created (outside the repository and outside Nextcloud,
# so that test outputs are neither committed nor synchronised)
test_root <- tools::R_user_dir("becoming_economists", "cache")

# Steps, in order (see AGENTS.md and the documentation for what each one does)
steps <- c(
  "FR/R/cleaning_sudoc.R",
  "FR/R/cleaning_thesesfr.R",
  "FR/R/merging_sudoc_thesesfr.R",
  "FR/R/cleaning_metadata.R",
  "FR/R/cleaning_institutions.R",
  "FR/R/cleaning_individuals.R",
  "FR/R/cleaning_edges.R",
  "FR/R/adding_columns_metadata.R",
  "FR/R/creating_csv.R"
)

# Folders written by the steps, relative to the data folder
output_folders <- c("intermediate_data/FR/sudoc", "intermediate_data/FR/these_fr", "cleaned_data/FR")

# Temporary ids were random before November 2026: mask them when comparing with
# tables produced before that date (set to FALSE once the published tables have
# deterministic ids, to also detect changes of ids).
mask_temp <- TRUE

#### RUN ####

real_data_path <- data_path

if (test_mode) {
  run_data_path <- create_test_copy(real_data_path, test_root, output_folders)
} else {
  if (!confirm_overwrite) {
    cli_abort("Production mode overwrites the shared files in {.path {real_data_path}}: set {.code confirm_overwrite <- TRUE} first.")
  }
  run_data_path <- real_data_path
}

timings <- run_steps(steps, run_data_path, log_dir = path(test_root, "logs"))
print(timings)

#### COMPARE ####

if (test_mode) {
  comparison <- compare_runs(
    new_root = run_data_path,
    old_root = real_data_path,
    subfolders = c("intermediate_data/FR", "cleaned_data/FR"),
    report_file = here("FR", "pipeline_log", paste0(Sys.Date(), ".md")),
    mask_temp = mask_temp
  )
}
