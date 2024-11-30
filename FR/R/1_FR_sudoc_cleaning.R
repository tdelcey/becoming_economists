################### Cleaning and Processing Sudoc Metadata #########################

# Load Data and Packages -----------------------------------------------------
# Load required packages and scripts for handling paths and functions
source(file.path("paths_and_packages.R"))

# Load the data saved in scraping_scripts/FR/scraping_sudoc_api.R.
data <- readRDS(here(FR_sudoc_raw_data_path, "sudoc_metadata.RDS"))

# Managing Duplicated Data --------------------------------------------------
# Two types of duplicates are addressed:
# 1. True duplicates: Same `nnt` (National Thesis Number) and author. This occurs when the same thesis 
#    is listed multiple times with different defense dates. Keep the most recent entry.
# 2. False duplicates: Same `nnt` but different authors. This may happen due to errors or shared identifiers.
#    Assign unique `nnt` values to differentiate these cases.

# Case 1: True duplicates
true_duplicates <- data %>% 
  unnest(nnt) %>% 
  get_dupes(nnt, author_idref) %>% 
  slice(2, .by = nnt) # Select the second occurrence to remove the duplicate

# Case 2: False duplicates
false_duplicates <- data %>% 
  unnest(nnt) %>% 
  get_dupes(nnt) %>% 
  select(-dupe_count) %>% # remove the column secretly created by get_dupes()
  group_by(author_idref) %>%
  filter(n() == 1) %>% # ensure that the author is not the same, and so that it is a false duplicate
  group_by(nnt) %>% 
  mutate(nnt = paste0(nnt, "_", row_number()),
         nnt = as.list(nnt)) %>% 
  ungroup()

# merging the two types of duplicates
url_to_remove <- c(true_duplicates %>% pull(url), 
                   false_duplicates %>% pull(url))

data <- data %>% 
  filter(!url %in% url_to_remove) %>% # we remove all the duplicates via the url
  bind_rows(false_duplicates) # we add back the false duplicates which now have a different nnt

# Cleaning File------------------------

## Unnesting columns when possible

# Unnest columns with single or zero elements per row for easier processing
col_to_unnest <- map(data, ~ map_lgl(., ~length(.) < 2)) %>% 
  map_lgl(., ~all(.)) %>% 
  .[. == TRUE] %>% 
  names()

data <- data %>%
  unnest(cols = all_of(col_to_unnest), keep_empty = TRUE) %>% 
  mutate(across(where(is.character), ~ map_chr(., ~ifelse(. == "", NA_character_, .)))) 

## Cleaning dates----------- 

# Extract and clean soutenance (defense) dates:
# - Extract year from `year_defence` or fallback to `other_type_info`.
# - Handle multiple dates for a thesis by keeping the oldest (assumed defense date).
# - Flag dates outside the query range (1899–1985) for manual review.

date_clean <- data %>% 
  select(url, year_defence, other_type_info) %>% 
  unnest(year_defence) %>% 
  mutate(year_defence = str_extract(year_defence, "\\d{4}") %>% as.integer(), # we make sure to extract only the year
         year_defence = ifelse(is.na(year_defence), str_extract(other_type_info, "\\d{4}") %>% as.integer(), year_defence)) %>% # we use another column when information is missing
  filter(! is.na(year_defence)) %>% 
  mutate(date_gap = max(year_defence) - min(year_defence),
         year_defence = ifelse(min(year_defence) %in% 1899:1985, min(year_defence), max(year_defence)), .by = url) %>% # A very complex line to replace a wrong 1822 by a right 1922 (and take the minimum in other cases)
  unique() %>% 
  select(-other_type_info)

# Alert about missing or problematic dates
cli_alert(glue("{nrow(data) - nrow(date_clean)} theses on {nrow(data)} have no information about the date of defense"))
# Check if dates only in the interval:
all_dates <- date_clean %>% 
  pull(year_defence) %>% 
  unique() %>% 
  sort()
if(any(! all_dates %in% 1899:1985)){ # 1899 is ok
  problematic_dates <- all_dates[which(! all_dates %in% 1899:1985)]
  cli_alert_warning(glue("One or several dates are outside of the time period used in SUDOC query: {str_flatten_comma(problematic_dates)}. To check!!"))
  
  date_clean %>% 
    filter(year_defence %in% problematic_dates) %>% 
    pull(url)
} 

#' This is used to understand large gaps in the different dates of defense. 
#' In most cases, we can confidently say that this is linked to the (very) posterior publication of the thesis in SUDOC and
#' to some mistakes in the record. Hence, taking the minimum date is a good strategy.
if(date_clean %>% pull(date_gap) %>% unique() %>% {any(. > 3)}){
  cli_alert_danger("Some dates for a thesis have a gap superior to 3 years")
  date_clean %>% 
    filter(date_gap > 3) %>% 
    arrange(desc(date_gap))
}

# Join cleaned dates back to the main dataset
data <- data %>% 
  select(-year_defence) %>%
  left_join(date_clean, by = "url")

## Standardizing Types and Fields-----------------

#' We have information about the type of thesis that we will standardized and recode as follow:
#' - Thèses d'Etat
#' - Thèse de 3e cycle
#' - Thèse complémentaire
#' - Thèse de docteur-ingénieur
#' - Thèse sur travaux
#' - Thèse (when more information is missing)
data <- data %>% 
  mutate(type = map(type, unique),
         field = map(field, unique)) # remove duplicates in type and field

#' How do we process for recoding?
#' - First, we check in the type column that, when we have multiple elements for a thesis, that's a doublon and
#' so we don't need to select one type
#' - Second, we fill missing type info by the content of the other_type_info column (see scraping_sudoc_api.R for more info
#' on this column).
#' - Third, we exclude from our data what's not Phd thesis (for instance, Master dissertation), linked to some 
#' problems in SUDOC data classification (in our case, around 50 cases) 
#' - Fourth, we standardize the tye of the thesis in six different categories (see above)
#' - Fifth, for the more general category "Thèse", we check in other_type_info column if we don't have 
#' other information allowing to change the category.
#' 

# Check if type can be unnest and clean thesis type
if(data %>% pull(type) %>% map_int(length) %>% { any(. > 1L)}){
  cli_alert_danger("Several types per row. We need to choose a type!")
  data %>% 
    mutate(length_type = map_int(type, length)) %>% 
    filter(length_type > 1) 
  } else {
    cli_alert_success("Only one type per row. Everything is ok!")
  }

data <- data %>% 
  mutate(type = map(type, ~ .[1]), # We select the first type when we have different ones
         other_type_info = map(other_type_info, ~ .[1])) %>% # no need here as other_type_info"is not a list anymore, but just in case
  unnest(c(type, other_type_info), keep_empty = TRUE) %>% 
  mutate(type = str_trim(type, "both")) %>% 
  mutate(type = ifelse(is.na(type), other_type_info, type)) %>% # in all the cases here, when nothing in type, the info is in other_type_info
  filter(!str_detect(type, "APT|M(é|e)m(oire|\\.)|Ma(i|î)trise|Magister|D(\\.)?E(\\.)?(A|S)|Diplôme|DIPLOME SUPERIEUR|^h\\.|Habilita(t)?ion|U.E.R. 02|\\?$")) %>% # FILTER LINES THAT ARE NOT THESIS BASED ON TYPE INFO 
  mutate(type = case_when(
    str_detect(type, regex("(é|e)(t)?at", ignore_case = TRUE)) ~ "Thèse d'État",
    str_detect(type, "cycle|3|spécialité") ~ "Thèse de 3e cycle",
    str_detect(type, regex("compl", ignore_case = TRUE)) ~ "Thèse complémentaire",
    str_detect(type, regex("ingénieur|ing\\.", ignore_case = TRUE)) ~ "Thèse de docteur-ingénieur",
    str_detect(type, regex("travaux", ignore_case = TRUE)) ~ "Thèse sur travaux",
    TRUE ~ "Thèse"))

# Testing for the existence of a different info in other_type_info column
different_info <- data %>% 
  filter(type == "Thèse" & !is.na(other_type_info)) %>% 
  select(other_type_info) %>% 
  mutate(other_type_info = case_when(
    str_detect(other_type_info, regex("(é|e)(t)?at", ignore_case = TRUE)) ~ "Thèse d'État",
    str_detect(other_type_info, "cycle|3|spécialité") ~ "Thèse de 3e cycle",
    str_detect(other_type_info, regex("compl", ignore_case = TRUE)) ~ "Thèse complémentaire",
    str_detect(other_type_info, regex("ingénieur|ing\\.", ignore_case = TRUE)) ~ "Thèse de docteur-ingénieur",
    str_detect(other_type_info, regex("travaux", ignore_case = TRUE)) ~ "Thèse sur travaux",
    TRUE ~ "Thèse")) %>% 
  filter(other_type_info != "Thèse")
if(nrow(different_info) > 1) {
  cli_alert_danger(glue("{nrow(different_info)} theses have a different information between type and other_type_info columns"))
} else {
  cli_alert_success(glue("{nrow(different_info)} theses have a different information between type and other_type_info columns.
                        Everything is ok!"))
}

#' Regarding fields, we will test the possibility of two different fields for a thesis
#' (we have deleted doublons above). If it's the case, we will need to check the code.
if(data %>% pull(field) %>% map_int(length) %>% { all(. < 2L)}){
  cli_alert_success("Only one field per row. Everything is ok!")
  data <- data %>% 
    unnest(field) %>% 
    mutate(field = str_trim(field, "both"))
} else {
  cli_alert_danger("Several fields per row. We need to check the code!")
}

## Standardizing languages----------------

#' We first check for the possibility of two different languages for the same thesis. Then we recode 
#' language values to standardize them with those extracted in theses.fr.
if(data %>% pull(language) %>% map_int(length) %>% { any(. > 1L)}){
  cli_alert_danger("Several languages per row. We need to check the code and concatenate them.")
  data %>% 
    mutate(length_language = map_int(language, length)) %>%
    filter(length_language > 1) %>% 
    select(url, language)
} else {
  cli_alert_success("Only one language per row. Everything is ok!")
}

data <- data %>% 
  mutate(language = map_chr(language, ~str_flatten(., collapse = "_"))) %>% # flattening (and unlisting) for those with multiple languages (only one here)
  mutate(across(c(language, language_2), ~ str_replace_all(., c(
    "fre" = "fr",
    "eng" = "en",
    "und" = NA_character_,
    "ger" = "de",
    "spa" = "es")))) %>% 
  # managing the unique case of two languages in the same column: we separate, and then fill the second language column
  separate(language, into = c("lang1", "lang2"), sep = "_", fill = "right") %>% 
  mutate(language = lang1) %>%
  mutate(language_2 = if_else(is.na(language_2) & !is.na(lang2), lang2, language_2)) %>%
  # Drop intermediate columns
  select(-lang1, -lang2)

#'Check language count:
#' `data %>% count(language)`
#' 

## Removing missing information------------
#' Remove missing information like "Directeur de thèse inconnus"
#' We do it before cleaning people, as it allows to adjust problem of scraping and 
#' realigned idref and nom

data <- data %>% 
  mutate(supervisor_name = map(supervisor_name, ~.[! .  %in% c("Directeur de thèse inconnu", "# NON PRECISE", "Directeur inconnu")]))

# Create and Save Final Outputs --------------------------------------------
#' We will save the data in four different files:
#' - sudoc_metadata: the metadata of the theses
#' - sudoc_edge: the edge file which linked theses with institutions and individuals
#' - sudoc_person: the table with information about individuals participating to the theses (authors, jury members, etc.)
#' - sudoc_institution: the table with information about institutions linked to the theses (laboratories, universities, etc.)

data <- data %>%
  rename(these_id = nnt) %>% 
  mutate(accessible = NA, # for conformity with theses.fr
         country = "France",
         these_id = ifelse(is.na(these_id), paste0("temp_sudoc_thesis_", sample(100000:999999, nrow(.))), these_id))

## Select and save metadata variables ------------

sudoc_metadata <- data %>%
  select(
    these_id,
    url,
    year_defence,
    title_fr,
    title_en,
    abstract_fr,
    abstract_en,
    language,
    language_2,
    country,
    field,
    type,
    accessible
  )

saveRDS(sudoc_metadata, here(FR_sudoc_intermediate_data_path, "sudoc_metadata.RDS"))

## Creating Edge Table--------

#' One important step here is to create an id for each entity (individual or institution) that is not identified by an idref.
#' We will differentiate them by a prefix "temp_sudoc_person_" or "temp_sudoc_institution_" followed by a random number. 
sudoc_edge <- data %>% 
  select(these_id,
         author_idref,
         author_name,
         author_firstname,
         supervisor_name,
         supervisor_firstname,
         supervisor_idref,
         member_name,
         member_firstname,
         member_idref,
         reviewer_name,
         reviewer_firstname,
         reviewer_idref,
         president_name,
         president_firstname,
         president_idref,
         institution_defence_name,
         institution_defence_idref,
         institution_defence_from_info_name,
         doctoral_school_name,
         doctoral_school_idref,
         laboratory_name,
         laboratory_idref,
         research_partner_name,
         research_partner_idref) %>% 
  mutate(across(! where(is.list) & !starts_with("these_id"), ~as.list(.))) %>% # necessary for all information to fit in the same columns
  pivot_longer(cols = -these_id, names_to = "variable", values_to = "value") %>% # linking thesis and institutions/intdividuals
  unnest(value)  %>% 
  separate(variable, into = c("role", "info"), sep = "_(?=[^_]+$)") %>% # extracting the role after the last "_"
  mutate(order = 1:n(), .by = c(these_id, role, info)) %>% # necessary to avoid list columns in pivot_wider
  pivot_wider(names_from = info, values_from = value) %>% 
  filter(! (is.na(name) & is.na(idref))) %>% # removing missing information
  rename(entity_role = role,
         entity_id = idref,
         entity_name = name,
         entity_firstname = firstname) %>% 
  select(-order) %>% 
  mutate(entity_id = ifelse(is.na(entity_id) & str_detect(entity_role, "author|member|supervisor|reviewer|president"), 
                        paste0("temp_sudoc_person_", 
                               sample(100000:999999, nrow(.))), entity_id),
         entity_id = ifelse(is.na(entity_id) & str_detect(entity_role, "institution|school|partner|laboratory"), 
                            paste0("temp_sudoc_institution_", 
                                   sample(100000:999999, nrow(.))), entity_id)) 

# We add a source file necessary to clean doublons later
sudoc_edge <- sudoc_edge %>% 
  mutate(source = "sudoc")

saveRDS(sudoc_edge, here(FR_sudoc_intermediate_data_path, "sudoc_edge.RDS"))

## Person table ------

sudoc_person <- sudoc_edge %>%
  filter(str_detect(entity_role, "author|member|supervisor|reviewer|president")) %>%
  select(entity_id, entity_name, entity_firstname) %>%
  unique()

saveRDS(sudoc_person, here(FR_sudoc_intermediate_data_path, "sudoc_person.rds"))

## Institution table ------

sudoc_institution <- sudoc_edge %>%
  filter(str_detect(entity_role, "institution|school|partner|laboratory")) %>%
  select(entity_id, entity_name) %>%
  unique()

saveRDS(sudoc_institution, here(FR_sudoc_intermediate_data_path, "sudoc_institution.rds"))
