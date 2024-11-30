# Load packages and data-----

source(file.path("paths_and_packages.R"))

idref_person_table <- readRDS(here(FR_raw_data_path, "idref", "idref_persons.rds")) %>% 
  select(-date_scrap)

thesis_person <- readRDS(here(FR_intermediate_data_path, "thesis_person.rds")) %>% 
  unique

# join idref table with person_table---------

# Convert idref_person_table to data.table
idref_person_table <- as.data.table(idref_person_table)

# Process idref_person_table
idref_person_table[, birth := str_extract(birth, ".{4}")] # Extract only the year from birth
idref_person_table[, length_info := map_int(info, length)]
idref_person_table[, info := ifelse(length_info > 1,
                                    map_chr(info, ~ paste0(., collapse = "\n")),
                                    info)] # paste into one value info if multiple values
idref_person_table[, length_info := NULL]  # Remove length_info column


# Process thesis_person with a left join of idref_person

thesis_person <- merge(
  thesis_person,            # x: left table
  idref_person_table,      # y: right table
  by.x = "entity_id",       # Column in x to join on
  by.y = "idref",           # Column in y to join on
  all.x = TRUE              # Keeps all rows from x (left join)
)


thesis_person[,`:=`(entity_name = fifelse(is.na(last_name), entity_name, last_name),
                    entity_firstname = fifelse(is.na(first_name), entity_firstname, first_name))]

# Drop unneeded columns
thesis_person[, c("first_name", "last_name") := NULL]

# Remove duplicate lines with same idref while keeping all other columns
thesis_person <- thesis_person[!duplicated(thesis_person, by = c("entity_id", "entity_firstname", "entity_name"))]

# basic normalization of strings to find homonym 
thesis_person[, authors := paste0(entity_firstname, entity_name, collapse = "+"), by = entity_id]
thesis_person[, authors := stri_trans_tolower(authors)]
thesis_person[, authors := stri_replace_all_regex(authors, "[:punct:]", " ")]
thesis_person[, authors := stri_trans_general(authors, id = "Latin-ASCII")]
thesis_person[, authors := str_squish(authors)]
thesis_person[, authors := stri_trim(authors)]

# function to find duplicate, create a temp variable "new id" and group by this variable to find homonym

thesis_person <- thesis_person %>%
  as_tibble %>%
  group_by(authors) %>%
  arrange(entity_id) %>%
  mutate(new_id = first(entity_id)) %>%
  group_by(new_id) %>%
  mutate(homonym_of = if_else(n() > 1, list(entity_id), NA)) %>%
  ungroup() %>%
  select(-authors, -new_id)


#### GENRE ##### 

# Charger les données du recensement INSEE
# Utilisation de fread pour une lecture rapide des fichiers CSV
insee_census_data <- fread(file.path(raw_data_path, "insee_prénoms_2023.csv"), sep = ";")

# Renommer les colonnes pour des noms plus explicites
setnames(insee_census_data, c("preusuel", "sexe", "annais", "nombre"), 
         c("firstname", "sexe", "year", "count"))

# Calculer les fréquences de genre pour chaque prénom
gender_frequency <- insee_census_data[
  # Calculer le total des occurrences par prénom
  , .(n_total = sum(count)), by = firstname][
    # Joindre avec les données originales pour récupérer les totaux
    insee_census_data, on = "firstname"][
      # Calculer la somme des occurrences par sexe et prénom, ainsi que le pourcentage
      , .(n_sexe = sum(count), 
          n_total = unique(n_total),
          percentage = sum(count) / unique(n_total) * 100), 
      by = .(sexe, firstname)][
        # Filtrer les prénoms fortement associés (>90%) à un sexe particulier
        percentage > 90, .(firstname, new_gender = sexe)][
          # Supprimer les doublons éventuels
          !duplicated(firstname)]


# Filtrer uniquement les lignes sans genre renseigné

# Convertir `thesis_person` en data.table si ce n'est pas déjà fait
thesis_person <- as.data.table(thesis_person)

# Filtrer uniquement les lignes sans genre renseigné
entity_firstname_new_gender <- thesis_person[is.na(gender), .(entity_firstname, gender)]

# Mettre le prénom en majuscules pour harmoniser
entity_firstname_new_gender[, name_match := str_to_upper(entity_firstname)]

# Remplacer les ponctuations par des espaces
entity_firstname_new_gender[, name_match := str_replace_all(name_match, "[:punct:]", " ")]

# Extraire le premier mot du prénom
entity_firstname_new_gender[, name_match := str_extract(name_match, "^[^ ]+")]

# Supprimer les espaces inutiles
entity_firstname_new_gender[, name_match := str_squish(name_match)]

# Supprimer les doublons
entity_firstname_new_gender <- entity_firstname_new_gender[!duplicated(name_match)]


# Joindre avec la table gender_frequency
entity_firstname_new_gender <- merge(
  entity_firstname_new_gender, # Table de gauche
  gender_frequency,           # Table de droite
  by.x = "name_match",        # Clé de la table de gauche
  by.y = "firstname",         # Clé de la table de droite
  all.x = TRUE                # Jointure à gauche pour conserver toutes les lignes de la première table
)

# Évaluer la distribution des nouveaux genres déterminés
entity_firstname_new_gender[, .N, by = new_gender]

# Joindre les nouveaux genres détectés sur le prénom avec merge()
thesis_person <- merge(
  thesis_person,                            # Table principale
  entity_firstname_new_gender[, c("entity_firstname", "new_gender")], # Table secondaire avec colonnes nécessaires
  by = "entity_firstname",                 # Clé de jointure
  all.x = TRUE                             # Jointure à gauche
)

# Convertir les valeurs numériques de new_gender en texte (male/female)
thesis_person$new_gender <- ifelse(
  thesis_person$new_gender == 1, "male", "female"
)

# Compléter la colonne gender avec new_gender si gender est manquant
thesis_person$gender_expended <- ifelse(
  is.na(thesis_person$gender), thesis_person$new_gender, thesis_person$gender
)

# final arrange 

thesis_person <- thesis_person %>% 
  select(-new_gender) %>% 
  relocate(entity_firstname, entity_id, entity_name, gender, gender_expended, birth, country, country_name, info, organization, last_date_org, start_date_org, end_date_org, other_link, homonym_of)
               
# save 

saveRDS(thesis_person, here(FR_cleaned_data_path, "thesis_person.rds"))


# TIDYVERSE VERSION
# # insee census data
# 
# insee_census_data <- read.csv(here(raw_data_path, "insee_prénoms_2023.csv"), sep = ";") %>% 
#   rename(firstname = preusuel, 
#          sexe = sexe,
#          year = annais,
#          count = nombre)
# 
# 
# gender_frequency <- insee_census_data %>% 
#   group_by(firstname) %>%
#   mutate(n_total = sum(count)) %>%
#   group_by(sexe, firstname) %>%
#   reframe(n_sexe = sum(count),
#           n_total = n_total,
#           percentage = n_sexe/n_total*100) %>% 
#   unique %>%
#   # if a firstname is associated at more than 90% to a specific gender, we apply this gender to our firstname with na at gender variable 
#   mutate(new_gender = ifelse(percentage > 90, sexe, NA)) %>% 
#   filter(!is.na(new_gender)) %>% 
#   select(firstname, new_gender) %>% 
#   unique
# 
# 
# # join with thesis_person 
# 
# entity_firstname_new_gender <- thesis_person %>%
#   # filter the line without gender
#   filter(is.na(gender)) %>% 
#   # left_join(thesis_edge, by = "entity_id") %>%
#   # left_join(thesis_metadata, by = "these_id") %>%
#   select(entity_firstname, gender) %>% 
#   # harmonize firstname
#   mutate(name_match = str_to_upper(entity_firstname),
#          name_match = str_replace_all(name_match, "[:punct:]", " "),
#          # extract anything before the first space: we asssume that the first word determined the gender of the firstname
#          name_match = str_extract_all(name_match, "^[^ ]+"),
#          name_match = str_squish(name_match)
#          ) %>%
#   unique %>% 
#   # left join with first_name and add gender variable
#   left_join(gender_frequency, by = c("name_match" = "firstname"))
# 
# 
# # eval 
# 
# entity_firstname_new_gender %>% 
#   count(new_gender) 
# 
# # join with thesis_person
# 
# thesis_person <- thesis_person %>%
#   left_join(entity_firstname_new_gender %>% 
#               select(entity_firstname, new_gender)) %>% 
#   mutate(new_gender = ifelse(new_gender == 1, "male", "female")) %>% 
#   mutate(gender_expended = ifelse(is.na(gender), new_gender, gender)) %>% 
#   select(-new_gender)
# 
# #save 
# 
# saveRDS(thesis_person, here(FR_cleaned_data_path, "thesis_person.rds"))
# 
