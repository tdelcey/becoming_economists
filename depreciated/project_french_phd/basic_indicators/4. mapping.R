source(here::here("0_paths_and_packages.R"))

#' script for heat mapping the number of thesis in France (at the department level)

#' The goald is to assign a department to every institutions by the successive hypotheses: 
#' Rule 1: If the institution mention a city, the university is in the city 
#' Rule 2: If the institution mention a region, the university is in the admin city of the region (i.e. Université de Bourgogne == Dijon)
#' Rule 4: (not implemented yet) handmade assignment (i.e. University Gustave Effeil, Sorbonne, etc.)


#data gouv about dep, reg and city
city <-
  read.csv(here(raw_data_path, "data_french_map", "cities.csv"))
department <-
  read.csv(here(raw_data_path, "data_french_map", "departments.csv"))
regions <-
  read.csv(here(raw_data_path, "data_french_map", "regions.csv"))
university_table <-
  readRDS(here(FR_cleaned_data_path, "University_table.rds"))


thesis_table <-
  readRDS(here(FR_cleaned_data_path, "thesis_table.rds"))

# safe check since university_table are not cleaned yet 
university_table <- thesis_table %>%
  ungroup() %>%
  select(doc_id) %>%
  left_join(select(university_table,-idref), by = "doc_id") %>%
  unique()

#merge datagouv data 
city_dep_region <- city %>%
  rename(
    city_slug = slug,
    city_name = name,
    city_lat = gps_lat,
    city_long = gps_lng
  ) %>%
  left_join(select(department, c(code, name, slug, region_code)), by = c("department_code" = "code")) %>%
  rename(dep_name = name,
         dep_slug = slug) %>%
  left_join(select(regions, c(code, name, slug)), by = c("region_code" = "code")) %>%
  rename(reg_name = name,
         reg_slug = slug) %>%
  mutate(name_dep2 = str_remove_all(dep_slug, "'")) %>%
  mutate(name_dep2 = iconv(name_dep2, to = "ASCII//TRANSLIT")) %>%
  mutate(name_dep2 = str_to_lower(name_dep2)) %>%
  select(-c(zip_code, id)) %>%
  group_by(insee_code) %>%
  mutate(city_lat = mean(city_lat),
         city_long = mean(city_long)) %>%
  ungroup() %>%
  select(-insee_code) %>%
  unique()


#data linking new regions with the older regions classification 
french_regions <-
  readxl::read_xlsx(here(
    raw_data_path,
    "data_french_map",
    "french_new_former_regions.xlsx"
  ),
  sheet = 2)

#cleaning value 
older_french_regions <- french_regions %>%
  filter(str_detect(`Code 2021`, "FR.*")) %>%
  select(1, 3:6) %>%
  mutate(id = str_remove_all(`Code 2021`, "[:digit:]*")) %>%
  group_by(id) %>%
  fill(everything(), .direction = "updown") %>%
  ungroup() %>%
  select(`NUTS level 1`, `NUTS level 2`, `NUTS level 3`) %>%
  rename(reg_name = `NUTS level 1`,
         reg_old_name = `NUTS level 2`) %>%
  transmute(
    reg_name = str_to_lower(reg_name),
    reg_old_name = str_to_lower(reg_old_name),
    reg_name = iconv(reg_name, to = "ASCII//TRANSLIT"),
    reg_old_name = iconv(reg_old_name, to = "ASCII//TRANSLIT"),
    reg_name = str_replace_all(reg_name, "[[:punct:]]", " "),
    reg_old_name = str_replace_all(reg_old_name, "[[:punct:]]", " "),
    reg_name = str_replace_all(reg_name, "  ", " "),
    reg_name = str_replace_all(reg_name, "\\p{Pd}", " "),
    reg_old_name = str_replace_all(reg_old_name, "\\p{Pd}", " "),
    reg_old_name = str_replace_all(reg_old_name, "  ", " ")
  ) %>%
  unique() %>%
  group_by(reg_name) %>%
  mutate(reg_old_name = list(reg_old_name))

#city to remove that will interfere with the matching rule 
city_to_remove <- c("Clermont", "Aix")

city_dep_region <- city_dep_region %>%
  left_join(older_french_regions, by = c("reg_slug" = "reg_name")) %>%
  filter(!city_name %in% city_to_remove) %>% 
  unique()

#data which associated admin city with the region  
word_cities <-
  read.csv(here(raw_data_path, "data_french_map", "worldcities.csv"))

french_admin_cities <- word_cities %>%
  filter(country == "France",
         capital == "primary" |
           capital == "admin") %>%
  transmute(
    city_name = str_to_lower(city),
    city_name = iconv(city_name, to = "ASCII//TRANSLIT"),
    reg_name = str_to_lower(admin_name),
    reg_name = str_replace_all(reg_name, "[[:punct:]]", " "),
    reg_name = iconv(reg_name, to = "ASCII//TRANSLIT"),
    is_admin = "yes"
  ) %>%
  unique()

#merge all geographical data 
city_dep_region <- city_dep_region %>%
  left_join(french_admin_cities,
            by = c("reg_slug" = "reg_name",
                   "city_slug" = "city_name"))


saveRDS(city_dep_region,
        here(raw_data_path, "data_french_map", "city_dep_region.rds"))

#### merge with university table ### 

#' city matching 
#' WARNING: imperfect matching
#' the university name can match a small city whose name is a subset or the same than the targeted one 

#when the university mention a city, the institution is in the city 
university_with_city_name <- university_table %>%
  mutate(
    # data are not clean yet, so I will use only second_institution that are more informative about the city
    # institution = ifelse(is.na(institution), "", institution),
    # second_institution = ifelse(is.na(second_institution), "", second_institution),
    # university_name = paste(institution, second_institution),
    university_name = second_institution,
    university_name = iconv(university_name, to = "ASCII//TRANSLIT"),
    university_name = str_replace_all(university_name, "[[:punct:]]", " ")
  ) %>%
  mutate(city_slug = str_extract(
    university_name,
    paste0("\\b", city_dep_region$city_slug, "\\b", collapse = "|")
  )) %>%
  left_join(city_dep_region, by = c("city_slug" = "city_slug")) %>%
  unique()

#region matching 
#when the university mention a region, the institution is in the admin city of the region  
university_with_region_name <- university_with_city_name %>%
  filter(is.na(city_slug)) %>%
  select(doc_id, university_name) %>%
  mutate(reg_slug = str_extract(
    university_name,
    paste0("\\b", city_dep_region$reg_slug, "\\b", collapse = "|")
  )) %>%
  left_join(city_dep_region %>%
              filter(is_admin == "yes"),
            by = c("reg_slug" = "reg_slug"))

#' institution with no city 
#' #evaluation: problem with older region university (lorraine) and some exceptions "sorbonne"

university_not_found <- university_with_region_name %>%
  filter(is.na(city_slug))


#merge city and region matching 
university_with_region_name_found <- university_with_region_name %>%
  filter(!is.na(city_slug))

university_found <- university_with_city_name %>%
  filter(!is.na(city_slug)) %>%
  bind_rows(university_with_region_name_found)

#count the number of thesis by city 
university_count <- university_found %>%
  select(-second_institution,-institution,-university_name) %>%
  unique() %>%
  add_count(city_name) %>%
  mutate(n2 = n / max(n)) %>%
  filter(!city_name == "Paris")


#building the heatmap

#france map with the boundaries of each department 
france <- map_data("france")
#join university_count with france map 
france_with_university_count <- france %>%
  mutate(region = str_to_lower(region),
         region = str_replace_all(region, "-", " "),
         region = str_remove_all(region, "'")) %>%
  left_join(university_count, by = c("region" = "dep_slug"))

  
# keep only top city for gglabel 
top_city <- university_count %>%
  select(city_name,  city_long,  city_lat, n) %>%
  unique() %>%
  slice_max(n, n = 20) %>%
  mutate(city_name = (str_to_title(city_name)))

#map 
gg <- france_with_university_count %>%
  ggplot() +
  geom_polygon(aes(
    x = long,
    y = lat,
    group = group,
    fill = n
  ),
  color = "white",
  stat = "identity") +
  theme_void() +
  coord_map() +
  scale_fill_gradient(name = "Number of theses",
                      low = "green",
                      high = "darkred",
                      na.value = "lightgreen") +
  geom_point(data = top_city,
             aes(x = city_long,
                 y = city_lat),
             size = 0.0001) +
  ggrepel::geom_text_repel(
    data = top_city,
    aes(
      x = city_long,
      y = city_lat,
      label = city_name,
      size = n,
      max.overlaps = 20
    ),
    alpha = 0.9,
    show.legend = FALSE
  ) +
  scale_size_continuous(range = c(3, 10)) +
  labs(title = "Thèses par lieux de soutenance (Paris exclu)") 
  

#save 

ggsave("heat_map_phd.jpg", plot = gg, path = figures_path, width=10, height=10, dpi=300)


