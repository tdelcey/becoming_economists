# EconThesis Database
Thomas Delcey, Aurélien Goutsmedt

## What is the EconThesis Database project?

The goal is to create a database of the Ph.D. defended in economics in
the XXth and XXIst centuries in different countries. This project has a
companion website, available
[here](https://tdelcey.github.io/becoming_economists_page/).

This project implies:

- to collect different information through different sources (from list
  of PhD in `.pdf` files to online institutional databases);
- to clean these different types of information to obtain the relevant
  information we need: the author of the PhD dissertation, its title,
  its date of defence, the university, and any other useful information
  (PhD supervisor, classification of the PhD dissertation, like a JEL
  code).

At this point, the project focuses on three countries:

- France, collecting data from the [Sudoc](https://www.sudoc.abes.fr/)
  and [Theses.fr](https://theses.fr/?domaine=theses) databases;
- The United States, collecting data from the list of PhD granted in US
  universities, published each year by the *American Economic Review*
  and then the *Journal of Economic Literature*;
- The United Kingdom, collecting data from the [EThOS
  catalogue](https://bl.iro.bl.uk/collections/e492dc4b-82d9-4f8c-bb0a-2cdd8a62105d?locale=en%29).

## Organisation of the repository

The repository is organised along the different databases for each
country. For each country, two folders are available:

- The “documentation” (e.g., for [France](./FR/documentation)) folders
  contain the documentation about the building of the different
  database. You will find detailed explanations about the process of
  collecting the data and cleaning it for each country.
- The “R” (e.g., for [France](./FR/R)) folders contain the different
  scripts used to clean and produce the database for the the country in
  question.

## Databases

You can find each database in a Zenodo repository:

- [France](https://doi.org/10.5281/zenodo.14541427)
  [![](https://zenodo.org/badge/DOI/10.5281/zenodo.14541427.svg)](https://doi.org/10.5281/zenodo.14541427)

- United States: work in progress
