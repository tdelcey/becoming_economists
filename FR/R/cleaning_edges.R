#################### Cleaning the Data Linking Theses and Entities ####################

#' Purpose: 
#' This script cleans and standardizes edges (relationships) between theses, 
#' institutions, and individuals. It utilizes data from `idref` for standardizing 
#' institution and individual names and ensures removal of duplicates. It uses the
#' data cleaned in `cleaning_institutions.R` and `cleaning_individuals.R`.
#' 
#' Outputs:
#' 1. A complete data frame of edges with originally scraped information for validation.
#' 2. A short, cleaned, and usable data frame of edges for analysis.

# Load packages and data--------------------------------------------------------
source(file.path("paths_and_packages.R"))
p_load(tidyfast)

thesis_individual <- readRDS(here(FR_cleaned_data_path, "thesis_individual.rds"))
thesis_institution <- readRDS(here(FR_cleaned_data_path, "thesis_institution.rds"))
thesis_edge <- readRDS(here(FR_intermediate_data_path, "thesis_edge.rds"))

# Cleaning edges for institutions----------------------------------------------

# 1. Collect new IDs for institutions from previous cleaning steps.
#    These are updated IDs obtained from the "cleaning_institutions.R" script.
new_ids <- thesis_institution[! is.na(old_id), .(new_id = entity_id, old_id = old_id)] %>% 
  dt_unnest(old_id, keep = FALSE) %>% # Unnest rows where an institution has multiple old IDs
  .[, .(new_id, old_id = V1)] %>% 
  unique()

# 2. Match old IDs to entity IDs in thesis_edge and replace with new IDs.
institution_filter <- c("institution_defense",
                        "research_partner",
                        "doctoral_schools",
                        "institution_defence",
                        "institution_defence_from_info",
                        "laboratory")  # Filter for relevant institution roles
institutions_edge <- merge.data.table(thesis_edge[entity_role %in% institution_filter], 
                 new_ids,
                 by.x = "entity_id",
                 by.y = "old_id",
                 all.x = TRUE) 
# Replace old IDs with new IDs wherever available
institutions_edge[, original_id := entity_id]  # Retain old ID for reference
institutions_edge[, entity_id := fifelse(is.na(new_id), entity_id, new_id)]
institutions_edge <- institutions_edge[, new_id := NULL]

# 3. Add preferred names for institutions from `thesis_institution` table.
#    Save original names for post-processing checks.
setnames(institutions_edge, "entity_name", "original_entity_name")
institutions_edge <- merge.data.table(institutions_edge, 
                                thesis_institution[, .(entity_id, entity_name)], 
                                by = "entity_id", 
                                all.x = TRUE)

# 4. Remove duplicates institutions when in similar roles
# We search for duplicates in "institutions_defence", "institution_defence_from_info" and "research_partner". 
# If we have the same information twice or more for these three entity roles, we keep the first one in "institutions_defence".
setorder(institutions_edge, thesis_id, entity_role, entity_id)
institutions_edge <- institutions_edge[! duplicated(institutions_edge[, .(thesis_id, entity_id)]),]

# Cleaning Edges for individuals--------------------------------
# update individual edges (merge by entity_id since we did not remove any id from script cleaning the individual table, except duplicates)
individuals_edge <- thesis_edge[! entity_role %in% institution_filter]
setnames(individuals_edge, c("entity_name", "entity_firstname"), c("original_entity_name", "original_entity_firstname"))

# Add preferred names for individuals from `thesis_individual` table
individuals_edge <- merge.data.table(individuals_edge, 
                                 thesis_individual[, .(entity_id, entity_name, entity_firstname)], 
                                 by = "entity_id", 
                                 all.x = TRUE)

# Saving the final edge tables--------------------------------
# Combine cleaned edges for institutions and individuals
thesis_edge <- bind_rows(institutions_edge, individuals_edge) 
setorder(thesis_edge, thesis_id, entity_role, entity_id)

# Save the complete edge table with all original information for validation
saveRDS(thesis_edge[, .(thesis_id, entity_id, original_id, entity_role, entity_name, entity_firstname, original_entity_name, original_entity_firstname, source)], 
        here(FR_cleaned_data_path, "thesis_edge_complete_data.rds"))


# Removing duplicates
# First we remove what are very certain duplicates with similar entity name and id
thesis_edge_filtered <- thesis_edge[, .(thesis_id, entity_id, entity_role, entity_name, entity_firstname)] %>% 
  unique() 

# Then, we need to do some manual cleaning to separate true duplicates from false ones
thesis_edge_filtered[thesis_id == "1985REN1G001" & entity_role == "author", entity_firstname := first(entity_firstname)]
thesis_edge_filtered[thesis_id == "1987AIX32018" & entity_role == "supervisor", entity_firstname := first(entity_firstname)]
thesis_edge_filtered[entity_name == "Centi" & entity_role == "supervisor", entity_firstname := first(entity_firstname)]

# Now we can remove duplicates with same name and first names
thesis_edge_filtered <- thesis_edge_filtered[!duplicated(thesis_edge_filtered[, .(thesis_id, entity_role, entity_name, entity_firstname)])]

# This is the short usable version, with no duplicates
saveRDS(thesis_edge_filtered,
        here(FR_cleaned_data_path, "thesis_edge.rds"))
