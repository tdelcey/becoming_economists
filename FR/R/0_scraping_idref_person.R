################### Scraping IdRef to get individuals' data #########################

#' Purpose: This script extracts metadata about individuals (e.g., Ph.D. students, supervisors, referees)
#' associated with French theses. The data is retrieved from the IdRef API using unique IdRef 
#' identifiers available in Thèses.fr or SUDOC. The script handles both incomplete and fresh data
#' extractions, performs progressive saving, and augments the data with additional country information 
#' when applicable.
#' 
#' This script must be run after the `scripts/cleaning_scripts/FR/3_FR_merging_database.R` script, to 
#' import individuals idref.
#' 
#' The extracted data will support the standardization of individuals names and relationships 
#' in downstream processing (see `/scripts/cleaning_scripts/FR/FR_cleaning_persons.R`).


# Loading data and packages-----
pacman::p_load(here,
               httr,
               progress,
               xml2)
# Source helper functions
source(file.path("paths_and_packages.R")) # Path and packages management
source(file.path("FR", "R", "helper_functions.R")) # xml_text_in_list()

# Prepare the List of IdRefs to Search -----------------------------------------------
# Load pre-scraped thesis data and identify individuals with valid IdRefs (excluding temporary IDs).
idrefs <- readRDS(here(FR_intermediate_data_path, "thesis_person.rds")) %>%
  filter(!str_detect(entity_id, "^temp")) %>% 
  pull(entity_id) %>% 
  unique()

if("idref_persons_temp.rds" %in% list.files(here(FR_raw_data_path, "idref"))){
  message("Loading existing data")
  all_data <- readRDS(here(FR_raw_data_path, "idref", "idref_persons_temp.rds"))
  idrefs <- setdiff(idrefs, compact(all_data) %>% names()) # Skip already extracted IdRefs
} else {
  message("Creating a new object to store data")
  # We extract the list of idref for individuals
  all_data <- vector(mode = "list", length = length(idrefs))
  names(all_data) <- idrefs
}

# Setting the progress bar----------------
pb <- progress_bar$new(
  format = "  Processing [:bar] :percent in :elapsed",
  total = length(idrefs), # Total number of iterations
  width = 60
)

message(glue::glue("{length(idrefs)} persons to extract"))
for (idref in idrefs) {
  
  pb$tick() # Advance the progress bar
  
  tryCatch({
    
    # Send GET request to the URL
    url <- glue::glue("https://www.idref.fr/{idref}.rdf")
    response <- GET(url, timeout(5)) # Adding timeout to handle slow responses
    
    if(status_code(response) == 404) {
      # Handle missing IdRef entries
      all_data[[idref]] <- data <- tibble(info = list("erreur 404"))
    }
    # Check if the request was successful
    if (status_code(response) == 200) {
      # Parse the content of the response
      content <- content(response, as = "text", encoding = "UTF-8")
      xml_content <- read_xml(content)
    
    data <- tibble(
      last_name = xml_content %>%
        xml_find_all(".//foaf:familyName") %>%
        xml_text_in_list(),
      first_name = xml_content %>%
        xml_find_all(".//foaf:givenName") %>%
        xml_text_in_list(),
      gender = xml_content %>%
        xml_find_all(".//foaf:gender") %>%
        xml_text_in_list(),
      birth = xml_content %>%
        xml_find_all(".//bio:Birth //dcterms:date") %>%
        xml_text_in_list(),
      country = xml_content %>%
        xml_find_all(".//dbpedia-owl:citizenship") %>%
        xml_attr("resource") %>%
        list(),
      info = xml_content %>%
        xml_find_all(".//rdau:P60492") %>%
        xml_text() %>%
        unique() %>%
        list(),
      organization = xml_content %>%
        xml_find_all(".//org:hasMembership //foaf:Organization") %>%
        xml_text_in_list(),
      last_date_org = xml_content %>%
        xml_find_all(".//org:hasMembership") %>%
        xml_find_all(".//dcterms:date", flatten = FALSE) %>%
        map(xml_text) %>% 
        map_chr(\(x) if(length(x) == 0 || unlist(x) %in% c("", "….")) return(NA) else return(x)) %>% # to be sure to have the same number of values than organization
        list(),
      start_date_org = xml_content %>%
        xml_find_all(".//org:hasMembership") %>%
        xml_find_all(".//schema:startDate", flatten = FALSE) %>%
        map(xml_text) %>% 
        map_chr(\(x) if(length(x) == 0 || unlist(x) %in% c("", "….")) return(NA) else return(x)) %>% # to be sure to have the same number of values than organization
        list(),
      end_date_org = xml_content %>%
        xml_find_all(".//org:hasMembership") %>%
        xml_find_all(".//schema:endDate", flatten = FALSE) %>%
        map(xml_text) %>% 
        map_chr(\(x) if(length(x) == 0 || unlist(x) %in% c("", "….")) return(NA) else return(x)) %>% # to be sure to have the same number of values than organization
        list(),
      other_link = xml_content %>%
        xml_find_all(".//owl:sameAs") %>%
        xml_attr("resource") %>% 
        list())
    
    all_data[[idref]] <- data
    }
    
    # Save progress every 50 records to avoid data loss
    if (purrr::compact(all_data) %>% length %% 50 == 0) {
      saveRDS(all_data, here(FR_raw_data_path, "idref", "idref_persons_temp.rds"))
      gc() # Trigger garbage collection
    }
    
  }, error = function(e) {
    # Handle scraping errors gracefully
    warning(glue::glue("\\n Error for {idref}: {e$message}"))
    
    all_data[[idref]] <- NULL
  })
    
}

# Save Final Data
saveRDS(all_data, here(FR_raw_data_path, "idref", "idref_persons_temp.rds"))

# Post-Processing: Missing Data Check ------------------------------------------------
null_data <- map(all_data, is.null) %>% keep(~ . == TRUE)
if (length(null_data) > 0) {
  message(glue("{length(null_data)} individuals still have missing information."))
} else {
  message("IdRef data extraction complete.")
}

# Transform to Final Tibble
data_people <- bind_rows(all_data, .id = "idref") %>%
  mutate(date_scrap = Sys.Date())

# Extract Country Information from GeoNames ------------------------------------------
if (length(null_data) == 0) {
  message("Starting GeoNames country extraction...")
  
  geonames_id <- data_people %>%
    select(country) %>%
    mutate(country_id = str_extract(country, "\\d+")) %>%
    filter(!is.na(country_id)) %>%
    distinct() %>%
    as.data.table()
  
  # Function to Get Country Name from GeoNames API
  get_country_from_geonames <- function(url, max_retries = 5, wait_time = 2) {
    attempt <- 1
    while (attempt <= max_retries) {
      try({
        response <- GET(url, timeout(10))
        if (status_code(response) == 200) {
          content <- content(response, as = "text", encoding = "UTF-8")
          xml_content <- read_xml(content)
          country_name <- xml_content %>% xml_find_first(".//gn:officialName[@xml:lang='en']") %>% xml_text()
          if (!is.na(country_name)) return(country_name)
        }
      }, silent = TRUE)
      Sys.sleep(wait_time)
      attempt <- attempt + 1
    }
    stop("Failed to retrieve country information after multiple attempts.")
  }
  
  # Fetch Country Names
  for (id in geonames_id$country_id) {
    url <- glue("http://sws.geonames.org/{id}/about.rdf")
    geonames_id[country_id == id, country_name := get_country_from_geonames(url)]
  }
  
  # Merge Country Data with Main Table
  data_people <- data_people %>%
    left_join(geonames_id[, .(country, country_name)])
}

# Save Final IdRef Data with Country Information -------------------------------------
saveRDS(data_people, here(FR_raw_data_path, "idref", "idref_persons.rds"))