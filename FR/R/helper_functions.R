# Scraping helper functions---------------------

#  Define the function to get validated user input for discipline to scrape
#' get_discipline_to_scrape
#' 
#' @description
#' This function prompts the user to enter a specific discipline, either "economics" or "law".
#' The function will continue prompting until the user enters a valid input, ensuring that the
#' script only proceeds when one of the expected values is provided. It uses styled console 
#' messages for user guidance and feedback, displaying success or error alerts accordingly.
#' 
#' @details
#' The function is designed to facilitate user interaction in scripts where specific input is
#' required before data scraping or other processes can begin. It keeps asking for input until
#' a valid option ("economics" or "law") is given, preventing unintentional script termination.
#' 
#' @return 
#' A character string, either "economics" or "law", representing the user's chosen discipline.
#' 
#' @examples
#' discipline <- get_discipline_to_scrape()
#' # Use the discipline variable to determine further actions based on the user input
get_discipline_to_scrape <- function() {
  # Loop until the user provides a valid input
  repeat {
    # Prompt with styled message
    cli_alert_info("Please enter a value ('economics' or 'law'):")
    user_input <- readline()
    
    # Check if the input is valid
    if (user_input %in% c("economics", "law")) {
      # Success message
      cli_alert_success(paste(user_input, "data will be scraped\n"))
      return(user_input)  # Return the valid input
    } else {
      # Error message for invalid input
      cli_alert_danger("Error: Invalid input. Please enter either 'economics' or 'law'.")
    }
  }
}

# Custom function to wrap text extraction in a list format
#' xml_text_in_list
xml_text_in_list <- function(x) {
  xml_text(x) %>% list()
}

#' Fetch Text from XML Nodes by Tag and Code
#'
#' This function extracts text content from SUDOC XML nodes that match a specified
#' `tag` and `code` within an XML document. It's designed to streamline and
#' simplify the extraction of data from structured XML fields by minimizing repetitive
#' code. The SUDOC tags and codes are explained 
#' here: https://documentation.abes.fr/sudoc/manuels/administration/aidewebservices/index.html#SudocMarcXML
#'
#' @param page An XML document object (parsed with `xml2::read_xml`) from which
#' text will be extracted.
#' @param tags A character vector of tags representing the `datafield` nodes (e.g., `c("328", "214", "210")`).
#' @param codes A character vector of codes representing the `subfield` nodes within the tags (e.g., `c("d", "e")`).
#' @param give_list Logical indicating whether to return the extracted text as a list (default is `FALSE`).
#'
#' @return A character vector containing the text found in the specified XML nodes.
#' If no nodes are found, it returns an empty character vector.
#'
#' @examples
#' # Assume 'page' is an XML document loaded with xml2::read_xml
#' # Fetch text from the '328', '214', or '210' tags with 'd' or 'e' subfield codes
#' date_soutenance <- fetch_text_by_tags_and_codes(page, c("328", "214", "210"), c("d", "e"))

fetch_text_by_tags_and_codes <- function(page, tags, codes, give_list = FALSE) {
  # Create an XPath expression for multiple tags
  tag_conditions <- paste0("@tag='", tags, "'", collapse = " or ")
  # Create an XPath expression for multiple codes
  code_conditions <- paste0("@code='", codes, "'", collapse = " or ")
  # Full XPath expression for tags and codes
  xpath_expr <- paste0(".//datafield[", tag_conditions, "]//subfield[", code_conditions, "]")
  
  # Find nodes matching any of the specified tags and codes, then extract text
  if(give_list == TRUE) {
    xml_find_all(page, xpath_expr) %>%
      xml_text_in_list()
  } else {
    xml_find_all(page, xpath_expr) %>%
      xml_text()
  }
}

#' Perform Language Identification Using fastText
#'
#' This function identifies the language of text data using a pre-trained fastText language model
#' and outputs the results as a data.table.
#'
#' @param input_obj A character vector containing the text data to be analyzed (e.g., abstracts).
#' @param id_obj A data.table containing a list of identifier corresponding to the input object.
#' @param pre_trained_language_model_path A string specifying the path to the pre-trained fastText language model file.
#' Parameter from fastText `language_identification` function.
#' @param k Integer. The number of most probable languages to return for each text. Parameter from fastText `language_identification` function.
#' @param th Numeric. The probability threshold for returning predictions. Parameter from fastText `language_identification` function.
#' @param threads Integer. The number of threads to use for processing. Parameter from fastText `language_identification` function.
#' @param verbose Logical. If TRUE, print progress information. Parameter from fastText `language_identification` function.
#'
#' @return A data.table with three columns: `language_fastText`, `prob_fastText`, and `thesis_id`.
#' @importFrom data.table data.table setnames
#' @examples
#' # Example usage:
#' language_abstract_fastText <- identify_language(
#'   input_obj = thesis_metadata[!is.na(abstract_other)]$abstract_other,
#'   thesis_metadata = thesis_metadata,
#'   pre_trained_language_model_path = "path/to/model.ftz",
#'   k = 1,
#'   th = 0.0,
#'   threads = 1,
#'   verbose = TRUE
#' )
identify_fastText_language <- function(input_obj, id_obj, pre_trained_language_model_path,
                              k = 1, th = 0.0, threads = 1, verbose = TRUE) {
  
  # Perform language identification using the fastText model
  language_fastText <- language_identification(
    input_obj = input_obj,
    pre_trained_language_model_path = pre_trained_language_model_path,
    k = k,
    th = th,
    threads = threads,
    verbose = verbose
  ) %>% 
    as.data.table()
  
  # Add `thesis_id` from thesis_metadata
  language_fastText[, thesis_id := id_obj]
  
  # Rename columns
  setnames(language_fastText, c("language_fastText", "prob_fastText", "thesis_id"))
  
  return(language_fastText)
}

#' Identify Potential Duplicates in Thesis Metadata
#'
#' This function detects potential duplicates in thesis metadata by comparing titles within groups 
#' of the same author. It calculates string distances between pairs of titles using the Optimal 
#' String Alignment (OSA) algorithm and filters results based on predefined thresholds.
#'
#' @param data_dt A `data.table` containing the thesis metadata, with at least three columns: 
#'   - `authors`: Normalized author names used for grouping.
#'   - `title`: Normalized thesis titles.
#'   - `thesis_id`: Unique identifiers for each thesis.
#' @param threshold_distance Numeric. The maximum absolute string distance between two titles for them 
#'   to be considered duplicates.
#' @param threshold_normalization Numeric. The maximum normalized string distance (distance divided by
#'   the product of the title lengths) for two titles to be considered duplicates.
#'
#' @return A `data.table` containing the following columns:
#'   - `thesis_id`: The identifier for the primary thesis in the duplicate group.
#'   - `thesis_id_2`: The identifier for the duplicate thesis.
#'   - `authors`: The author associated with the duplicates.
#'   - `text1`: The first title in the comparison.
#'   - `text2`: The second title in the comparison.
#'   - `distance`: The absolute string distance between the titles.
#'   - `normalized_distance`: The normalized string distance between the titles.
#'   If no duplicates are found, the function returns `NULL`.
#'
#' @details
#' The function first groups titles by `authors`, then compares all pairs of titles within each group.
#' String distances are calculated using the OSA algorithm, which accounts for single-character 
#' substitutions, deletions, and transpositions. The results are filtered based on the provided 
#' thresholds to minimize false positives.
#'
#' @examples
#' # Sample data
#' data_dt <- data.table(
#'   authors = c("smith john", "smith john", "doe jane"),
#'   title = c("My Thesis Title", "My Thesis Titel", "Another Thesis"),
#'   thesis_id = c("ID1", "ID2", "ID3")
#' )
#'
#' # Detect duplicates with specific thresholds
#' find_duplicates(data_dt, threshold_distance = 2, threshold_normalization = 0.05)
#'
#' @export
find_duplicates <- function(data_dt, threshold_distance, threshold_normalization, workers) {
 
   # Group data by authors to avoid unnecessary comparisons
  data_dt <- data_dt[, .(titles = list(title), ids = list(thesis_id)), by = authors]
  data_dt <- data_dt[lengths(titles) > 1]  # Keep only groups with more than one title for safety (should not be necessary if data is clean)
  
  # Define a helper function for processing a single group
  process_group <- function(titles, ids, author) {
    # Compare all title pairs within the group
    comparison <- CJ(titles, titles, sorted = FALSE, unique = TRUE)
    setnames(comparison, c("text1", "text2"))
    comparison <- comparison[text1 <= text2]  # Avoid redundant comparisons
    
    # Calculate string distance and normalized distance
    comparison[, distance := stringdist::stringdist(text1, text2, method = "osa")]
    comparison[, normalized_distance := distance / (str_count(text1) * str_count(text2))]
    
    if (nrow(comparison) > 0) {
      comparison[, authors := author]
      
      title_match <- comparison %>%
        as.data.table() %>%
        merge(data.table(title1 = titles, thesis_id_1 = ids), by.x = "text1", by.y = "title1", allow.cartesian = TRUE) %>%
        merge(data.table(title2 = titles, thesis_id_2 = ids), by.x = "text2", by.y = "title2", allow.cartesian = TRUE) %>%
        .[thesis_id_1 != thesis_id_2, .(thesis_id_1, thesis_id_2, authors, text1, text2, distance, normalized_distance)]
      
      return(title_match)
    }
    return(NULL)
  }
  
  # Set up parallel processing
  plan(multisession, workers = workers)
  
  # Use future_map to parallelize the processing of each group
  results <- future_map(
    1:nrow(data_dt),
    ~ process_group(
      titles = data_dt$titles[[.x]],
      ids = data_dt$ids[[.x]],
      author = data_dt$authors[.x]
    ),
    .progress = TRUE
  )
  
  if(length(results) > 0) {
    results <- results %>% 
      rbindlist()
    setkey(results, key = thesis_id_1)
    duplicates <- results[normalized_distance < threshold_normalization & distance < threshold_distance, ]
    setnames(duplicates, "thesis_id_1", "thesis_id")
    duplicates <- unique(duplicates)
    
    return(duplicates)
  } else {
    return(NULL)
  }
}

#' Manually Match Duplicates Based on Patterns in Titles
#'
#' This function identifies and matches potential duplicates in thesis metadata based on a given 
#' pattern in the titles. It assigns a consistent ID to all theses whose titles match the pattern.
#'
#' @param data A `data.frame` or `data.table` containing thesis metadata, including a column for titles
#'   (e.g., `title_fr`) and unique IDs (e.g., `thesis_id`).
#' @param id_ref The column to use as the reference for assigning duplicate IDs (e.g., `thesis_id`).
#' @param pattern A string or regular expression to match titles that are considered duplicates.
#'
#' @return A `data.frame` or `data.table` with an additional column `id_new`:
#'   - `id_new`: The ID assigned to theses matching the pattern, based on the first ID in the group.
#'   - Rows where the pattern is not matched will be excluded from the output.
#'
#' @details
#' This function is useful for handling specific duplicate cases that cannot be resolved automatically.
#' By manually providing a pattern, you can group entries with similar or identical titles and assign 
#' a consistent ID to indicate they are duplicates. The function ensures that all matched entries are 
#' assigned the same ID, which is the first ID in the group.
#'
#' @examples
#' # Example dataset
#' thesis_metadata <- data.table(
#'   thesis_id = c("ID1", "ID2", "ID3"),
#'   title_fr = c("Approche systémique et régulation économique", 
#'                "Approche systémique et régulation économique", 
#'                "Another Title")
#' )
#'
#' # Match duplicates manually using a specific title pattern
#' matching_duplicate_manually(
#'   data = thesis_metadata, 
#'   id_ref = thesis_id, 
#'   pattern = "Approche systémique et régulation économique"
#' )
#'
#' @export
matching_duplicate_manually <- function(data, id_ref, pattern) {
  # Match rows where the title matches the provided pattern
  match <- data %>%
    mutate(id_new = if_else(str_detect(title_fr, {{pattern}}), first({{id_ref}}), NA_character_)) %>%
    drop_na(id_new)
  
  return(match)
}
