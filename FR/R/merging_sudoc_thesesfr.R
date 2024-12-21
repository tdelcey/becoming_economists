############### Merging the SUDOC and Theses.fr databases ################

#' Purpose: This script merges Ph.D. data classified as economics from the SUDOC and Theses.fr databases 
#' into unified tables: metadata, edge, person, and institution.

# Load Data and Packages -----------------------------------------------------
# Load required packages and scripts for handling paths and functions
source(file.path("paths_and_packages.R"))

# Load metadata from SUDOC and Theses.fr -------------------------------------
sudoc_metadata <- readRDS(here(FR_sudoc_intermediate_data_path, "sudoc_metadata.rds")) 

thesesfr_metadata <- readRDS(here(FR_thesefr_intermediate_data_path, "thesesfr_metadata.rds")) %>% 
  as_tibble %>% 
  mutate(year_defence = ymd(year_defence) %>% year())

# Combine and deduplicate metadata
thesis_metadata <- bind_rows(thesesfr_metadata, sudoc_metadata) %>% 
  distinct(thesis_id, .keep_all = TRUE)

# Merge Edge Data ------------------------------------------------------------
# Load edge tables from SUDOC and Theses.fr
sudoc_edge <- readRDS(here(FR_sudoc_intermediate_data_path, "sudoc_edge.rds")) %>% 
  as.data.table()
thesesfr_edge <- readRDS(here(FR_thesefr_intermediate_data_path, "thesesfr_edge.rds"))

# Combine, filter, and clean edge data
thesis_edge <- bind_rows(thesesfr_edge, sudoc_edge) %>% 
  unique

# Merge Person Data ----------------------------------------------------------
# Load person tables from SUDOC and Theses.fr
sudoc_person <- readRDS(here(FR_sudoc_intermediate_data_path, "sudoc_person.rds"))
thesesfr_person <- readRDS(here(FR_thesefr_intermediate_data_path, "thesesfr_person.rds"))
thesis_person <- bind_rows(thesesfr_person, sudoc_person) %>% 
  unique

# Merge Institution Data -----------------------------------------------------
# Load institution tables from SUDOC and Theses.fr
sudoc_institution <- readRDS(here(FR_sudoc_intermediate_data_path, "sudoc_institution.rds"))
thesesfr_institution <- readRDS(here(FR_thesefr_intermediate_data_path, "thesesfr_institution.rds"))

thesis_institution <- bind_rows(thesesfr_institution, sudoc_institution) %>% 
  unique
  
# Saving Everything-----------------
saveRDS(thesis_metadata, here(FR_intermediate_data_path, "thesis_metadata.rds"))
saveRDS(thesis_edge, here(FR_intermediate_data_path, "thesis_edge.rds"))
saveRDS(thesis_person, here(FR_intermediate_data_path, "thesis_person.rds"))
saveRDS(thesis_institution, here(FR_intermediate_data_path, "thesis_institution.rds"))
