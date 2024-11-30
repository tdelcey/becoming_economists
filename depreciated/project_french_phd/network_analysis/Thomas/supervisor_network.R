source(here::here("0_paths_and_packages.R"))

thesis_table <- readRDS(here(FR_cleaned_data_path, "all_thesis_table.rds"))
people_table <- readRDS(here(FR_cleaned_data_path, "people_table.rds"))


### preparing data: creating edges and nodes ###

# we build here a global first supervisor network, 
#members are the nodes of the network, and the edges are the number of times they are in a same jury
#we look only at big supervisor (i.e. more than 10 supervisions)

jury_table <- people_table %>%
  filter(!role == "author") %>%
  filter(!is.na(idref)) 

test <- people_table %>%
  filter(role == "supervisor",
         !is.na(doc_id)) %>%
  count(doc_id) %>%
  filter(n > 1)
  

edges <- jury_table %>%
  select(idref, doc_id) %>%
  rename("people_id" = idref) %>%
  as_tibble()

nodes <- jury_table %>%
  filter(role == "supervisor") %>%
  add_count(idref, name = "size") %>%
  select(-doc_id, -role, -database) %>%
  rename("people_id" = idref) %>%
  unique() %>%
  group_by(people_id) %>%
  slice(., 1) %>%
  ungroup() %>%
  mutate(label_node = paste(nom, prenom)) %>%
  as_tibble() 


#build network 

graph <- networkflow::build_dynamic_networks(
  nodes = nodes, 
  directed_edges = edges,
  source_id = "people_id", 
  target_id = "doc_id",
  cooccurrence_method = "coupling_angle",
  filter_components = FALSE,
  keep_singleton	= FALSE, 
  edges_threshold = 3)

#communities detection 


graph <- networkflow::add_clusters(graph, 
                      clustering_method = "leiden",
                      objective_function = "modularity",
                      resolution = 1,
                      seed = 123) #CPM is said to be used by default but it is not


graph_with_label <- networkflow::name_clusters(graph,
                                               method = "given_column", 
                                               cluster_id = "cluster_leiden",
                                               label_columns = "label_node",
                                               order_by = "size")

#put color on communities   
nb_communities <- graph_with_label %>%
  activate(nodes) %>%
  as_tibble() %>%
  count(cluster_leiden) %>%
  nrow
    
palette <- scico::scico(n = nb_communities, palette = "roma") %>% # creating a color palette
      sample()
    
#label communities  
graph_with_label <- networkflow::color_networks(graph_with_label, 
                                                         column_to_color = "cluster_leiden",
                                                         color = palette) 

#layout 
# graph_with_label <- networkflow::layout_networks(graph_with_label, 
#                                       "people_id",
#                                       "fr")
graph_with_label <- vite::complete_forceatlas2(graph_with_label, first.iter = 10000)


# graph_with_label <- networkflow::prepare_label_networks(graph_with_label,
#                                                                   x = "x",
#                                                                   y = "y",
#                                                                   cluster_label_column = "cluster_label")
    
    
 # graph_with_label <- graph_with_label %>%
 #   activate(nodes) %>%
 #   filter(size_cluster_leiden > 0.05)
    
labels_community_xy <- graph_with_label %>%
      activate(nodes) %>%
      select(cluster_label, x, y, color) %>%
      as_tibble %>%
      group_by(cluster_label) %>%
      summarise(label_x = mean(x),
                label_y = mean(x),
                color = color) %>%
      unique()

top_node_xy <- graph_with_label %>%
  activate(nodes) %>%
  as_tibble %>%
  group_by(cluster_leiden) %>%
  slice_max(size, n = 10) %>%
  unique()

gg <- ggraph::ggraph(graph_with_label, "manual", x = x, y = y) + 
  ggraph::geom_edge_arc0(aes(width = weight, color = color), alpha = 0.5, strength = 0.2, show.legend = FALSE) +
  ggraph::scale_edge_width_continuous(range = c(0.1,8)) +
  ggraph::scale_edge_colour_identity() +
  ggraph::geom_node_point(aes(x=x, y=y, size = size, fill = color, colour = color), pch = 21, alpha = 0.7, show.legend = FALSE) +
  scale_size_continuous(range = c(5,40)) +
  scale_fill_identity() +
  ggnewscale::new_scale("size") +
  #ggrepel::geom_label_repel(data = labels_community_xy, aes(x=label_x, y=label_y, label = cluster_label, fill = color), size = 6, alpha = 0.7) +  
  ggrepel::geom_text_repel(data = top_node_xy, aes(x=x, y=y, label = label_node), size = 4, fontface="bold", alpha = 1, point.padding=NA, show.legend = FALSE) +
  scale_size_continuous(range = c(0.5,5)) +
  theme_void()

ggsave(paste0("gg_graph_supervisors", ".jpg"), device = "jpg", plot = gg, path = figures_path, width=20, height=10, dpi=300)



  