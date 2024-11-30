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

people_table <- readRDS(here(FR_cleaned_data_path, "people_table.rds")) %>% 
  filter(role == "author") %>% 
  arrange(gender_cleaned) %>% 
  select(doc_id, gender_cleaned) %>% 
  distinct(doc_id, .keep_all = TRUE)
  

#add gender to thesis_table. We have a problem with thesis with several authors. How to select?

corpus <- thesis_table %>%
  left_join(people_table) %>%
  mutate(date = as.integer(date),
         gender = ifelse(is.na(gender_cleaned), "Unknown", gender_cleaned),
         gender = as_factor(gender))

# We create two types of corpus: corpus with titles, and corpus with titles + abstract (abstracts appear as soon as 1986)
corpus_title <- corpus %>%
  rename(text = title.fr) %>% 
  filter(! is.na(text)) %>% 
  select(doc_id, text, date, gender) %>%
  distinct(text, .keep_all = TRUE)

corpus_abstract <- corpus %>% 
  filter(date > 1985,
         !is.na(abstract.fr),
         ! str_detect(abstract.fr, "Le résumé en français n'a pas été")) %>% 
  mutate(text = paste(abstract.fr, title.fr)) %>%
    select(doc_id, text, date, gender) %>%
    distinct(text, .keep_all = TRUE)
  
  
#' #' we want to be sure there is no abstract in english in abstract.fr
#' #' we use textcat to detect language (time-consuming)
#'
#'
deal_with_language <- FALSE

if(deal_with_language){
language <- corpus %>%
  select(doc_id, text) %>%
  mutate(language = textcat::textcat(text))

rows_to_delete <- language %>%
  filter(str_detect(language, "english"))

cat(paste(rows_to_delete %>% nrow, " documents avec un texte en anglais"))

corpus <- corpus %>%
  anti_join(rows_to_delete, by = "doc_id")
}


#' `saveRDS(corpus_abstract, here(FR_intermediate_data_path, "tm", paste0("corpus_abstract.rds")))`
#' `saveRDS(corpus_title, here(FR_intermediate_data_path, "tm", paste0("corpus_title.rds")))`

#' # Topic modelling on corpus
#'
#' To start the session you can load either corpus_title or corpus_abstracts
#' `corpus_abstract <- readRDS(here(FR_intermediate_data_path, "tm", paste0("corpus_abstract.rds")))`
#' `corpus_title <- readRDS(here(FR_intermediate_data_path, "tm", paste0("corpus_title.rds")))`
#' ## Choosing the preprocessing steps and the number of topics ##
#'

# prepare stop_words
stop_words <- bind_rows(get_stopwords(language = "fr", source = "stopwords-iso"),
                        get_stopwords(language = "fr", source = "snowball")) %>% 
  distinct(word) %>% 
  pull(word)

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
    "contribution",
    "travaux",
    "exemple",
    "rôle",
    "aspects",
    "conséquences")

custom_stop_words <- c(stop_words, uninformative_words) %>% 
  unique

#' To install spacy: `spacy_install(python_version = reticulate::py_config()[["version"]])`
spacy_initialize("fr_core_news_sm") # or "fr_core_news_lg"

for(is_text in c("title", "abstract")){
corpus_type <- readRDS(here(FR_intermediate_data_path, "tm", paste0("corpus_", is_text, ".rds")))
parsed <- corpus_type %>% 
  mutate(text = str_replace_all(text, "’", "'") %>% # problematic character for lemmatisation
           tolower(),
         text = str_remove_all(text, "[>]{1,2}"),
         text = str_replace_all(text, "ﬂ", "fl"),
         text = str_replace_all(text, "ﬁ", "fi"),
         text = str_trim(text, "both")) %>% 
  pull(text) %>% 
  spacy_parse()

parsed_filtered <- parsed %>% 
  as.data.table %>% 
  filter(! pos %in% c("PUNCT", "SYM", "SPACE"),
         token != "-",
         ! str_detect(token, "^\\d+$")) %>%
  mutate(lemma = str_remove_all(lemma, "[[:punct:]]")) %>% 
  filter(str_detect(lemma, "[[:letter:]]")) %>% 
  .[, `:=`(bigram = ifelse(token_id < lead(token_id), str_c(lemma, lead(lemma), sep = "_"), NA),
           trigram = ifelse(token_id + 1 < lead(token_id, 2), str_c(lemma, lead(lemma), lead(lemma, 2), sep = "_"), NA)),
    by = .(doc_id, sentence_id)] %>% 
  filter(! lemma %in% custom_stop_words,
         ! token %in% custom_stop_words) 

bigrams <- parsed_filtered %>% 
  select(doc_id, sentence_id, token_id, bigram) %>% 
  filter(! is.na(bigram)) %>% 
  mutate(window_id = 1:n()) %>%
  add_count(bigram) %>% 
  filter(n > 10) %>% 
  separate(bigram, c("word_1", "word_2"), sep = "_") %>% 
  filter(if_all(starts_with("word"), ~ ! . %in% custom_stop_words))

#trigrams <- parsed_filtered %>% 
 # select(doc_id, sentence_id, token_id, trigram) %>% 
#  filter(! is.na(trigram)) %>% 
 # mutate(window_id = 1:n()) %>%
  #add_count(trigram) %>% 
#  filter(n > 10) %>% 
 # separate(trigram, c("word_1", "word_2", "word_3"), sep = "_") %>% 
  #filter(if_all(starts_with("word"), ~ ! . %in% custom_stop_words))

bigram_pmi_values <- bigrams %>% 
  pivot_longer(cols = starts_with("word"), names_to = "rank", values_to = "word") %>% 
  mutate(word = paste0(rank, "_", word)) %>% # We do that because pmi does not take into account the order of words
  select(window_id, word, rank) %>% 
  widyr::pairwise_pmi(word, window_id) %>% 
  arrange(item1, pmi) %>% 
  filter(str_detect(item1, "word_1")) %>% 
  mutate(across(starts_with("item"), ~str_remove(., "word_(1|2)_"))) %>% 
  rename(word_1 = item1,
         word_2 = item2,
         pmi_bigram = pmi) %>% 
  group_by(word_1) %>% 
  mutate(rank_pmi_bigram = 1:n())

#trigram_pmi_values <- trigrams %>% 
 # pivot_longer(cols = starts_with("word"), names_to = "rank", values_to = "word") %>% 
#  mutate(word = paste0(rank, "_", word)) %>% # We do that because pmi does not take into account the order of words
 # select(window_id, word, rank) %>% 
#  widyr::pairwise_pmi(word, window_id) %>% 
 # arrange(item1, pmi) %>% 
  #filter(str_detect(item1, "word_1")) %>% 
  #mutate(across(starts_with("item"), ~str_remove(., "word_(1|2)_"))) %>% 
  #rename(word_1 = item1,
  #       word_2 = item2,
   #      pmi_bigram = pmi) %>% 
  #group_by(word_1) %>% 
  #mutate(rank_pmi_bigram = 1:n())

bigrams_to_keep <- bigrams %>% 
  left_join(bigram_pmi_values) %>% 
  filter(pmi_bigram > 3,
         rank_pmi_bigram < 10) %>%
  mutate(bigram = paste0(word_1, "_", word_2)) %>% 
  distinct(bigram) %>% 
  mutate(keep_bigram = TRUE)

parsed_final <- parsed_filtered %>% 
  left_join(bigrams_to_keep) %>% 
  mutate(lemma = if_else(keep_bigram, bigram, lemma, missing = lemma),
         lemma = if_else(lag(keep_bigram), lag(bigram), lemma, missing = lemma),
         token_id = if_else(lag(keep_bigram), token_id - 1, token_id, missing = token_id)) %>% 
  distinct(doc_id, sentence_id, token_id, lemma)

doc_id <- corpus_type %>% 
  distinct(doc_id) %>% 
  mutate(id = paste0("text", 1:n()))
  
term_list <- parsed_final %>% 
  rename(id = doc_id) %>% 
  left_join(doc_id) %>% 
  select(-id)

saveRDS(term_list, here(FR_intermediate_data_path, "tm", paste0("terms_list_", is_text, ".rds")))
}

threshold_title <- 0.001
threshold_abstract <- 0.003

for(is_text in c("title", "abstract")){
terms_list <- readRDS(here(FR_intermediate_data_path, "tm", paste0("terms_list_", is_text, ".rds"))) %>% 
  rename(term = lemma)

label <- paste0("threshold_", is_text)
threshold <- eval(ensym(label))
#term frequency 
terms_frequency <- terms_list %>%
  count(term, name = "frequency") %>%
  filter(frequency <= distinct(term_list, doc_id) %>% 
           nrow() * threshold)

#remove words 
terms_list_filtered <- terms_list %>%
  anti_join(terms_frequency, by = "term")

#transform list of terms into stm object 
corpus_in_dfm <- terms_list_filtered %>%
  add_count(term, doc_id) %>%
  cast_dfm(doc_id, term, n)

corpus_type <- readRDS(here(FR_intermediate_data_path, "tm", paste0("corpus_", is_text, ".rds")))
metadata <- terms_list_filtered %>%
  select(doc_id) %>% 
  left_join(select(corpus_type, doc_id, date, gender, text)) %>% 
  distinct(doc_id, date, gender, text)

prepped_docs <- quanteda::convert(corpus_in_dfm, to = "stm",  docvars = metadata)

saveRDS(prepped_docs, here(FR_intermediate_data_path, "tm", paste0("prepped_docs_", is_text, ".rds")))
}

#' Running the script to choose the number of topics
#set.seed(123)

for(is_text in c("title", "abstract")){
seed <- c(123)
nb_cores <- availableCores()/2 - 1

#' Run the topic model in background
jobRunScript(here("script", "project_french_phd", "textual_analysis", "background_scripts", "stm_choosing_model.R"),
             importEnv = TRUE)
}

#' searching k

many_stm <- readRDS(here(FR_intermediate_data_path, "tm", paste0("many_stm_", is_text, ".rds")))
heldout <- make.heldout(prepped_docs$documents,
                        prepped_docs$vocab)

k_result <- many_stm %>%
  mutate(
    #exclusivity = map(st_models, exclusivity),
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
    #exclusivity = map_dbl(exclusivity, mean),
    lbound,
  )

#intemerdiate saving
#' `saveRDS(k_result, here(FR_intermediate_data_path, "tm", paste0("k_result_", is_text, ".rds")), compress = TRUE)`
#' `k_result <- readRDS(here(FR_intermediate_data_path, "tm", paste0("k_result_", is_text, ".rds")))`



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
  paste0("K_eval_", is_text, ".jpg"),
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
  paste0("K_coherence_&_exclu_", is_text, ".jpg"),
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
  paste0("plot_mix_exclusivity_", is_text, ".jpg"),
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

