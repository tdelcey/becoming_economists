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
#' This script takes the data.frame cleaned in the previous [script](/script/US_txt_1_extracting_references.md).
#' In this script, we will put all the lines about the same dissertation on one line. 
#' 
#' > WARNING: This script still needs a lot of cleaning
#' 
#+ r setup, include = FALSE
knitr::opts_chunk$set(eval = FALSE)

#' # Loading packages, paths and data
#' 

source("cleaning_data/0_paths_and_packages.R")

#' # Identifying references with spacyr
#' 
#' The strategy is to tokenize and tag words using `spacyr`. It allows us to spot the 
#' row that begins by two proper nouns identified as individuals proper nouns by `spacyr`.
#' We use this method until 1965. After 1966, you have the word "Ph.D." just after the name
#' of the author of the dissertation, making it very easy to identify the beginning of a reference.
#' 
#' ## Identification step
#'
#' ### Period 1906-1965 
db_before_references_1 <- readRDS(here(US_txt_intermediate_data_path, "db_before_references")) %>% 
  filter(text != "" , !is.na(text), Year <= 1965) %>% 
  mutate(id_line = 1:n()) %>% 
  as.data.table

#tokenize. Run spacyr::spacy_initialize()

df_token <- spacy_parse(db_before_references_1$text, tag = TRUE, pos = TRUE)

#create id for each ref by combining cumsum & ifelse conditions describe below
df_name <- as.data.table(df_token) %>%
  mutate(
    id_ref =
      cumsum(
        ifelse(sentence_id == 1 & # it should in the first sentence of the line
          (pos == "PROPN" & (lead(pos, n = 1) == "PROPN")) & # it should be at least a proper noun followed by another proper noun in the line
          ((entity == "PERSON_I" | entity == "PERSON_B") & (lead(entity, n = 1) == "PERSON_I" | (lead(entity, n = 1) == "PERSON_B")) & # it should be, at least, a person, followed by another person in the line
            (token_id == 1 & (lead(token_id, n = 1) == 2))) # it should be, at least, the first two tokens of the sentence in the line
        , 1, 0)
            )
        )

merging_lines <- df_name %>% 
  mutate(id_line = str_remove(doc_id, "text") %>% as.integer) %>% 
  select(id_line, id_ref) %>% 
  unique

db_with_references <- db_before_references_1 %>% 
  left_join(merging_lines) %>% 
  group_by(id_ref) %>% 
  mutate(ref = paste0(text, collapse = " ")) %>% 
  distinct(ref, .keep_all = TRUE) %>% 
  select(id_ref, ref, Year, university, category, status, text) %>% # we keep text just to check if everything is ok for the moment but apparently it is
  rename("doc_year" = Year) %>% 
  as.data.table()

#' ### Period 1966-2021 
#' 
#' > Some possible thing to do will be to check if there is no problem in the writing
#' of "Ph.D." like missing points, or missing uppercase. Also check for "D.B.A" that I
#' found somewhere.
#' 
db_before_references <- readRDS(here(US_txt_intermediate_data_path, "db_before_references")) %>% 
  as_tibble() %>% 
  filter(text != "" , !is.na(text), Year >= 1966) %>% 
  mutate(id_line = 1:n(),
         text = str_replace_all(text, "Ph(.)?D([:punct:])? ", "Ph.D. "),
         text = str_replace_all(text, "D.?B.?A([:punct:])? ", "D.B.A. "),
         status = "Degree conferred") %>%  # After 1966, we just have degrees conferred
  as.data.table()

db_before_references_2 <- db_before_references %>% 
  mutate(id_ref = (cumsum(str_detect(text, "(^| |,)Ph\\.D\\. |D.?B.?A([:punct:])? "))) + max(db_with_references$id_ref)) %>% 
  group_by(id_ref) %>% 
  mutate(ref = paste0(text, collapse = " ")) %>% 
  distinct(ref, .keep_all = TRUE) %>% 
  select(id_ref, ref, Year, university, category, status, text) %>% # we keep text just to check if everything is ok for the moment but apparently it is
  rename("doc_year" = Year) %>% 
  as.data.table()


# bind
db_with_references <- db_with_references %>% 
  bind_rows(db_before_references_2)

#' intermediary save: 
#' `saveRDS(db_with_references, here(US_txt_intermediate_data_path, "db_with_references"))`

#' loading:
#' `db_with_references <- readRDS(here(US_txt_intermediate_data_path, "db_with_references"))`
#' 
#' ## cleaning steps
#' 
#' There are first very simple things to clean on the `ref` column:
#' 
#' - removing the invisible dash and the following space between two part of a same word
#' like "psycho­ logical" (first line of `df_ref`)
#' 
#' 

db_with_references <- db_with_references %>% 
  mutate(ref = str_remove(ref, "­ |­ ")) %>% 
  as.data.table

#' ### Identifying problematic references 
#' 
#' Due to our identification method, there are only one type of problematic references:
#' references coalescing two or more references, as the authors of the second reference
#' (and perhaps in very rare case of the third one) have not been identified. 
#' 
#' For references before the apparition of abstracts (meaning before 1966), we can check
#' the distribution of the length of the ref, and look at the 1% longer references to 
#' see the problem. 
#' 

db_with_references[, length_ref := ifelse(doc_year <= 1965, str_count(ref), NA)]
db_with_references[, problematic_ref := ifelse(length_ref > quantile(length_ref, probs = 0.95, na.rm = TRUE), "long", "good")]
db_with_references[, problematic_ref := ifelse(length_ref < quantile(length_ref, probs = 0.05, na.rm = TRUE), "short", problematic_ref)]
db_with_references[, problematic_ref := ifelse(length_ref == 0, NA, problematic_ref)]

#######################################################################################
#########################################################################################
###################### Old Method ######################################################
#######################################################################################

db <- readRDS(here(US_txt_intermediate_data_path, "db_before_references"))

#' # Identifying the references
#' 
#' Our goal is to identify the first line of a ref, and then to give an id to 
#' a ref and put all the lines of a ref on the same line. We will do that by identifying
#' the name of the PhD.

# control for "Reverend"
db[, is_rev := str_detect(text, "Rev. ")]
db[, text := str_remove(text, "Rev. ")]

# Identifying names pattern
pattern_names <- "^((([A-z]+ )+((([A-Z]{1,2}( )?\\.( )?){1,2}[A-z]+)|(([A-z]+( )?)+))|([A-z \\.]+)))(,( Jr.,)?|.|( ))"

##better way to construct pattern names regex: separate each part of the regex for simplicity
##first and middle names include a space after the character strings. 
#first_names <- "^([A-Z]{1}[a-z]+(( )|\\-)?)+" #anything beginning with an upper letter and a set of lower letters. Include also anything that repeated this sequence with space or quadratin ("Jean Sebastien ", "Jean-Sebastien "). 
#middle_names <- "([A-Z]{1,2}[a-z]?( )?\\.( )?){0,2}" #middle initial "A.", "AB.", "von", "A .", "A. ". This sequence is repeating itself one or two times. 
#last_names <- "([A-Z]{1}[a-z]+(( )|\\-)?)+" #same pattern than first name 
#comma <- "(,( Jr.,)?|\\.|( ))" #end pattern with the next comma, dot, space (include junior exception)


db[, name := str_extract(text, pattern_names)]

# Cleaning problematic names
db[! str_detect(name, "^[A-Z]")]$name <- NA
remove_words <- c("University",
                  "College",
                  "Seminary",
                  "Degree",
                  "History",
                  "State",
                  "economic",
                  "policy",
                  "Universite",
                  "Autonoma ",
                  "Riviere",
                  "June,",
                  "^A\\.M\\.,",
                  "^B\\.D\\.,",
                  "^M\\.A\\.,",
                  "^M\\.E\\.,",
                  "^M\\.S\\.,",
                  "^A\\.B\\.,",
                  "Ph\\.D\\.",
                  "^B\\.C\\.L\\.,",
                  "^Upsala",
                  "^LL\\.B\\.,",
                  "Cal\\.,",
                  "Feb\\.,",
                  "[:digit:]",
                  ":$",
                  "Testament",
                  "San Francisco",
                  "California",
                  "Greenpoint",
                  "Completed",
                  "School",
                  "The",
                  "Exchange",
                  "Pennsylvania",
                  "Office",
                  "Law",
                  "Accepted",
                  "Railroad",
                  "Statistics",
                  "Apprenticeship")
lines_to_clean <- str_which(db$name, paste0(remove_words, collapse = "|"))
db[lines_to_clean]$name <- NA

# control for particle
db[, has_particle := str_detect(name, " von | de | den | der | del | da | van | la | chi | du | y | yak | ul | yen [A-Z]")]

#' We remove the `name` content when we find words beginning with a lower case (and
#' not being a particle)
db[! has_particle == TRUE, contain_lower_case := str_detect(name, " [a-z]+") ]
db[contain_lower_case == TRUE]$name <- NA

#' We want to identify `name` column with too many words to be names. 

db[str_count(name, "\\W") >= 6]$name <- NA

#' We can clean later what's in `name` to check if this is really
#' proper name. identifying the start ref by counting them, and then
#' counting the number of lines between a start ref, and the next start. Above
#' 4, we can be quite sure there is a problem before 1965 (as there was no abstract).
#' We can check for higher line gap for after 1965.
#' 

db[, id_start_ref := cumsum(! is.na(name))]
db[, line_gap := .N, by = "id_start_ref"]

#' Look at problematic refs with `View(db[(line_gap > 4 & Year < 1966) | (line_gap > 13 & Year >= 1966)])`

#' We can now identify each refs and put all the lines together.
#' 

db_final <- db %>% 
  mutate(id_ref = cumsum(! is.na(name))) %>% 
  group_by(id_ref) %>% 
  mutate(ref = paste(text, collapse = " ")) %>% 
  select(Year, id_ref, ref, university, name, category) %>% 
  mutate(ref = str_remove_all(ref, "­ ")) %>% #' We can now clean the "false space", which are easily identifiable
  unique() %>% 
  distinct(Year, ref, .keep_all = TRUE) %>% 
  as.data.table

saveRDS(db_final, here(US_txt_intermediate_data_path, "db_with_references"))

#' loading:
#' `db_with_references <- readRDS(here(US_txt_intermediate_data_path, "db_with_references"))`
