##' ---
#' title: "Script for compressing the oringinal UK thesis database"
#' author: "Aurélien Goutsmedt and Thomas Delcey"
#' date: "/ Last compiled on `r format(Sys.Date())`"
#' output: 
#'   github_document:
#'     toc: true
#'     number_sections: true
#' ---
#' 
#' # What is this script for?
#' 
#' In this script, we juste import the original CSV with proper encoding and compress
#' it using `arrow` package and `brotli` compressing method 
#' 
#+ r setup, include = FALSE
knitr::opts_chunk$set(eval = FALSE)

#' # Compressing

source("cleaning_data/0_paths_and_packages.R")

db_uk <- read_csv(here(UK_ethos_raw_data_path, "EThOS_CSV_202109.csv")) %>%
  clean_names() %>% 
  rename("supervisor" = supervisor_s,
         "funder" = funder_s,
         "ethos_url" = e_th_os_url)
write_parquet(db_uk, here(UK_ethos_raw_data_path, "EThOS_brotli_202109"), compression = "brotli")
