#' Running Topic model
prepped_docs <- readRDS(here::here(FR_intermediate_data_path, "tm", paste0("prepped_docs_", is_text, ".rds")))

#run a structured topic model with data as covariate

library(stm)
structured_topic_model <-
  stm(
    documents = prepped_docs$documents,
    vocab = prepped_docs$vocab,
    prevalence = ~gender + s(date),
    content = ~gender,
    data = prepped_docs$meta,
    K = nb_topics,
    init.type = "Spectral",
    verbose = TRUE,
    seed = seed,
    ngroups = n_groups,
    emtol = 1e-04
  )

saveRDS(structured_topic_model, here::here(FR_intermediate_data_path, "tm", paste0("structured_topic_model_", is_text, ".rds")))