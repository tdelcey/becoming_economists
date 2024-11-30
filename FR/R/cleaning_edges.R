# Load packages and data-----

source(file.path("paths_and_packages.R"))

thesis_metadata <- readRDS(here(FR_cleaned_data_path, "thesis_metadata.rds")) %>% as_tibble()
thesis_person <- readRDS(here(FR_cleaned_data_path, "thesis_person.rds")) %>% as_tibble()
thesis_institution <- readRDS(here(FR_cleaned_data_path, "thesis_institution.rds")) %>% as_tibble()
thesis_edge <- readRDS(here(FR_intermediate_data_path, "thesis_edge.rds")) %>% as_tibble()


# update institution edges (merge by old_id) 

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