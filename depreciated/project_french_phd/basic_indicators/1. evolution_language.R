source(here::here("0_paths_and_packages.R"))

thesis_table <- readRDS(here(FR_cleaned_data_path, "thesis_table.rds")) %>%
  ungroup


#both sudoc and thesis.fr provided a language variable so the analysis is straightforward 


gg <- thesis_table  %>%
  filter(str_detect(language, "^fr$|^en")) %>%
  filter(date %in% c(1990:2020)) %>%
  count(language, date) %>%
  group_by(date) %>%
  mutate(n_perc = n/sum(n)*100) %>%
  ggplot() +
  geom_line(aes(x = as.numeric(date), y = n_perc, colour = language), 
            linewidth = 1.5) +
  scale_color_manual(name = "Langue de la thèse", values = c("fr" = "darkred", 
                                                             "en" = "darkblue",
                                                             "enfr" = "darkgreen")) +
  ylab("Proportion") +
  xlab("") +
  theme_light() 

ggsave("distribution_langue.jpg", plot = gg, path = figures_path, width=5, height=5, dpi=300)


#number of thesis with title in english 
thesis_table %>%
  select(title.en, date) %>%
  filter(!is.na(title.en)) %>%
  count(date) %>%
  ggplot() +
  geom_line(aes(x = as.numeric(date), y = n), 
            linewidth = 1.5,
            colour = "darkred")
