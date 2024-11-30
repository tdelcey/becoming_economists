################## Scraping Sudoc for French Dissertations #################

#' Purpose: This script scrapes the Sudoc database to retrieve the Sudoc ID for each dissertation in economics 
#' and law from 1900 to 1985 and 1968, respectively. The Sudoc ID is later used to query metadata via the Sudoc 
#' API. The script prompts the user to choose a discipline to scrape and then connects to the Sudoc database. 
#' The script can be run in background.
#' 
#' First script in the scraping pipeline for SUDOC. scraping_sudoc_api.R should be run after this script.

# Loading required paths and helper functions------------------
# - This section loads supporting paths and helper functions for setting up packages and helper routines.
source(here::here("paths_and_packages.R"))
source(here("FR", "R", "helper_functions.R"))

# Loading required packages for web scraping
p_load(RSelenium, rvest)  # Load RSelenium for browser automation and rvest for HTML parsing

# Building queries to Sudoc -------------
#' This script connects to the Sudoc database to retrieve dissertation records by filtering for theses
#' from 1900 to 1985 in economics and from 1900 to 1968 in law. Since economics theses often cross into
#' law in France, we search for records in both disciplines. The script extracts the Sudoc ID for each 
#' dissertation to be used in further metadata extraction.

# Define time periods for each discipline
first_year_econ <- 1900
last_year_econ <- 1985
first_year_law <- 1900
last_year_law <- 1968  # Limited to 1968 for law, as economics departments existed by then

# Predefined URLs for querying economics and law theses in Sudoc
# url economics: "Note de thèse" = "econo*", with * being a wildcard
sudoc_url_econ <- glue("https://www.sudoc.abes.fr/cbs//DB=2.1/SET=28/TTL=10/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=econo*&ACT1=-&IKT1=63&TRM1=&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=4&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=fr&ADI_JVU={first_year_econ}-{last_year_econ}&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+")

# url law: "droit" in "Note de Thèse" + "econo*" in title
sudoc_url_law <- glue("https://www.sudoc.abes.fr/cbs//DB=2.1/SET=31/TTL=1/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=droit&ACT1=*&IKT1=4&TRM1=econo*&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=1016&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=fr&ADI_JVU={first_year_law}-{last_year_law}&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+")

# Determine the discipline to scrape (either "economics" or "law")
if (exists("discipline")) { 
  user_choice <- discipline  # Use pre-defined discipline if running in background
} else { 
  user_choice <- get_discipline_to_scrape()  # Prompt user interaction if running directly
}

# Select URL and year range based on the discipline choice 
sudoc_url <- if (user_choice == "economics") sudoc_url_econ else sudoc_url_law
first_year <- if (user_choice == "economics") first_year_econ else first_year_law
last_year <- if (user_choice == "economics") last_year_econ else last_year_law

# Connecting to Sudoc----------
# Establish connection to RSelenium for web scraping
remDr <- rsDriver(browser = "firefox", port = 4444L, chromever = NULL)
browser <- remDr[["client"]]
browser$maxWindowSize()
browser$navigate(sudoc_url)
Sys.sleep(1)  # Allow time for page to load

# Move to the next page to retrieve the correct URL for the search results
browser$findElement("css selector", ".header > span:nth-child(24) > a:nth-child(1) > span:nth-child(1)")$clickElement()
Sys.sleep(1)
current_url <- browser$getCurrentUrl()[[1]] %>% 
  str_remove("[:digit:]{2}$") %>% 
  str_replace("NXT", "SHW")

# Retrieve the number of documents to construct URLs for pagination
page_html <- browser$getPageSource()[[1]] %>% 
  read_html()
number_of_doc <- page_html %>% 
  html_elements("td.result") %>% 
  html_elements("span") %>% 
  .[2] %>% 
  html_text() %>% 
  str_extract("[:digit:]+") %>% 
  as.integer()

pages <- str_c(current_url, seq(1, number_of_doc))  # List of all result pages URLs

# Loop through each page to retrieve dissertation links
#' Each page is visited to extract a permanent link for each thesis, which is later used to query
#' metadata via the Sudoc API. If Sudoc session expires, the script reinitializes the session by starting
#' where it has been saved for the last time.

# Check if URLs are already saved for this session, and create the object if needed
if (glue("sudoc_urls_{user_choice}_{first_year}-{last_year}.RDS") %in% list.files(FR_sudoc_raw_data_path)) {
  urls <- readRDS(here(FR_sudoc_raw_data_path, glue("sudoc_urls_{user_choice}_{first_year}-{last_year}.RDS")))
} else {
  urls <- vector(mode = "character", length = length(pages))
}

# Initialize counter for resuming on error
k <- length(which(urls != ""))

for(i in (k + 1):length(pages)){
  tryCatch({
    # Navigate to page and extract link to each dissertation
    browser$navigate(pages[i])
    Sys.sleep(runif(1, 1, 2))
    page_html <- browser$getPageSource()[[1]] %>% 
      read_html()
    urls[i] <- page_html %>% 
      html_elements("span tr:nth-child(1) .rec_title .link_gen") %>% 
      html_attr("href")
    
    if(urls[i] == "") { # Refresh session if link extraction fails due to Sudoc session expiration
      browser$navigate(sudoc_url)
      Sys.sleep(runif(1, 1, 2))
      browser$findElement("css selector", ".header > span:nth-child(24) > a:nth-child(1) > span:nth-child(1)")$clickElement()
      Sys.sleep(runif(1, 1, 2))
      browser$navigate(pages[i])
      
      page_html <- browser$getPageSource()[[1]] %>% 
        read_html()
      urls[i] <- page_html %>% 
        html_elements("span tr:nth-child(1) .rec_title .link_gen") %>% 
        html_attr("href")
      
      if(urls[i] == "") {
        urls[i] <- "page problem" 
        message(glue::glue("page problem with {pages[i]}"))
      }
    }
    # Save progress every 100 pages or at the last page
    if (i %% 100 == 0 | i == length(pages)) {
      saveRDS(urls,
              here(FR_sudoc_raw_data_path, glue("sudoc_urls_{user_choice}_{first_year}-{last_year}.RDS")))
    }
    
  }, error = function(e) {
    urls[i] <- "page problem"
    message(glue::glue("page problem with {pages[i]}"))
  })
}

# Final save of URLs after loop completes
saveRDS(urls,
        here(FR_sudoc_raw_data_path, glue::glue("sudoc_urls_{user_choice}_{first_year}-{last_year}.RDS")))
remDr$server$stop()  # Stop RSelenium server