############### Script to remove duplicate ################


checking_doublon <- sudoc %>%
  select(title, date, author, id_doc) %>%
  left_join(select(thesis_kind, c(id_doc, thesis_kind))) 

#find duplicate with get_dupes from Janitor package

perfect_duplicate <- checking_doublon %>%
  get_dupes(title)


#certain duplicate are not perfect duplicate. We find approximate duplicate based on Levenshtein distance 

#we select lines which are not perfect duplicate 
checking_doublon <- checking_doublon %>%
  anti_join(perfect_duplicate)

#we first apply lv distance to title
#WARNING: the loop is time-consuming 
df_save <- checking_doublon[0, ] 

for (i in 1:nrow(checking_doublon)){ 
  #select in df_match lines for which levenshtein distance is equal to 10% of pattern length 
  df_match <- checking_doublon[agrep(checking_doublon$title[i], checking_doublon$title[1:nrow(checking_doublon)], max=0.1),] 
  #if pattern only match itself (1), delete the line
  if (nrow(df_match) > 1){
    df_save <- rbind(df_save, df_match)
  }
  df_save <- df_save[!duplicated(df_save$id_doc), ] ## delete duplicated lines
}

approximate_duplicate_title <- df_save 


saveRDS(approximate_duplicate_title, here(FR_sudoc_intermediate_data_path, "approximate_duplicate_title.rds"))
approximate_duplicate_title <- readRDS(here(FR_sudoc_intermediate_data_path, "approximate_duplicate_title.rds"))

#in approximate title duplicate, check approximate author duplicate

df_save <- approximate_duplicate_title[0, ] 
df_save$match_id <- ""
for (i in 1:nrow(approximate_duplicate_title)){ 
  #select in df_match lines for which levenshtein distance is equal to 10% of pattern length 
  df_match <- approximate_duplicate_title[agrep(approximate_duplicate_title$author[i], approximate_duplicate_title$author[1:nrow(approximate_duplicate_title)], max=0.1),] 
  df_match$match_id <- i 
  #if pattern only match itself (1), delete the line
  if (nrow(df_match) > 1){
    df_save <- rbind(df_save, df_match)
  }
  df_save <- df_save[!duplicated(df_save$id_doc), ] ## delete duplicated lines
}  

approximate_duplicate_title_author <- df_save 

saveRDS(approximate_duplicate_title_author, here(FR_sudoc_intermediate_data_path, "approximate_duplicate_title_author.rds"))


#to merge duplicate line, we first keep the line with the less NA

important_variable <- c("id_doc", "title", "author", "supervisor", 
                        "institution", "date", "thesis_national_number",
                        "thesis_information", "abstract", "topics")

less_na_lines <- approximate_duplicate_title_author %>%
  left_join(select(sudoc, all_of(important_variable))) %>%
  mutate(nb_not_na = rowSums(!is.na(select(., all_of(important_variable))))) %>% 
  group_by(match_id) %>% 
  slice_max(order_by = nb_not_na, n = 1, with_ties = FALSE) 


#delete duplicate 
duplicate_to_delete <- approximate_duplicate_title_author %>%
  ungroup() %>%
  select(id_doc) %>%
  anti_join(less_na_lines)


