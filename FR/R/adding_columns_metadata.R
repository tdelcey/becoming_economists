#################### Adding Columns to Metadata ####################

#' Purpose: 
#' Now that with have a clean `thesis_edge`, we will integrate some additional
#' columns to `thesis_metadata` to have the author, supervisor and institution
#' of the thesis.
#' 

# Loading Packages and Data-----------------
source(file.path("paths_and_packages.R"))

thesis_metadata <- readRDS(here(FR_cleaned_data_path, "thesis_metadata.rds"))
thesis_edge <- readRDS(here(FR_cleaned_data_path, "thesis_edge.rds"))

# Extracting authors and institutions of defence----------------
authors <- thesis_edge[entity_role == "author", .(thesis_id, entity_name, entity_firstname, author_id = entity_id)]
authors <- authors[, author := str_c(entity_firstname, ", ", entity_name)][, .(thesis_id, author, author_id)]

# Check that there is only one author per these_id
stopifnot(all(authors[, .N, by = thesis_id]$N == 1))

institutions <- thesis_edge[entity_role %in% c("institution_defence", "institution_defence_from_info"), .(thesis_id, institution_thesis_name = entity_name, institution_thesis_id = entity_id)]
# Keep only the first institution for each thesis_id
institutions <- institutions[, .(institution_thesis_name = institution_thesis_name[1], institution_thesis_id = institution_thesis_id[1]), by = thesis_id]

# Merging with Metadata---------------
thesis_metadata <- merge(thesis_metadata, authors, by = "thesis_id", all.x = TRUE)
thesis_metadata <- merge(thesis_metadata, institutions, by = "thesis_id", all.x = TRUE)

# saving data 
saveRDS(thesis_metadata[, .(thesis_id, year_defence, author, author_id, title_fr, title_en, title_other, abstract_fr, abstract_en, abstract_other, language, language_2, institution_thesis_name, institution_thesis_id, country, field, type, accessible, url, duplicates)], 
        here(FR_cleaned_data_path, "thesis_metadata.rds"))
