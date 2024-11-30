#' Create a gender variable based on census data 
#' Alex's code 

source(here::here("0_paths_and_packages.R"))

thesis_table <- readRDS(here(FR_cleaned_data_path, "thesis_table.rds")) %>% as.data.table()
people_table <- readRDS(here(FR_intermediate_data_path, "people_table.rds")) %>% as.data.table()

gender_gouv_table <- fread(here(FR_cleaned_data_path, "prenoms_genre_census.csv")) %>% as.data.table()

# remove all punctuation (we don't need dots anymore)
gender_gouv_table[,First_Name_cleaned:=str_replace_all(preusuel, "[:punct:]","")]
gender_gouv_table[,First_Name_cleaned:=tolower(First_Name_cleaned)] 

## remove accents, now we have some duplicate and possible diferences between previously differentiated prenom
gender_gouv_table[,First_Name_cleaned:=stringi::stri_trans_general(First_Name_cleaned, "Latin-ASCII")] 

gender_gouv_table <- gender_gouv_table[,sum(nombre),.(First_Name_cleaned, sexe)]

gender_gouv_table <- data.table::dcast(gender_gouv_table, First_Name_cleaned ~ sexe, value.var = "V1")
gender_gouv_table[is.na(`1`), `1`:=0]
gender_gouv_table[is.na(`2`), `2`:=0]

gender_gouv_table[, n_name:=`1`+`2`]
gender_gouv_table[, share_m:=`1`/n_name]
gender_gouv_table[, share_f:=`2`/n_name]

#if more than 90% of firstname is related to a gender, we assign this firstname to gender   
gender_gouv_table[share_m>=0.9, gender_cleaned:="Male"] 
gender_gouv_table[share_f>=0.9, gender_cleaned:="Female"]
#if not, we do not assign a gender 
gender_gouv_table[is.na(gender_cleaned), gender_cleaned:="Unknown"]

#people table
people_table_name <- copy(people_table)
people_table_name[,prenom_1:=str_replace_all(prenom_1, "[:punct:]","")] # remove all punctuation
people_table_name[,prenom_1:=tolower(prenom_1)] 
people_table_name[,prenom_1:=stringi::stri_trans_general(prenom_1, "Latin-ASCII")] 

prenom_gender_match <- merge(people_table_name, gender_gouv_table[,list("prenom_1"=First_Name_cleaned, gender_cleaned)], by="prenom_1", all.x = TRUE)
prenom_gender_match <- merge(prenom_gender_match, thesis_table[,.(doc_id, date)], by="doc_id", all.x = TRUE)

prenom_gender_match[is.na(gender_cleaned), gender_cleaned:="Unknown"]


saveRDS(prenom_gender_match %>% as_tibble, here(FR_cleaned_data_path, "people_table.rds"))


#' plot 
# author_gender <- prenom_gender_match[role=="author"]
# supervisor_gender <- prenom_gender_match[role=="supervisor"]
# 
# hist_author_gender <- author_gender[,.N,.(gender_cleaned,date)]
# hist_author_gender[,tot:=sum(N),date]
# hist_author_gender[,share:=N/tot]
# 
# ggplot(data=hist_author_gender[date>=1950], aes(x=as.numeric(date), y=share, fill=gender_cleaned)) +
#   geom_bar(stat="identity", alpha = 0.7)+
#   scale_fill_brewer(name = "Genre",
#                     palette="Dark2")+
#   theme_light() +
#   labs(x = "",
#        y = "%",
#        title = "Gender of authors")
# 
# 
# hist_supervisor_gender <- supervisor_gender[,.N,.(gender_cleaned,date)]
# hist_supervisor_gender[,tot:=sum(N),date]
# hist_supervisor_gender[,share:=N/tot]
# 
# ggplot(data=hist_supervisor_gender[date>=1950], aes(x=as.numeric(date), y=share, fill=gender_cleaned)) +
#   geom_bar(stat="identity", alpha = 0.7)+
#   scale_fill_brewer(name = "Genre",
#                     palette="Dark2")+
#   theme_light() +
#   labs(x = "",
#        y = "%",
#        title = "Gender of Supervisor")
