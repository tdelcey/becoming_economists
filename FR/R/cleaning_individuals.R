#################### Cleaning the data on individuals ####################

#' Purpose: This script clean the data on individuals by using the data extracted
#' from idref.fr. It serves notably to standardized the first name and name for 
#' each idref. 
#' We then find homonyms or possible duplicates and list them in an additional columns.
#' Finally, we use the INSEE data on first names to attribute missing genders.


# Load packages and data--------------------------------------------------------
source(file.path("paths_and_packages.R"))

# Load data on individuals
idref_individual_table <- readRDS(here(FR_raw_data_path, "idref", "idref_persons.rds")) %>% 
  as.data.table

setkey(idref_individual_table, idref)
thesis_individual <- readRDS(here(FR_intermediate_data_path, "thesis_individual.rds"))
setkey(thesis_individual, entity_id)

# Clean and Join with idref Data ---------------------------------------------------------

# Process idref_individual_table
idref_individual_table[, birth := str_extract(birth, ".{4}")] # Extract only the year from birth

# Managing the different elements in the information column
idref_individual_table[, info := map_chr(info, function(x) {
  if (length(x) == 0) {
    NA_character_
  } else if (length(x) == 1) {
    x
  } else {
    paste(x, collapse = "\n")
  }
})]

# paste into one value info if multiple values
idref_individual_table[, `:=` (date_scrap = NULL)]  # Remove intermediate columns no longer needed

# Process thesis_individual with a left join of idref_individual
thesis_individual <- merge(
  thesis_individual,            
  idref_individual_table,      
  by.x = "entity_id",       
  by.y = "idref",           
  all.x = TRUE              
)

# Update `entity_name` and `entity_firstname` based on available `first_name` and `last_name` in idref
thesis_individual[,`:=`(entity_name = fifelse(is.na(last_name), entity_name, last_name),
                    entity_firstname = fifelse(is.na(first_name), entity_firstname, first_name))]

# Drop unneeded columns
thesis_individual[, c("first_name", "last_name") := NULL]

# Remove duplicate lines with same idref while keeping all other columns
thesis_individual <- thesis_individual[!duplicated(thesis_individual, by = c("entity_id", "entity_firstname", "entity_name"))]

# Find Homonyms or Possible Duplicates ----------------------------------------

# Normalize strings to identify potential homonyms
thesis_individual[, authors := paste(entity_firstname, entity_name), by = entity_id]
thesis_individual[, authors := stri_trans_tolower(authors)]
thesis_individual[, authors := stri_replace_all_regex(authors, "[:punct:]", " ")]
thesis_individual[, authors := stri_trans_general(authors, id = "Latin-ASCII")]
thesis_individual[, authors := str_squish(authors)]
thesis_individual[, authors := stri_trim(authors)]

# Step 1: Create a grouping variable (`new_id`) to identify homonyms
thesis_individual[, new_id := entity_id[1], by = authors] 

# Initialize `homonym_of` column as a list
thesis_individual[, homonym_of := vector("list", .N)]  # Initialize as a list column

# Step 2: Populate `homonym_of` with lists of `entity_id` for groups with more than one row
thesis_individual[, homonym_of := fifelse(.N > 1, list(list(entity_id)), list(NA)), by = new_id] # the first list wrap the entity_id in a list, the second list wrap all the entity_id together

# Step 3: # Remove the current `entity_id` from the list of homonyms
# thesis_individual[! is.na(homonym_of), homonym_of := map2(homonym_of, entity_id, ~ unlist(.x) %>% setdiff(.y))] 
thesis_individual[, `:=` (authors = NULL, new_id = NULL)]

# Attribute Missing Gender-----------------------

# Load INSEE census data
insee_census_data <- fread(file.path(raw_data_path, "insee_prénoms_2023.csv"), sep = ";")

# Rename columns for clarity
setnames(insee_census_data, c("preusuel", "sexe", "annais", "nombre"), 
         c("firstname", "sexe", "year", "count"))

# Calculate gender frequencies by name
insee_census_data[, n_total := sum(count), by = firstname] 
insee_census_data[, n_sexe := sum(count), by = .(sexe, firstname)] 
gender_frequency <- insee_census_data[!is.na(firstname) & str_count(firstname) > 1, .(sexe, firstname, n_sexe, n_total)] %>% 
  unique()
gender_frequency[, percentage := n_sexe / n_total] 

# Filter by most probable gender (high threshold to avoid ambiguity)
gender_frequency <- gender_frequency[percentage > 0.95, .(firstname, gender_expanded = sexe)] 
gender_frequency[, gender_expanded := fifelse(gender_expanded == 1, "male", "female")]

# Match names from `thesis_individual` with `gender_frequency`
thesis_individual[is.na(gender), name_match := str_to_upper(entity_firstname)] # Uppercase to harmonize with INSEE data
thesis_individual[, name_match := str_replace_all(name_match, "[:punct:]", " ")] 
thesis_individual[, name_match := str_remove(name_match, "^[A-Z](\\.)?\\s|\\sd(e|')?$")] # Remove initials or remove particule at the end
thesis_individual[, name_match := str_extract(name_match, "^[^ ]+")] # Extract first first name
thesis_individual[, name_match := str_squish(name_match)]

# Merge `gender_frequency` with `thesis_individual`
thesis_individual <- merge(
  thesis_individual, # Table principale
  gender_frequency,           # Table de droite
  by.x = "name_match",        # Clé de la table de gauche
  by.y = "firstname",         # Clé de la table de droite
  all.x = TRUE)

# Update `gender_expanded` for rows where `gender` is missing
thesis_individual[, gender_expanded := fifelse(is.na(gender_expanded), gender, gender_expanded)]

# Last cleaning steps ---------------------------------------------------------
# Standardizing the names and first names
thesis_individual[, entity_name := str_to_title(entity_name)]
thesis_individual[, entity_firstname := str_to_title(entity_firstname)]

# Save the Cleaned Data -------------------------------------------------------
thesis_individual <- thesis_individual[, .(entity_id, entity_name, entity_firstname, gender, gender_expanded,
                                   birth, country_name, information = info, organization, last_date_org, start_date_org, 
                                   end_date_org, other_link, homonym_of)]

saveRDS(thesis_individual, here(FR_cleaned_data_path, "thesis_individual.rds"))
