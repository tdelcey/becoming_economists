########################  Cleaning Metadata Table for Theses #####################
#'
#' Purpose: This script processes and cleans metadata for theses, focusing on titles and abstracts.
#' The goal detect and manage missing or incorrect values, notably linked to language detection.
#' In a second step, we identify and manage duplicates in the metadata, by using string distance 
#' functions to find duplicates.

# Load Required Packages and Data -------------------------------------------

# Source helper scripts for paths and utility functions
source(file.path("paths_and_packages.R"))
source(file.path("FR", "R", "helper_functions.R"))

# Loading packages
p_load(cld3,
       fastText,
       stringdist,
       furrr)

# Loading data
thesis_metadata <- readRDS(here(FR_intermediate_data_path, "thesis_metadata.rds"))
setDT(thesis_metadata, key = "thesis_id")
thesis_edge <- readRDS(here(FR_intermediate_data_path, "thesis_edge.rds"))
setDT(thesis_edge, key = "thesis_id")

# Cleaning titles and abstract----------

## Managing upper cases in titles and abstracts---------------------
#' Titles and abstracts in full uppercase letters are normalized to sentence case. 
#' This standardization removes formatting noise while retaining information.
#' 
#' Threshold: Titles/abstracts with > 80% uppercase letters are considered "full caps"
#' and thus transformed in normal sentence format. The threshold has been tested manually.

thesis_metadata[str_count(title_fr, "[:upper:]")/str_count(title_fr, "[:letter:]") > 0.8, title_fr := str_to_sentence(title_fr)]
thesis_metadata[str_count(title_en, "[:upper:]")/str_count(title_en, "[:letter:]") > 0.8, title_en := str_to_sentence(title_en)]
thesis_metadata[str_count(abstract_fr, "[:upper:]")/str_count(abstract_fr, "[:letter:]") > 0.8, abstract_fr := str_to_sentence(abstract_fr)]
thesis_metadata[str_count(abstract_en, "[:upper:]")/str_count(abstract_en, "[:letter:]") > 0.8, abstract_en := str_to_sentence(abstract_en)]

## Cleaning Empty or Problematic Titles and Abstracts ---------------------
#' Some titles and abstracts are incorrectly populated with placeholder text or irrelevant symbols.
#' These are replaced with `NA`.

# Replace problematic values in French and English titles/abstracts
thesis_metadata[title_fr == ".", title_fr := NA_character_]
thesis_metadata[abstract_en == ".", abstract_en := NA_character_]
thesis_metadata[abstract_fr %in% c("Résumé en français", "RESUME Français", "No abstract.", 
                                   "Le résumé en français n'a pas été communiqué par l'auteur."), abstract_fr := NA_character_]
thesis_metadata[abstract_en %in% c(".../...", "Non fourni", "Le résumé en anglais n'a pas été communiqué par l'auteur.", 
                                   "Pas de résumé en anglais", "Unavailable"), abstract_en := NA_character_]

## Filling Missing Titles and Abstracts -----------------------------------
#' Titles and abstracts are filled using `title_other` and `abstract_other` where possible.
#' Language detection is performed using cld3 and fastText, with thresholds to ensure accuracy.

### Cleaning and Detecting Language in `title_other`---------------
# Remove extraneous text before the actual title
thesis_metadata[, title_other := str_remove(title_other, "^[^[:upper:]]*(?=[:upper:])")]

# Detect language using cld3
thesis_metadata[!is.na(title_other), language_cld3 := detect_language(title_other)]

# Load pre-trained fastText language detection model
file_ftz <- system.file("language_identification/lid.176.ftz", package = "fastText") # importing the pre-trained model
# Detect language using fastText and store in a separate table
language_fastText <- identify_fastText_language(
  input_obj = thesis_metadata[!is.na(title_other)]$title_other, # import from helper_functions.R
  id_obj = thesis_metadata[! is.na(title_other)]$thesis_id,
  pre_trained_language_model_path = file_ftz) %>% 
  as.data.table

# Merge detected languages into `thesis_metadata`
thesis_metadata <- merge(thesis_metadata, language_fastText, by = "thesis_id", all.x = TRUE) 

# Assign detected languages with a combined cld3/fastText approach
thesis_metadata[, detect_language := ifelse(prob_fastText > 0.6 | (language_cld3 == language_fastText), language_fastText, NA)]

#### Filling Missing Titles Based on Detected Language---------------------
#' If a title is missing in French or in English, we fill it with the title_other column if the language is the same.
thesis_metadata[! is.na(title_other) & is.na(title_fr) & detect_language == "fr", title_fr := title_other]
thesis_metadata[! is.na(title_other) & is.na(title_en) & detect_language == "en", title_en := title_other]

#' Now that we have very few remaining case something we can do (after careful verification) is to fill the remaining missing values
#' with the corresponding language. It implies using cld3 first, and then fastText (but that's very contextual and depending on our remaining data here)
thesis_metadata[! is.na(title_other) & is.na(detect_language) & is.na(title_en) & language_cld3 == "en", title_en := title_other]
thesis_metadata[! is.na(title_other) & is.na(detect_language) & is.na(title_en) & language_fastText == "en", title_en := title_other]
thesis_metadata[! is.na(title_other) & is.na(title_fr) & language_fastText == "fr", title_fr := title_other]

#### Final Cleanup for `title_other` Column---------------------
#' As a last step, we remove the content of the title_other column when it is in English or in French, as we have now 
#' filled the title_en and title_fr columns with the appropriate values.
thesis_metadata[! is.na(title_other) & title_fr == title_other, title_other := NA_character_]
thesis_metadata[! is.na(title_other) & title_en == title_other, title_other := NA_character_]
thesis_metadata[! is.na(title_other) & ! is.na(title_fr) & detect_language == "fr", title_other := NA_character_]
thesis_metadata[! is.na(title_other) & ! is.na(title_en) & detect_language == "en", title_other := NA_character_]
thesis_metadata <- thesis_metadata[, -(c("language_cld3", "language_fastText", "prob_fastText", "detect_language"))]

### Repeat the Process for `abstract_other`--------------------------------
#' We do the same for the abstract. When both French and English abstract are missing, we will fill both
#' columns with appropriate language. We still implement the same approach for language detection as for the title,
#' even if it appears that running cld3 is not necessary anymore.

thesis_metadata[, abstract_other := str_remove(abstract_other, "^[^[:upper:]]*(?=[:upper:])")] # remove everything before the start of the Abstract
thesis_metadata[! is.na(abstract_other), language_cld3 := detect_language(abstract_other)]
language_abstract_fastText <- identify_fastText_language(input_obj = thesis_metadata[! is.na(abstract_other)]$abstract_other, # import from helper_functions.R
                                                         id_obj = thesis_metadata[! is.na(abstract_other)]$thesis_id,
                                                         pre_trained_language_model_path = file_ftz) %>% 
  as.data.table

thesis_metadata <- merge(thesis_metadata, language_abstract_fastText, by = "thesis_id", all.x = TRUE)

#' The results are much better here as there are more text in the abstract than in the title.
#' There is just two errors in original data to manage: an "English" abstract is actually in French, while the 
#' other abstract is in English. So we fill first the French abstract, then we correct the error
#' then we fill the English abstract. 
#' The use of the probability is just in case, for more robust application to other data.
thesis_metadata[! is.na(abstract_other) & is.na(abstract_fr) & language_fastText == "fr" & prob_fastText > 0.6, abstract_fr := abstract_other]
thesis_metadata[! is.na(abstract_other) & ! is.na(abstract_en) & is.na(abstract_fr) & language_fastText == "en", abstract_fr := abstract_en] # Here we put the two "false" English abstract in the French abstract column
thesis_metadata[! is.na(abstract_other) & language_fastText == "en" & prob_fastText > 0.6, abstract_en := abstract_other] # here we also replace the two English abstract that are actually in French
thesis_metadata[! is.na(abstract_other) & ! is.na(abstract_fr) & is.na(abstract_en) & language_fastText == "fr" & prob_fastText > 0.7, abstract_en := abstract_fr] # We do the same for the false "French" abstract
thesis_metadata[! is.na(abstract_other) & language_fastText == "fr" & prob_fastText > 0.6, abstract_fr := abstract_other]

#' Last step: we remove other abstract in French or English
thesis_metadata[! is.na(abstract_other) & abstract_fr == abstract_other, abstract_other := NA_character_]
thesis_metadata[! is.na(abstract_other) & abstract_en == abstract_other, abstract_other := NA_character_]
thesis_metadata[! is.na(abstract_other) & ! is.na(abstract_fr) & language_fastText == "fr", abstract_other := NA_character_] # That's just in case, but apparently there are no cases
thesis_metadata[! is.na(abstract_other) & ! is.na(abstract_en) & language_fastText == "en", abstract_other := NA_character_] # No case

thesis_metadata <- thesis_metadata[, -(c("language_cld3", "language_fastText", "prob_fastText"))]

## Checking Language Consistency of Titles and Abstracts -------------------

#' Titles and abstracts are verified for language consistency. Errors are corrected 
#' by reassigning values or moving content between columns where necessary.
#' We detect languages for `title_fr` and `title_en` using cld3 and fastText.
#' To avoid errors, a stricter probability threshold (0.6) is applied. 
#' The process is manually validated for correctness.

### Detecting language in titles-------------------------------------------
# Detect language in titles using cld3
thesis_metadata[!is.na(title_fr), language_cld3_fr := detect_language(title_fr)]
thesis_metadata[!is.na(title_en), language_cld3_en := detect_language(title_en)]

# Detect language in titles using fastText (parallelized)
plan(multisession, workers = future::availableCores() - 2)
language_fastText_fr <- future_map2(thesis_metadata[!is.na(title_fr)]$title_fr,
                                    thesis_metadata[!is.na(title_fr)]$thesis_id,
                                    ~ identify_fastText_language(input_obj = .x, # import from helper_functions.R
                                                                 id_obj = .y,
                                                                 pre_trained_language_model_path = file_ftz,
                                                                 verbose = FALSE) %>% 
                                      as.data.table %>% 
                                      .[1],
                                    .progress = TRUE,
                                    .options = furrr_options(seed = 1234)
) %>% 
  rbindlist
setnames(language_fastText_fr, c("language_fastText_fr", "prob_fastText_fr", "thesis_id"))

language_fastText_en <- future_map2(thesis_metadata[!is.na(title_en)]$title_en,
                                    thesis_metadata[!is.na(title_en)]$thesis_id,
                                    ~ identify_fastText_language(input_obj = .x, # import from helper_functions.R
                                                                 id_obj = .y,
                                                                 pre_trained_language_model_path = file_ftz,
                                                                 verbose = FALSE) %>% 
                                      as.data.table %>% 
                                      .[1],
                                    .progress = TRUE,
                                    .options = furrr_options(seed = 1234)
) %>% 
  rbindlist
setnames(language_fastText_en, c("language_fastText_en", "prob_fastText_en", "thesis_id"))

# Merge language detections into the main table
thesis_metadata <- merge(thesis_metadata, language_fastText_fr, by = "thesis_id", all.x = TRUE)
thesis_metadata <- merge(thesis_metadata, language_fastText_en, by = "thesis_id", all.x = TRUE)

# Combine cld3 and fastText results with strict probability threshold
thesis_metadata[, language_title_fr := ifelse(prob_fastText_fr > 0.6 & language_cld3_fr == language_fastText_fr, language_cld3_fr, NA_character_)]
thesis_metadata[, language_title_en := ifelse(prob_fastText_en > 0.6 & language_cld3_en == language_fastText_en, language_cld3_en, NA_character_)]

### Title Corrections Based on Language -------------------------------------
# step 1: Move non-English titles from `title_fr` to `title_other`
thesis_metadata[language_title_fr != "fr" & language_title_fr != "en", title_other := title_fr]
thesis_metadata[language_title_fr != "fr" & language_title_fr != "en", title_fr := NA_character_]

# step 2: Move non-French titles from `title_en` to `title_other` (just for consistency, no case here)
thesis_metadata[language_title_en != "fr" & language_title_en != "en", title_other := title_en]
thesis_metadata[language_title_en != "fr" & language_title_en != "en", title_en := NA_character_]

# step 3: Handle cases where English titles exist in both `title_fr` and `title_en`
thesis_metadata[language_title_fr == "en" & language_title_en == "en", title_fr := NA_character_]
# we need to add a strict proba condition as the identification is not working perfectly on title_en, with English titles falsely identified as French
thesis_metadata[language_title_en == "fr" & language_title_fr == "fr" & prob_fastText_en > 0.8, title_en := NA_character_]  

# step 4: Triangular correction: Handle misplaced English titles in `title_fr` and vice versa
thesis_metadata[language_title_fr == "en" & language_title_en != "en", title_other := title_fr]
thesis_metadata[language_title_fr == "en" & language_title_en == "fr", title_fr := title_en]
thesis_metadata[language_title_fr == "en" & language_title_en == "fr", title_en := title_other]
thesis_metadata[language_title_fr == "en" & language_title_en == "fr", title_other := NA_character_]

# Remove unnecessary columns after processing
thesis_metadata <- thesis_metadata[, -(c("language_cld3_fr", "language_cld3_en", "language_fastText_fr", "language_fastText_en", "prob_fastText_fr", "prob_fastText_en", "language_title_fr", "language_title_en"))]

### Abstract Corrections Using fastText Only-------------------------------------
#' We do the same for the abstracts but only with the fastText model, 
#' which is largely sufficient because of the length of the text.
language_fastText_abstract_fr <- future_map2(thesis_metadata[!is.na(abstract_fr)]$abstract_fr,
                                             thesis_metadata[!is.na(abstract_fr)]$thesis_id,
                                             ~ identify_fastText_language(input_obj = .x, # import from helper_functions.R
                                                                          id_obj = .y,
                                                                          pre_trained_language_model_path = file_ftz,
                                                                          verbose = FALSE) %>% 
                                               as.data.table %>% 
                                               .[1],
                                             .progress = TRUE,
                                             .options = furrr_options(seed = 1234)
) %>% 
  rbindlist
setnames(language_fastText_abstract_fr, c("language_fastText_abstract_fr", "prob_fastText_abstract_fr", "thesis_id"))

language_fastText_abstract_en <- future_map2(thesis_metadata[!is.na(abstract_en)]$abstract_en,
                                             thesis_metadata[!is.na(abstract_en)]$thesis_id,
                                             ~ identify_fastText_language(input_obj = .x, # import from helper_functions.R
                                                                          id_obj = .y,
                                                                          pre_trained_language_model_path = file_ftz,
                                                                          verbose = FALSE) %>% 
                                               as.data.table %>% 
                                               .[1],
                                             .progress = TRUE,
                                             .options = furrr_options(seed = 1234)
) %>% 
  rbindlist
setnames(language_fastText_abstract_en, c("language_fastText_abstract_en", "prob_fastText_abstract_en", "thesis_id"))

# Merge language detection into the main table
thesis_metadata <- merge(thesis_metadata, language_fastText_abstract_fr, by = "thesis_id", all.x = TRUE)
thesis_metadata <- merge(thesis_metadata, language_fastText_abstract_en, by = "thesis_id", all.x = TRUE)

# Correct one specific unique fastText issue (`uk` -> `en`)
thesis_metadata[language_fastText_abstract_en == "uk", language_fastText_abstract_en := "en"]

# step 1: Move non-French abstracts from `abstract_fr` to `abstract_other`
thesis_metadata[language_fastText_abstract_fr != "fr" & language_fastText_abstract_fr != "en", abstract_other := abstract_fr]
thesis_metadata[language_fastText_abstract_fr != "fr" & language_fastText_abstract_fr != "en", abstract_fr := NA_character_]

# step 2: Move non-French abstracts from `abstract_en` to `abstract_other` (just for consistency, no case here)
thesis_metadata[language_fastText_abstract_en != "fr" & language_fastText_abstract_en != "en", abstract_other := abstract_en]
thesis_metadata[language_fastText_abstract_en != "fr" & language_fastText_abstract_en != "en", abstract_en := NA_character_]

# step 3: Handle cases where English abstracts exist in both `abstract_fr` and `abstract_en`
thesis_metadata[language_fastText_abstract_fr == "en" & language_fastText_abstract_en == "en", abstract_fr := NA_character_]
thesis_metadata[language_fastText_abstract_en == "fr" & language_fastText_abstract_fr == "fr", abstract_en := NA_character_]

# step 4: Triangular correction: Handle misplaced English titles in `title_fr` and vice versa
thesis_metadata[language_fastText_abstract_fr == "en" & language_fastText_abstract_en != "en", abstract_other := abstract_fr]
thesis_metadata[language_fastText_abstract_fr == "en" & language_fastText_abstract_en == "fr", abstract_fr := abstract_en]
thesis_metadata[language_fastText_abstract_fr == "en" & language_fastText_abstract_en == "fr", abstract_en := abstract_other]
thesis_metadata[language_fastText_abstract_fr == "en" & language_fastText_abstract_en == "fr", abstract_other := NA_character_]

# Remove unnecessary columns after processing
thesis_metadata <- thesis_metadata[, -(c("language_fastText_abstract_fr", "language_fastText_abstract_en", "prob_fastText_abstract_fr", "prob_fastText_abstract_en"))]

# Handling Duplicates in Thesis Metadata-------------------------------------
#' Here we address duplicates in the thesis metadata, specifically focusing on author information and titles.
#' Duplicates arise due to inconsistencies in data sources (e.g., Sudoc vs theses.fr) and variations in how information
#' like names and titles are written. The aim is to:
#' 
#' - Identify duplicates by comparing titles and author names using string distance metrics.
#' - Consolidate duplicate entries by assigning consistent IDs and grouping them together.
#' - Handle specific cases of duplicates identified manually.
#'
#' The approach ensures data consistency and avoids false positives by using strict thresholds and checking
#' everything manually.
#' 
data_to_match <- thesis_metadata %>% 
  left_join(thesis_edge[entity_role == "author",])

# Merging with data.table does not work for no understandable reasons...
#data_to_match <- merge.data.table(thesis_edge[entity_role == "author",], thesis_metadata, by.x = "thesis_id", by.y = "thesis_id", allow.cartesian = TRUE)
setorder(data_to_match, thesis_id, entity_id)

#' Perform string normalization for titles and authors.
#' This step standardizes text to make comparisons more effective by:
#' - Lowercasing all text.
#' - Removing punctuation.
#' - Translating accented characters to their base forms.
#' - Trimming extra whitespace.
data_to_match[, title := fifelse(title_fr == "" | is.na(title_fr), title_en, title_fr)]
data_to_match[, title := tolower(title)]
data_to_match[, title := stri_replace_all_regex(title, "[:punct:]", " ")]
data_to_match[, title := stri_trans_general(title, id = "Latin-ASCII")] 
data_to_match[, title := str_squish(title)] 
data_to_match[, title := stri_trim(title)] 
data_to_match[, authors := tolower(entity_name)] 
data_to_match[, authors := stri_replace_all_regex(authors, "[:punct:]", " ")] 
data_to_match[, authors := stri_trans_general(authors, id = "Latin-ASCII")] 
data_to_match[, authors := str_squish(authors)] 
data_to_match[, authors := stri_trim(authors)] 
# Filter out rows with missing or empty titles or authors
data_to_match <- data_to_match[!is.na(title) & title != "" & !is.na(authors) & authors != "" , .(thesis_id, title, authors)] 
# Keep only rows where authors have duplicates
data_to_match <- data_to_match[, .SD[duplicated(authors) | duplicated(authors, fromLast = TRUE)]] %>% 
  unique()

## Detecting duplicate with find_duplicates() -----------------------------------

# The find_duplicates() function detects potential duplicates in thesis metadata by comparing titles within groups 
#' of the same author. It calculates string distances between pairs of titles using the Optimal 
#' String Alignment (OSA) algorithm and filters results based on predefined thresholds.

# Filter to use with verifications of data by eye
duplicates <- find_duplicates(data_to_match, 
                              threshold_distance = 80, 
                              threshold_normalization = 0.007,
                              workers = future::availableCores() - 2) 
# We post-restrict the filtering to avoid false positives but capture all true positives
duplicates <- duplicates[normalized_distance < 0.0051 | (distance < 51 & normalized_distance < 0.00622)]

# Group duplicates by primary ID
duplicates <- rbind(duplicates[, .(thesis_id, thesis_id_2)],
                        duplicates[, .(thesis_id = thesis_id_2, thesis_id_2 = thesis_id)]) %>% 
  unique()
duplicates <- duplicates[, .(duplicates = list(thesis_id_2)), by = "thesis_id"]

# Add duplicates to the main metadata table
thesis_metadata <- thesis_metadata %>%
  left_join(duplicates[, .(thesis_id, duplicates)]) %>% 
  mutate(duplicates = ifelse(duplicates == "NULL", NA_character_, duplicates))

## Handling specific cases-----------------------------------------------------

# Group together id with the same pattern
specific_cases <- thesis_metadata[title_fr %like% "Approche systémique et régulation économique",]
thesis_metadata[title_fr %like% "Approche systémique et régulation économique", duplicates := map(thesis_id, ~ setdiff(specific_cases$thesis_id, .x))]

## Checking the right number of duplicates----------------------------------------
# We unnest the duplicates and we check that each id is present the same number of 
# times on both sides.

test_dt <- copy(thesis_metadata)
test_dt <- dt_unnest(test_dt, duplicates, keep = FALSE) %>% 
  .[!is.na(V1), .(thesis_id, V1)]
test_dt[, n_thesis := .N, by = thesis_id]
test_dt[, n_duplicates := .N, by = V1]

if(nrow(test_dt[n_duplicates != n_thesis]) == 0) {
  cli_alert_success("All duplicates have been correctly assigned.")
} else {
  cli_alert_danger("Some duplicates have not been correctly assigned.")
}

# Saving final results
saveRDS(thesis_metadata, here(FR_cleaned_data_path, "thesis_metadata.rds"))
