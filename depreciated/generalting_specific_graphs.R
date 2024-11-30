source(here::here("0_paths_and_packages.R"))
source(here("script",
            "project_french_phd",
            "functions_for_tm.R"))


abstracts_rate <- readRDS(here(FR_cleaned_data_path, "thesis_table.rds")) %>% 
  ungroup %>% 
  group_by(date) %>% 
  summarise(abstracts_here = sum(!is.na(abstract.fr))/n(),
            abstract_missing = 1 - abstracts_here) %>% 
  pivot_longer(cols = starts_with("abstract"), 
               names_to = "abstracts",
               values_to = "percentage") %>% 
  mutate(percentage = round(percentage, 2),
         date = as.integer(date))
  
abstracts_plot <- abstracts_rate %>% 
  ggplot(aes(date, percentage, fill = abstracts)) +
  geom_bar(stat = "identity", position = "stack") +
  scico::scale_fill_scico_d(palette = "roma", begin = 0.2, end = 0.8, 
                            labels = c("No", "Yes")) +
  scale_x_continuous(expand = c(0,0), n.breaks = 10) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "Quality of data on abstracts",
       fill = "Do we have an abstract?",
       x = NULL,
       y = NULL) +
  theme(legend.position = "bottom") +
  theme_hc()

ggsave(
  paste0("abstract_presence.png"),
  device = ragg::agg_png,
  plot = abstracts_plot,
  path = figures_path,
  width = 20, 
  height = 15,
  units = "cm", 
  res = 300
)

stm_abstract <- readRDS(here(FR_intermediate_data_path, "tm", paste0("structured_topic_model_abstract.rds")))
stm_title <- readRDS(here(FR_intermediate_data_path, "tm", paste0("structured_topic_model_title.rds")))

for(is_text in c("title", "abstract")){
label <- paste0("stm_", is_text)
structured_topic_model <- eval(ensym(label))
#find average gamma by topic (proportion documents)
gamma_terms <- tidy(structured_topic_model,
                    matrix = "gamma") %>%
  group_by(topic) %>%
  summarise(gamma = mean(gamma)) %>%
  arrange(desc(gamma)) %>%
  left_join(top_terms, by = "topic") %>%
  mutate(topic = paste0("Topic ", topic),
         topic = reorder(topic, gamma))

#plot 
display_topics <- 20
gg <- gamma_terms %>%
  top_n(display_topics, gamma) %>%
  ggplot(aes(topic, gamma, label = str_wrap(topic_label, 50), fill = topic)) +
  geom_col(show.legend = FALSE) +
  geom_text(hjust = 0, nudge_y = 0.0005, size = 8) +
  scale_y_continuous(expand = c(0,0),
                     limits = c(0, max(gamma_terms$gamma) + 0.011),
                     labels = percent_format()) +
  coord_flip() +
  theme_tufte(base_family = "IBMPlexSans", ticks = FALSE,
              base_size = 30) +  
#  theme(plot.title = element_text(size = 14)) +
  labs(
    x = NULL,
    y = expression(gamma),
    title = glue::glue("Top {display_topics} topics by prevalence ({is_text})"),
    subtitle = "Words are top contributors to each topic"
  )

ggsave(
  paste0("top_topics_gamma_", is_text, "_", display_topics, ".jpg"),
  device = "jpg",
  plot = gg,
  path = here(figures_path, "tm"),
  width = 32,
  height = 22,
  dpi = 300
)
}


prepped_docs <- readRDS(here::here(FR_intermediate_data_path, "tm", paste0("prepped_docs_title.rds")))
top_terms <- readRDS(here(FR_intermediate_data_path, "tm", paste0("top_terms_title.rds")))


metadata <- tibble(doc_id = prepped_docs$meta$doc_id,
                   date = prepped_docs$meta$date) %>% 
  mutate(document = 1:n()) 
  
data_per_year <- tidy(stm_title,
     matrix = "gamma") %>%
  left_join(metadata) %>% 
  group_by(topic, date) %>% 
  mutate(mean_gamma = mean(gamma)) %>% 
  distinct(topic, date, mean_gamma) %>% 
  left_join(top_terms) %>% 
  mutate(labels = paste0(topic, " - ", topic_label))

plot_year <- data_per_year %>% 
  filter(topic %in% c(69, 1, 14, 41, 71),
         between(date, 1945, 2022)) %>% 
  ggplot(aes(date, mean_gamma, color = str_wrap(labels, 25))) +
  scale_x_continuous(expand = c(0,0)) +
  geom_smooth(se = FALSE, span = 0.5) +
  theme_hc(base_size = 16) +
  scale_y_continuous(labels = scales::percent_format()) +
  scico::scale_color_scico_d(palette = "roma") +
  labs(y = "Prevalence",
         x = NULL,
         title = "Prevalence of specific topics over years",
         color = NULL)

ggsave(
  paste0("topic_per_year_gamma_mean_title.png"),
  device = ragg::agg_png,
  plot = plot_year,
  path = here(figures_path, "tm"),
  width = 35, 
  height = 25,
  units = "cm", 
  res = 300
)
  

plot_year <- data_per_year %>% 
  filter(between(date, 1945, 2022)) %>% 
    ggplot(aes(
      x = date,
      y = mean_gamma,
      group = factor(labels)
    )
    ) +
    scale_y_continuous(expand = c(0,0)) +
    facet_wrap(~ fct_reorder(str_wrap(labels, 25), topic), nrow = 12, scales = "free_y") +
    #  geom_ribbon(alpha = .5, show.legend = FALSE) +
    geom_smooth(se = FALSE, span = 0.4) +
    theme(strip.text = element_text(size = 3)) 

  ggsave(
    paste0("topic_per_year_gamma_mean_title.png"),
    device = ragg::agg_png,
    plot = plot_year,
    path = here(figures_path, "tm"),
    width = 50, 
    height = 40,
    units = "cm", 
    res = 300
  )



