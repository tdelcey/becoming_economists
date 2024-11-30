### PACKAGE, DATA, FUNCTION ###

source("cleaning_data/0_paths_and_packages.R")

db_original <- readRDS(here(US_txt_intermediate_data_path, "db_with_references")) %>% 
  as.data.frame()

db <- as.data.frame(db_original) %>%
  mutate(ref = str_trim(ref, "both")) %>%
  select(c(doc_year, ref)) %>%
  mutate(original_ref = ref)

db_cleaned <- db %>% 
  mutate(ref = str_replace(ref, "Mass\\.", "Massachussets"),
         ref = str_replace(ref, "Inst\\.", "Institute"),
         ref = str_replace(ref, "Tech\\.", "Technology"),
         ref = str_replace(ref, "(U|u)niv\\. ", "University"))

periods <- data.table(start_year = c(1906, 1912, 1946, 1966, 1974),
                      end_year = c(1911, 1945, 1965, 1973, 2022))

#for(i in 1:nrow(periods)){
 # assign(paste0("db", i),
  #       value = db_cleaned %>% filter(between(doc_year, periods$start_year[i], periods$end_year[i])))
#}

db_list <- list()
for(i in 1:nrow(periods)){
  db_list[[paste0(periods$start_year[i], "-", periods$end_year[i])]] <- db_cleaned %>% filter(between(doc_year, periods$start_year[i], periods$end_year[i]))
}

#tokenization (run one time and saved, we just need to load r.data from data_path)

spacyr_compute <- TRUE
db_token_list <- list()
if(spacyr_compute == TRUE){
  for(i in 1:nrow(periods)){
    tokens <- spacy_parse(db_list[[i]]$ref, pos = TRUE, tag = TRUE, entity = TRUE)
    db_token_list[[paste0(periods$start_year[i], "-", periods$end_year[i])]] <- tokens
  }
  
  saveRDS(db_token_list, here(US_txt_intermediate_data_path, "db_token_list.rds"))
}

# Load tokenization
#' `db_token_list <- readRDS(here(US_txt_intermediate_data_path, "db_token_list.rds")))`


##regex extracting function

extract_regex <-function(df, string, variable, regex, #variables
         clean = FALSE, #paramater
         output = c("extract", "remove", "both")){

    #output  
    if(output == 'extract') {
    df[,variable] = str_extract(df[,string], regex) #extracte regex and put it in a new variable
    }
    if(output == 'remove'){
    df[,string] = str_remove(df[,string], regex) #remove extracted string from original string variable
    } 
    if(output == 'both') {
    df[,variable] = str_extract(df[,string], regex) #both
    df[,string] = str_remove(df[,string], regex)
    }
    
    #cleaning
    if(clean == TRUE){
    df[,variable] = str_trim(df[,variable], "both") #clean
    df[,string] = str_trim(df[,string], 'both') #clean
    return(df)
    }
    if(clean == FALSE) {
    return(df)
    }
}
  
### FIRST PERIOD ###

##strategy: extract through regex.

##regex

year_phd_regex <- "(,|\\.) [:digit:]{4}\\.$"
title_regex <- paste0(
  "(\\.|,)([A-z ,'’;“”\\-\\—\\:\\(\\)", #the general regex: a dot or a comma, follow by words, take account of punctions and digit number
  "([:digit:]*)?", #exceptions: date in many dissertations
  "([:digit:]{4}\\-[:digit:]{2,4})?", #exceptions:  "date-date" in many dissertation titles
  "]+)(\\.)?$")

  
#extract phd_year and create a working db1
db1_working <- extract_regex(db1, 'ref', 'year_phd', year_phd_regex, output = 'both', clean = TRUE)

#filter negative results (either right negative or false negative)
#to be clean manually
db1_negative1 <- db1_working %>% filter(is.na(year_phd)) 

#extract from other lines the title
db1_working <- db1_working %>% filter(!is.na(year_phd))
db1_working <- extract_regex(db1_working, 'ref', 'title', title_regex, output = 'both')

#filter negative results (either right negative or false negative)
db1_negative2 <- db1_working %>% filter(is.na(title))

#normalize number of col for rbind and merge unextracted dataframe
db1_negative1['title'] <- NA
db1_negative <- rbind(db1_negative1, db1_negative2)

db1_working <- db1_working %>%
  filter(!is.na(title)) %>% 
  rename("name and degree" = 'ref')

db1_working <- db1_working[, c("doc_year", "original_ref", "name and degree", "title", "year_phd")]
  
db1_working <- db1_working %>%
mutate(title_length = str_length(title)) %>% #compute length of title
  mutate(title_length_percentile = ntile(title_length, 100)) #percentile

db1_positive <- db1_working %>%
  filter(title_length_percentile < 6 | title_length_percentile > 94)

db1_clean <- db1_working %>%
  filter(title_length_percentile >= 6 & title_length_percentile <= 94)

#evaluation
nrow(db1_negative)/nrow(db1)*100 #percent of potential false_negative lines to check
nrow(db1_positive)/nrow(db1)*100 #percent of potential false_positive lines to check
nrow(db1_clean)/nrow(db1)*100 #percent of presumably clean lines

#save
saveRDS(db1_negative, here(US_txt_intermediate_data_path, "db1_negative_1906_1911"))
saveRDS(db1_positive, here(US_txt_intermediate_data_path, "db1_positive_1906_1911"))
saveRDS(db1_clean, here(US_txt_intermediate_data_path, "db1_clean_1906_1911"))


### SECOND PERIOD ###

#regex
university_phd_regex <- "\\.([A-z ]+)\\.$"
year_phd_regex <- "(,|\\.) [:digit:]{4}$"
title_regex <- paste0(
  "(\\.|,)([A-z ,'’;“”\\-\\—\\:\\(\\)", #the general regex: a dot or a comma, follow by words (letters + space + punctions and parantheses)
  "([:digit:]*)?", #exceptions: date in many dissertations
  "([:digit:]{4}\\-[:digit:]{2,4})?", #exceptions:  "date-date" in many dissertation titles
  "]+)(\\.)?$") #might end by a comma or not (if not it should end by exceptions, if not by the general regex)

## regex method

#extracing university phd
db2_working <- extract_regex(db2, 'ref', 'university_phd', university_phd_regex, output = 'both', clean = TRUE)

#save negative results (either right or false negatives)
db2_negative1 <- db2_working %>%
  filter(is.na(university_phd))

#extracting year phd
db2_working <- db2_working %>% filter(!is.na(university_phd))
db2_working <- extract_regex(db2_working, 'ref', 'year_phd', year_phd_regex, output = 'both', clean = TRUE)

#if not extract, save for later
db2_negative2 <- db2_working %>%
  filter(is.na(year_phd))

#extracting title 
db2_working <- db2_working %>% filter(!is.na(year_phd))
db2_working <- extract_regex(db2_working, 'ref', 'title', title_regex, output = 'both', clean = TRUE)


#negative 
db2_negative3 <- db2_working %>%
  filter(is.na(title))

db2_negative1['title'] <- NA
db2_negative1['year_phd'] <- NA
db2_negative2['title'] <- NA

db2_negative_regex <- rbind(db2_negative1, db2_negative2, db2_negative3)

#positive
db2_working <- db2_working %>%
  filter(!is.na(title)) %>% 
  rename("name and degree" = 'ref')

db2_working <- db2_working[, c("doc_year", "original_ref", "name and degree", "title", "year_phd")]
db2_working <- db2_working %>%
  mutate(title_length = str_length(title)) %>% #compute length of title
  mutate(title_length_percentile = ntile(title_length, 100)) 

#positive 
db2_positive_regex <- db2_working %>% #compute #percentile
  filter(title_length_percentile < 6 | title_length_percentile > 94)

#clean 
db2_clean_regex <- db2_working %>%
  filter(title_length_percentile >= 6 &title_length_percentile <= 94)

nrow(db2_negative_regex)/nrow(db2)*100 #percent of potential false_negative lines to check
nrow(db2_positive_regex)/nrow(db2)*100 #percent of potential false_positive lines to check
nrow(db2_clean_regex)/nrow(db2)*100 #percent of presumably clean lines

## spacy r method 

#mutate textid into ref_id
db2_working <- db2_token %>% mutate(id_ref = str_remove(doc_id, "text") %>% as.integer)


### Extract name&degree (sentence 1), title (sentence 2), and abstract (sentence 3 and more)
db2_1 <- db2_working %>%
  filter(sentence_id == 1) %>%
  group_by(id_ref) %>%
  mutate(name_degree = paste0(token, collapse = ' ')) %>%
  select(id_ref, name_degree) %>%
  unique()

db2_2 <- db2_working %>%
  filter(sentence_id == 2) %>%
  group_by(id_ref) %>%
  mutate(title = paste0(token, collapse = ' ')) %>%
  select(id_ref, title) %>%
  unique()

db2_3 <- db2_working %>%
  filter(sentence_id > 2) %>%
  group_by(id_ref) %>%
  mutate(abstract = paste0(token, collapse = ' ')) %>%
  select(id_ref, abstract) %>%
  unique()

#merge 
db2_working <- merge(db2_1, db2_2, by = "id_ref", all.x = TRUE) %>%
  merge(db2_3, by = 'id_ref', all.x = TRUE)

db2_negative_nlp <- db2_working %>%
  filter(is.na(title))

db2_working <- db2_working %>%
  filter(!is.na(title))

#extract false positive 

db2_working <- db2_working %>%
  mutate(title_length = str_length(title)) %>% #compute length of title
  mutate(title_length_percentile = ntile(title_length, 100))

db2_positive_nlp <- db2_working %>% #compute #percentile
  filter(title_length_percentile < 6 | title_length_percentile > 94)

db2_clean_nlp <- db2_working %>%
  filter(title_length_percentile >= 6 & title_length_percentile <= 94)

#evaluation 
nrow(db2_negative_nlp)/nrow(db2)*100 #percent of potential false_negative lines to check
nrow(db2_positive_nlp)/nrow(db2)*100 #percent of potential false_positive lines to check
nrow(db2_clean_nlp)/nrow(db2)*100 #percent of presumably clean lines


#save
saveRDS(db2_positive_nlp, here(US_txt_intermediate_data_path, "db2_positive_1911-1945"))
saveRDS(db2_negative_nlp, here(US_txt_intermediate_data_path, "db2_negative_1911-1945"))
saveRDS(db2_clean_nlp, here(US_txt_intermediate_data_path, "db2_clean_1911-1945"))

### THIRD PERIOD ###


#mutate textid into ref_id
db3_working <- db3_token %>% 
  mutate(id_ref = str_remove(doc_id, "text")
         %>% as.integer)

### Extract name&degree (sentence 1), title (sentence 2), and abstract (sentence 3 and more)
db3_1 <- db3_working %>%
  filter(sentence_id == 1) %>%
  group_by(id_ref) %>%
  mutate(name_degree = paste0(token, collapse = ' ')) %>%
  select(id_ref, name_degree) %>%
  unique()

db3_2 <- db3_working %>%
  filter(sentence_id == 2) %>%
  group_by(id_ref) %>%
  mutate(title = paste0(token, collapse = ' ')) %>%
  select(id_ref, title) %>%
  unique()

db3_3 <- db3_working %>%
  filter(sentence_id > 2) %>%
  group_by(id_ref) %>%
  mutate(abstract = paste0(token, collapse = ' ')) %>%
  select(id_ref, abstract) %>%
  unique()

#merge 
db3_working <- merge(db3_1, db3_2, by = "id_ref", all.x = TRUE) %>%
  merge(db3_3, by = 'id_ref', all.x = TRUE)

db3_negative <- db3_working %>%
  filter(is.na(title))

db3_working <- db3_working %>%
  filter(!is.na(title))

db3_working <- db3_working %>%
  mutate(title_length = str_length(title)) %>% #compute length of title
  mutate(title_length_percentile = ntile(title_length, 100)) 

db3_positive <- db3_working %>% #compute #percentile
  filter(title_length_percentile < 6 | title_length_percentile > 94) # select title with extreme length values (first and top 5%)

db3_clean <- db3_working %>%
  filter(title_length_percentile >= 6 & title_length_percentile <= 94) # select not extreme values

nrow(db3_negative)/nrow(db3)*100 #percent of potential false_negative lines to check
nrow(db3_positive)/nrow(db3)*100 #percent of potential false_positive lines to check
nrow(db3_clean)/nrow(db3)*100 #percent of presumably clean lines



#save 
saveRDS(db3_positive, here(US_txt_intermediate_data_path, "db3_positive_1946-1965"))
saveRDS(db3_negative, here(US_txt_intermediate_data_path, "db3_negative_1946-1965"))
saveRDS(db3_clean, here(US_txt_intermediate_data_path, "db3_clean_1946-1965"))


### FOURTH PERIOD ###

#mutate textid into ref_id
db4_working <- db4_token %>% mutate(id_ref = str_remove(doc_id, "text") %>% as.integer)


### Extract name&degree (sentence 1), title (sentence 2), and abstract (sentence 3 and more)
db4_1 <- db4_working %>%
  filter(sentence_id == 1) %>%
  group_by(id_ref) %>%
  mutate(name_degree = paste0(token, collapse = ' ')) %>%
  select(id_ref, name_degree) %>%
  unique()

db4_2 <- db4_working %>%
  filter(sentence_id == 2) %>%
  group_by(id_ref) %>%
  mutate(title = paste0(token, collapse = ' ')) %>%
  select(id_ref, title) %>%
  unique()

db4_3 <- db4_working %>%
  filter(sentence_id > 2) %>%
  group_by(id_ref) %>%
  mutate(abstract = paste0(token, collapse = ' ')) %>%
  select(id_ref, abstract) %>%
  unique()

#merge 
db4_working <- merge(db4_1, db4_2, by = "id_ref", all.x = TRUE) %>%
  merge(db4_3, by = 'id_ref', all.x = TRUE)

db4_negative <- db4_working %>%
  filter(is.na(title))

db4_working <- db4_working %>%
  filter(!is.na(title))

#extract false positive 

db4_working <- db4_working %>%
mutate(title_length = str_length(title)) %>% #compute length of title
mutate(title_length_percentile = ntile(title_length, 100)) 

db4_positive <- db4_working %>% #compute #percentile
filter(title_length_percentile < 6 | title_length_percentile > 94) # select title with extreme length values (first and top 5%)

db4_clean <- db4_working %>%
  filter(title_length_percentile >= 6 & title_length_percentile <= 94) # select title with extreme length values (first and top 5%)

#evaluation
nrow(db4_negative)/nrow(db4)*100 #percent of potential false_negative lines to check
nrow(db4_positive)/nrow(db4)*100 #percent of potential false_positive lines to check
nrow(db4_clean)/nrow(db4)*100 #percent of presumably clean lines


###save data
saveRDS(db4_positive, here(US_txt_intermediate_data_path, "db4_positive_post1965"))
saveRDS(db4_negative, here(US_txt_intermediate_data_path, "db4_negative_post1965"))
saveRDS(db4_clean, here(US_txt_intermediate_data_path, "db4_clean_post1965"))

### FIFTH PERIOD ###

#mutate textid into ref_id
db5_working <- db_list$`1974-2022` %>% 
  as.data.table

db5_working[, `:=` (name = str_extract(ref, ".*(?=Ph\\.D\\.)|.*(?=D\\.B\\.A\\.)") %>% str_trim("both"),
            ref_cleaned = str_extract(ref, "(?<=Ph\\.D\\.).*|(?=D\\.B\\.A\\.).*"))] # extracting name
db5_working[, name := str_remove(name, "[:punct:]$")] #clean name
db5_working[, `:=` (university = str_extract(ref_cleaned, ".*?(?=\\d{4})") %>% str_trim("both"),
                    title = str_extract(ref_cleaned, "(?<=\\d{4}).*") %>% str_remove("^[:punct:]") %>%  str_trim("both"),
                    year = str_extract(ref_cleaned, "\\d{4}"))]
column_to_check <- c("university", "title", "year", "name")
db5_working <- db5_working[, (paste0("na_", columns_to_check)) := lapply(.SD, function(x) is.na(x)), .SDcols = column_to_check ]
db5_working <- db5_working[, (paste0("length_", columns_to_check)) := lapply(.SD, function(x) str_count(x)), .SDcols = column_to_check]
db5_working <- db5_working[, (paste0("length_", columns_to_check)) := lapply(.SD, function(x) ifelse(is.na(x), 0, x)), .SDcols = paste0("length_", columns_to_check)]
db5_working <- db5_working[, university := ifelse(is.na(university), str_extract(ref_cleaned, "^[A-z]+([A-z]+)?(?=\\.)"), university)]

# spotting problems

db5_problems <- db5_working %>% 
  filter(if_any(all_of(paste0("na_", columns_to_check)), ~.==TRUE) |
           length_university == 0 |
           length_name < 7 |
           ntile(length_title, 100) >= 98 |
           ntile(length_title, 100) <= 2)


db5_1 <- db5_working %>%
  filter(sentence_id == 1) %>%
  group_by(id_ref) %>%
  mutate(name_degree = paste0(token, collapse = ' ')) %>%
  select(id_ref, name_degree) %>%
  unique()

db4_2 <- db4_working %>%
  filter(sentence_id == 2) %>%
  group_by(id_ref) %>%
  mutate(title = paste0(token, collapse = ' ')) %>%
  select(id_ref, title) %>%
  unique()

db4_3 <- db4_working %>%
  filter(sentence_id > 2) %>%
  group_by(id_ref) %>%
  mutate(abstract = paste0(token, collapse = ' ')) %>%
  select(id_ref, abstract) %>%
  unique()

#merge 
db4_working <- merge(db4_1, db4_2, by = "id_ref", all.x = TRUE) %>%
  merge(db4_3, by = 'id_ref', all.x = TRUE)

db4_negative <- db4_working %>%
  filter(is.na(title))

db4_working <- db4_working %>%
  filter(!is.na(title))

#extract false positive 

db4_working <- db4_working %>%
  mutate(title_length = str_length(title)) %>% #compute length of title
  mutate(title_length_percentile = ntile(title_length, 100)) 

db4_positive <- db4_working %>% #compute #percentile
  filter(title_length_percentile < 6 | title_length_percentile > 94) # select title with extreme length values (first and top 5%)

db4_clean <- db4_working %>%
  filter(title_length_percentile >= 6 & title_length_percentile <= 94) # select title with extreme length values (first and top 5%)

#evaluation
nrow(db4_negative)/nrow(db4)*100 #percent of potential false_negative lines to check
nrow(db4_positive)/nrow(db4)*100 #percent of potential false_positive lines to check
nrow(db4_clean)/nrow(db4)*100 #percent of presumably clean lines


###save data
saveRDS(db4_positive, here(US_txt_intermediate_data_path, "db4_positive_post1965"))
saveRDS(db4_negative, here(US_txt_intermediate_data_path, "db4_negative_post1965"))
saveRDS(db4_clean, here(US_txt_intermediate_data_path, "db4_clean_post1965"))





