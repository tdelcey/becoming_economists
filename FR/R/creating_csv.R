################### Creating a .csv Version of the Database ###################

files <- list.files(FR_cleaned_data_path, pattern = "*.rds", full.names = TRUE)
for (file in files) {
  data <- readRDS(file)
  write_csv(data, str_remove(file, ".rds") %>% str_c(".csv"))
}
