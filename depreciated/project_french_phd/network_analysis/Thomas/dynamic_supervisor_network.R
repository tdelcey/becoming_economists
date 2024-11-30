source(here::here("0_paths_and_packages.R"))

thesis_table <- readRDS(here(FR_cleaned_data_path, "all_thesis_table.rds"))
people_table <- readRDS(here(FR_cleaned_data_path, "people_table.rds"))


### preparing data: creating edges and nodes ###

