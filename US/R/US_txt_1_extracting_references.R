#' ---
#' title: "Script for building the US thesis database"
#' author: "Aurélien Goutsmedt and Thomas Delcey"
#' date: "/ Last compiled on `r format(Sys.Date())`"
#' output: 
#'   github_document:
#'     toc: true
#'     number_sections: true
#' ---
#' 
#' # What is this script for?
#' 
#' This script aims at extracting the text from all the AER/JEL `.txt` with the list
#' of phd dissertations. We remove or classify in other columns all the information in the
#' `.txt` that are not part of the reference of a dissertation. The next [script](/script/US_txt_2_creating_references.md)
#' will put all the lines about the same dissertation on one line. 
#' 
#' > WARNING: This script still needs a lot of cleaning
#' 
#+ r setup, include = FALSE
knitr::opts_chunk$set(eval = FALSE)

#' # Loading packages, paths and data
#' 

source("cleaning_data/0_paths_and_packages.R")
  
#' # Creating the database
#' 
#' ## Extracting the text
#' 
#' We extract all `.txt` and create a data.frame with one line per row. Then, we
#' merge all the data.frames together. 

corpus_raw <- data.frame("doc_id" = c(), "Year" = c(), "text" = c())
list_txt_US <- list.files(path = US_txt_raw_data_path)

for (i in 1:length(list_txt_US)){
  document_text <- read_delim(here(US_txt_raw_data_path, list_txt_US[i]), delim = "\n")
  year <- str_extract(list_txt_US[i], "[:digit:]{4}")
  document <- cbind(i, year, document_text)
  colnames(document)  <- c("doc_id","Year","text")
  
  corpus_raw <- rbind(corpus_raw,document) %>% 
    mutate(text = str_replace_all(text, "\f","")) %>% 
    as.data.table() 
}

corpus_raw <- corpus_raw %>% 
  mutate(row_number = 1:n()) %>% 
  filter(!is.na(Year))

#' Saving corpus:  
#' `saveRDS(corpus_raw, here(US_txt_intermediate_data_path, "corpus_raw"))`
#' Loading data:  
#' `corpus_raw <- readRDS(here(US_txt_intermediate_data_path, "corpus_raw"))`
#'
#' Evaluating what we have to do by looking at different years:
#' `View(corpus_raw %>% filter(Year == "1907"))`


#' ### Removing headers and footers
#' 
#' Our goal here is to remove the pages and all the header and footers
#' that we have in the text.

month <- c("January","February","March","April","May","June",
           "July","August","September","October","November","December")
header_month <- paste0("^", toupper(month), " [:digit:]{4}$")

header_bracket <- str_which(corpus_raw$text,"^\\[[ ]{0,1}[A-z]{2,}")

headers <- c("^[:digit:]{4}\\]$", # Year
             "^[:digit:]{4}$",    # Page (four numbers)
             "^[:digit:]{3}$",
             "^[:digit:]{2}$",
             #you can write the 4 first line in one line as follow "^[:digit:]{2-4}(\\])?$
             "VOL\\.[ ]{0,1}[:digit:]{1,3} NO\\.[ ]{0,1}[:digit:]{1,2}$", # Volume info
             "Terms and Conditions",
             "^\\[[ ]{0,1}[A-z]{2,}",
 #            "^[:digit:]{4}[\\]]{0,1} Accounting", # special case where the name of the category (Accounting, Business Methods...) is so long that it is on the same line than page and year
             header_month)
headers_raw <- str_which(corpus_raw$text,paste0(headers, collapse = "|"))

#' We create a special column with headers. We have some headers that are too hard
#' to identify, like for instance the category of the dissertation which are in odd
#' pages header for some years. These particular headers are situated between
#' the month of the publication, and the page, and thus we can spot them (if line i
#' and line i + 2 are header, it means that i + 1 is also a header).

corpus_raw$header <- "FALSE"
corpus_raw[headers_raw]$header <- "TRUE"

for(i in headers_raw){
  if(corpus_raw[i + 2]$header == TRUE){
    corpus_raw[i + 1]$header <- TRUE
  }
}

#' We add manually some headers that we have identified and cannot remove 
#' with the method above.

to_remove <- c("^THE AMERICAN ECONOMIC REVIEW$","^THE ECONOMIC BULLETIN$",
               "^Journal of Economic Literature$","^LIST OF DOCTORAL DISSERTATIONS$",
               "^Doctoral Dissertations$", "^Doctored Dissertations$",
               "DOCTORAL DISSERTATIONS",
               "^This content downloaded","^All use subject to")

header_to_remove <- str_which(corpus_raw$text, paste0(to_remove, collapse = "|"))
corpus_raw[header_to_remove]$header <- "TRUE"

corpus_raw <- corpus_raw[header == FALSE]


#' ### General cleaning
#' 
#' We remove all the ^ and * that are at the beginning of a line.
corpus_raw <- corpus_raw[, text := str_remove(text, "^\\^|^\\*|^♦|^II\\. |^\\.|^''|^'|^\\\\r\\.")]
corpus_raw <- corpus_raw[, text := str_trim(text, "both")]

#' Contingent cleaning
#' 
#' Here are some minor corrections due to mistake in the pdf or things that 
#' cannot be done automatically.

corpus_raw <- corpus_raw[, text := str_replace(text, "Hattori, Bunshiro", "Hattori Bunshiro")]
corpus_raw <- corpus_raw[, text := str_replace(text, "H. Wirt Steele\\.", "H. Wirt Steele,")] 
corpus_raw <- corpus_raw[, text := str_replace(text, "Wjrt ", "Wirt ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "A jit ", "Ajit ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "hx-ERY", "Henry")]
corpus_raw <- corpus_raw[, text := str_replace(text, "\\(Charles\\)", "Charles")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Van deb Merwe", "Van der Merwe")]
corpus_raw <- corpus_raw[, text := str_replace(text, "D unstone ", "Dunstone ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "J uni a ", "Junia ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Aran k a ", "Aranka ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Go st a ", "Gosta ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Wend all ", "Wendall ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Lauck lin ", "Laucklin ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "zVlexander ", "Alexander ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "'Wiuaa\\.di  ", "Wiuaadi ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Edith a ", "Edith A\\. ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "7,\\. T\\. Egartner", "Z. T. Egartner")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Overlach\\.", "Overlach,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Murchie\\.", "Murchie,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Nolen\\.", "Nolen,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Oswald\\.", "Oswald,")] 
corpus_raw <- corpus_raw[, text := str_replace(text, "Alley\\.", "Alley,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Voorhis\\.", "Voorhis,")] 
corpus_raw <- corpus_raw[, text := str_replace(text, "Villaume\\.", "Villaume,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Cudmore\\.", "Cudmore,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Grasberg\\.", "Grasberg,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Oscar W\\. Junek", "Oscar W. Junek")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Francis A\\. Staten", "Francis A. Staten")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Sullivan\\.", "Sullivan,")]
corpus_raw <- corpus_raw[, text := str_replace(text, "kLZABA\\.", "Klzaba")]
corpus_raw <- corpus_raw[, text := str_replace(text, "I,evi", "Levi")]
corpus_raw <- corpus_raw[, text := str_replace(text, "''Wslson", "Wilson")]
corpus_raw <- corpus_raw[, text := str_remove(text, "yffiiAAKM\\.")]
corpus_raw <- corpus_raw[, text := str_remove(text, "Mrs. ")] 
corpus_raw <- corpus_raw[, text := str_replace(text, "6. Vineberg", "S. Vineberg")] 
corpus_raw <- corpus_raw[, text := str_replace(text, "‘William Blakeman", "William Blakeman")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Willi am ", "William ")]
corpus_raw <- corpus_raw[, text := str_replace(text, "Y ale U niv er si ty", "Yale University")]
corpus_raw[str_which(text, "Restriction of immigraHenry"), text := "Henry P. Fairchild, A.B., Doane College, 1900. Restriction of immigration"]

#' Saving corpus: 
#' `saveRDS(corpus_raw, here(US_txt_intermediate_data_path, "corpus_raw_cleaned"))`
#' Loading data:  
#' `corpus_raw <- readRDS(here(US_txt_intermediate_data_path, "corpus_raw_cleaned"))`


#' # Extracting University and category information
#' 
#' The goal of this section is to clean `corpus_raw_cleaned` by excluding all non-necessary information
#' and by putting information in the titles of the documents (like university until 1911, and category/JEl 
#' code after) in separate columns. At the end, the `text` column should only contain information about
#' individual dissertations.
#' 
#' We divide our corpus in 4 parts:
#' 
#' - 1906-1911: dissertations are classified according to the University to which
#' the phd student is affiliated
#' - 1911-1968: dissertations are classified according to the category/theme of the dissertation
#' - 1969-1990: the original pdf are on two columns (which change the strategy to identify categories) and
#' dissertations are classified according to the pre-1991 JEL categorisation
#' - 1991-2021: still two columns, but new JEL code classification (easier to identify because of the 
#' use of the letter/code at the beginning of the category title)
#' 
#' ## 1st framework: 1906-1911
#' 
#' From 1906 to 1911, the meta-title are the universities (like "UNIVERSITY."). 
#' Our first goal is to identify the meta-title, that is, here, the name of the
#' universities. It will allow us first to remove everything before the beginning
#' of the list.
#' 

db_period1 <- data.table("doc_id" = c(),
                         "Year" = c(),
                         "text" = c(),
                         "university" = c())

for(i in 1906:1911){
db <- corpus_raw[Year == i]

#' We correct the line with an error in Bryn Mawr in 1906. Then, we use the position
#' of Bryn Mawr (the first university) to delete everything before.
db[str_which(db$text, "BRYN MAWR")]$text <- "BRYN MAWR"

if(length(str_which(db$text, "BRYN MAWR")) > 0){
db <- db[-(1:(str_which(db$text, "BRYN MAWR")-1))]
} else {
db <- db[-(1:(str_which(db$text, "COLUMBIA")-1))]  
}

university <- data.table(university = str_extract(db$text, "^[A-Z ]{2,}[:punct:]{0,1}$"),
                           id_univ = "NA") %>% 
  .[! is.na(university)]
university$id_univ <- 1:length(university$university)

# Now we use a cumulative sum each time we encouter a meta-title, and use this
# to add the name of the university.
db <- db %>% 
  mutate(id_univ = cumsum(str_detect(text, 
                                     paste0(university$university, collapse = "|")))) %>% 
  left_join(university) %>%
  mutate(university = str_trim(str_remove(university, "[:punct:]"), "both")) %>% 
  select(-id_univ)  %>% 
  as.data.table()

remove_univ <- str_which(db$text, paste0(university$university, collapse = "|"))

db <- db[-remove_univ]

db_period1 <- rbind(db_period1, db)
}

#' ## 2nd framework: 1912-1968
#' 
category <- data.table("Year" = c(),
                       "text" = c())

for(i in c(1912:1914,1916:1945,1947:1968)){ # We don't have 1915 and 1946. This process works until we have two columns in 1969.
  db <- corpus_raw[Year == i]
  
#  if(length(str_which(db$text, "Theory and Its History")) > 0){
#    db <- db[-(1:(str_which(db$text, "Theory and Its History")[1]-1))]
#  } else {
#    db <- db[-(1:(str_which(db$text, "Economic Theory;")-1))]  
#  }
  is_category <- db[str_which(db$text, "^[A-Z][a-z]+[ ,;]"), c("Year","text")]
  is_category <- is_category[! str_which(is_category$text, "\\.")]
  is_category <- is_category[! str_which(is_category$text, "[:digit:]")]
  is_category <- is_category[str_which(is_category$text, "[A-z]+$")]
  is_category <- is_category[str_count(text, "\\w+") < 9]
  
  category <- rbind(category, is_category)
}

not_category <- c("Land; Housing",
                  "Frederic Earnest",
                  "North Carolina",
                  "Thomas and John",
                  "Gaines Thomson Cartin",
                  "Universities",
                  "Published by",
                  "Review",
                  "state movement",
                  "^An analysis",
                  "^Degree",
                  "Licentiate",
                  "Method to the",
                  "Puerto Rican",
                  "The use of",
                  "^Theses",
                  "^Thesis")
to_remove <- str_which(category$text, paste0(not_category, collapse = "|"))
category <- category[-to_remove][,-"Year"] %>% 
  unique()

#' We add the category that have more than 8 words and that we have excluded first.
add_category <- c("Price and Allocation Theory; Income and Employment Theory; Related")
category <- rbind(category, add_category, use.names = FALSE)

#' We clean the names of the category to unify them (but we will exchange the spotted category for the cleaned
#' one later).
#' 
category$category <- category$text
category[text == "Economic Geography; Regional Planning; Urban"]$category <- "Economic Geography; Regional Planning; Urban Land; Housing"
category[text == "Pubic Finance, Taxation, and Tariff"]$category <- "Public Finance, Taxation, and Tariff"
category[text == "Securities Markets"]$category <- "Business Finance; Insurance; Investments; Securities Markets"
category[text == "Security Markets; Insurance"]$category <- "Business Finance; Insurance; Investments; Securities Markets"
category[text == "Socialism and Co-operative Enterprises"]$category <- "Socialism and Cooperative Enterprises"
category[text == "Capital and Capitalistic Organization"]$category <- "Capital and Capitalistic Organizations"
category[text == "Labor and Labor Oganizations"]$category <- "Labor and Labor Organizations"
category[text == "Transportation and Communication"]$category <- "Transportation and Communications"
category[text == "Economic History; National Economics"]$category <- "Economic History; National Economies"
category[text == "Economic Systems; Post-War Planning"]$category <- "Economic Systems; Postwar Planning"
category[text == "Industrial Organization; Public Regulation o£ Business"]$category <- "Industrial Organization; Public Regulation of Business"
category[text == "National Economies"]$category <- "Economic History; Economic Development; National Economies"
category[text == "National Economies; Economic Development; National"]$category <- "Economic History; Economic Development; National Economies"

category[str_which(text, "Fisheries$")]$category <- "Agriculture, Mining, Forestry and Fisheries"
category[str_which(text, "Accounting, Business Methods")]$category <- "Accounting, Business Methods, Investments, and the Exchanges"
category[str_which(text, "^Trade,")]$category <- "Trade, Commerce, and Commercial Crises"
category[str_which(text, "^Business Finance; ")]$category <- "Business Finance; Insurance; Investments; Securities Markets"
category[str_which(text, "^Land Economics; ")]$category <- "Land Economics; Agricultural Economics; Economic Geography; Housing"
category[str_which(text, "^Economic Geography; ")]$category <- "Land Economics; Agricultural Economics; Economic Geography; Housing"
category[str_which(text, "^Money, Credit and Banking")]$category <- "Money and Banking; Short-Term Credit; Consumer Finance"
category[str_which(text, "History of Economic Thought")]$category <- "Price and Allocation Theory; Income and Employment Theory; Related Empirical Studies; History of Economic Thought" 
category[str_which(text, "Industry Studies")]$category <- "Industrial Organization; Government and Business; Industry Studies" 


#' We identify all the lines with a category, and we give all lines under this category 
#' (and above the next one), the name of the category.

db_period2 <- data.table("doc_id" = c(),
                         "Year" = c(),
                         "text" = c(),
                         "category" = c())
for(i in c(1912:1914,1916:1945,1947:1968)){ # We don't have 1915 and 1946
  db <- corpus_raw[Year == i]
  category_row <- str_which(db$text, paste0("^",category$text,"$", collapse = "|"))
  db$category <- "NA"
  
  for(i in 1:(length(category_row)-1)){
    db[category_row[i]:(category_row[i+1]-1)]$category <- db[category_row[i]]$text
  }
  
  db[category_row[length(category_row)]:length(db$text)]$category <- db[category_row[length(category_row)]]$text
  db <- db[-category_row]
  db_period2 <- rbind(db_period2, db)
}

db_period2 <- db_period2[category != "NA"]

#' We do exactly the same as above, but for the status of the thesis
thesis_status_row <- str_which(db_period2$text, "^Degree|^Theses|^Thesis")
db_period2$status <- "NA"

for(i in 1:(length(thesis_status_row)-1)){
  db_period2[thesis_status_row[i]:(thesis_status_row[i+1]-1)]$status <- db_period2[thesis_status_row[i]]$text
}

db_period2[thesis_status_row[length(thesis_status_row)]:length(db_period2$text)]$status <- db_period2[thesis_status_row[length(thesis_status_row)]]$text
db_period2 <- db_period2[-thesis_status_row]

#' We now clean thesis status
#' 

db_period2[str_which(status, "Completed")]$status <- "Thesis Completed and Accepted"
db_period2[str_which(status, "Preparation")]$status <- "Thesis in Preparation"
db_period2[str_which(status, "Degree")]$status <- "Degree conferred"

#' We now merge the category with the cleaned categories
db_period2 <- merge(db_period2, category[,c("text","category")], by.x = "category", by.y = "text", all.x = TRUE)


#' We will now merge the table for 1912-1965 with the first table.
db_period2 <- db_period2[, c("doc_id","Year","text","row_number", "category.y","status")][order(row_number)]
setnames(db_period2, "category.y","category") 

db_period1 <- db_period1[, c("doc_id","Year","text","row_number","university")]

#' ## 3rd framework: 1969-1990
#' 
#' As the pdf had two columns after 1969, the strategy to identify titles (that are now on
#' 1 to 4 lines) are different.

db <- corpus_raw %>% 
  filter(between(Year, 1969, 1990))

#' Here, we first attemp a rough identification of category, by searching for certain patterns
is_category <- db %>% 
  select(text, row_number, Year) %>% 
  filter(str_detect(text, "^[A-Z][a-z]+[ ,;]|^including |^and [A-Z][a-z]"),
        ! str_detect(text, "\\.|:|[:digit:]"),
        str_detect(text, "[A-Z][a-z]+(,|;)?$|Method­$|including$|and$")) %>% # Ne finit que rarement pas par une majuscule / special case "methodology"
  mutate(upper_case_word = str_count(text, "[A-Z][a-z]+( |$|,|;)"), # on compte les mots avec majuscules
         number_word = str_count(text, "\\w+")) %>% 
  filter(upper_case_word > 1, 
         number_word < 7) %>%  # after 7, too much chance of having two upper-case words, whereas 5 words seem to be the max for JEL code
  mutate(identified = TRUE)

#' We need to add what follows "Method-" in the next line, as it won't be match as not starting by an uppercase letter.
#' We bind the supplementary lines with what we have already match.
end_with_invisible_dash <- is_category %>% 
  filter(str_detect(text, "­$"))
end_with_invisible_dash <- data.table("row_number" = end_with_invisible_dash$row_number + 1,
                                      "identified" = TRUE)

is_category_augmented <- is_category %>% 
  select(row_number, identified) %>% 
  bind_rows(end_with_invisible_dash)

#' Now we need to look at the lines just following and just preceding a category, 
#' to be sure to have all the content of the category name.
#' We bind this with the other lines we have already identified and we join with the whole 1969-1990 corpus.
row_numbers <- setdiff(c((is_category_augmented$row_number + 1), (is_category_augmented$row_number - 1)),
                       is_category_augmented$row_number)
row_numbers <- data.table("row_number" = row_numbers,
                          "identified" = FALSE) 

is_category_augmented <- is_category_augmented %>% 
  bind_rows(row_numbers) %>% 
  arrange(row_number) %>% 
  left_join(select(db, doc_id, Year, text, row_number))

#' We give an identification to each category. Each category should contain a first line, before
#' the category, the lines of the category, and a last line, just after the category.

is_category_augmented <- is_category_augmented %>% 
  mutate(id_jel = lead(row_number, n = 1) == row_number + 1,
         id_jel = lag(id_jel, n = 1) == FALSE,
         id_jel = ifelse(is.na(id_jel), FALSE, id_jel),
         id_jel = cumsum(id_jel == TRUE)) 

#' To decide which category to keep, we look if the first line is not the first line of a reference.
#' If it is the case, it means that the category is actually a title, and not a true category. The last
#' part of a true category is directly followed by a first reference. So the last line should looks
#' like the first line of a reference.

keep_jel <- is_category_augmented %>% # absolute cheating but too difficult to take into account 
  mutate(is_name = ifelse(identified == FALSE, str_detect(text, "Ph.D.|D.B.A."), NA),
         is_name = ifelse(str_detect(text, "^and Accounting$|^and Forecasting$|^and Institutions$"), TRUE, is_name)) %>% 
  group_by(id_jel) %>% 
  mutate(first_line = row_number == min(row_number),
         last_line = row_number == max(row_number)) %>% 
  filter((is_name == FALSE & first_line == TRUE) | (is_name == TRUE & last_line == TRUE))

is_category_cleaned <- is_category_augmented %>% 
  filter(identified == TRUE & id_jel %in% keep_jel$id_jel) %>% 
  group_by(id_jel) %>% 
  mutate(category = paste(text, collapse = " "),
         category = str_remove(category, "­ ")) %>% 
  select(-identified) %>% 
  ungroup

#' The method above is far from perfect (and perhaps a bit useless, if not it allows us to 
#' find the full name of the category). So we need to spot the true category and eliminate 
#' what is not a category by matching with the beginning of a category.
to_keep <- c("General Econ",
             "Theory, History",
             "Agriculture and Natural",
             "Business Administration, including",
             "Economic Growth and Development",
             "Economic Statistics; including",
             "Industrial Organization",
             "International Economics",
             "Manpower,",
             "Monetary and Fiscal",
             "Not Classified",
             "Quantitative Economic Methods",
             "Urban and Regional",
             "Welfare Programs;")

is_category_cleaned <- is_category_cleaned %>% 
  filter(str_detect(category, paste0("^", to_keep, collapse = "|"))) %>% 
  group_by(id_jel) %>% 
  mutate(rank_info = 1:n())

#' We need to do a last round of cleaning as we have some part of texts that are not 
#' category at all.

is_category_cleaned <- is_category_cleaned %>% 
  filter(! str_detect(text, "^Carlo")) %>% 
  mutate(category = ifelse(str_detect(category, "^Quantitative Economic Methods and Data, including Econometric Methods, Economic and Social Data, and Analysis"),
                           "Quantitative Economic Methods and Data, including Econometric Methods, Economic and Social Data, and Analysis",
                           category))

#' We can now merge year by year, allowing us to remove the beginning of each doc
db_period3 <- data.table("doc_id" = c(),
                         "Year" = c(),
                         "text" = c(),
                         "category" = c())
for(i in 1969:1990){
  db_per_year <- corpus_raw %>% 
    filter(Year == i) %>% 
    left_join(filter(is_category_cleaned, Year == i)) %>% 
    filter(row_number >= min(filter(is_category_cleaned, Year == i)$row_number)) %>% 
    mutate(rank_info = ifelse(is.na(rank_info), 0, rank_info)) %>% 
    mutate(id_category = cumsum(rank_info == 1))
  
  id_category <- db_per_year %>% 
    filter(rank_info == 1) %>% 
    select(id_category, category)
  
  db_per_year <- db_per_year %>% 
    select(-c(category, rank_info)) %>% 
    left_join(id_category) %>% 
    filter(is.na(id_jel)) %>% 
    select(-c(header, id_jel, row_number, id_category))
  
  db_period3 <- db_period3 %>% 
    bind_rows(db_per_year)
}

#' ## 4th framework: 1991-2021
#' 
#' Here, we use the new classification of the jel code to do the matching.
#' We import the list of jel code, build from `.xml` in 
#' [creating_JEL_list.R](/cleaning_data/helper_scripts/creating_JEL_list.R).

jel_code <- readRDS(here(raw_data_path, "jel_code")) %>% 
  filter(rank == 1) %>% 
  select(code, description)

db <- corpus_raw %>% 
  filter(between(Year, 1991, max(corpus_raw$Year %>% as.integer)))

#' The identification is simpler here: we just need a line that begin by an upper case
#' letter, and followed by a word with an upper case letter. We have just to be more 
#' careful for the code "A".
is_category <- db %>% 
  select(text, row_number, Year) %>% 
  filter((str_detect(text, "^(?!A)[A-Z] [A-Z][a-z]") |
           str_detect(text, "^A General Economic")) &
           ! str_detect(text, "\\?|Ph\\.D\\.")) %>% 
  mutate(code = str_extract(text, "^[A-Z](?= )")) %>% 
  left_join(jel_code)

#' We now have to add the lines that follow the first line identified, to complete
#' the name of the category (later to remove these lines)
spot_category <- db %>% 
  mutate(is_category = row_number %in% is_category$row_number,
         is_ref = str_detect(text, "Ph.D.|D.B.A.|\\d{4}"),
         is_category = ifelse(lag(is_category, 1) == TRUE & is_ref == FALSE, TRUE, is_category),
         is_category = ifelse(lag(is_category, 1) == TRUE & is_ref == FALSE, TRUE, is_category),
         is_category = ifelse(str_detect(text, "(• |^)Personnel Economics"), TRUE, is_category)) # matching manually the only part we cannot match

#' We keep the category position to be used in the loop for removing the category lines
category_position <- spot_category %>% 
  filter(is_category == TRUE) %>% 
  select(-c(header, is_ref, doc_id)) %>% 
  left_join(is_category)

#' Here is a loop year by year, which serve to remove the introductory text before the first category
db_period4 <- data.table("doc_id" = c(),
                         "Year" = c(),
                         "text" = c(),
                         "category" = c())
for(i in 1991:max(corpus_raw$Year %>% as.integer)){
db_per_year <- corpus_raw %>% 
  filter(Year == i) %>% 
  left_join(filter(category_position, Year == i)) %>% 
  filter(row_number >= min(filter(category_position, Year == i)$row_number)) %>% 
  mutate(id_category = cumsum(!is.na(code)))

id_category <- db_per_year %>% 
  filter(!is.na(code)) %>% 
  select(id_category, category = description)

db_per_year <- db_per_year %>% 
  left_join(id_category) %>% 
  filter(is.na(is_category)) %>% 
  select(-c(header, is_category, code, description, row_number, id_category))

db_period4 <- db_period4 %>% 
  bind_rows(db_per_year)
}

#' We can merge for the four periods
db_before_references <- db_period1 %>% 
  bind_rows(db_period2) %>%
  bind_rows(db_period3) %>% 
  bind_rows(db_period4)

#' We save the data.frame to end this script. We have removed and saved all the information that were not part
#' of the references of the dissertation. In the next script, we put the different lines of a same reference together.
saveRDS(db_before_references, here(US_txt_intermediate_data_path, "db_before_references"))
