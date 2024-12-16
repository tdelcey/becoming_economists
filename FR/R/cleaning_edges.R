#################### Cleaning the data linking theses and entities ####################

#' Purpose: This script 


# Load packages and data--------------------------------------------------------
source(file.path("paths_and_packages.R"))
p_load(tidyfast)

thesis_metadata <- readRDS(here(FR_cleaned_data_path, "thesis_metadata.rds"))
thesis_person <- readRDS(here(FR_cleaned_data_path, "thesis_person.rds"))
thesis_institution <- readRDS(here(FR_cleaned_data_path, "thesis_institution.rds"))
thesis_edge <- readRDS(here(FR_intermediate_data_path, "thesis_edge.rds"))

# update institution edges (merge by old_id) 

new_ids <- thesis_institution[! is.na(old_id), .(new_id = entity_id, old_id = old_id)] %>% 
  dt_unnest(old_id, keep = FALSE)

new_ids[thesis_edge, on = .(V1 = entity_id),][, entity_id := fifelse(is.na(new_id), V1, new_id)]

institution_edges <- thesis_institution %>% 
  # unnest to prepare matching 
  unnest(old_id) %>% 
  # keep new update informaton 
  select(entity_id, old_id, entity_name) %>%
  mutate(old_id = ifelse(is.na(old_id), entity_id, old_id)) %>% 
  # left_join by equivalent_id
  left_join(thesis_edge %>% select(these_id, entity_id, entity_role),
            by = c("old_id" = "entity_id")) %>% 
  select(-old_id) %>% 
  unique

# update person edges (merge by entity_id since we did not remove any id from script cleaning the person table, except duplicate)

person_edges <- thesis_person %>% 
  # keep new update informaton 
  select(entity_id, entity_name, entity_firstname) %>%
  # left_join by equivalent_id
  left_join(thesis_edge %>% select(these_id, entity_id, entity_role),
            by = c("entity_id" = "entity_id")) %>% 
  unique




# creating the final edge table

thesis_edge <- bind_rows(institution_edges, person_edges) 


# save the final edge table

saveRDS(thesis_edge, here(FR_cleaned_data_path, "thesis_edge.rds"))