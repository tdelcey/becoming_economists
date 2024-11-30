source(here::here("0_paths_and_packages.R"))

thesis_table <- readRDS(here(FR_cleaned_data_path, "thesis_table.rds")) %>%
  ungroup


#tf frequency with essais in the title (all corpus)
gg <- thesis_table %>%
  select(title.fr, date) %>%
  group_by(date) %>%
  unnest_tokens(input = title.fr,
               output = token) %>%
  add_count(date) %>%
  filter(str_detect(token, "essais")) %>%
  add_count(date) %>%
  ggplot() +
  geom_line(aes(x = as.numeric(date), y = nn/n), 
            linewidth = 1.5,
            colour = "darkblue") +
  labs(
    x = "",
    y = "Term frequency",
    title = "Fréquence du mot 'essais'",
    subtitle = "Normalisé par le nombre de mots dans le corpus"
  ) + 
  theme_light()
  

ggsave(
  paste0("thèse_articles", ".jpg"),
  device = "jpg",
  plot = gg,
  path = here(figures_path, "french_internationalization"),
  width = 10,
  height = 8,
  dpi = 300
)


sudoc_thesis_df %>%
  select(titres.fr, date) %>%
  filter(str_detect(title.fr, "essais")) %>%
  add_count(date) %>%
  ggplot() +
  geom_line(aes(x = as.numeric(date), y = n), 
            linewidth = 1.5,
            colour = "darkblue") +
  ylab("Term frequency") +
  xlab("Year") +
  theme_light()

