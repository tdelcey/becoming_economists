####################### Download and Save theses.fr data #######################

#' Purpose: This script downloads the CSV file of all the defended theses stored on
#' [data.gouv.fr](https://www.data.gouv.fr/fr/datasets/theses-soutenues-en-france-depuis-1985/#/resources). 
#' We save the data as an RDS file in the specified directory. This approach optimizes file storage
# and facilitates faster loading in R.

# Load required packages ------------------------------------------------------
# `here` is used to handle file paths, and `readr` for CSV reading.
pacman::p_load(here,
               readr)

# Define the download URL and file paths --------------------------------------
download_url <- "https://www.data.gouv.fr/fr/datasets/r/eb06a4f5-a9f1-4775-8226-33425c933272"
output_path <- here(FR_raw_data_path, "theses.fr", "data_theses_fr.rds")

# Download and read the CSV ---------------------------------------------------
# Read the CSV directly from the URL, without saving it locally
these_data <- read_csv(download_url)

# Save the data as an RDS file ------------------------------------------------
# This step saves the data frame in RDS format, which is more space-efficient
# and can be loaded faster in future R sessions.
write_rds(these_data, file = output_path, compress = "gz", compression = 9L)
