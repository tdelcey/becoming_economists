################### Scraping IdRef to Get Institutions' Data #########################

#' Purpose: This script extracts metadata about institutions (e.g., universities, laboratories, doctoral schools)
#' associated with French theses. Using IdRef identifiers, the script retrieves:
#' - Institution names (preferred and alternate)
#' - Linked institutions (predecessors, successors, subordinates)
#' - Dates of activity
#' - Country information
#' 
#' This script must be run after the `/FR/merging_sudoc_thesesfr.R` script, to 
#' import institutions idref.
#'
#' The extracted data will support the standardization of institution names and relationships 
#' in downstream processing (see `/FR/R/cleaning_institutions.R`).

# Load Required Libraries and Scripts ------------------------------------------------
pacman::p_load(here, httr, progress, xml2, glue, tibble, purrr, data.table, dplyr)

# Source helper functions
source(file.path("paths_and_packages.R"))
source(file.path("FR", "R", "helper_functions.R")) # Includes `xml_text_in_list`


# Load List of IdRefs for Institutions -----------------------------------------------
idrefs <- readRDS(here(FR_intermediate_data_path, "thesis_institution.rds")) %>% 
  filter(! str_detect(entity_id, "^temp")) %>% 
  pull(entity_id) %>% 
  unique()

# Initialize or Load Storage for Data ------------------------------------------------
# If all_data exist, it means that we have potentially a unfinished object and we want to 
# know the idref we still need to extract. If not, we create the object

if("idref_institutions_temp.rds" %in% list.files(here(FR_raw_data_path, "idref"))){
  all_data <- readRDS(here(FR_raw_data_path, "idref", "idref_institutions_temp.rds"))
  
  # For institutions, we want to retrieve additional institutions which are linked to the institutions
  # we have already extracted, in order to extend our list and improve cleaning of institutions later
  if("idref_institutions.rds" %in% list.files(here(FR_raw_data_path, "idref"))){
    idref_institutions <- readRDS(here(FR_raw_data_path, "idref", "idref_institutions.rds"))
    
    # What are the institutions id we have already collected?
    existing_idrefs <- idref_institutions %>% 
      pull(entity_id) %>% 
      c(., idrefs) %>% 
      unique()
    
    # What are the new institutions id we don't have already collected?
    new_idrefs <- idref_institutions %>% 
      select(predecessor_idref, successor_idref, subordinated_idref, unit_of_idref) %>% 
      mutate(across(where(is.character), ~as.list(.))) %>% 
      pivot_longer(everything()) %>% 
      unnest(value) %>% 
      filter(! is.na(value)) %>% 
      distinct(value) %>% 
      filter(! value %in% existing_idrefs) %>% 
      pull(value)
    
    # Create a second list with new_idrefs initialized to NULL
    new_data <- vector(mode = "list", length = length(new_idrefs))
    names(new_data) <- new_idrefs
  }
  
  # Check missing idrefs from previous extraction and add the new id collected
  missed_idrefs <- map(all_data, is.null) %>% 
    .[. == TRUE] %>% 
    names()
  
  all_data <- c(all_data, new_data)
  all_data <- all_data[-which(duplicated(names(all_data)))] # avoid creating duplicates
  idrefs <- setdiff(idrefs, compact(all_data) %>% names()) %>% 
    c(., missed_idrefs, new_idrefs) %>% 
    unique() # Better twice than once
  
} else {
  # First run: Initialize storage for data 
  all_data <- vector(mode = "list", length = length(idrefs))
  names(all_data) <- idrefs
}

# Progress Bar Initialization --------------------------------------------------------
pb <- progress_bar$new(
  format = "  Processing [:bar] :percent in :elapsed",
  total = length(idrefs), # Total IdRefs to process
  width = 60
)

# Main Loop: Scraping IdRef Data -----------------------------------------------------
message(glue("{length(idrefs)} institutions to extract"))
for (idref in idrefs) {
  pb$tick() # Advance the progress bar
  
  tryCatch({
    # Send GET request to the URL
    url <- glue::glue("https://www.idref.fr/{idref}.rdf")
    response <- GET(url, timeout(20)) # Adding timeout to handle slow responses
    
    if(status_code(response) == 404) {
      all_data[[idref]] <- data <- tibble(info = list("erreur 404"))
    }
    # Check if the request was successful
    if (status_code(response) == 200) {
      # Parse the content of the response
      content <- content(response, as = "text", encoding = "UTF-8")
      xml_content <- read_xml(content)
      
      data <- tibble(
        url = url,
        scraped_id = xml_content %>%
          xml_find_all(".//dcterms:identifier") %>%
          xml_text(),
        pref_name = xml_content %>%
          xml_find_all(".//foaf:Organization //skos:prefLabel") %>%
          xml_text(),
        other_labels = xml_content %>%
          xml_find_all(".//foaf:Organization //skos:altLabel") %>%
          xml_text_in_list(),
        country = xml_content %>%
          xml_find_all(".//foaf:Organization //dbpedia-owl:citizenship") %>%
          xml_attr("resource") %>% 
          list(),
        date_of_birth = xml_content %>%
          xml_find_all(".//rdau:P60524") %>%
          xml_text_in_list(),
        date_of_death = xml_content %>%
          xml_find_all(".//rdau :P60525") %>%
          xml_text_in_list(),
        information = xml_content %>%
          xml_find_all(".//rdau:P60492") %>%
          xml_text_in_list(),
        replaced_idref = xml_content %>% 
          xml_find_all(".//dcterms:replaces") %>% 
          xml_attr("resource") %>%
          str_extract(., "\\d+[A-z]*") %>%
          list(),
        predecessor = xml_content %>%
          xml_find_all(".//rdau:P60683 //skos:label") %>%
          xml_text_in_list(),
        predecessor_idref = xml_content %>%
          xml_find_all(".//rdau:P60683 //foaf:Organization") %>% 
          xml_attr("about") %>% 
          str_extract(., "\\d+[A-z]*") %>% 
          list(),
        successor = xml_content %>%
          xml_find_all(".//rdau:P60686 //skos:label") %>%
          xml_text_in_list(),
        successor_idref = xml_content %>%
          xml_find_all(".//rdau:P60686 //foaf:Organization") %>% 
          xml_attr("about") %>% 
          str_extract(., "\\d+[A-z]*") %>% 
          list(),
        subordinated = xml_content %>%
          xml_find_all("//org:hasUnit //skos:label") %>%
          xml_text_in_list(),
        subordinated_idref = xml_content %>%
          xml_find_all("//org:hasUnit //foaf:Organization") %>% 
          xml_attr("about") %>% 
          str_extract(., "\\d+[A-z]*") %>% 
          list(),
        unit_of = xml_content %>%
          xml_find_all("//org:unitOf //skos:label") %>%
          xml_text_in_list(),
        unit_of_idref = xml_content %>%
          xml_find_all("//org:unitOf //foaf:Organization") %>% 
          xml_attr("about") %>% 
          str_extract(., "\\d+[A-z]*") %>% 
          list(),
        other_link = xml_content %>%
          xml_find_all(".//owl:sameAs") %>%
          xml_attr("resource") %>% 
          list()
      )
      
      all_data[[idref]] <- data
    }
    
    if (purrr::compact(all_data) %>% length %% 50 == 0) {
      saveRDS(all_data, here(FR_raw_data_path, "idref", "idref_institutions_temp.rds"))
      gc()
    }
    
  }, error = function(e) {
    
    warning(glue::glue("\\n Error for {idref}: {e$message}"))
    
    all_data[[idref]] <- NULL
  })
  
}

# Final save of temporary data
saveRDS(all_data, here(FR_raw_data_path, "idref", "idref_institutions_temp.rds"))

# Post-processing collected data---------------
# select names of vectors that are null
null_data <- map(all_data, is.null) %>% 
  .[. == TRUE]

# final tibble 
data_institutions <- bind_rows(all_data, .id = "entity_id") 

col_to_unnest <- map(data_institutions, ~map(., ~length(.) < 2)) %>% 
  map_lgl(., ~all(.) == TRUE) %>% 
  .[. == TRUE] %>% 
  names()

data_institutions <- data_institutions %>%
  unnest(cols = all_of(col_to_unnest), keep_empty = TRUE)

nb_new_id <- data_institutions %>% 
  select(predecessor_idref, successor_idref, subordinated_idref, unit_of_idref) %>% 
  mutate(across(where(is.character), ~as.list(.))) %>% 
  pivot_longer(everything()) %>% 
  unnest(value) %>% 
  filter(! is.na(value)) %>% 
  distinct(value) %>% 
  filter(! value %in% c(data_institutions$entity_id, idrefs)) %>% 
  nrow()

message(glue::glue("{nb_new_id} new institutions discovered!"))

if(length(null_data) > 0 | nb_new_id > 0){
  message(glue::glue("{length(null_data) + nb_new_id} institution(s)' information are still missing"))
} else {
  message("Extraction of institutions idref is complete")
}

# Extract Countries--------------------

if(length(null_data) == 0 & nb_new_id == 0){# To be launched when all institutions collected
  message("Launching extraction of country information")
geonames_id <- data_institutions %>% 
  select(country) %>% 
  mutate(country_id = str_extract(country,"\\d+")) %>% 
  filter(!is.na(country_id)) %>% 
  unique() %>% 
  as.data.table()

get_country_from_geonames <- function(url, max_retries = 5, wait_time = 2) {
  attempt <- 1
  
  while (attempt <= max_retries) {
    try({
      # Send GET request to the URL
      response <- GET(url, timeout(10)) # Adding timeout to handle slow responses
      
      # Check if the request was successful
      if (status_code(response) == 200) {
        # Parse the content of the response
        content <- content(response, as = "text", encoding = "UTF-8")
        xml_content <- read_xml(content)
        
        # Extract country name
        country_name <- xml_content %>% 
          xml_find_first(".//gn:officialName[@xml:lang='en']") %>% 
          xml_text()
        
        if (!is.na(country_name) && country_name != "") {
          return(country_name)
        } else {
          stop("Country information not found.")
        }
      }
    }, silent = TRUE)
    
    # Wait before the next attempt
    Sys.sleep(wait_time)
    attempt <- attempt + 1
  }
  
  stop("Failed to retrieve the country information after multiple attempts.")
}

# Extracting all the country names
for(id in geonames_id$country_id){
  url <- glue::glue("http://sws.geonames.org/{id}/about.rdf")
  geonames_id[country_id == id, country_name := get_country_from_geonames(url)]
}

# Merging with original data
data_institutions <- data_institutions %>% 
  left_join(geonames_id[, .(country, country_name)])
}

saveRDS(data_institutions, here(FR_raw_data_path, "idref", "idref_institutions.rds"))
