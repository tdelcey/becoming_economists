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
#' The original CSV with the data has been compressed in [UK_ethos_1_compressing.R](/script/UK_ethos_1_compressing.R).
#' In this script we clean problematic data and identify economics dissertation.
#' 
#' Strategy: could be better to clean what we have to clean after extracting economics thesis via
#' the "Social, Economic & Political Studie" category.
#' 
#' We have to clean:
#' 
#' - Standardisation of the `qualification` column.
#' 
#+ r setup, include = FALSE
knitr::opts_chunk$set(eval = FALSE)

#' # Package and data

source("cleaning_data/0_paths_and_packages.R")

#' The original CSV with the data has been compressed in [UK_ethos_1_compressing.R]

db_uk <- read_parquet(here(UK_ethos_raw_data_path, "EThOS_brotli_202109")) %>% 
  as.data.table

#' # Cleaning of remaining encoding problem 

### classification 

uk_disciplines <- lazy_dt(db_uk) %>% 
  count(subject_discipline) %>% 
  as.data.table

#filter economics dissertation
db_uk_sample <- db_uk %>%
  dplyr::filter(str_detect(subject_discipline, "Social, Economic & Political Studies")) %>%
  as.data.table

# check qualification
select(db_uk, qualification) %>% unique() %>% View()

