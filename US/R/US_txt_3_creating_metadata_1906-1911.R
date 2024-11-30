############## PACKAGE AND  DATA ###############

source("cleaning_data/0_paths_and_packages.R")

#upload data
df <- readRDS(here(US_txt_intermediate_data_path, "db_with_references")) %>% 
  as.data.table

df[, c("degree1", "degree1_university", "degree1_year", 
       "degree2", "degree2_university", "degree2_year",
       "degree3", "degree3_university", "degree3_year", 
       "degree4", "degree4_university", "degree4_year",
       "abstract", "phd_year", "phd_state"
)] <- NA

################ 1906 - 1911 ###################

df <- df %>% 
  filter(Year <= 1911)

#From 1906 to 1950, most ref are structured as the following: 
#Family name Surname, degree1, degree1_Univ, degree1_year; degree2, degree2_Univ, degree2_year. Dissertation_title. Dissertation_year.
#Hence, the code here may be easily extended to 1950


#list of ERRORS to fix before any extraction: 
#raw 307, title and author stuck together. 

########### EXTRACTING INFORMATION #############

#The strategy below is the following:
#We extract the first information from the reference (here family and surname). 
#We then deleting it from ref, and so on until the last information (the title of the thesis).
#For each piece of information we apply a three-step process: (1) extracting patterned information ("pattern"),
# (2) extracting information that cannot be patterned ("exceptions"), (3) we also clean after the ref for preparing the next extraction.


###LIST OF REGEX
##some tips:
##(X)? include in a regex means that "X" might be here but not necessary.
##(?! X)(A) means that we are looking for any "A" that do no include X. 

#REGEX FOR NAMES
# Find first and last names and stop to a :punct: or a space. 
# First brackets is the first name, second brackets is a possible, but not necessary middle name, third is last name.
pattern_names <- "^((([A-z]+ )+((([A-Z]{1,2}( )?\\.( )?){1,2}[A-z]+)|(([A-z]+( )?)+))|([A-z \\.]+)))(,( Jr.,)?|.|( ))"

#REGEX FOR DEGREE
#Find degree abbreviation based on the repetition of upper characters and dot (sometimes comma): "M.A.", "B.A.", "B.S."
pattern_degree <- "^( ){0,2}([A-Z( )?])([A-Z])?([a-z])?((\\.|,)( )?)([A-Z( )?])([a-z])?((\\.|,)( )?)([A-Z]\\.)?"
pattern_double_degree <- "^(( ){0,2}[A-Z]( )?[A-Z]?[a-z]?(\\.|,)( )?[A-Z]( )?[A-Z]?[a-z]?\\.( )?(,)?){2}"

#list of exception degree that cannot be regexed
exception_degree <- c("B.Litt.", "Grad. Imp.", 
                       "Doctor’s Degree", 
                       "Candidate of Commercia", 
                       "Certificate of Classical Gymnasium", 
                       "Classical Gymnasium", "Filosofie Kandidat", "Litt.B",
                       "Certificate of Classical Gymnasium", "certificate of maturity",
                       "Doctor's Degree", "equivalent to A.B.", "equivalent to A.M.",
                       "Pacific Theological", "Nijni-Novgorod Gymnasium \\(Russia\\)", "Graduate Student")


#REGEX FOR DEGREE UNIVERSITY
#find any series of characters with "university" and related words starting, ending or between a series of normal characters (and some specific characters like "?") 
pattern_degree_university <- "^([A-z ­\\.’\\-]+)?(University|Uni­ versity|Univer­ sity|Institute|College|Col­ lege|University of|Uni­ versity of|State University of)([ A-z(­)?]+)?(,|\\.|;| )"
#pattern_degree_university <- "(?!([A-Z( )?\\.]{4,5}))(?!(^(Industry and community(;)?)|(Industry and a community)))(^[A-z (\\-){1}(\\’){1}]+(\\([A-z \\.]+\\))*(,|;))"

#exception degree
exception_degree_university <- c("Nebraska Wesleyan Univer­ sity",
                                  "Nebraska Wesleyan University.",
                                  "Western Reserve University,", 
                                  "Western Reserve Univer­ sity",
                                  "Royal University of Upsala ", 
                                  "Riga Polytechnic Insti­ tute (Russia)",
                                  "University of Nebraska.", "Columbia University.", 	
                                  "Westminister College.", 
                                  "Heidelberg University.", 
                                  "University of Wisconsin.", 
                                  "Florida State College", 
                                  "Fargo College.",
                                  "William Jewell College.", 
                                  "Eureka College.", 
                                  "Christian University.", 
                                  "Colorado University.",
                                  "Florida State College",
                                  "Doane College.",
                                  "Tientsin Univ.,",
                                  "Riga Polytechnic Insti­ tute (Russia), ",
                                  "Mass. Institute of Technology,", 
                                  "Chin Shih College", "Gymnasium Warsaw", 
                                  "Lyceum of Jurisprudence, Yaroslavi", 
                                  "Columbia,",
                                  "Columbia Univeristy", "Dartmouth", "DePauw", 
                                  "Glasgow University (Scotland)", "Har­ vard", 
                                  "Cornell", 
                                  "Yale", "Univ of Cal.", 
                                  "Bethany Col? lege", "Diploma, Union Theological Seminary", 
                                  "Har? vard", "Harvard",
                                  "State University of Iowa", "Iowa State Normal School",
                                  "Iowa State Normal", 
                                  "Radcliffe", "Michigan", "Lehigh", 
                                  "Doshisha Gakow", "Chicago", 
                                  "Bryn Mawr", "Stanford", "Wisconsin",
                                  "Case School of Applied Science", 
                                  "Wesleyan", "Swarthmore", 
                                  "Libau Commercial Government School", 
                                  "Cherkassi", "Tri-State School", "Nebraska", 
                                  "Harvard Univeristy", "Rochester Theological Seminary",
                                  "University of St. Petersburg", "Indiana", "Harvard",
                                  "Waseda University \\(Tokio Japan\\)", 
                                  "State Normal \\(Warrensburg, Mo\\.\\)", 
                                  "Waseda University, Tokio",
                                  "Waseda University, Japan", 
                                  "Doshisha College, Tokio, Japan", 
                                  "Waseda University \\(Tokio, Japan\\)")

#REGEX FOR DEGREE_YEAR
#finds any series of 4 digit character (and an exception XXXX-XX)
pattern_degree_year <- "^[:digit:]{4}(\\-[:digit:]{2,4})?"
#case where there is two years stuck together
pattern_double_year <- "^([:digit:]{4})(,|;)?(( )?[:digit:]{4})"

###FIRST STEP: Surname and Family Name
#First step is now made in creating_reference.R but we still need to remove names from ref for preparing next extraction

#List of irrelevant information that need to be removed after first step extraction 
to_remove_after <- c("^( \\(Radcliffe College\\),)", "^(Radcliffe College\\),)", "Equivalent", "equivalent to")

df1 <- df %>% 
#save original ref as "original_ref" and remove names from ref
mutate(original_ref = ref) %>%
#mutate(names = str_extract_all(ref, pattern_names)) %>% we already have names
mutate(ref = str_remove_all(ref, pattern_names)) %>%
mutate(ref = str_remove_all(ref, paste0(to_remove_after, collapse = "|"))) %>%
#cleaning 
mutate(name = str_remove(name, "(,|\\.)$")) %>%
mutate(ref = str_trim(ref, "left"))

#remaining errors:
#raw 338, related to a particular structure without punctions in which ref = "names X" (Ely O Merchant A.B.)
#raw 674, Clyde Orvai. Ruggles (related to the dot)


####DEGREE1####

### First of all, we need to manage few cases where years degree1 and degree2 are together
### Put them in a separate col "double-year"
df2 <- df1 %>%
  mutate(double_degree = str_extract(ref, pattern_double_degree)) %>%
  #fill the degree1 and degree2 with the first year of "double_degree"
  mutate(degree1 = str_extract(double_degree, pattern_degree)) %>%
  mutate(double_degree = str_remove(double_degree, pattern_degree)) %>% #removing first ref from double ref
  mutate(double_degree = str_remove(double_degree, "^(. )")) %>% #cleaning double year string
  mutate(degree2 = str_extract(double_degree, pattern_degree)) %>% # extract second year
  #cleaning 
  mutate(ref = str_remove(ref, pattern_double_degree)) %>% #delete double year from ref
  mutate(ref = str_remove(ref, "^(. )")) %>% #cleaning ref
  mutate(ref = str_trim(ref, "left")) %>% # cleaning ref 
  subset(select = -c(double_degree)) 

###function 
extract_regex <- function(df, string, variable, regex) {
 df[,variable] = str_extract(df[,string], regex)
  return(df)
}

test <- extract_regex(data.frame(df1), 'ref', "degree1", pattern_degree)
#rm(df1)

#extracting pattern_degree and removing it from ref
df2 <- df2 %>%
  mutate(degree1 = 
           case_when(is.na(degree1) ~ str_extract(ref, pattern_degree), 
           TRUE ~ df2$degree1)) %>%
  mutate(ref = str_remove_all(ref, pattern_degree)) 

    #same process with exceptions_degree1
  for (i in 1:length(exception_degree)){
    df2 <- df2 %>%
    mutate(degree1 = replace(degree1, str_extract(ref, paste0("^(",exception_degree[i], ")"))==exception_degree[i], exception_degree[i])) %>%
    mutate(ref = str_remove(ref, paste0("^(",exception_degree[i], ")")))
  }

#List of irrelevant information that need to be removed after second step extraction 
to_remove_after <- paste0(c("^(Agr., )", "^(in Econ., )", "^(in Economics, )", "^(equivalent,)", "^(and Ph.D.\\),)"), collapse ="|")

#cleaning variable:
df2$degree1 <- str_trim(df2$degree1, "both")
df2$ref <- str_remove(df2$ref, "^(, |., )")
df2$ref <- str_remove(df2$ref, to_remove_after)
df2$ref <- str_trim(df2$ref, "left")

#evaluating extraction, saving remaining errors 
#and remove from the main df
#df2_control <- df2 %>% filter(is.na(degree1))
#df3 <- df2 %>% filter(!is.na(degree1))
#rm(df2)


####DEGREE1_UNIVERSITY####

#first exceptions_degree1_university
#first extract pattern_degree1_university
df3 <- df2 %>%
mutate(degree1_university = str_extract(ref, pattern_degree_university))

for (i in 1:length(exception_degree_university)){
  df3 <- df3 %>%
    mutate(degree1_university = replace(degree1_university, str_extract(ref, paste0("^(",exception_degree_university[i], ")"))==exception_degree_university[i], exception_degree_university[i])) %>%
    mutate(ref = str_remove(ref, paste0("^(",exception_degree_university[i], ")")))
}

##cleaning the whole 
df3 <- df3 %>%
    mutate(ref = str_remove(ref, pattern_degree_university)) %>%
    mutate(degree1_university = replace(degree1_university, degree1_university=="character(0)", NA)) %>%
    #removing useless regional details remaining in ref 
    mutate(ref = str_remove(ref, "^(( )?,( )?)")) %>%
    mutate(ref = str_remove(ref, "^( \\((.*)\\)|Kansas|)")) %>%
    mutate(ref = str_trim(ref, "left")) %>%
    mutate(ref = str_remove(ref, "^[:punct:]*( )?")) %>%
    mutate(ref = str_trim(ref, "left")) %>%
    mutate(degree1_university = str_trim(degree1_university, "both")) %>%
    mutate(degree1_university = str_remove(degree1_university, "(,|;)$"))

#for ref with double_degree => university is the same for degree1 and 2. 
df3 <- df3 %>% 
  mutate(degree2_university = case_when(!is.na(degree1) & (!is.na(degree2)) ~ degree1_university,
                                        FALSE ~ ""))


#controlling, and saving remaining errors
#df3_control <- df3 %>% 
#filter(degree1_university == 'NA')
#rm(df3)

####DEGREE1_YEAR####

#correct an OCR error with id_ref 406 and other typo problems

df4 <- df3 %>% 
  mutate(ref = case_when(id_ref == 406 ~ str_replace(ref, "^(|l906. Economic aspects of the Mormon experiments in Utah. 1911.,)",
                           "1906. Economic aspects of the Mormon experiments in Utah. 1911."),
               TRUE ~ df3$ref))

####

to_remove_after <- paste0(c("^(Japan, )", "^(Iowa, )", "^(Kansas, )", 
                            "^(Petersburg, )", "^(Russia, )", "^(S\\. W\\.\\)), ",
                            "^(Tokyo, Japan(,|\\.) )"), collapse ="|")

#cleaning variable:
df4$ref <- str_remove(df4$ref, to_remove_after)

### First of all, we need to manage cases double_degree_year
### extract in a separate col "double_year"
df4 <- df4 %>%
  mutate(double_year = str_extract(ref, pattern_double_year)) %>%
  # put them in degree1 and degree 2
  mutate(degree1_year = str_extract(double_year, pattern_degree_year)) %>%
  mutate(double_year = str_remove(double_year, pattern_degree_year)) %>% #removing first ref from double ref
  mutate(double_year = str_remove(double_year, "^(.|, )")) %>% 
  mutate(double_year = str_trim(double_year, "left")) %>% #cleaning double year string
  mutate(degree2_year = str_extract(double_year, pattern_degree_year)) %>% # extract second year
  #cleaning
  mutate(ref = str_remove(ref, pattern_double_year)) %>% #delete double year from ref
  mutate(ref = str_remove(ref, "^(. )")) %>% #cleaning ref
  mutate(ref = str_trim(ref, "left")) %>% # cleaning ref 
  subset(select = -c(double_year)) #remove double_year raw

#extract regular degree1_year
df4 <- df4 %>%
    mutate(degree1_year = case_when(is.na(degree1_year) ~ str_extract(ref, pattern_degree_year),
                          TRUE ~ df4$degree1_year)) %>%
    mutate(ref = str_remove(ref, pattern_degree_year)) %>%
    #cleaning 
    mutate(ref = str_remove(ref, "^(,|\\.|;|, and | and )")) %>%
    mutate(ref = str_trim(ref, "left"))



#Controling
df4_control <- df4 %>% 
  filter(is.na(degree1_year))
#df4_control <- rbind(df4_control, df3_control)
rm(df4_control)
#df5 <- df4 %>% filter(!is.na(degree1_year))
#rm(df4)

####DEGREE2#### 
### First of all, we need to manage few cases where years degree2 and degree3 (or degree3 and degree4) are together

df5 <- df4 %>% 
  #cleaning typo 
  mutate(ref = str_remove(ref, "^(and )"))  %>%
  #Put double years in a separate col "double_year"
  mutate(double_degree = str_extract(ref, pattern_double_degree))

df5 <- df5 %>% 
  mutate(degree3 = case_when(
                    !is.na(degree2) & is.na(degree3) ~ str_extract(double_degree, pattern_degree),
                    TRUE ~ as.character(df5$degree3))) %>%
  #cleaning this first extract
  mutate(ref = str_remove(ref, "^(C\\.\\),) ")) %>%
  #extracting 
  mutate(degree2 = 
           case_when(is.na(degree2) ~ str_extract(double_degree, pattern_degree),
                     TRUE ~ as.character(df5$degree2))) %>%
  mutate(double_degree = str_remove(double_degree, pattern_degree)) %>% #removing first ref from double ref
  mutate(double_degree = str_remove(double_degree, "^(. )")) %>% 
  mutate(degree4 = case_when(
                     !is.na(degree3) & is.na(degree4) ~ str_extract(double_degree, pattern_degree),
                     TRUE ~ as.character(df5$degree4))) %>% 
  mutate(degree3 = case_when(
                     is.na(degree3) ~ str_extract(double_degree, pattern_degree),
                     TRUE ~ as.character(degree3))) %>%
  #cleaning 
  mutate(ref = str_remove(ref, pattern_double_degree)) %>% #delete double year from ref
  mutate(ref = str_remove(ref, "^(. )")) %>% #cleaning ref
  mutate(ref = str_trim(ref, "left")) %>% # cleaning ref 
  subset(select = -c(double_degree)) 

#rm(df1)

#normal extracting pattern_degree and removing it from ref
#for someline, degreeX (X=[2,3]) has been already extracted, and hence the normal extraction is degree X +1
df5 <- df5 %>%
  mutate(degree3 = 
           case_when(!is.na(degree2) & is.na(degree3)~ str_extract(ref, pattern_degree),
                     TRUE ~ df5$degree3)) %>%
  mutate(degree2 = 
           case_when(is.na(degree2) ~ str_extract(ref, pattern_degree), 
                     TRUE ~ df5$degree2)) %>%
  mutate(ref = str_remove_all(ref, pattern_degree)) 

#exception 
for (i in 1:length(exception_degree)){
  df5 <- df5 %>%
    mutate(degree2 = replace(degree2, str_extract(ref, paste0("^(",exception_degree[i], ")"))==exception_degree[i], exception_degree[i])) %>%
    mutate(ref = str_remove(ref, paste0("^(",exception_degree[i], ")")))
}

#cleaning 
df5 <- df5 %>%
  mutate(ref = str_remove(ref, "^(\\. |, |; |\\.,)")) %>%
  mutate(ref = str_trim(ref, "left")) 


####DEGREE2_university#### 

#first an exception case: when "same" degree2_university = degree1_university
df6 <- df5 %>%
  mutate(degree2_university = 
           case_when(str_detect(ref, "^(same,)") ~ df5$degree1_university,
                     TRUE ~ df5$degree2_university)) %>%
  #cleaning 
  mutate(ref= str_remove(ref, "^(same,)"))

#extract pattern degree_university 
#(we already extract some degree2_university, for these lines, new extraction is degree3_university
df6 <- df6 %>%
  mutate(degree3_university =
           case_when(!is.na(degree2_university) ~ str_extract(ref, pattern_degree_university),
                     TRUE ~ df6$degree2_university)) %>%
  mutate(degree2_university = 
           case_when(is.na(degree2_university) ~ str_extract(ref, pattern_degree_university),
                     TRUE ~ df6$degree2_university)) %>%
  mutate(ref =  str_remove(ref, pattern_degree_university)) %>%
  #cleaning
  mutate(degree3_university = str_remove(degree3_university, "(,)$")) %>%
  mutate(ref = str_trim(ref, "left"))

#exception 
 for (i in 1:length(exception_degree_university)){
  df6 <- df6 %>%
    mutate(degree2_university = replace(degree2_university, str_extract(ref, paste0("^(",exception_degree_university[i], ")"))==exception_degree_university[i], exception_degree_university[i])) %>%
    mutate(ref = str_remove(ref, paste0("^(",exception_degree_university[i], ")")))
}

#cleaning 
df6 <- df6 %>%
mutate(ref = str_remove(ref, "^(\\. |, |; )")) %>%
mutate(ref = str_trim(ref, "left")) 

### controlling 

#df6_control <- df6 %>% 
#filter(is.na(degree2_university))
#rm(df6_control)
####DEGREE2_year#### 

df7 <- df6 %>%
  mutate(degree3_year =
           case_when(!is.na(degree2_year) & is.na(degree3_year) ~ str_extract(ref, pattern_degree_year),
                     TRUE ~ as.character(df6$degree3_year))) %>%
  #cleaning a OCR error 
  mutate(ref = case_when(id_ref == 582 ~ str_replace(ref, "^(19C9. History of labor legislation in the Scandinavian countries. 1911.)",
                                                     "1909. Economic aspects of the Mormon experiments in Utah. 1911."),
                         TRUE ~ df6$ref)) %>%
  #extracting 
  mutate(degree2_year = 
           case_when(is.na(degree2_year) ~ str_extract(ref, pattern_degree_year),
                     TRUE ~ df6$degree2_year)) %>% # extract second year
  mutate(ref = str_remove(ref, pattern_degree_year)) %>% #delete double year from ref
  mutate(ref = str_remove(ref, "^(\\.|,|;)")) %>% #cleaning ref
  mutate(ref = str_trim(ref, "left")) # cleaning ref 

#df7_control <- df7 %>% 
#filter(is.na(degree2_year))

####DEGREE3#### 
df8 <- df7 %>%
  mutate(degree3 = 
           case_when(is.na(degree3) ~ str_extract(ref, pattern_degree),
                     TRUE ~ df7$degree3)) %>%
  #condition on removing ref: only if degree2 was N.A  before the current process 
  #without condition, some degree3 might be deleted. 
  mutate(ref = str_remove(ref, pattern_degree)) %>%
  #cleaning 
  mutate(ref = str_remove(ref, "^(,|\\.|;)")) %>%
  mutate(ref = str_trim(ref, "left"))

#exception 
for (i in 1:length(exception_degree)){
  df8 <- df8 %>%
    mutate(degree2 = replace(degree2, str_extract(ref, paste0("^(",exception_degree[i], ")"))==exception_degree[i], exception_degree[i])) %>%
    mutate(ref = str_remove(ref, paste0("^(",exception_degree[i], ")")))
}

####DEGREE3_university#### 

#first an exception case: when "same" degree2_university = degree1_university
df9 <- df8  %>%
  #pre-cleaning %>%
  mutate(ref = str_remove(ref, "degree. ")) %>%
  mutate(degree3_university = 
           case_when(str_detect(ref, "^(same,)") ~ df8$degree2_university,
                     TRUE ~ df8$degree3_university)) %>%
  #cleaning 
  mutate(ref= str_remove(ref, "^(same,)"))

#extract pattern degree_university 
df9 <- df9 %>%
  #extracting degree4 when degree3 fill
  mutate(degree4_university = 
           case_when(is.na(degree4_university) & !is.na(degree3_university) & !is.na(degree2_university) ~ str_extract(ref, pattern_degree_university),
                     TRUE ~ as.character(df9$degree4_university))) %>%
  mutate(degree3_university =
           case_when(is.na(degree3_university) & !is.na(degree2_university) ~ str_extract(ref, pattern_degree_university),
                           TRUE ~ as.character(df9$degree3_university))) %>%
  mutate(degree2_university =
           case_when(is.na(degree2_university) & !is.na(degree1_university) ~ str_extract(ref, pattern_degree_university),
                     TRUE ~ as.character(df9$degree2_university))) %>%
  mutate(ref =  str_remove(ref, pattern_degree_university))


for (i in 1:length(exception_degree_university)){
  df9 <- df9 %>%
    mutate(degree3_university = replace(degree3_university, str_extract(ref, paste0("^(",exception_degree_university[i], ")"))==exception_degree_university[i], exception_degree_university[i])) %>%
    mutate(ref = str_remove(ref, paste0("^(",exception_degree_university[i], ")")))
}

#cleaning 
df9 <- df9 %>%
  mutate(ref = str_remove(ref, "^(\\. |, )")) %>%
  mutate(ref = str_trim(ref, "left")) 

####DEGREE3_year#### 
df9 <- df9 %>%
  #extracting degree4 when degree3 fill
  mutate(degree3_year = 
           case_when(is.na(degree3_year) & !is.na(degree2_year) ~ str_extract(ref, pattern_degree_year),
                     TRUE ~ as.character(df9$degree3_year))) %>%
  mutate(ref = str_remove(ref, pattern_degree_year)) %>%
  #cleaning 
  mutate(ref = str_remove(ref, "^(\\. |, )")) %>%
  mutate(ref = str_trim(ref, "left")) 

#### Final extraction #### 

#extract remaining degree4_university. 
df9 <- df9 %>% 
  mutate(degree4_university = 
           case_when(is.na(degree4_university)  ~ str_extract(ref, pattern_degree_university),
                     TRUE ~ df9$degree4_university)) %>%
  mutate(ref = str_remove(ref, pattern_degree_university)) %>% 
  mutate(degree4_year = 
           case_when(is.na(degree4_year) ~ str_extract(ref, pattern_degree_year),
                     TRUE ~ as.character(df9$degree4_year))) %>%
  mutate(ref = str_remove(ref, pattern_degree_year))

#cleaning df
delete <- paste0(c("\\(The highest imperial college in Pekin\\.\\)", "(; )?also at"), collapse = "|")
df9 <- df9 %>% 
  mutate(ref = str_remove(ref, delete)) %>%
  mutate(ref = str_remove(ref, "^(;)")) %>%
  mutate(ref = str_trim(ref, "left"))

#cleaning df environnement
rm(df, df1, df2, df3, df4, df5, df6, df7, df8)


#### DUPLICATE #### 
#cleaning df
rm(df, df1, df2, df3, df4, df5, df6, df7, df8)

#We use the Levenshtein distances implemented in agrep func
#to identify duplicate PhD, and we keep only most recent one

df_filter <- df9 %>%
  #removing from title (ref): upper case punctuation, blanc spaces
  mutate(ref = tolower(original_ref)) %>%
  mutate(ref = str_remove_all(original_ref, "[[:punct:]]")) %>%
  mutate(ref = str_remove_all(original_ref, "[[\\s]]")) %>%
  #removing from name: upper case punctuation, blanc spaces
  mutate(ref = tolower(ref)) %>%
  mutate(ref = str_remove_all(ref, "[[:punct:]]")) %>%
  mutate(ref = str_remove_all(ref, "[[\\s]]")) %>%
  #select both ref & name as a filter (name alone is not safe because of homonyms)
  select(c(ref, name))

df_filter <- do.call(paste0, df_filter)  ## concatenate all columns (we apply lv distance once to the all line)
df_save <- df9[0,] ## empty data frame for storing loop results

#for each metadata, search for duplicated based on df_filter
for (i in 1:nrow(df9)){  ## produce results for each line of the data frame
  df_match <- df9[agrep(df_filter[i], df_filter, max=0.3*nchar(df_filter[i])),] ##set level of similarity required (less than 50% dissimilarity in this case)
  df_save <- rbind(df_save, filter(df_match, Year == max(Year)))  ## for lines with matches, keep only the older, store outputs in df_save
  df_save <- df_save[!duplicated(df_save), ] ## delete duplicated lines 
}


#for (i in 1:nrow(df9)){  ## produce results for each row of the data frame
  #df2 <-df9[agrep(xx[i],xx,max=0.3*nchar(xx[i])),] ##set level of similarity required (less than 30% dissimilarity in this case)
  #if(nrow(df2) >= 2){df3 <-rbind(df3, df2)}  ## rows without matches returned themselves...this eliminates them
  #df3<-df3[!duplicated(df3), ]  ## store saved values in df3
#}

#stringdist(xx[i], xx, method = 'lv') 

#d_matrix <- stringdistmatrix(df9$name_id, df9$name_id, method = 'lv', useNames= "string")
#d_matrix[upper.tri(d_matrix, diag = TRUE)] <- NA
#d_db <- setNames(reshape2::melt(d_matrix, na.rm = TRUE), c('real_name', 'name_id', 'lv_distance'))
