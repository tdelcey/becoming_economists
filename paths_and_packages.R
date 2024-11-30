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

#### PATH ####

#original text path stored in google drive 
if(str_detect(getwd(), "tunex")){
  data_path <- "G:/Mon Drive/Phd_Project/data"
} else {
  if(str_detect(getwd(), "Admin")) {
    data_path <- "G:/.shortcut-targets-by-id/1Lhjzr0rDBjblTPYh9PoVBsi_uupV9z8L/Phd_Project/data"
  } else {
  if(str_detect(getwd(), "thomd")) {
    data_path <- "G:/.shortcut-targets-by-id/1Lhjzr0rDBjblTPYh9PoVBsi_uupV9z8L/Phd_Project/data"
    } else {
      data_path <- "G:/.shortcut-targets-by-id/1Lhjzr0rDBjblTPYh9PoVBsi_uupV9z8L/Phd_Project/data"
    }}
    print(paste("The path for data is", data_path))
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

# Why saving this in the data file?? It should be in the project repo no?
# figures_path <- here(data_path, "figures")


