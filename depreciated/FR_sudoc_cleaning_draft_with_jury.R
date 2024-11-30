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

sudoc_data <- readRDS(here(FR_sudoc_raw_data_path, "sudoc_data.rds"))
sudoc_df <- readRDS(here(FR_sudoc_raw_data_path, "sudoc_data_{first_year}-{last_year}.rds"))

#save all uncleaning information in one col
sudoc_df <- sudoc_df %>%
  mutate(saving_information = apply(., 1, paste, collapse = "|"))

#remove space blanc before and after all variables 

sudoc_df <- sudoc_df %>%
  mutate_all(str_trim, "both")

#### date #####

#I only clean existing date and add date with thesis information when the date was missing. 
#for safety, we could also create a second variable "date2" and compare with the first one "date"

sudoc_df <- sudoc_df %>%
    #when date value has not 4 digits, find and replace the date in thesis information
    mutate(date = case_when( 
      str_detect(date, "[:digit:]{4}", negate = TRUE) ~ str_extract(thesis_information, "[:digit:]{4}$"),
                          TRUE ~ date)
          ) %>%
    #remove brackets, dot and alphabetic value from some dates
    mutate(date = str_remove_all(date, "[:punct:]+|[A-z]+")) %>% 
    #remove second date
    mutate(date = str_remove(date, "(?<=[:digit:]{4}).*")) %>%
    mutate(date = str_trim(date, "both"))


#evaluation: 

eval_df <- sudoc_df %>%
  filter(!str_detect(date, "^[:digit:]{4}$") | is.na(date))

distribution <- sudoc_df %>%
  group_by(date) %>%
  summarise(n = n()) 

#plot distribution
distribution %>%
  filter(!is.na(n) & date < 1985) %>% #check the errors after 1985
  ggplot() +
  geom_line(aes(x = as.numeric(date), y = n), 
            linewidth = 1.5, color = "darkred") +
  ylab("Nombre de thèses") +
  xlab("Année")

#create an number id by thesis from 1 to n (1 is the first, n is the latest)

sudoc_df <- sudoc_df %>%
  arrange(date) %>%
  mutate(id = row_number()) %>%
  relocate(id, before = 1)


#handmade pre-cleaning

sudoc_df <- sudoc_df %>%
  #duplicate names
  mutate(title = str_remove(title, "William Cavestro / ")) %>%
  mutate(title = str_remove(title, "Hanspeter Weisshaupt / ")) %>%
  mutate(title = str_replace(title, 
                             "Les Problèmes financiers d'une entreprise internationale / la Société Nationale ELF-Aquitaine / Philippe Cier",
                             "Les Problèmes financiers d'une entreprise internationale: la Société Nationale ELF-Aquitaine / Philippe Cier"
                             )
        ) %>%
  mutate(title = str_replace(title, 
                             "Essai sur les structures et les résultats d'exploitation / exploitations de grande et de petite superficie ; Louis Malassis ; [sous la direction de] M. Fromont",
                             "Essai sur les structures et les résultats d'exploitation: exploitations de grande et de petite superficie ; Louis Malassis ; [sous la direction de] M. Fromont"
  )
  )

#to handle 
#	exploitations de grande et de petite superficie

#### author ####

#first step: DRAFT
#I exploit the variable "author" and try to separate and classify information contained in this variable: 
#"author" contains information about authors but also directors and members of the jury and institution providing the thesis

# separate the variable "author" in a new variable "author_information" 
# the separator is a newline 
# in the new tibble, each id has a number of rows equal to the the number of different pieces of information contained in "author"
author_information_separated_df <- sudoc_df %>%
  unnest_lines(output = author_information,
                 input = author) %>%
    select(id, author_information) 

#exploring the different information 
#  test2 <- author_information_separated_df %>%
#    count(id) 

#  test3 <- test2 %>% 
#    group_by(n) %>%
#    summarise(n2 = n())

# I transform rows into new classified columns
author_information_classified_df <- author_information_separated_df %>%
  group_by(id) %>%
  mutate(author = str_extract(author_information, ".*(?=auteur)")) %>%
  mutate(director = str_extract(author_information, ".*(?=(préfacier, etc.|directeur de thèse|directeur de publication|directeur de thèse. président du jury de soutenance|directeur de thèse. président du jury de soutenance. membre du jury|directeur de la recherche))")) %>%
  mutate(president = str_extract(author_information, ".*(?=(président du jury de soutenance|président du jury de soutenance. membre du jury))")) %>%
  mutate(referee = str_extract(author_information, ".*(?=rapporteur de la thèse)")) %>%
  mutate(member = str_extract(author_information, ".*(?=membre du jury)")) %>%
  mutate(member_varia = str_extract(author_information, ".*(?=(technicien graphique|metteur en scène ou réalisateur))")) %>%
  mutate(institution = str_extract(author_information, ".*(?=organisme de soutenance)")) %>%
  mutate(institution2 = str_extract(author_information, ".*(?=(ecole doctorale associée à la thèse|fonction à préciser|laboratoire associé à la thèse|organisme de cotutelle|autre partenaire associé à la thèse|éditeur scientifique|éditeur commercial|collaborateur|chef de choeur|equipe de recherche associée à la thèse|fondateur|entreprise associée à la thèse))"))

#evaluate:
test <- author_information_classified_df %>%
  filter(is.na(author) & 
         is.na(director) &
           is.na(member) &
           is.na(referee) &
           is.na(president) &
           is.na(institution) & 
           is.na(institution2) &
           is.na(member_varia))

#I bind lines by id 
author_information_df <- author_information_classified_df %>%
  group_by(id) %>%
  summarise_all(list(~toString(na.omit(.))))


#second step: DRAFT 
#I exploit the variable "title"
#"title" conains information about title and authors 

#I separate the variable "title" in a new variable "title_information"
    
title_information_separated_df <- sudoc_df %>%
  unnest_regex(output = title_information,
               input = title,
               pattern = " / ") %>%
  select(id, title_information) 

#exploring the different information 
#  test2 <- title_information_separated_df %>%
#    count(id) 

# I transform rows into new classified columns
title_information_classified_df <- title_information_separated_df %>%
  mutate(title_information = str_remove_all(title_information, "\\[|\\]")) %>%
  group_by(id) %>%
  mutate(title = first(title_information)) %>%
  mutate(other_information = nth(title_information, n = 2)) %>%
  mutate(other_information2 = nth(title_information, n = 3))

#title is at 99% clean (some expection to clean by hand above)






#some author1 and author2 has information about president and jury, I extract such information into new variable 
#classifying director 
  
title_information_classified_df2 <- title_information_classified_df %>%
    mutate(director = str_extract(author, "(?<=sous la (direction|dir\\.)).*")
           
           ) %>%
    
  mutate(director = ifelse(is.na(director),
                             str_extract(author, "(?<=directeur de recherches?).*"), 
                             director)
           ) %>%
      
    mutate(director = ifelse(is.na(director),
                             str_extract(author, "(?<=; dir\\. ).*"), 
                             director)
           ) %>%
    
  mutate(director = ifelse(is.na(director),
                           str_extract(author, "(?<= préfaces? de ).*"), 
                           director)
          ) %>%    
  
    mutate(director = ifelse(is.na(director),
                             str_extract(author2, "(?<=sous la (direction|dir\\.)).*"), 
                             director)
           ) %>%
    
    mutate(director = ifelse(is.na(director),
                             str_extract(author2, "(?<=directeur de recherches?).*"), 
                             director)
           ) %>%
    mutate(director = ifelse(is.na(director),
                             str_extract(author2, "(?<=; dir\\. ).*"), 
                             director)
           ) %>%
  #remove the extracted information from authors and other1
  mutate(author = str_remove(author, "(?=(sous la (direction|dir\\.))|directeur de recherches?|; dir\\. |préfaces? de ).*")) %>%
  mutate(author2 = str_remove(author2, "(?=(sous la (direction|dir\\.))|directeur de recherches?|; dir\\. ).*"))


#classifying president 

title_information_classified_df3 <- title_information_classified_df2 %>%
  #information in author 
  mutate(president = str_extract(author2, "(?<=président du jury).*")) %>%
  mutate(president = ifelse(is.na(president),
                            str_extract(author, "(?<=sous la présidence de ).*"),
                            president)
         ) %>%
  mutate(president = ifelse(is.na(president),
                            str_extract(author, "(?<=présidente? d(e|u) jury ).*"),
                            president)
         ) %>%
  mutate(president = ifelse(is.na(president),
                            str_extract(author, "(?<=président ).*"),
                            president)
  )  %>% #information in director 
  mutate(president = ifelse(is.na(president),
                            str_extract(director, "(?<=président de jury).*"),
                            director)
         ) %>%
  mutate(director =  str_remove(director, "(?=président de jury).*")) %>%
  
  #remove the extracted information from authors and other1
  mutate(author2 = str_remove(author2, "(?=président du jury).*")) %>%
  mutate(author = str_remove(author, "(?=(sous la présidence de|présidente? d(e|u) jury |président )).*"))


#final result 

title_information_df <- title_information_classified_df3 %>%
  mutate(author = ifelse(!is.na(author2),
                         str_c(author, author2, ","),
                         author)) %>%
  select(-c(title_information, author2)) %>%
  unique()

#evaluation 

to_evaluate <- title_information_df %>%
    filter(str_count(author, "\\w+") > 3)



#STEP 3 compare: author_information_df title_information_df

title_information_df <- title_information_df %>%
  select(id, title, author, director) %>%
  rename(author2 = author,
         director2 = director)
  
test <- author_information_df %>%
  select(id, author, director) %>%
  left_join(title_information_df) %>%
  filter(author == "" & !is.na(author2))
  

test <- author_information_df %>%
  select(id, author, director) %>%
  left_join(title_information_df) %>%
  filter(director == "" & !is.na(director2))
















