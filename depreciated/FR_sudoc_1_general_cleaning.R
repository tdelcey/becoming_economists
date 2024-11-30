############### Script to clean the data extracting from Sudoc ################

#' AURELIEN instruction: 
#' To clean:
#' - the `title` column: you have the title, but also sometimes the author and additional
#' information (type of phd and where and when it was defended)
#' - the `author` column where you have the author (possible doublon with the `title` 
#' column), the phd supervisor, the member 
#' of the committee and the university of defense (All the information are not always
#' there). Easy to clean as separated by a return to line (`\n`)
#' - the `thesis_information` where you have the type of PhD, the name of the "discipline"
#' (it contains the word "économique(s)" and "économie"), the university of defense (doublon
#' with `author` column) and the date of defense (possible doublon with `date` and `title` columns). 
#' The best option is to extract everything to control for information we already have (for the university
#' and the date).
#' - the `topics` column where you have keywords.
#' - the removing or separating the non-French phd.
#'


#'THOMAS's code: 
#### loading data ####
source(here::here("0_paths_and_packages.R"))

# sudoc_data <- readRDS(here(FR_sudoc_raw_data_path, "sudoc_data.rds"))
sudoc_df <- readRDS(here(FR_sudoc_raw_data_path, "sudoc_data_1920-2022.rds"))
#thesefr_df <- readRDS(here(FR_thesefr_intermediate_data_path, "Thesis_table.rds"))

# first basic cleaning
sudoc_df <- sudoc_df %>%
  mutate(saving_information = apply(., 1, paste, collapse = "|"),  # save all uncleaned information in one col
         id_doc = str_extract(sudoc_url, "(?<=\\.fr\\/)[\\d[:letter:]]+$")) %>%  #extract id from url
  mutate_all(str_trim, "both") %>%  #remove space blanc before and after all variables 
  filter(str_detect(country, "France")) # removing thesis that are also in these.fr

#### FIRST STEP: cleaning date #####

#' I only clean existing date and add date with thesis information when the date was missing. 
# for safety, we could also create a second variable "date2" and compare with the first one "date"

sudoc_df <- sudoc_df %>%
  mutate(date = case_when( 
    str_detect(date, "[:digit:]{4}", negate = TRUE) ~ str_extract(thesis_information, "[:digit:]{4}$"),
    TRUE ~ date)) %>% #when date value has not 4 digits, find and replace the date in thesis information
  mutate(date = str_remove_all(date, "[:punct:]+|[A-z]+")) %>% #remove brackets, dot and alphabetic value from some dates
  mutate(date = str_remove(date, "(?<=[:digit:]{4}).*")) %>%  #remove second date
  mutate(date = str_trim(date, "both")) 

#' evaluation of missing date: 
#' `eval_df <- sudoc_df %>% filter( is.na(date)) %>% View()` 
#' We delete missing dates

sudoc_df <- sudoc_df %>% 
  filter(!str_detect(date, "^[:digit:]{4}$") | ! is.na(date)) # footnote: the first condition is useless for now

#### SECOND STEP: cleaning author #####

# first step: 
#I exploit the variable "author" and try to separate and classify information contained in this variable: 
#"author" contains information about authors but also supervisor and members of the jury and institution 

#' separate the variable "author" in a new variable "author_information": 
#' 
#' - the separator is a newline 
#' - in the new tibble, each id_doc has a number of rows equal to 
#' the number of different pieces of information contained in "author"

author_information_separated_df <- sudoc_df %>%
  unnest_lines(output = author_information,
                 input = author) %>%
    select(id_doc, author_information) 

# I transform rows into new classified columns
author_information_classified_df <- author_information_separated_df %>%
  group_by(id_doc) %>%
    mutate(author = str_extract(author_information, ".*(?=auteur)"),
           supervisor = str_extract(author_information, ".*(?=(préfacier, etc.|directeur de thèse|directeur de publication|directeur de thèse. président du jury de soutenance|directeur de thèse. président du jury de soutenance. membre du jury|directeur de la recherche|encadrant académique))"),
           president = str_extract(author_information, ".*(?=(président du jury de soutenance|président du jury de soutenance. membre du jury))"),
           referee = str_extract(author_information, ".*(?=rapporteur de la thèse)"),
           member = str_extract(author_information, ".*(?=membre du jury)"),
           member_varia = str_extract(author_information, ".*(?=(technicien graphique|metteur en scène ou réalisateur|secrétaire))"),
           institution = str_extract(author_information, ".*(?=organisme de soutenance)"),
           institution2 = str_extract(author_information, ".*(?=(ecole doctorale associée à la thèse|fonction à préciser|laboratoire associé à la thèse|organisme de cotutelle|autre partenaire associé à la thèse|éditeur scientifique|éditeur commercial|collaborateur|chef de choeur|equipe de recherche associée à la thèse|fondateur|entreprise associée à la thèse))"))
  
#' evaluate:
#' `author_information_classified_df %>% filter(across(author:institution2, ~is.na(.)))`

#' second step: Cleaning the names
#' 
#' I bind lines by id_doc 
#' 
author_information_df <- author_information_classified_df %>%
  group_by(id_doc) %>%
  summarise_all(list(~toString(na.omit(.))))

#### THIRD STEP: cleaning title #####

#' I exploit here the variable "title": 
#' 
#' - "title" contains information about title and authors, and sometimes supervisor and jury members
#' - I separate the variable "title" in a new variable "title_information"
    
title_information_separated_df <- sudoc_df %>%
  unnest_regex(output = title_information,
               input = title,
               pattern = " / ",
               to_lower = FALSE) %>%
  select(id_doc, title_information) 

#exploring the different information 
#  test2 <- title_information_separated_df %>%
#    count(id) 

# I transform rows into new classified columns

# We build two lists that allows us to identify supervisors and president of jury in title information
supervisor_mark <- c("sous? la di?ri?ection (de |d'|d’)?", # manage also typos
                     "sous la dir\\.? (de |d'|d’)?",
                     "travaux dirigés par ",
                     "directeur de recherches? ",
                     "directeur d'études(,)? ",
                     "direction de recherches? ",
                     "dirigée? par ",
                     "dir\\.",
                     "préfaces? de ",
                     "préf\\. de ",
                     "^M\\. ?le prof\\. ",
                     "Monsieur le professeur ",
                     "Prof\\. ?")
president_mark <- c("président (de jury |de thèse |: )",
                    "sous la présidence de ",
                    "prés\\. (M\\. le professeur )?")

title_information_classified_df <- title_information_separated_df %>%
  mutate(title_information = str_remove_all(title_information, "\\[|\\]")) %>%
  group_by(id_doc) %>%
  mutate(title = first(title_information), 
         other_information = nth(title_information, n = 2),
         other_information2 = nth(title_information, n = 3),
         other_information_split = str_extract(other_information, "(?<=;( )?).+") %>% 
                                                 str_trim("both"), # put the information after author in another column
         author_bis = str_remove(other_information, "( )?;( )?.+"), # everything before ; is the author
         supervisor_bis = str_extract(other_information_split, 
                                  regex(paste0("(?<=", supervisor_mark, ").+", collapse = "|"),
                                        ignore_case = TRUE)),
         supervisor_bis = ifelse(is.na(supervisor_bis), 
                             str_extract(other_information_split, "^[A-Z][:alpha:]+(\\.)?(( |-)[A-Z][:alpha:]+(\\.)?)? [A-Z][:alpha:]+"),
                             supervisor_bis) %>% 
           str_trim("both"),
         supervisor_bis = str_remove_all(supervisor_bis, 
                                     regex("^de |^d'|^d’|Monsieur le professeur |par le prof\\. ", ignore_case = TRUE)),
         president_bis = ifelse(is.na(supervisor_bis), 
                                str_extract(other_information_split, 
                                            regex(paste0("(?<=", president_mark, ").+", collapse = "|"),
                                                  ignore_case = TRUE)),
                                NA),
         president_bis = str_remove_all(president_bis, 
                                         regex("d(u|e) jury |de thèse |: |M\\. le professeur |^M\\.( )?", ignore_case = TRUE))) 

title_information_df <- title_information_classified_df %>%
  distinct(id_doc, title, author_bis, supervisor_bis, president_bis)

#### FOURTH STEP: merging author, title and date #####

sudoc_clean_df <- sudoc_df %>%
  select(-c(title, author)) %>%
  left_join(select(author_information_df, c(id_doc, author, supervisor, president, referee, member, institution, institution2))) %>%
  left_join(title_information_df) %>%
  relocate(c(title, author, supervisor, institution), .after = id_doc) %>%
  mutate(across(everything(), ~ifelse(.=="", NA, as.character(.))),
         author = ifelse(is.na(author), author_bis, author),
         supervisor = ifelse(is.na(supervisor), supervisor_bis, supervisor),
         president = ifelse(is.na(president), president_bis, president),
         supervisor = ifelse(str_detect(supervisor, "non precis|inconnu"), NA, supervisor))

#' Just a precautionary save:
#' `saveRDS(sudoc_clean_df, here(FR_sudoc_intermediate_data_path, "sudoc_clean_df.rds"))`



#### FINAL TABLE #### 

#copying alex tables for thesis
#Alex_author <- readRDS(here(FR_thesefr_intermediate_data_path, "Authors_table.rds"))
#Alex_thesis <- readRDS(here(FR_thesefr_intermediate_data_path, "Thesis_table.rds"))
#Alex_supervisor <- readRDS(here(FR_thesefr_intermediate_data_path, "Supervisors_table.rds"))
#sudoc data
sudoc_clean_df <- readRDS(here(FR_sudoc_intermediate_data_path, "sudoc_clean_df.rds"))


author_clean <- sudoc_clean_df %>%
  group_by(id_doc) %>%
  unnest_regex(input = author, output = author_clean, pattern = "\\. ,") %>%  #separate the first author from other names (co-authors, supervisors, etc.) 
  distinct(id_doc, .keep_all = TRUE) %>%  # keep only the first author
  mutate(author_clean = str_remove_all(author_clean, "\\(.*"), #can delete second authors when they are not correctly separated from first author
         author_clean = str_trim(author_clean, "both"),
         author_clean = str_remove(author_clean, "\\.$"),
         nom = str_extract(author_clean, ".*(?=,)"),
         prenom = str_extract(author_clean, "(?<=,).*"))


# handling special names with humaniformat 

library(humaniformat)

special_case <- author_clean %>%
  filter(!author_clean == "") %>%
  filter((is.na(nom)|is.na(prenom)))

special_case <- special_case %>%
  mutate(prenom = paste(first_name(author_clean), ifelse(!is.na(middle_name(author_clean)),
                                                         middle_name(author_clean),
                                                         ""
                                                         ))) %>%
  mutate(nom = last_name(author_clean))

#final_table, adding special, uppcase, and order of co-authering 

Authors_table <- author_clean %>%
  filter(!(is.na(nom)|is.na(prenom))) %>%
  bind_rows(special_case) %>%
  mutate(across(ends_with("nom"), ~ str_to_title(.) %>% str_trim("both"))) %>%
  select(-author_clean) %>%
  group_by(id_doc) %>%
  mutate(order = row_number(),
         role = "auteur") 

#find possible duplicate
#test <- Authors_table %>% 
 # ungroup() %>%
  #select(nom, prenom) %>%
  #get_dupes() #janitor duplicate

#supervisor 

Supervisor_table <- sudoc_clean_df %>%
  select(id_doc, supervisor) %>%
  filter(!is.na(supervisor)) %>%
  group_by(id_doc) %>%
  unnest_regex(input = supervisor, output = supervisor_clean, pattern = "\\. ,") %>%
  mutate(order = row_number()) %>%
  mutate(supervisor_clean = str_remove_all(supervisor_clean, "\\(.*"), # can delete second director  when they are not correctly separated from first authors
         supervisor_clean = str_trim(supervisor_clean, "both"),
         supervisor_clean = str_remove(supervisor_clean, "\\.$"),
         nom = str_extract(supervisor_clean, ".*(?=,)"),
         prenom = str_extract(supervisor_clean, "(?<=,).*"),
         across(ends_with("nom"), ~ str_to_title(.) %>% str_trim("both")),
         role = "supervisor") %>%
  select(-supervisor_clean)  

people_table <- bind_rows(Authors_table, Supervisor_table) %>%
  group_by(nom, prenom) %>%
  mutate(id_individual = paste0(dplyr::cur_group_id() , "-", "people")) %>% 
  ungroup()

saveRDS(people_table, here(FR_sudoc_intermediate_data_path, "people_table.rds"))

#saveRDS(Authors_table, here(FR_sudoc_intermediate_data_path, "Authors_table.rds"))
#Authors_table <- readRDS(here(FR_sudoc_intermediate_data_path, "Authors_table.rds"))
#saveRDS(Supervisor_table, here(FR_sudoc_intermediate_data_path, "Supervisor_table.rds"))
#Supervisor_table <- readRDS(here(FR_sudoc_intermediate_data_path, "Supervisor_table.rds"))


#### CLEAN INSTITUTION

#we already created 2 variable institution and institution2 when we clean author variable
#the goal is to compare these 2 variables with the information contained in thesis information

institution_clean <- sudoc_clean_df %>%
  select(id_doc, institution, institution2, thesis_information) %>%
  #delete faculty information
  mutate(institution_cleaning = str_remove_all(institution, "\\..*"),
         institution_cleaning = str_remove(institution_cleaning, "\\.$"),
         institution_cleaning = str_to_title(institution_cleaning),
         institution_cleaning = str_trim(institution_cleaning, "both"),
         #thesis_information 
         thesis_information = str_squish(thesis_information),
         institution_cleaning_2 = str_extract(thesis_information, "(?<=: ).*(?= : (\\[|d)?\\d{4})") %>% 
           str_extract("(?<=: ).*"))


institution_clean <- institution_clean %>% 
  mutate(institution_cleaning_3 = ifelse(is.na(institution_cleaning_2), 
                                         str_extract(thesis_information, "(?<=: ).*(?=(.,) \\d{4})",
                                         NA)))

institution_clean <- institution_clean %>% 
  mutate(institution_cleaning_3 = ifelse(is.na(institution_cleaning_2), 
                                         str_extract(thesis_information, paste0(institutions, collapse = "|")),
                                         NA))


id_institution <- institution_clean %>%
  filter(!is.na(institution_cleaning)) %>%
  select(c(institution_cleaning)) %>%
  unique() %>%
  mutate(id_institution = paste0(row_number(), "-", "institution"))


Institution_table <- institution_clean %>%
  select(-c(institution)) %>%
  left_join(id_institution) %>%
  rename(institution = institution_cleaning)


n_institution <- Institution_table  %>%
  filter(!is.na(institution)) %>%
  group_by(institution) %>%
  summarise(n = n())

saveRDS(Institution_table, here(FR_sudoc_intermediate_data_path, "Institution_table.rds"))
Institution_table <- readRDS(here(FR_sudoc_intermediate_data_path, "Institution_table.rds"))

#table linking document, authors and supervisor 

Linking_table <- sudoc_clean_df %>%
  select(id_doc) %>%
  left_join(select(Authors_table, c(id_doc, id_indivudal))) %>%
  left_join(select(Supervisor_table, c(id_doc, id_indivudal)), 
                   by = "id_doc",
                   suffix = c("_author", "_supervisor")) %>%
  left_join(select(Institution_table, c(id_doc, id_institution)))
  

saveRDS(Documenttopeople_table, here(FR_sudoc_intermediate_data_path, "Linking_table_table.rds"))



#table thesis 


