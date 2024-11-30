####################### Scraping Metadata from Sudoc API #######################
#' Purpose: This script retrieves metadata for French theses from the Sudoc API 
#' using a list of pre-collected URLs in scraping_sudoc_id.R. The metadata includes thesis titles, 
#' authors, abstract, jury members, institutions, etc. The data is progressively 
#' saved to avoid data loss during long runs. The script can be run in background.
#' 
#' The SUDOC api allows to access an `.xml` file for each thesis record. This `.xml`
#' displays structured metadata categorized depending on "tags" and "codes" which are
#' explained here: https://documentation.abes.fr/sudoc/manuels/administration/aidewebservices/index.html#SudocMarcXML
#' 
#' Second script to run after scraping_sudoc_id.R to extract SUDOC data.

# Load dependencies, functions, and setup paths ---------------------------------------------------------
source(here::here("paths_and_packages.R"))

# Load helper functions for the xml_text_in_list() and fetch_text_by_tags_and_codes() functions
source(here("FR", "R", "helper_functions.R"))

pacman::p_load(xml2,
               furrr)

# Load the URLs for each discipline ---------------------------------------------------------
# URLs have been pre-filtered based on disciplines (economics and law) and time ranges. 
# They are loaded and combined, avoiding duplicates in the final list.
urls_eco <- readRDS(here(FR_sudoc_raw_data_path, "sudoc_urls_economics_1900-1985.rds")) %>% 
  paste0(., ".xml") %>% 
  tibble(url = .,
         source = "sudoc_economics")

urls_law <- readRDS(here(FR_sudoc_raw_data_path, "sudoc_urls_law_1900-1968.rds")) %>% 
  paste0(., ".xml") %>% 
  tibble(url = .,
         source = "sudoc_law")

df_urls <- urls_eco %>% 
  bind_rows(urls_law) %>% 
  distinct(url, .keep_all = TRUE) # if "Note de Thèse" with both "droit" and "econo*"

# Load or Initialize Metadata Storage -------------------------------------------------------
  sudoc_metadata <- vector(mode = "list", length = length(df_urls$url))
  names(sudoc_metadata) <- df_urls$url

process_url_metadata <- function(url, source) {
  # Attempt to fetch the XML content of the URL
  repeat {
    page <- NULL
    try({
      page <- read_xml(url)
    }, silent = TRUE)
    if (!is.null(page)) break
  }
  
  ## Extract core metadata elements from the XML ----------------------------------------------
  
  ### Extracting basic info of the thesis--------------------
  nnt <- fetch_text_by_tags_and_codes(page, "029", "b", give_list = TRUE)
  # For titles, we can have several lines that we collapse together with a "\n"
  title_fr <- fetch_text_by_tags_and_codes(page, "200", c("a", "e"), give_list = FALSE) %>% paste0(., collapse = "\n")
  title_en <- fetch_text_by_tags_and_codes(page, "541", c("a", "e"), give_list = FALSE) %>% paste0(., collapse = "\n")
  language <- fetch_text_by_tags_and_codes(page, "101", "a", give_list = TRUE)
  language_2 <- fetch_text_by_tags_and_codes(page, "541", "z", give_list = TRUE)
  
  year_defence <- fetch_text_by_tags_and_codes(page, c("328", "214", "210"), "d", give_list = TRUE)
  
  abstract_fr <- xml_find_all(page, ".//datafield[@tag='330']") %>% xml_find_all(., ".//subfield[@code='z' and text()='fre']") %>% xml_parent(.) %>% xml_text_in_list()
  abstract_en <- xml_find_all(page, ".//datafield[@tag='330']") %>%  xml_find_all(., ".//subfield[@code='z' and text()='eng']") %>% xml_parent(.) %>% xml_text_in_list()
  
  country <- fetch_text_by_tags_and_codes(page, "102", "a", give_list = TRUE)
  
  ### Information about the thesis subject--------------
  
  rameaux <- xml_find_all(page, ".//datafield[@tag='606']") 
  rameaux_topic <- map(rameaux, ~ xml_find_all(., ".//subfield[@code='a' or @code = 'j' or @code = 'x' or @code='y']") %>% xml_text()) %>% map_chr(~ paste(., collapse = "--")) %>% list() 
  rameaux_topic_idref <- map(rameaux, ~ xml_find_all(., ".//subfield[@code='3']") %>% xml_text()) %>% map_chr(~ paste(., collapse = "--")) %>% list()
  
  topic <- fetch_text_by_tags_and_codes(page, "610", "a", give_list = TRUE)
  topic_language <- fetch_text_by_tags_and_codes(page, "610", "z", give_list = TRUE)
  
  # We extract general information about the thesis. Sometimes they are categorized and we can extract the field and type (and the date; see above).
  # But sometimes it is grouped together and we extract this in `other_type_info` for later cleaning.
  field <- fetch_text_by_tags_and_codes(page, "328", "c", give_list = TRUE)
  type <- fetch_text_by_tags_and_codes(page, "328", "b", give_list = TRUE)
  other_type_info <- fetch_text_by_tags_and_codes(page, "328", "a", give_list = TRUE)
  
  ### Extracting individuals and jury informations--------------  
  author_name <- fetch_text_by_tags_and_codes(page, "700", "a", give_list = TRUE)
  author_firstname <- fetch_text_by_tags_and_codes(page, "700", "b", give_list = TRUE)
  author_idref <- fetch_text_by_tags_and_codes(page, "700", "3", give_list = TRUE)
  
  if(length(unlist(author_name)) == 0){
    author <-   xml_find_all(page, ".//datafield[@tag='700' or @tag='701' or @tag='702']") %>% xml_find_all(., ".//subfield[@code='4' and text()='070']")
    author_name <- xml_parent(author) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
    author_firstname <- xml_parent(author) %>% xml_find_all(".//subfield[@code='b']") %>% xml_text_in_list()
    author_idref <- xml_parent(author) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  }
  
  supervisor <- xml_find_all(page, ".//datafield[@tag='700' or @tag='701' or @tag='702']") %>% xml_find_all(., ".//subfield[@code='4' and text()='727']")
  supervisor_name <- xml_parent(supervisor) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  supervisor_firstname <- xml_parent(supervisor) %>% xml_find_all(".//subfield[@code='b']") %>% xml_text_in_list()
  supervisor_idref <- xml_parent(supervisor) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  reviewers <- xml_find_all(page, ".//datafield[@tag='700' or @tag='701' or @tag='702']") %>% xml_find_all(., ".//subfield[@code='4' and text()='958']")
  reviewer_name <- xml_parent(reviewers) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  reviewer_firstname <- xml_parent(reviewers) %>% xml_find_all(".//subfield[@code='b']") %>% xml_text_in_list()
  reviewer_idref <- xml_parent(reviewers) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  president <- xml_find_all(page, ".//datafield[@tag='700' or @tag='701' or @tag='702']") %>% xml_find_all(., ".//subfield[@code='4' and text()='956']")
  president_name <- xml_parent(president) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  president_firstname <- xml_parent(president) %>% xml_find_all(".//subfield[@code='b']") %>% xml_text_in_list()
  president_idref <- xml_parent(president) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  members <- xml_find_all(page, ".//datafield[@tag='700' or @tag='701' or @tag='702']") %>% xml_find_all(., ".//subfield[@code='4' and text()='555']")
  member_name <- xml_parent(members) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  member_firstname <- xml_parent(members) %>% xml_find_all(".//subfield[@code='b']") %>% xml_text_in_list()
  member_idref <- xml_parent(members) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  ### Extracting institutions--------------
  institutions_defence <- xml_find_all(page, ".//datafield[@tag='711' or @tag='712']") %>% xml_find_all(., ".//subfield[@code='4' and text()='295']") 
  institution_defence_name <- xml_parent(institutions_defence) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  institution_defence_idref <- xml_parent(institutions_defence) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  # Sometimes, the institution is also stored in the 328 code, where we find general info about the thesis
  institution_defence_from_info_name <- fetch_text_by_tags_and_codes(page, "328", "e", give_list = TRUE)
  
  doctoral_schools <- xml_find_all(page, ".//datafield[@tag='711' or @tag='712']") %>% xml_find_all(., ".//subfield[@code='4' and text()='996']")
  doctoral_school_name <- xml_parent(doctoral_schools) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  doctoral_school_idref <- xml_parent(doctoral_schools) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  laboratories <- xml_find_all(page, ".//datafield[@tag='711' or @tag='712']") %>% xml_find_all(., ".//subfield[@code='4' and text()='981']")
  laboratory_name <- xml_parent(laboratories) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  laboratory_idref <- xml_parent(laboratories) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  research_partners <- xml_find_all(page, ".//datafield[@tag='711' or @tag='712']") %>% xml_find_all(., ".//subfield[@code='4' and text()='985']")
  research_partner_name <- xml_parent(research_partners) %>% xml_find_all(".//subfield[@code='a']") %>% xml_text_in_list()
  research_partner_idref <- xml_parent(research_partners) %>% xml_find_all(".//subfield[@code='3']") %>% xml_text_in_list()
  
  ### Assemble Metadata into Tibble------------
  tibble <- tibble(url,
                   source,
                   nnt,
                   title_fr,
                   title_en,
                   language,
                   language_2,
                   year_defence,
                   abstract_fr,
                   abstract_en,
                   country,
                   rameaux_topic,
                   rameaux_topic_idref,
                   topic,
                   topic_language,
                   field,
                   type,
                   other_type_info,
                   author_name,
                   author_firstname,
                   author_idref,
                   supervisor_name,
                   supervisor_firstname,
                   supervisor_idref,
                   reviewer_name,
                   reviewer_firstname,
                   reviewer_idref,
                   president_name,
                   president_firstname,
                   president_idref,
                   member_name,
                   member_firstname,
                   member_idref,
                   institution_defence_name,
                   institution_defence_idref,
                   institution_defence_from_info_name,
                   doctoral_school_name,
                   doctoral_school_idref,
                   laboratory_name,
                   laboratory_idref,
                   research_partner_name,
                   research_partner_idref)
  
  return(tibble)
}

plan(multisession, workers = future::availableCores() - 2)
sudoc_metadata <- future_map2(.x = df_urls$url, 
                              .y = df_urls$source, 
                              .f = process_url_metadata,
                              .progress = TRUE,
                              .options = furrr_options(seed = 1234))

# Final Save of All Metadata ----------------------------------------------------------------
final_metadata <- list_rbind(sudoc_metadata)

saveRDS(final_metadata, here(FR_sudoc_raw_data_path, "sudoc_metadata.RDS"))
