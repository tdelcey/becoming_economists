#' ##  K evaluation ## TO FINISH
#' to start the session open: 
library(stm)
library(future)
library(furrr)
library(tidyverse)
prepped_docs <- readRDS(here::here(FR_intermediate_data_path, "tm", paste0("prepped_docs_", is_text, ".rds")))

#prepare furrr parallélisation

plan(multisession, workers = nb_cores)

#run multiple correlated topic models

many_stm <- tibble::tibble(
  K = seq(50, 150, by = 10)) %>%
  dplyr::mutate(st_models = future_map(
    K,
    ~ stm(
      documents = prepped_docs$documents,
      vocab = prepped_docs$vocab,
      K = .,
      init.type = "Spectral",
      max.em.its = 800,
      verbose = FALSE,
      seed = seed
    ),
    .progress = TRUE,
    .options = furrr_options(seed = seed)
  ))

saveRDS(many_stm, here(FR_intermediate_data_path, "tm", paste0("many_stm_", is_text, ".rds")), compress = TRUE)

