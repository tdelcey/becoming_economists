################## Scraping Sudoc for French Dissertations #################

source("0_paths_and_packages.R")
sudoc_path <- here(data_path,
                   "raw_data",
                   "FR",
                   "sudoc")
# Connection to Sudoc
#' We use an url with preformated request in Sudoc. The strategy is to filter by thesis only,
#' to look at the category "notes de thèses" for filtering economics, and to only get what 
#' is between 1946 and 1984 (after there is thèse.fr)
#' 
#' When scraping, temporary data are save here:
#' `sudoc_data <- readRDS(here(sudoc_path, "sudoc_data.RDS"))`

# We enter the basic url of the search
first_year <- 1920
last_year <- 1970

#url: economie, economique, economiques, econ.
#sudoc_url <- "http://www.sudoc.abes.fr/cbs//DB=2.1/SET=7/TTL=10/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&IKT0=63&TRM0=economie&ACT1=%2B&IKT1=63&TRM1=economique&ACT2=%2B&IKT2=63&TRM2=economiques&ACT3=%2B&IKT3=1016&TRM3=econ.&SRT=YOP&ADI_TAA=&ADI_LND=&ADI_JVU={first_year}-{last_year}&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+&screen_mode=Recherche"


#url droit
#sudoc_url <- glue::glue("http://www.sudoc.abes.fr/cbs//DB=2.1/SET=12/TTL=10/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=Droit&ACT1=%2B&IKT1=63&TRM1=&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=1016&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=&ADI_JVU={first_year}-{last_year}&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+")



# Connecting to RSelenium
remDr <- rsDriver(browser = "firefox",
                  port = 4448L,
                  chromever = NULL)
browser <- remDr[["client"]]
browser$maxWindowSize()
browser$navigate(sudoc_url)
Sys.sleep(1)

# We move to the next page, to get the proper url
browser$findElement("css selector", ".header > span:nth-child(24) > a:nth-child(1) > span:nth-child(1)")$clickElement()
Sys.sleep(1)
current_url <- browser$getCurrentUrl()[[1]] %>% 
  str_remove("[:digit:]{2}$") %>% 
  str_replace("NXT", "SHW") # bibliographical reference are indexed dependeing on our initial research

page_html <- browser$getPageSource()[[1]] %>% 
  read_html()
number_of_doc <- page_html %>% # We extract the number of documents for the loop
  html_elements("td.result") %>% 
  html_elements("span") %>% 
  .[2] %>% 
  html_text() %>% 
  str_extract("[:digit:]+") %>% 
  as.integer

pages <- str_c(current_url, seq(1, number_of_doc)) # that's the list of all the url of our references

# We fix the list of labels we want (that's not the complete name of the label on the website)
wanted_labels <- tribble(
  ~ match_value, ~ column,
  "Identifiant", "sudoc_url",
  "Titre", "title",
  "Date", "date",
  "Auteur", "author",
  "Thèse", "thesis_information",
  "Sujets", "topics",
  "Langue", "language",
  "Pays", "country",
  "Résumé", "abstract",
  "Num.", "thesis_national_number")

extract_info_sudoc <- function(label){ # The funciton extract the corresponding info depending on label
  info <- data_html %>% 
    .[str_which(labels_in_html, label)] %>% 
    html_text2() %>% 
    .[1] %>% # This is necessary just because you have an ambiguity with "Titre" for very few references
    str_extract(regex("(?<=\u000A\u0009\u000A).*", dotall = TRUE))
  return(info)
}

#sudoc_data <- readRDS(here(sudoc_path, "sudoc_data_new.RDS")) 
sudoc_data <- list()
k = length(sudoc_data)

# Loop on all the pages
for(i in pages[(k + 1):length(pages)]){
  k = k + 1 # used only for saving regularly the list to avoid problems
  browser$navigate(i)
  Sys.sleep(runif(1, 1, 2))
  page_html <- browser$getPageSource()[[1]] %>% 
    read_html()
  data_html <- page_html %>% 
    html_elements("body div.lrmargin table tbody tr td div span table tbody tr") # that's the basic part of the html where information is (we don't want to do it each time)
  
  labels_in_html <- data_html %>% #that's the list of the labels (Author, title, etc...)
    html_elements("td.rec_lable") %>% 
    html_text()
  
  # Checking for each page which labels we have, in case the structure change (for instance we don't always have abstract)
  existing_labels <- labels_in_html[str_which(labels_in_html, paste0(wanted_labels$match_value, collapse = "|"))] %>% 
    str_extract(paste0(wanted_labels$match_value, collapse = "|")) %>% 
    unique()
  
  # Loop for extracting all the information present in the page
    data <- tibble(.rows = 1)
  for(j in seq_along(existing_labels)){
    column <- wanted_labels %>% 
      mutate(match_value = str_replace(match_value, "\\.", " ")) %>% 
      filter(str_detect(match_value, existing_labels[j])) %>% 
      pull(column)
    data <- data  %>% 
      mutate({{column}} := extract_info_sudoc(existing_labels[j]))
  }
    sudoc_data[[i]] <- data
    
    # Precautionnary saving
    if(k %in% seq(100, number_of_doc, 100)){
      saveRDS(sudoc_data,
              here(sudoc_path, "sudoc_data_new.RDS"))
      print(k)
      print(data$date)
    }
    if(length(data) == 0){ # if it fails, we stop the loop and relaunch the research
      message(glue::glue(
        "Stop at {k}: page is not loaded"
      ))
      browser$navigate(sudoc_url)
      k <- k - 1
      break
    }
}

sudoc_data_copy <- bind_rows(sudoc_data) %>% 
#  mutate(date = ifelse(is.na(date), tate, date)) %>%  #' To correct an error in the column name in the first scrapping.
  unique()

saveRDS(sudoc_data_copy,
        here(sudoc_path, glue::glue("sudoc_data_{first_year}-{last_year}.RDS")))

