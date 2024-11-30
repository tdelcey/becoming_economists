library(stm)
library(tidyverse)
structured_topic_model <- readRDS(here::here(FR_intermediate_data_path, "tm", paste0("structured_topic_model_", is_text, ".rds")))
prepped_docs <- readRDS(here::here(FR_intermediate_data_path, "tm", paste0("prepped_docs_", is_text, ".rds")))

#' ## topic covariate analysis 

#exploration 
label_topic <- labelTopics(structured_topic_model) 
sage_label_topics <- sageLabels(structured_topic_model)
#findThoughts(structured_topic_model, texts = corpus$title.fr, n=3, topics=83)


#' ### Topic prevalence to metadata 

estimate_effect <- estimateEffect(~gender + s(date),
                                  structured_topic_model,
                                  metadata = prepped_docs$meta %>% as_tibble,
                                  nsims = 200)

saveRDS(estimate_effect, here::here(FR_intermediate_data_path, "tm", paste0("estimate_effect_", is_text, ".rds")))