##################### Cleaning Persons Data ######################

#' Purpose: The goal is to replace the maximum of temporary id by real id from idref 
#' and to clean the institution names.
#' The basic strategy is to replace id temp by id ref using the name of the institution and the date of defence.
#' We replace the id temp by the idref of the institution if the name of the institution 
#' combined with the date of defence match a unique idref
#' For instance, if the name_entity is "Paris" and the date_soutenance is before 1970, 
#' we can replace the id_temp by the id_ref because there is one university of Paris before 1970 
#' But if the soutenance is after 1970, we cannot replace the id_temp by the id_ref because there 
#' are several universities in Paris after 1970. We need more specific name (Paris 1, Paris 2, etc.)
#' The core of this code is the tribble coupling a regex to match the name of the institution 
#' and the idref of the institution. 

# Load packages and data--------------------------------------------------------
source(file.path("paths_and_packages.R"))

# Load thesis institutions data
thesis_institutions <- readRDS(here(FR_intermediate_data_path, "thesis_institution.rds")) 
cli_alert_info(glue("We start with {thesis_institutions %>% distinct(entity_id) %>%  nrow} unique institutions."))
idref_institutions <- readRDS(here(FR_raw_data_path, "idref", "idref_institutions.rds")) %>% 
  as.data.table()

# Load edge and metadata tables to get the defence year
thesis_edge <- readRDS(here(FR_intermediate_data_path, "thesis_edge.rds")) 
thesis_metadata <- readRDS(here(FR_cleaned_data_path, "thesis_metadata.rds")) 

# Filter, join, and select relevant data ---------------------------------------
# Select institutions with temporary IDs and join with thesis_id and year_defence
thesis_institutions_with_date <- merge(thesis_institutions[entity_id %like% "temp"], thesis_edge[, .(thesis_id, entity_id)], by = "entity_id", all.x = TRUE)  # Join to add `thesis_id`
thesis_institutions_with_date <- merge(thesis_institutions_with_date, thesis_metadata[, .(thesis_id, year_defence)], by = "thesis_id", all.x = TRUE)  # Join to add `year_defence`
thesis_institutions_with_date <- thesis_institutions_with_date[! is.na(year_defence)]

# Define manual regex-based matching rules -------------------------------------
# Create a table with regex patterns, target idref

institutions_to_clean <- tribble(
  ~ regex, ~ entity_id, 
  "EHESS|E.H.E.S.S.", "026374889", # école des hautes études en sciences sociales. It is often linked with Paris 1, we link to EHESS
  # "^(Paris|Université de Paris|Université de Paris \\(1896-1968\\))$", "034526110", # université de Paris avant 1970
  "Paris", "034526110", # université de Paris avant 1970
  "Paris.*droit", "034925732", # faculté de droit de l'université de Paris 
  "(Paris|PARIS) ([1I])|Panth[ée]on", "027361802", # université Paris 1 après 1970 
  "Paris 2", "026403145", # université (avant 2021)
  "Paris 2", "260745863", # université (après 2021)
  "Paris 3", "027361837", # université
  "Paris 4", "026403633", # université (après 1970-2017)
  "Paris 5", "026404788", # université
  "Paris 6", "027787087", # université
  "Paris 7", "027542084", # université
  "Paris 8", "026403552", # université 
  "Paris 9", "027787109", #université 
  "Laboratoire d'Economie de Dauphine / LEDa", "164977147", #labo
  "Paris (X|10)", "026403587", # université 
  "Umr7235", "026403587", #labo
  "Paris 13", "175385920", # université
  "OMI", "174788525", #labo avant 2015
  "OMI", "190851031", #labo après 2015
  "ERUDITE", "177450517", #labo
  "Paris, Institut d'études politiques", "027918459", 
  "Théorie économique- modélisation et applications / THEMA", "128500484", #labo
  "EPHE|E.P.H.E.|Ecole Pratique des Hautes Etudes|Etude pratique des hautes études", "026375478",
  "Orléans", "026402971", # université
  "Nantes", "026403447", # université
  "^Grenoble$", "168435136", # université
  "Grenoble, Faculté de droit et sciences économiques", "029884942", #faculté
  "Grenoble 2", "103961852", #université entre 1970 et 1990
  "Grenoble 2", "02640432X", #université après 1990
  "Montpellier", "030091896", #université pré 1970
  "Montpellier", "028032837", #université (après 1970-2015)
  "Montpellier", "183316401", #université (2015-2021)
  "Montpellier 1", "028032837",#université (après 1970-2015)
  "Laboratoire Montpelliérain d'Économie Théorique et Appliquée / LAMETA", "058459928", #labo
  "Dijon", "02819005X", #université 
  "Dijon", "027412482", # faculté de droit 
  "Université de Dijon. Faculté de droit", "027412482", #faculté
  "Besançon", "026403188", #université
  "Université de Bordeaux", "030142199", #université 
  "Bordeaux 1", "027548341", #université (1971-2013)
  "Toulouse", "027297519",
  "Toulouse [1I]", "026404354",
  "Toulouse 2", "026403994", #université (1970-2013)
  "Poitiers", "026403765", #université 
  "Strasbourg", "02809509X",
  "Strasbourg 1", "026404540", #université (1970-2008)
  "Strasbourg 2", "026438763", #université (1970-2008)
  "Strasbourg 3", "026404311", #université (1970-2008)
  "Reims|(REGARDs) - Economie-Gestion, Agro-ressources, Développement durable, Santé", "026403838", #université
  "Lyon", "028025261",
  "Lyon [2|II]", "02640334X", #université (après 1969)
  "Lyon 3", "026404494", #université (après 1969)
  "Saint-Etienne|SAINT ETIENNE", "028209966", # université
  "Tours", "026404478", #université
  "Lille", "027291340",
  "Lille [1|I]|Université des sciences et technologies de Lille", "026404184", #université (1970-2017)
  "Lille 2", "026404389", #université (1970-2017)
  "Aix|Marseille", "028025253", #université  (1896-1973)
  "Aix-Marseille", "02640317X", #université (1973-2011)
  "Aix-Marseille", "15863621X", #université (2011-...)
  "Aix-Marseille 2|Aix-Marseille II", "026402882", #université (1969-2011)
  "Aix-Marseille 3", "026403153",
  "Nice", "026403498", #université (avant 2019)
  "GREDEG", "142564443", #labo 
  "Université de Clermont-Ferrand", "030142865", #université avant 1976
  "(CERDI) Centre d'études et de recherches sur le developpement international", "026433737", #labo
  "Clermont.Ferrand 1", "028032829", #université après 1976
  "Clermont.Ferrand 2", "026403102", #université après 1976
  "Nancy", "03362920X", 
  "Nancy [2|II]", "026403412", #université (1970-2012)
  "Rennes", "074314807",
  "Rennes [1|I]", "02778715X", #université (1970:2022)
  "Sciences de l'homme, des organisations et de la société", "139085610", #université (1970:2022)
  "Caen", "026403064",
  "Rouen", "026403919",
  "Amiens", "026403714",
  "Limoges", "059358041",
  "Brest", "026403021"
) 

# Now we have the manually checked idref, we can add dates of birth and death to validate the merging of id
institutions_to_clean <- institutions_to_clean %>%
  left_join(idref_institutions %>% select(entity_id, date_of_birth, date_of_death), by = "entity_id") %>%
  mutate(date_of_death = ifelse(is.na(date_of_death), 2024, date_of_death), # we set 2024 as default
         date_of_birth = ifelse(is.na(date_of_birth), 1896, date_of_birth), # some universities have no date of birth, we set 1896 as default (most modern universities have been created in 1896)
         date_of_birth = str_extract(date_of_birth, "\\d{4}") %>% as.integer(), # replace dates by year
         date_of_death = str_extract(date_of_death, "\\d{4}") %>% as.integer)

# Replace id_temp with idref based on regex and defense dates ------------------
# Iterate over institutions_to_clean and update thesis_institutions_with_date
for (i in 1:nrow(institutions_to_clean)) {
thesis_institutions_with_date[str_detect(entity_id, "^temp") &
                                str_detect(entity_name, institutions_to_clean$regex[i]) &
                                between(year_defence, institutions_to_clean$date_of_birth[i], institutions_to_clean$date_of_death[i]),
                              entity_id_clean := institutions_to_clean$entity_id[i]]
}

# Display stats about replacements
cli_alert_info(glue("We start with {thesis_institutions %>% distinct(entity_id) %>% nrow} unique institutions.
We had {thesis_institutions[entity_id %like% 'temp'] %>% nrow} id_temp to clean.
We have replaced {thesis_institutions_with_date[!is.na(entity_id_clean)] %>% nrow} id_temp ({round((thesis_institutions_with_date[!is.na(entity_id_clean)] %>% nrow)/(thesis_institutions[entity_id %like% 'temp'] %>% nrow), 4) * 100}%)."))

# Replace ids in thesis_institutions -------------------------------------------
# Replace entity_id with cleaned entity_id_clean 
thesis_institutions <- merge(thesis_institutions, thesis_institutions_with_date[, .(entity_id, entity_id_clean)], by = "entity_id", all.x = TRUE) %>% 
  .[, old_id := entity_id] %>% 
  .[, entity_id := ifelse(is.na(entity_id_clean), entity_id, entity_id_clean)]

#' Merge with the information extracted from idref about `scraped_id`.
#' Some old idref have been merged with new idref by the ABES. When you try to connect
#' to these old idrefs, you are redirected to the new ones. Hence, the `scraped_id` column
#' allows to know if the idref has been merged with another one. We keep the new idref
#' (the old one has been saved in `old_id`)
thesis_institutions <- merge(thesis_institutions, idref_institutions[,.(entity_id, scraped_id, pref_name)], by = "entity_id", all.x = TRUE)
thesis_institutions[!is.na(scraped_id) & scraped_id != entity_id, entity_id := scraped_id]

#' Now that we have managed this issue, we can remove `old_id` that are the same
#' as the `entity_id`
thesis_institutions[, old_id := ifelse(old_id == entity_id, NA_character_, old_id)]

#' We can now grouped all the `old_id` by the same `entity_id` and remove
#' duplicates in `entity_id`. We save the data separately to keep only unique
#' ids. 
old_ids <- thesis_institutions[, .(old_id = ifelse(all(is.na(old_id)), list(NA_character_), list(na.omit(old_id)))), by = entity_id]

#' We can now standardize the name of the institution by using the `pref_name` column extracted from
#' idref scraping
thesis_institutions <- thesis_institutions[!is.na(pref_name), entity_name := pref_name][, .(entity_id, entity_name)] %>% 
  unique()

# Add old IDs and enrich with idref metadata
thesis_institutions <- merge(thesis_institutions, old_ids, by = "entity_id")
thesis_institutions <- merge(thesis_institutions, idref_institutions[, -(c("scraped_id", "pref_name", "country", "info"))], by = "entity_id", all.x = TRUE)

# Save the cleaned dataset -----------------------------------------------------
saveRDS(thesis_institutions, here(FR_cleaned_data_path, "thesis_institution.rds"))
