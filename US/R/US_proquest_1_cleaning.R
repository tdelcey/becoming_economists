################################################
############## PACKAGE AND  DATA ###############
################################################

source(here(cleaning_path, "0_paths_and_packages.R"))

temp = list.files(path=here(US_pq_raw_data_path), pattern="*proquest*")
myfiles = lapply(temp, read_csv)
df <- do.call(rbind, myfiles)



         