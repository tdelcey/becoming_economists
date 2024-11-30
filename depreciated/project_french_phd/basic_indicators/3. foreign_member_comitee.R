source(here::here("0_paths_and_packages.R"))

#script for estimating the number of jury members that are foreigners
#foreigners can be defined as people that did not make her phd in France

#data 
thesis_table <- readRDS(here(FR_cleaned_data_path, "thesis_table.rds"))
people_table <- readRDS(here(FR_cleaned_data_path, "people_table.rds"))


#find people that have been supervisor, member, or referee but have not been "author"

not_foreign_people_table <- people_table %>% 
  group_by(nom, prenom) %>% 
  filter(all(role %in% "author") 
         & any(role %in% c("supervisor", "member", "referee")))

foreign_people_table <- people_table %>% 
  group_by(nom, prenom) %>% 
  filter(all(!role %in% "author") 
         & any(role %in% c("supervisor", "member", "referee"))) 

people_table %>%
  filter(!role == "author") %>%
  select(nom, prenom) %>%
  unique() %>%
  nrow()

these_participation_foreigner <- foreign_people_table %>%
  select(nom, prenom) %>%
  count() 
