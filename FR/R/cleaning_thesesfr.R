################### Cleaning and Processing Theses.fr Metadata #########################

# Load Data and Packages -----------------------------------------------------
# Load required packages and scripts for handling paths and functions
source(file.path("paths_and_packages.R"))

full_raw_theses <- read_rds(here(FR_raw_data_path, "theses.fr", "data_theses_fr.rds")) %>% 
  as.data.table()

full_raw_theses[auteur.nom %like% "Alayrac"] %>% View()
# Filtering economics-----------
#' Filter the dataset to include only theses related to economics.
#' This filtering is based on keywords like "econom" and "économ" found in the `discipline` column.
#' However, some unrelated disciplines may still match due to overlapping keywords (false positives).
raw_theses <- full_raw_theses[str_detect(discipline, regex("econom|économ", ignore_case = TRUE))] # filter econ thesis

#' Our simple filtering above means we have some false positives. We remove some fields that are not
#' economics:

field_to_delete <- c(
  "^technique(s)? et",
  "Droit des affaires et droit économique",
  "Droit et économie du tourisme",
  "Droit économique",
  "Droit international économique",
  "Droit de l'économie",
  "Droit public économique",
  "Cultures et économies de l'Europe centrale et de l'Est",
  "Droit public. Droit international économique",
  "Droit économique et social",
  "Démographie économique",
  "Géographie physique, humaine, économique et régionale",
  "Géographie humaine, économique et régionale",
  "Géographie humaine et économique") 
#' Do we need more filtering of discipline or are we satisfied with a few False Positive?

#' Remove entries matching the list of disciplines to be excluded.
raw_theses <- raw_theses[! str_detect(discipline, regex(paste0(field_to_delete, collapse = "|"), ignore_case = TRUE)),]

# Checking for identifier problems----------
#' Ensure that all theses have valid and unique identifiers (`nnt`).

# Check missing identifier:
if(raw_theses[nnt == "" | is.na(nnt),] %>% nrow() == 0) {
  cli_alert_success("No missing identifier,everything is ok!")
} else {
  cli_alert_danger("There are missing identifiers in the data!")
}

# Check for duplicated identifier
if (nrow(raw_theses[duplicated(nnt)]) > 0) {
  cli_alert_danger("There are duplicated identifiers in the data")
} else {
  cli_alert_success("No duplicated identifier in the data, everything is ok!")
  
}

## Small cleanings---------

#' Remove placeholder text for unknown thesis supervisors to improve data quality.
raw_theses <- raw_theses[directeurs_these.0.nom =="Directeur de thèse inconnu", directeurs_these.0.nom := NA_character_] 

#' Cleaning language columns:
#' When two langues are collapsed together in langues.0, like "enfr", we separate them
raw_theses[, `:=` (langues.1 = ifelse(str_count(langues.0) > 2, str_sub(langues.0, 3, 4), langues.1),
             langues.0 = ifelse(str_count(langues.0) > 2, str_sub(langues.0, 1, 2), langues.0))]

# Creating the different tables---------
#' Split the cleaned dataset into four structured tables:
#' - `thesesfr_metadata`: Core metadata about each thesis.
#' - `thesesfr_edge`: Links between theses and associated entities (individuals and institutions).
#' - `thesesfr_person`: Information about individuals involved in the theses.
#' - `thesesfr_institution`: Information about institutions linked to the theses.

## Thesis metadata table--------
#' Create a metadata table containing key information about each thesis.

thesesfr_metadata <- raw_theses[, .(these_id = nnt,
                                    year_defence = date_soutenance,
                                    language = langues.0,
                                    language_2 = langues.1,
                                    title_fr = titres.fr,
                                    title_en = titres.en,
                                    title_other = titres.autre.0,
                                    abstract_fr = resumes.fr,
                                    abstract_en = resumes.en,
                                    abstract_other = resumes.autre.0,
                                    field = discipline,
                                    accessible = accessible)]

#' Add additional fields for consistency with other datasets (e.g., SUDOC).
thesesfr_metadata[, `:=` (type = "Thèse", 
                          country = "France", # Default country
                          url = paste0("https://theses.fr/", these_id))] # creating the url to connect directly to theses.fr

# Save the metadata table
saveRDS(thesesfr_metadata, here(FR_thesefr_intermediate_data_path, "thesesfr_metadata.RDS"))

## Creating Edge Table--------
#' Create an edge table to capture relationships between theses and associated entities (individuals and institutions).
 
# Select relevant columns for relationships
col_to_long <- colnames(raw_theses)[str_detect(colnames(raw_theses), "^auteur|^membres_|^directeurs_|^rapporteurs|^president|^etablissements|^ecoles_|^partenaires_")]
filtered_columns <- raw_theses[, .SD, .SDcols = c("nnt", col_to_long)]

# Reshape data into a long format for processing relationships
edge_table_temp <- melt(filtered_columns, id.vars = "nnt", variable.name = "variable", value.name = "value") %>% 
  as.data.table()
edge_table_temp <- edge_table_temp[value != "", ]
edge_table_temp[, variable := str_replace(variable, "president_jury", "president_jury.0")] # we need this to have a similar format for jury president than for other roles
edge_table_temp[, variable := str_replace(variable, "auteur", "auteur.0")] # we need this to have a similar format for jury president than for other roles

# Split variable names into distinct columns
edge_table_temp[, c("role", "order", "info") := tstrsplit(variable, ".", fixed = TRUE)][, variable := NULL]
edge_table_temp <- data.table::dcast(edge_table_temp, nnt + role + order ~ info, value.var = "value")
edge_table_temp <- edge_table_temp[, `:=` (order = NULL,
                                           type = NULL)]
edges_table_temp <- edge_table_temp[!(is.na(nom) & is.na(idref))] # in case we have elements with no information at all

# Generate temporary IDs for entities lacking official identifiers (we will try disambuigating them later)
edge_table_temp[is.na(idref) & str_detect(role, "auteur|membres|directeurs|rapporteurs|president"), 
                idref := paste0("temp_thesefr_person_", 100000:(100000+.N-1))]
edge_table_temp[is.na(idref) & str_detect(role, "etablissements|ecoles|partenaires"), 
                idref := paste0("temp_thesefr_institution_", 100000:(100000+.N-1))]

# Rename columns for consistency and save the edge table
setnames(edge_table_temp, 
         c("nnt", "role", "idref", "nom", "prenom"), 
         c("these_id", "entity_role", "entity_id", "entity_name", "entity_firstname"))

# Rename role for consistency
edge_table_temp[, entity_role := str_replace(entity_role, "auteur", "author")]
edge_table_temp[, entity_role := str_replace(entity_role, "directeurs_these", "supervisor")]
edge_table_temp[, entity_role := str_replace(entity_role, "rapporteurs", "reviewer")]
edge_table_temp[, entity_role := str_replace(entity_role, "membres_jury", "member")]
edge_table_temp[, entity_role := str_replace(entity_role, "president_jury", "president")]
edge_table_temp[, entity_role := str_replace(entity_role, "etablissements_soutenance", "institution_defense")]
edge_table_temp[, entity_role := str_replace(entity_role, "ecoles_doctorale", "doctoral_school")]
edge_table_temp[, entity_role := str_replace(entity_role, "partenaires_recherche", "research_partner")]

# We add a source file necessary to clean doublons later
edge_table_temp[, source := "thesesfr"]

saveRDS(edge_table_temp, here(FR_thesefr_intermediate_data_path, "thesesfr_edge.RDS"))

## Creating Person Table-----------
thesesfr_person <- edge_table_temp[str_detect(entity_role, "author|member|supervisor|reviewer|president")]
thesesfr_person <- thesesfr_person[, `:=` (these_id = NULL, entity_role = NULL)] %>%
  unique()
saveRDS(thesesfr_person, here(FR_thesefr_intermediate_data_path, "thesesfr_person.rds"))

## Creating Institution Table-----------
thesesfr_institution <- edge_table_temp[str_detect(entity_role, "institution|school|partner|laboratory")]
thesesfr_institution <- thesesfr_institution[, `:=` (these_id = NULL, entity_role = NULL, entity_firstname = NULL)] %>%
  unique()
saveRDS(thesesfr_institution, here(FR_thesefr_intermediate_data_path, "thesesfr_institution.rds"))
