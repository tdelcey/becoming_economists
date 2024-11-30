# This script allows for launching various scripts of the project in the background
source(here::here("scripts", "paths_and_packages.R"))
source(here("scripts", "helper_scripts", "helper_functions.R"))
pacman::p_load(rstudioapi)

# Scraping of Sudoc-----------
# Define the discipline you want to scrape into the job
discipline <- get_discipline_to_scrape()

# Create a temporary environment containing only this object with the discipline
temp_env <- new.env()
temp_env$discipline <- discipline

jobRunScript(here::here("FR", "R", "scraping_sudoc_id.R"),
                         importEnv = temp_env,
                         exportEnv = "R_GlobalEnv")

jobRunScript(here::here("FR", "R", "scraping_sudoc_api.R"),
             importEnv = FALSE,
             exportEnv = "R_GlobalEnv")

# Scraping of Idref-----------
jobRunScript(here::here("FR", "R", "scraping_idref_person.R"),
             importEnv = FALSE,
             exportEnv = "R_GlobalEnv")

# Define the environment to store job output
jobRunScript(here::here("FR", "R", "scraping_idref_institution.R"),
             importEnv = FALSE,
             exportEnv = "R_GlobalEnv")
