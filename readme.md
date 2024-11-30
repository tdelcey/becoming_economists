# EconThesis Database
Thomas Delcey, Aurélien Goutsmedt

## What is the EconThesis Database project?

The goal is to create a database of the Ph.D. defended in economics in
the XXth and XXIst centuries in different countries. This project
implies:

- to collect different information through different sources (from list
  of PhD in `.pdf` files to online institutional databases);
- to clean these different types of information to obtain the relevant
  information we need: the author of the PhD dissertation, its title,
  its date of defence, the university, and any other useful information
  (PhD supervisor, classification of the PhD dissertation, like a JEL
  code).

At this point, the project focuses on three countries:

- France, collecting data from the [SUDOC](https://www.sudoc.abes.fr/)
  and [Theses.fr](https://theses.fr/?domaine=theses) databases;
- The United States, collecting data from the list of PhD granted in US
  universities, published each year by the *American Economic Review*
  and then the *Journal of Economic Literature*;
- The United Kingdom, collecting data from the [EThOS
  catalogue](https://bl.iro.bl.uk/collections/e492dc4b-82d9-4f8c-bb0a-2cdd8a62105d?locale=en%29).

## Organisation of the repository

The repository is organised as follows:

- The [documentation](.\documentation) folder contains the documentation
  about the building of the different database. You will find detailed
  explanations about the process of collecting the data and cleaning it
  for each country.
- The [scripts](.\scripts) folder contains the different scripts used in
  the project. They are organised by the type of scripts (scraping data,
  cleaning data, producing results, etc.) and by the country they are
  related to. For instance, the [FR](.\scripts/cleaning_scripts/FR)
  folder contains the scripts for cleaning the French data extracted
  from the [SUDOC](https://www.sudoc.abes.fr/) and
  [Theses.fr](https://theses.fr/?domaine=theses).

### Details on the scripts folder

- The [paths_and_packages.R](.\scripts/paths_and_packages.R) script is
  used to load the necessary packages and set the paths to the data.
- The
  [launch_scripts_in_background.R](.\scripts/launch_scripts_in_background.R)
  script is used to launch different scripts (scraping scripts for now)
  in the background.
- The [scraping_scripts](.\scripts/scraping_scripts) folder contains the
  scripts used to scrape the data from the different sources. For now,
  it is used for French data, to scrape the
  [SUDOC](https://www.sudoc.abes.fr/) and [idref](https://www.idref.fr/)
  websites.
- The [cleaning_scripts](.\scripts/cleaning_scripts) folder contains the
  scripts used to clean the data.
- The [producing_results_scripts](.\scripts/producing_results_scripts)
  folder contains the scripts used to produce results to illustrate the
  content of the database
- The [analysis_scripts](.\scripts/analysis_scripts) folder contains the
  scripts used to analyse the results produced in the
  [producing_results_scripts](.\scripts/producing_results_scripts)
  folder.
- The [helper_scripts](.\scripts/helper_scripts) folder contains scripts
  with different functions used in the other scripts.
