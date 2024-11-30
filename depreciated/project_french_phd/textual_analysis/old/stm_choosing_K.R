#' SCRIPT FOR CHOOSING K 
#'
#' Thomas node: Basically, I use stm function and aurelien topic model function 
#' but without the loop (too much computational time and running errors)

source(here::here("0_paths_and_packages.R"))

source(here("script",
            "project_french_phd",
            "functions_for_tm.R"))

#' Open data

thesis_table <-
  readRDS(here(FR_cleaned_data_path, "thesis_table.rds")) %>% ungroup

people_table <-
  readRDS(here(FR_cleaned_data_path, "people_table.rds")) %>% ungroup



corpus <- thesis_table %>%
  left_join(select(people_table, c(gender_cleaned, doc_id))) %>%
  select(doc_id, title.fr, date, gender_cleaned) %>%
  distinct(title.fr, .keep_all = TRUE) %>%
  mutate(date = as.integer(date),
         gender = as.factor(gender_cleaned))



#' we first want to be sure there is no title in english in title.fr
#' we use textcat to detect language

language <- corpus %>%
  select(doc_id, title.fr) %>%
  mutate(language = textcat::textcat(title.fr))

#if there is no title in french, we remove the lines
rows_to_delete <- language %>%
  filter(str_detect(language, "english"))

corpus <- corpus %>%
  anti_join(rows_to_delete, by = "doc_id")

cat(paste(rows_to_delete %>% nrow, " documents supprimés"))

#' To start the session you can load
#' `saveRDS(corpus, here(FR_intermediate_data_path, "tm", "corpus.rds"))`
#' `corpus <- readRDS(here(FR_intermediate_data_path, "tm", "corpus.rds"))`


#' # Topic modelling on titles
#'
#'
#' ## Choosing the preprocessing steps and the number of topics ##
#'



uninformative_words <- c(
  "analyse",
  "affecter",
  "application",
  "appliquer",
  "approche",
  "associer",
  "supposer",
  "hypothèse",
  "tentative",
  "base",
  "call",
  "enquêter",
  "implication",
  "étude",
  "caractériser",
  "choisir",
  "conséquence",
  "décliner",
  "baisse",
  "définir",
  "dépendre",
  "décrire",
  "dû",
  "augmenter",
  "économique",
  "économie",
  "exister",
  "explication",
  "étendre",
  "étendue",
  "tomber",
  "découverte",
  "suivre",
  "générer",
  "identifier",
  "impact",
  "importance",
  "imposer",
  "améliorer",
  "induire",
  "introduire",
  "question",
  "limite",
  "lien",
  "principal",
  "majeur",
  "observer",
  "obtenir",
  "survenir",
  "offrir",
  "pourcentage",
  "période",
  "proposer",
  "fournir",
  "but",
  "question",
  "élever",
  "récent",
  "récemment",
  "réduire",
  "réfléchir",
  "rester",
  "exiger",
  "spécifique",
  "tendance",
  "cas",
  "étude",
  "etude",
  "enjeux",
  "effets",
  "perspective",
  "contribution,
  travaux,
  exemple",
  "entre",
  "rôle",
  "aspects",
  "conséquences",
  "chez",
  "depuis",
  "non"
  )



# create the list of stop_words
stop_words <- get_stopwords(language = "fr") %>%
  pull(word)

custom_stop_words <- append(stop_words, uninformative_words)

#french additional pronoun

corpus2 <- corpus %>%
  mutate(title.fr = str_remove_all(title.fr, "[DdLl][’']"))

#pre-processing
corpus_processed <- textProcessor(
  corpus2$title.fr,
  metadata = corpus %>% select(-title.fr,-doc_id),
  language = "fr",
  customstopwords = custom_stop_words
)


#look at result
look_at_vocab <- corpus_processed$vocab %>%
  as_tibble


#adjust treshhold
#' `plotRemoved(corpus_processed$documents, lower.thresh = seq(1, 10, by = 2))`


#treshold
prepped_docs <- prepDocuments(
  corpus_processed$documents,
  corpus_processed$vocab,
  corpus_processed$meta,
  lower.thresh = 5, #the key pre-processing step
  upper.thresh = Inf
)

#' `saveRDS(prepped_docs, here(FR_intermediate_data_path, "tm", "prepped_docs.rds"))`

#' ##  K evaluation ##
#' 
#' depreciated code 
#'
#' #'stm function
# kresult <- searchK(corpus_processed$documents,
#                    corpus_processed$vocab,
#                    seq(80, 200, by = 10),
#                    init.type	= "LDA",
#                    cores = 1) #only 1 is available on window

# saveRDS(kresult, here(FR_intermediate_data_path,
#                       "tm",
#                       "kresult.rds"))

#held-out residual, coherence lower bound
#plot.searchK(kresult)

#set.seed(123)
seed <- c(123)

#prepare furrr parallélisation
nb_cores <- availableCores() - 1
plan(multisession, workers = nb_cores)

#' to start the session open: 
#' `prepped_docs <- readRDS(here(FR_intermediate_data_path, "tm", "prepped_docs.rds"))`

many_stm <- tibble(
  K = seq(50, 150, by = 10)) %>%
  mutate(st_models = future_map(
    K,
    ~ stm(
      documents = prepped_docs$documents,
      vocab = prepped_docs$vocab,
      prevalence = ~gender + s(date),
      content = ~gender,
      data = prepped_docs$meta,
      K = .,
      init.type = "Spectral",
      max.em.its = 800,
      verbose = FALSE,
      seed = seed
    ),
    .progress = TRUE,
    .options = furrr_options(seed = seed)
  ))

#intemerdiate saving
#' `saveRDS(many_stm, here(FR_intermediate_data_path, "tm", "many_stm.rds"))`
#' `many_stm <- readRDS(here(FR_intermediate_data_path, "tm", "many_stm.rds"))`


#' searching k


heldout <- make.heldout(prepped_docs$documents,
                        prepped_docs$vocab)

k_result <- many_stm %>%
  mutate(
    exclusivity = map(st_models, exclusivity),
    semantic_coherence = map(st_models, semanticCoherence, prepped_docs$documents),
    eval_heldout = map(st_models, eval.heldout, heldout$missing),
    residual = map(st_models, checkResiduals, prepped_docs$documents),
    bound =  map_dbl(st_models, function(x) max(x$convergence$bound)),
    lfact = map_dbl(st_models, function(x) lfactorial(x$settings$dim$K)),
    lbound = bound + lfact
  ) %>%
  # select(-bound, -lfact) %>%
  transmute(
    K,
    heldout = map_dbl(eval_heldout, "expected.heldout"),
    residual = map_dbl(residual, "dispersion"),
    semantic_coherence = map_dbl(semantic_coherence, mean),
    exclusivity = map_dbl(exclusivity, mean),
    lbound,
  )
#intemerdiate saving
#' `saveRDS(k_result, here(FR_intermediate_data_path, "tm", "k_result.rds"))`
#' `k_result <- readRDS(here(FR_intermediate_data_path, "tm", "k_result.rds"))`



#plotting metrics

k_metric_summary <- k_result %>%
  rename(`Heldout` = heldout) %>%
  gather(Metric, Value, -K)


gg <- k_metric_summary %>%
  ggplot(aes(K, Value, color = Metric)) +
  geom_point(size = 1, 
             show.legend = FALSE) +
  geom_line(linewidth = 1.5,
            alpha = 0.7,
            show.legend = FALSE) +
  facet_wrap(~ Metric, scales = "free_y") +
  scale_color_viridis_d() +
  labs(
    x = "K (number of topics)",
    y = NULL,
    title = "Model diagnostics by number of topics",
    subtitle = "These diagnostics indicate that a good number of topics would be around X"
  ) +
  theme(text = element_text(face = "bold")) +                     # Remove all legends from plot) +
  theme_minimal() 

ggsave(
  paste0("K_eval", ".jpg"),
  device = "jpg",
  plot = gg,
  path = here(figures_path, "tm"),
  width = 10,
  height = 10,
  dpi = 300
)


#exlusivity and coherence

gg <- k_result %>%
  select(K, exclusivity, semantic_coherence) %>%
  unnest() %>%
  mutate(K = as.factor(K)) %>%
  ggplot(aes(semantic_coherence, exclusivity, color = K)) +
  geom_point(size = 5, alpha = 0.7) +
  scale_color_viridis_d() +
  labs(
    x = "Semantic coherence",
    y = "Exclusivity",
    title = "Comparing exclusivity and semantic coherence",
    subtitle = "Models with fewer topics have higher semantic coherence for more topics, but lower exclusivity"
  ) +
  theme_minimal()

ggsave(
  paste0("K_coherence_&_exclu", ".jpg"),
  device = "jpg",
  plot = gg,
  path = here(figures_path, "tm"),
  width = 20,
  height = 10,
  dpi = 300
)

#testing different exclusivity parameters
weight_1 <- 0.3
weight_2 <- 0.5
weight_3 <- 0.7
  
# mix_measure <- tuning_results %>% 
mix_measure <- many_stm %>%
  mutate(
    frex_1 = map(st_models, average_frex, w = weight_1, nb_terms = 10),
    frex_2 = map(st_models, average_frex, w = weight_2, nb_terms = 10),
    frex_3 = map(st_models, average_frex, w = weight_3, nb_terms = 10)
  ) %>%
  select(K, frex_1, frex_2, frex_3)

setnames(mix_measure,
         c("frex_1",
           "frex_2",
           "frex_3"),
         c(
           paste0("frex_mean_", weight_1),
           paste0("frex_mean_", weight_2),
           paste0("frex_mean_", weight_3)
         ))

gg  <- mix_measure %>%
  pivot_longer(cols = starts_with("frex"),
               names_to = "measure",
               values_to = "measure_value") %>%
  mutate(measure_value = unlist(measure_value)) %>%
  ggplot(aes(K, measure_value)) +
  geom_point(size = 2, alpha = 0.7) +
  geom_line() +
  facet_wrap( ~ measure, scales = "free_y") +
  theme_bw() +
  labs(x = "Number of topics",
       y = "Frex mean",
       title = "Frex mean value for different number of topics and preprocessing steps")

ggsave(
  paste0("plot_mix_exclusivity", ".jpg"),
  device = "jpg",
  plot = gg,
  path = here(figures_path, "tm"),
  width = 20,
  height = 10,
  dpi = 300
)

#'choose and save the topic model 

saveRDS(filter(many_stm, K == 100), 
        here(FR_intermediate_data_path, 
             "tm", 
             "chosen_topic_models.rds"))

