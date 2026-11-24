package_list <- c("pacman", #loading packages
                  "here", # building clearer paths
                  "tidyverse",
                  "cli", # for managing alerts and messages
                  "glue", # for string interpolation
                  "data.table",
                  "janitor", 
                  "stringi"
              )

for (p in package_list) {
  if (p %in% installed.packages() == FALSE) {
    install.packages(p, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

# Number of threads used with data.table in percentage of total CPU
setDTthreads(percent = 70)

#### PATH ####

# The data live outside the repository, in a folder named "phd_data" shared
# through Nextcloud. Each author's machine is recognised from the working
# directory. Thomas's paths still point to the former Google Drive folder:
# they must be replaced by the local copy of the shared Nextcloud "phd_data"
# folder (a warning is raised below until then).
if (str_detect(getwd(), "agoutsmedt")) {
  data_path <- file.path(path.expand("~"), "Nextcloud/Research/data/phd_data")
} else if (str_detect(getwd(), "tunex")) {
  data_path <- file.path(path.expand("~"), "google_drive/Mon Drive/Phd_Project/data")
} else {
  # "Admin", "thomd" and any other machine
  data_path <- "G:/.shortcut-targets-by-id/1Lhjzr0rDBjblTPYh9PoVBsi_uupV9z8L/Phd_Project/data"
}

cli::cli_alert_info("The path for data is {.path {data_path}}")
if (basename(data_path) != "phd_data") {
  cli::cli_warn(c(
    "The data folder should now be the shared Nextcloud folder {.val phd_data}.",
    "i" = "Current path: {.path {data_path}}.",
    "i" = "Update {.file paths_and_packages.R} with the path of your local copy of {.val phd_data}."
  ))
}
if (!dir.exists(data_path)) {
  cli::cli_warn("The data folder {.path {data_path}} does not exist on this machine.")
}

# data type
raw_data_path <- here(data_path, "raw_data")
intermediate_data_path <- here(data_path, "intermediate_data")

# country
US_raw_data_path <- here(raw_data_path, "US")
US_intermediate_data_path <- here(intermediate_data_path, "US")

UK_raw_data_path <- here(raw_data_path, "UK")
UK_intermediate_data_path <- here(intermediate_data_path, "UK")

FR_raw_data_path <- here(raw_data_path, "FR")
FR_intermediate_data_path <- here(intermediate_data_path, "FR")

# database
US_txt_raw_data_path <- here(US_raw_data_path, "AEA_JEL", "txt")
US_txt_intermediate_data_path <- here(US_intermediate_data_path, "txt")

US_pq_raw_data_path <- here(US_raw_data_path, "proquest")

UK_ethos_raw_data_path <- here(UK_raw_data_path, "ethos")
UK_ethos_intermediate_data_path <- here(UK_intermediate_data_path, "ethos")

FR_thesefr_raw_data_path <- here(FR_raw_data_path, "these_fr")
FR_thesefr_intermediate_data_path <- here(FR_intermediate_data_path, "these_fr")

FR_sudoc_raw_data_path <- here(FR_raw_data_path, "sudoc")
FR_sudoc_intermediate_data_path <- here(FR_intermediate_data_path, "sudoc")

FR_cleaned_data_path <- here(data_path, "cleaned_data/FR")
