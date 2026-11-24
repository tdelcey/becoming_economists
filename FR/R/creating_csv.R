################### Creating a .csv Version of the Database ###################

#' Purpose: export every cleaned table of the French database (`.rds` in
#' `FR_cleaned_data_path`) to `.csv`, the format published on Zenodo.
#' List columns (`duplicates`, `homonym_of`, `old_id`) are written by readr as
#' their values separated by "|".

source(file.path("paths_and_packages.R"))

files <- list.files(FR_cleaned_data_path, pattern = "\\.rds$", full.names = TRUE)
for (file in files) {
  csv_file <- str_replace(file, "\\.rds$", ".csv")
  write_csv(readRDS(file), csv_file)
  cli_alert_success("Written {.file {basename(csv_file)}}")
}
