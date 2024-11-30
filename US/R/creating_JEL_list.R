source("cleaning_data/0_paths_and_packages.R")

library(xml2)
jel_xml <- read_xml(here(raw_data_path, "jel_code_2.xml"), as = "text")
jel_list <- as_list(jel_xml)
jel_code <- tibble(jel_list) %>% 
  unnest_longer(jel_list) %>% 
  select(jel_list) %>% 
  unnest_wider(jel_list) %>% 
  unnest_longer(code) %>% 
  unnest_longer(description) %>%
  pivot_longer(cols = starts_with("classification"), names_to = "rank", values_to = "data") %>% 
  filter(data != "NULL") %>%
  unnest_wider(data, names_repair = "unique") %>% 
  unnest_longer(code...4) %>% 
  unnest_longer(description...5) %>%
  select(-rank) %>% 
  pivot_longer(cols = starts_with("classification"), names_to = "rank", values_to = "data") %>% 
  filter(data != "NULL") %>%
  unnest_wider(data) %>% 
  unnest_longer(code) %>% 
  unnest_longer(description) %>%
  pivot_longer(cols = starts_with("code"), names_to = "rank_code", values_to = "code") %>%
  pivot_longer(cols = starts_with("description"), names_to = "rank_description", values_to = "description") %>% 
  mutate(rank_code = case_when(rank_code == "code...1" ~ 1,
                               rank_code == "code...4" ~ 2,
                               rank_code == "code" ~ 3),
         rank_description = case_when(rank_description == "description...2" ~ 1,
                                      rank_description == "description...5" ~ 2,
                                      rank_description == "description" ~ 3)) %>% 
  filter(rank_code == rank_description) %>% 
  select(code, description, rank = rank_code) %>%
  unique

# cleaning

jel_code <- jel_code %>% 
  mutate(description = str_remove_all(description, " &bull"))

write_csv(jel_code, here(raw_data_path, "jel_code"))
saveRDS(jel_code, here(raw_data_path, "jel_code"))
