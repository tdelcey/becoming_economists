#' TOPIC ANALYSIS
#' Thomas note: Basically, I use aurelien topic model functions 
#' but without the loop (too much computational time and running errors)

source(here::here("0_paths_and_packages.R"))
source(here("script",
            "project_french_phd",
            "functions_for_tm.R"))

#' Choose to run the TM on abstracts or titles. Choose other parameters for tm

seed <- c(123)
nb_topics <- 120
n_groups <- 4 # batching the data to accelerate the computation (see doc)

#' Run the topic model in background

for(is_text in c("abstract", "title")){
  print("start")
  jobRunScript(here("script", "project_french_phd", "textual_analysis", "background_scripts", "stm_running_model.R"),
               importEnv = TRUE)
  Sys.sleep(60)
}


for(is_text in c("title", "abstract")){
  structured_topic_model <- readRDS(here(FR_intermediate_data_path, "tm", paste0("structured_topic_model_", is_text, ".rds")))
  
  #find top terms by topic (beta) and label topic 
  top_terms <- tidy(structured_topic_model,
                    matrix = "beta") %>%
    group_by(topic, term) %>%
    summarise(beta_mean = mean(beta)) %>% 
    group_by(topic) %>%
    top_n(7, beta_mean) %>%
    summarise(topic_label = paste0(term, collapse = ", "))
  
  saveRDS(top_terms, here(FR_intermediate_data_path, "tm", paste0("top_terms_", is_text, ".rds")))
  
  #we can also look at beta taking account of covariates 
  #top_terms_gender <- tidy(structured_topic_model,
  #                        matrix = "beta")  %>%
  #group_by(topic, term, y.level) %>%
  #summarise(beta_mean = mean(beta)) %>%
  #unique() %>%
  #group_by(topic, y.level) %>%
  #top_n(7, beta_mean) %>%
  #select(topic, term, y.level) %>%
  #summarise(topic_label = list(term)) %>%
  #mutate(topic_label = map(topic_label, paste, collapse = ", ")) %>% 
  #unnest()
  
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
  display_topics <- 120
  gg <- gamma_terms %>%
    top_n(display_topics, gamma) %>%
    ggplot(aes(topic, gamma, label = topic_label, fill = topic)) +
    geom_col(show.legend = FALSE) +
    geom_text(hjust = 0, nudge_y = 0.0005, size = 4) +
    scale_y_continuous(expand = c(0,0),
                       limits = c(0, max(gamma_terms$gamma) + 0.008),
                       labels = percent_format()) +
    coord_flip() +
    theme_tufte(base_family = "IBMPlexSans", ticks = FALSE) +  theme(plot.title = element_text(size = 14)) +
    labs(
      x = NULL,
      y = expression(gamma),
      title = glue::glue("Top {display_topics} topics by prevalence"),
      subtitle = "Words are top contribute to each topic"
    )
  
  ggsave(
    paste0("top_topics_gamma_", is_text, ".jpg"),
    device = "jpg",
    plot = gg,
    path = here(figures_path, "tm"),
    width = 20,
    height = 32,
    dpi = 300
  )
  
  #' ## topic correlation network ## 
  #' we use the correlation coefficients between topics as edges of a network of topics 
  
  
  topic_corr <- topicCorr(structured_topic_model, method = "huge")
  
  nodes <- top_terms
  
  edges <- as.data.frame(as.matrix(topic_corr$poscor)) %>%
    mutate(from = row_number()) %>%
    pivot_longer(cols = all_of(1:nb_topics),
                 names_to = "to",
                 values_to = "weight") %>%
    mutate(to = str_remove(to, "V"),
           from = as.character(from)) %>%
    filter(weight != 0) %>%
    unique()
  
  graph_corr <-
    tbl_graph(nodes = nodes,
              edges = edges,
              directed = FALSE)
  
  graph_corr <- add_clusters(
    graph_corr,
    clustering_method = "leiden",
    objective_function = "modularity",
    resolution = 1,
    n_iterations = 3000,
    seed = seed
  )
  
  color <-
    scico(n = length(unique((
      V(graph_corr)$cluster_leiden
    ))),
    palette = "roma",
    begin = 0.1)
  
  graph_corr <- color_networks(graph_corr,
                               column_to_color = "cluster_leiden",
                               color = color)
  
  graph_corr <-
    vite::complete_forceatlas2(graph_corr, first.iter = 5000)
  
  
  gg <- ggraph(graph_corr,
               layout = "manual",
               x = x,
               y = y) +
    geom_edge_arc0(
      aes(color = color, width = weight),
      strength = 0.3,
      alpha = 0.8,
      show.legend = FALSE
    ) +
    scale_edge_width_continuous(range = c(0.5, 5)) +
    scale_edge_colour_identity() +
    scale_fill_identity() +
    geom_node_label(
      aes(label = topic_label, fill = color, size = size_cluster_leiden),
      show.legend = FALSE,
      alpha = 0.7
    )
  
  
  ggsave(
    paste0("topic_correlation_graph_with_leiden_clustering_", is_text, ".jpg"),
    device = "jpg",
    plot = gg,
    path = here(figures_path, "tm"),
    width = 30,
    height = 30,
    dpi = 300
  )
}

for(is_text in c("abstract", "title")){
  print("start")
  jobRunScript(here("script", "project_french_phd", "textual_analysis", "background_scripts", "stm_estimate_effect.R"),
               importEnv = TRUE)
  Sys.sleep(40)
}

for(is_text in c("title", "abstract")){
  structured_topic_model <- readRDS(here(FR_intermediate_data_path, "tm", paste0("structured_topic_model_", is_text, ".rds")))
  estimate_effect <- readRDS(here(FR_intermediate_data_path, "tm", paste0("estimate_effect_", is_text, ".rds")))
  top_terms <- readRDS(here(FR_intermediate_data_path, "tm", paste0("top_terms_", is_text, ".rds")))
  
  # Look at date 
  
  ee_date <- tidystm::extract.estimateEffect(
    estimate_effect,
    "date",
    structured_topic_model,
    method = "continuous") %>%
    left_join(top_terms, by = "topic")
  
  #slope <- ee_date %>%
  # filter(
  #  covariate.value == max(ee_date$covariate.value) |
  #   covariate.value == min(ee_date$covariate.value)
  #) %>%
  #select(topic_label, covariate.value, estimate) %>%
  #pivot_wider(values_from = estimate, names_from = covariate.value) %>%
  #mutate(slope = `1954` - `2021`) %>%
  #select(topic_label, slope) %>%
  #arrange(slope)
  
  #ee_date <- ee_date %>%
  # left_join(slope)
  
  #' We plot the impact for each topic:
  
  topic_per_year <- ee_date %>% 
    mutate(topic_label = paste0(topic, " - ", topic_label)) %>% 
    ggplot(aes(
        x = covariate.value,
        y = estimate,
#        ymin = ci.lower,
 #       ymax = ci.upper,
        group = factor(topic)
      )
    ) +
    scale_y_continuous(expand = c(0,0)) +
    facet_wrap(~ fct_reorder(str_wrap(topic_label, 25), topic), nrow = 12) +
  #  geom_ribbon(alpha = .5, show.legend = FALSE) +
    geom_line() +
    theme(strip.text = element_text(size = 3)) 
  
  ggsave(
    paste0("topic_per_year_", is_text, ".png"),
    device = ragg::agg_png,
    plot = topic_per_year,
    path = here(figures_path, "tm"),
    width = 50, 
    height = 40,
    units = "cm", 
    res = 300
  )
  
  # Look at gender 
  
  ee_gender <- tidystm::extract.estimateEffect(
    estimate_effect,
    "gender",
    structured_topic_model,
    method = "difference",
    cov.value1 = "Female",
    cov.value2 = "Male") %>%
    left_join(top_terms, by = "topic")
  
  ee_gender_max <- ee_gender %>%
    filter(estimate > 0) %>%
    mutate(gender = "Female") %>%
    slice_max(estimate, n = 15)
  
  ee_gender_min <- ee_gender %>%
    filter(estimate < 0) %>%
    slice_min(estimate, n = 15) %>%
    mutate(gender = "Male")
  
  gg_ee_gender <- rbind(ee_gender_max, ee_gender_min) %>%
    mutate(topic = reorder(topic, estimate)) %>%
    ggplot(aes(x = topic, y = estimate, label = paste(topic, "-", topic_label), fill = gender)) +
    geom_col() +
    geom_text(size = 7,
              position = position_stack(vjust = .5)) +
    scale_fill_brewer(name = "Genre",
                      palette = "Dark2")+
    coord_flip() +
    theme_hc(base_size = 22) +
    theme() +
    labs(
      x = NULL,
      y = "Expected topic proportion difference",
      title = glue::glue("Topics by gender ({is_text}s)")
      # caption = paste("Words are top", expression(beta)
    )
  
  ggsave(
    paste0("gg_ee_gender_", is_text, ".png"),
    device = ragg::agg_png,
    plot = gg_ee_gender,
    path = here(figures_path, "tm"),
    width = 23,
    height = 20,
    dpi = 300
  )
  
#opposite, get topics whith less differences 
ee_gender_min <- ee_gender %>%
    filter(estimate > 0) %>%
    mutate(gender = "Female") %>%
    slice_min(estimate, n = 15)
  
ee_gender_max <- ee_gender %>%
    filter(estimate < 0) %>%
    slice_max(estimate, n = 15) %>%
    mutate(gender = "Male")
  
gg_ee_gender <- rbind(ee_gender_max, ee_gender_min) %>%
    mutate(topic = reorder(topic, estimate)) %>%
    ggplot(aes(x = topic, y = estimate, label = paste(topic, "-", topic_label), fill = gender)) +
    geom_col() +
    geom_text(size = 3,
              position = position_stack(vjust = .5)) +
    scale_fill_brewer(name = "Genre",
                      palette = "Dark2")+
    coord_flip() +
    theme_hc() +
    theme(plot.title = element_text(size = 15)) +
    labs(
      x = NULL,
      y = "Expected topic proportion difference",
      title = "Topics by gender"
      # caption = paste("Words are top", expression(beta)
    )
  
  ggsave(
    paste0("gg_ee_gender_MINIMUM", is_text, ".png"),
    device = ragg::agg_png,
    plot = gg_ee_gender,
    path = here(figures_path, "tm"),
    width = 15,
    height = 15,
    dpi = 300
  )
}


#'#' ### Topic content to meta data 

#exploration 
#dev.off()
plot(structured_topic_model, 
     type = "perspectives", 
     topics = c(53),
     covarlevels = c("Female", "Male"),
     n = 25,
     xlim = 500,
     ylim = 500,
     text.cex = -0.5)


plot(structured_topic_model, 
     type = "perspectives", 
     topics = c(102),
     covarlevels = c("Female", "Male"),
     n = 20,
     text.cex = 3)

#' #'aurelien method to add value to stm:labelTopic() but without this insane loop time consuming computation
#' problem covariates
#' 
#' frex_value <- calculate_frex(structured_topic_model, nb_terms = 20, w = 0.5) %>%
#'   mutate(measure = "frex") %>%
#'   rename(value = frex) %>%
#'   select(-mean)
#' 
#' 
#' beta_value <- calculate_beta(structured_topic_model, nb_terms = 20) %>%
#'   mutate(measure = "beta") %>%
#'   rename(value = beta)
#' 
#' score_value <- calculate_score(structured_topic_model, nb_terms = 20) %>%
#'   mutate(measure = "score") %>%
#'   rename(value = score)
#' 
#' 
#' top_terms <- rbind(frex_value, beta_value, score_value)
#' 
#' 
#' label_topics <- name_topics(top_terms, method = "beta", nb_word = 5)


#we can know look at top words in topic depending of the metrics used

#tidy for plotting 
