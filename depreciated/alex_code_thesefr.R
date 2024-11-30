# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 0. Specific Functions ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# from_wide_to_long_order_column <- function(table = Raw_theses, 
#                                                       variable_name = "^auteurs")
# {  
#   # Preparing list of variable to transform and variable to make list
#   List_of_variables_table <- str_subset(List_of_variables, variable_name)
#   N_max <- str_extract(List_of_variables_table,"[:digit:]") %>% as.data.table() %>% .[,.N,.] %>% .[,.N]
#   
#   # Extracting and prepping authors table
#   Table <- table[,.SD,.SDcols = c("iddoc",List_of_variables_table)]
#   Table[is.na(Table)] <- "" # remove NA because inconsistency between NA and no char
#   
#   # Making it into a list to lapply
#   list_tables <- list() # transform authors table as lists per order
#   for (number_distinct_variables in 0:(N_max-1)){
#     list_tables[[paste0(number_distinct_variables)]] <- Table[,.SD,.SDcols = c("iddoc",str_subset(List_of_variables,paste0(variable_name,"\\.",number_distinct_variables,"\\.")))]
#     list_tables[[paste0(number_distinct_variables)]] <- list_tables[[paste0(number_distinct_variables)]] %>% .[,order:=number_distinct_variables]
#   }
#   
#   list_tables <- lapply(list_tables, function(df){ # change column names
#     old_name_columns <- ls(df)
#     new_name_columns <- str_replace_all(old_name_columns,paste0(variable_name,"\\.[:digit:]\\."),"")
#     setnames(df, c(old_name_columns), c(new_name_columns))
#   })
#   
#   table_final <- copy(rbindlist(list_tables))
#   
#   return (table_final)
# }
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 1. Thesis table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# List_of_variables_thesis_table <- c("nnt","status","date_soutenance","titres.fr","titres.en","resumes.fr","resumes.en","sujets.fr","sujets.en","sujets_rameau","discipline","langues.0","nnt","source","auteur.idref", "auteur.nom", "auteur.prenom")
# Thesis <- raw_theses[,.SD,.SDcols = c(List_of_variables_thesis_table)]
# Thesis[,Annee_soutenance:=str_sub(date_soutenance,1,4)] # create a Annee_soutenance variable
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 2. Authors table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# author_table_final <- from_wide_to_long_order_column(Raw_theses, variable_name = "^auteurs")
# author_table_final <- author_table_final[!(idref=="" & nom=="" & prenom=="")]
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 3. Supervisors table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# supervisors_table_final <- from_wide_to_long_order_column(Raw_theses, variable_name = "^directeurs_these")
# supervisors_table_final <- supervisors_table_final[!(idref=="" & nom=="" & prenom=="")]
# supervisors_table_final[,role:="supervisor"]
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 4. Jury table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# 
# # Jury
# jury_table_final <- from_wide_to_long_order_column(Raw_theses, variable_name = "^membres_jury")
# jury_table_final <- jury_table_final[!(idref=="" & nom=="" & prenom=="")]
# jury_table_final[,role:="jury"]
# 
# # Reviewers
# reviewers_table_final <- from_wide_to_long_order_column(Raw_theses, variable_name = "^rapporteurs")
# reviewers_table_final <- reviewers_table_final[!(idref=="" & nom=="" & prenom=="")]
# reviewers_table_final[,role:="reviewers"]
# 
# # President
# List_of_variables_president <- str_subset(List_of_variables,"^president_jury")
# # Extracting and prepping authors table
# president_table_final <- Raw_theses[,.SD,.SDcols = c("iddoc",List_of_variables_president)]
# president_table_final[is.na(president_table_final)] <- "" # remove NA because inconsistency between NA and no char
# old_name_columns <- ls(president_table_final)
# new_name_columns <- str_replace_all(old_name_columns,"^president_jury\\.","")
# setnames(president_table_final, c(old_name_columns), c(new_name_columns))
# president_table_final[,role:="president"][,order:=1]
# president_table_final <- president_table_final[!(idref=="" & nom=="" & prenom=="")]
# 
# # Full jury
# full_jury_final_table <- rbind(supervisors_table_final, jury_table_final, reviewers_table_final, president_table_final)
# 
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 5. Labo table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# labo_table_final <- from_wide_to_long_order_column(Raw_theses, "^partenaires_recherche")
# labo_table_final <- labo_table_final[!(idref=="" & nom=="" & type=="")]
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 6. ED table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ED_table_final <- from_wide_to_long_order_column(Raw_theses, "^ecoles_doctorales")
# ED_table_final <- ED_table_final[!(idref=="" & nom=="")]
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 7. University of defense table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Univ_table_final <- from_wide_to_long_order_column(Raw_theses, "^etablissements_soutenance")
# Univ_table_final <- Univ_table_final[!(idref=="" & nom=="")]
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 8. KW table ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# 
# # Keywords - Rameau
# rameau_KW <- copy(Thesis[,.(iddoc,sujets_rameau)])
# rameau_KW <- rameau_KW %>% tidyr::separate_rows(sujets_rameau,sep= "\\|\\|") %>% as.data.table()
# rameau_KW <- rameau_KW[sujets_rameau!=""]
# rameau_KW[,.N,sujets_rameau][order(-N),head(.SD,20)] # top words
# 
# # Keywords - sujets.fr
# fr_KW <- copy(Thesis[,.(iddoc,sujets.fr)])
# fr_KW <- fr_KW %>% tidyr::separate_rows(sujets.fr,sep= "\\|\\|") %>% as.data.table()
# fr_KW <- fr_KW[sujets.fr!=""]
# fr_KW[,.N,sujets.fr][order(-N),head(.SD,20)] # top words
# 
# # Keywords
# en_KW <- copy(Thesis[,.(iddoc,sujets.en)])
# en_KW <- en_KW %>% tidyr::separate_rows(sujets.en,sep= "\\|\\|") %>% as.data.table()
# en_KW <- en_KW[sujets.en!=""]
# en_KW[,.N,sujets.en][order(-N),head(.SD,20)] # top words
# 
# KW_uni1 <- copy(rameau_KW)
# setnames(KW_uni1, "sujets_rameau", "words")
# KW_uni2 <- copy(en_KW)
# setnames(KW_uni2, "sujets.en", "words")
# KW_uni3<- copy(fr_KW)
# setnames(KW_uni3, "sujets.fr", "words")
# KW_unified <- rbind(KW_uni1, KW_uni2, KW_uni3)
# 
# 
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# #### 9. Saving it all ####
# #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# 
# saveRDS(Thesis, here(data_path,"intermediate_data","FR","these_fr","Thesis_table.RDS"))
# saveRDS(author_table_final, here(data_path,"intermediate_data","FR","these_fr","Authors_table.RDS"))
# saveRDS(supervisors_table_final, here(data_path,"intermediate_data","FR","these_fr","Supervisors_table.RDS"))
# saveRDS(full_jury_final_table, here(data_path,"intermediate_data","FR","these_fr","Jury_table.RDS"))
# saveRDS(labo_table_final, here(data_path,"intermediate_data","FR","these_fr","Laboratory_table.RDS"))
# saveRDS(ED_table_final, here(data_path,"intermediate_data","FR","these_fr","ED_table.RDS"))
# saveRDS(Univ_table_final, here(data_path,"intermediate_data","FR","these_fr","Univ_table.RDS"))
# saveRDS(list(rameau_KW, fr_KW, en_KW), here(data_path,"intermediate_data","FR","these_fr","KW_table_separated.RDS"))
# saveRDS(KW_unified, here(data_path,"intermediate_data","FR","these_fr","KW_table_unified.RDS"))
# 
