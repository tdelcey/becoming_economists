# Documentation - Becoming an economist: France
Thomas Delcey, Aurelien Goutsmedt
2025-01-21

<link href="documentation_french_database_files/libs/htmltools-fill-0.5.8.1/fill.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/htmlwidgets-1.6.4/htmlwidgets.js"></script>
<link href="documentation_french_database_files/libs/datatables-css-0.0.0/datatables-crosstalk.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/datatables-binding-0.33/datatables.js"></script>
<script src="documentation_french_database_files/libs/jquery-3.6.0/jquery-3.6.0.min.js"></script>
<link href="documentation_french_database_files/libs/dt-core-1.13.6/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="documentation_french_database_files/libs/dt-core-1.13.6/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/dt-core-1.13.6/js/jquery.dataTables.min.js"></script>
<link href="documentation_french_database_files/libs/crosstalk-1.2.1/css/crosstalk.min.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/crosstalk-1.2.1/js/crosstalk.min.js"></script>
<script src="documentation_french_database_files/libs/plotly-binding-4.10.4/plotly.js"></script>
<script src="documentation_french_database_files/libs/setprototypeof-0.1/setprototypeof.js"></script>
<script src="documentation_french_database_files/libs/typedarray-0.1/typedarray.min.js"></script>
<link href="documentation_french_database_files/libs/plotly-htmlwidgets-css-2.11.1/plotly-htmlwidgets.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/plotly-main-2.11.1/plotly-latest.min.js"></script>
<script src="documentation_french_database_files/libs/viz-1.8.2/viz.js"></script>
<link href="documentation_french_database_files/libs/DiagrammeR-styles-0.2/styles.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/grViz-binding-1.0.11/grViz.js"></script>


- [Introduction](#introduction)
  - [Sources](#sources)
  - [Usage and Access](#usage-and-access)
- [Presentation of the tables](#presentation-of-the-tables)
  - [Thesis Metadata](#thesis-metadata)
  - [Edges](#edges)
    - [Complete Edges Data](#complete-edges-data)
  - [Institutions](#institutions)
  - [Individuals](#individuals)
- [Data collection and cleaning
  process](#data-collection-and-cleaning-process)
  - [Scraping](#scraping)
    - [theses.fr](#thesesfr)
    - [Sudoc](#sudoc)
    - [IdRef](#sec-idref)
  - [Cleaning](#cleaning)
    - [Sudoc](#sudoc-1)
    - [Theses.fr](#thesesfr-1)
    - [Merging](#merging)
    - [Metadata](#sec-cleaning-metadata)
    - [Institutions](#sec-cleaning-institutions)
    - [Individuals](#sec-cleaning-persons)

[![](https://zenodo.org/badge/DOI/10.5281/zenodo.14541427.svg)](https://doi.org/10.5281/zenodo.14541427)

# Introduction

This database compiles information on Ph.D. dissertations in economics
defended in France since 1900.[^1]

The French database is implemented as a relational database that
integrates multiple interconnected data frames. It is organized around
four main components:

- **Thesis Metadata:** This table contains the core information for each
  dissertation. Each entry corresponds to a single thesis and includes
  details such as the title, defense date, abstract, and other relevant
  metadata.
- **Edges Data:** This table captures the connections between the other
  three tables, linking individuals, institutions, and theses. It
  associates each thesis with the individuals and institutions involved
  in its production, thereby enabling a synthetized view of these
  relationships.[^2]
- **Institutions Data:** This table includes information on
  universities, laboratories, doctoral schools, and other institutions
  associated with the dissertations. Each entry corresponds to a single
  institution.
- **Individual Data:** This table contains information on the
  individuals involved in the dissertations, including authors,
  supervisors, and jury members. Each entry corresponds to a single
  individual.

## Sources

The data used in this project comes from three mains sources:

- **Theses.fr:** <https://theses.fr/>
- **Sudoc:** <https://www.sudoc.fr/>
- **IdRef:** <https://www.idref.fr/>

These sources are the result of the work of the
[ABES](https://abes.fr/l-abes/presentation/) (l’Agence bibliographique
de l’enseignement supérieur) who produced metadata and APIs regarding
research and superior education. The data of the three sources
mentionned above are under the [Etabab “Open
Licence”](https://www.etalab.gouv.fr/licence-ouverte-open-licence/).[^3]

- [Theses.fr](https://theses.fr/) is a comprehensive repository for PhD
  dissertations defended in French institutions since 1985.[^4] It
  includes metadata such as the title of the dissertation, author, date
  of defense, institution, supervisor, abstract, etc. The database
  covers a wide range of disciplines, providing access, in some cases,
  to digital theses.

- [Sudoc](https://www.Sudoc%20.fr/) stands for “*Système Universitaire
  de Documentation*”. It is a union catalog that includes references to
  various documents held in French academic and research libraries. It
  covers books, journal articles, dissertations, and other academic
  works. The Sudoc database includes metadata like title, author,
  publication date, and library locations where the documents can be
  found. It is a key resource for academic research in France, providing
  a broad overview of available scholarly materials. Regarding PhD, it
  allows to find dissertations defended before 1985, and to recover
  relevant metadata.

- [IdRef](https://www.idref.fr/) stands for “*Identifiants et
  Référentiels pour l’Enseignement supérieur et la Recherche*”. It is a
  database focused on managing and standardizing the names and
  identifiers of authors and other contributors to academic and research
  works. It provides authority control for names used in academic
  cataloging, ensuring consistency and aiding in accurate attribution of
  works. IdRef is used in conjunction with Sudoc and other databases to
  support the management of bibliographic data in the French higher
  education and research sectors. In our project, it allows us to find
  additional data on individuals and institutions.

Our data-building approach focuses on ensuring consistency and quality
while preserving the integrity of the original information. We relies on
two principles to build this database:

- **No Data transformation**: Our work primarily involves data
  collection, categorization, and cleaning. We intentionally minimized
  transformations, restricting them to only minor and non-impactful
  adjustments. Specifically, we avoided altering the cell values of the
  original data, instead encoding any modifications in new columns.[^5]
  The complete edges data frame keeps a track of our transformations.

- **Disambiguation**: We aimed to disambiguate theses and associated
  entities (individuals and institutions) as thoroughly as possible.
  Disambiguation involves identifying and distinguishing between entries
  with similar descriptions. This process is essential to avoid
  duplicated data or to merge distinct entries. To address this, we
  assigned a unique identifier to each entity. The identifiers provided
  by the Agence Bibliographique de l’Enseignement Supérieur (ABES)
  through IdRef served as our primary source for unique identifiers. In
  cases where ABES identifiers were unavailable, we generated our own
  unique identifiers to maintain consistency and accuracy.

## Usage and Access

Our database is released under the [CC-BY-4.0
licence](https://creativecommons.org/licenses/by/4.0/). allowing free
access and use by anyone. The data is hosted in a [Zenodo
repository](https://doi.org/10.5281/zenodo.14541427). While the database
focuses on Ph.D. dissertations in economics and queries sources based on
the field of the thesis, the scripts have been designed with
flexibility. They can be adapted for other queries involving notably
different disciplines.

If you use our data or scripts, please cite the following reference:
“Delcey Thomas, and Aurélien Goutsmedt. (2024). Becoming an Economist: A
Database of French Economics PhDs. Zenodo.
https://doi.org/10.5281/zenodo.14541427”

``` bibtex
@article{
  title={Becoming an Economist: A Database of French Economics PhDs},
  author={Delcey, Thomas and Goutsmedt, Aurélien},
  journal={Zenodo},
  year={2024},
  doi={https://doi.org/10.5281/zenodo.14541427}
}
```

> [!WARNING]
>
> ### Code usages
>
> Note that some of our data cleaning steps are tailored to the specific
> characteristics of the datasets we extracted. We systematically
> identified issues in our data and applied manual cleaning processes,
> such as removing problematic titles, identifying duplicates, and
> standardizing institutional names.
>
> If you use our code to extract data, it is essential to carefully
> assess the quality of your extracted data and adapt the cleaning steps
> accordingly. Feel free to reach out to us for guidance if you plan to
> use our code for similar data extraction tasks.

# Presentation of the tables

## Thesis Metadata

The `thesis_metadata` table contains 16 variables:

- `thesis_id`: the unique identifier of the thesis. If it exists, it is
  the official “national number of the thesis” created by the ABES and
  the theses.fr website. If not, it is a temporary identifier we have
  created.
- `year_defence`: the year of the thesis defense. Our database covers
  the period 1899-2023.
- `language` and `language_2` are the languages of the thesis. The
  variable is harmonized to make the information on language found in
  Sudoc and These.fr compatible.
- `title_fr`: the title of the thesis in French.
- `title_en`: the title of the thesis in English.
- `title_other`: the title of the thesis in another language.
- `abstract_fr`: the abstract of the thesis in French.
- `abstract_en`: the abstract of the thesis in English.
- `abstract_other`: the abstract of the thesis in another language.
- `field`: the field of the thesis (such as “Sciences économiques”). The
  field remains unaltered by our work and can take on a wide range of
  values, as indicated by the number of distinct entries (696).
- `accessible`: a binary variable indicating whether the fulltext is
  accessible or not (data coming only from theses.fr).
- `type`: the type of the thesis. Type can take 6 values: Thèse, Thèse
  d’État, Thèse complémentaire, Thèse de 3e cycle, Thèse de
  docteur-ingénieur, Thèse sur travaux. All categories are derived from
  categories found in Sudoc.
- `country`: the country where the thesis was defended, i.e. France.
  <!-- Cela va servir quand on va merger avec les autres bases de données, donc faut le garder pour la cohérence -->
- `url`: the url of the thesis on [theses.fr](https://theses.fr/) or
  [Sudoc](https://www.sudoc.fr/) websites
- `duplicate_of`: a list of `thesis_id` that indicate duplicated thesis.
  We identified duplicates but did not remove them to preserve the
  maximum information from the raw sources. This variable allows users
  to handle duplicates using their preferred strategy.

> [!NOTE]
>
> ### Temporary identifiers
>
> When we were unable to provide an ABES identifiers for a thesis or
> entity, we created our own unique “temporary identifiers” coded as
> follows `temp_X_Y`, X representing the source of the original
> information (either “sudoc” or “thesesfr”) and Y being a randomly
> generated unique number. We refer to these identifiers as temporary
> because they may be replaced in future updates by ABES identifiers,
> either as ABES updates its sources or as we improve our cleaning
> process.

> [!WARNING]
>
> ### `Language`
>
> The `language` variables may be important for exploring issues related
> to the internationalization of economics. However, the raw source data
> exhibited a notable error rate in the classification of title and
> abstract languages: French titles were frequently mislabeled as
> English, and vice versa. To address this issue, we employed language
> prediction models to correct the misclassified information when
> possible. For a detailed explanation of the cleaning process, refer to
> <a href="#sec-cleaning-metadata" class="quarto-xref">Section 3.2.4</a>.

<a href="#tbl-metadata" class="quarto-xref">Table 1</a> shows a sample
of the thesis metadata table. The thesis metadata table contains 21025
theses.
<a href="#fig-metadata_distribution" class="quarto-xref">Figure 1</a>
shows the distribution of theses over time.

<div id="tbl-metadata">

Table 1: Sample of the metadata table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-46f91f0a7f4e7ce7b2f3" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-46f91f0a7f4e7ce7b2f3">{"x":{"filter":"none","vertical":false,"data":[["1975NICE0021","temp_sudoc_thesis_317618","1984PA100153","1995CNAM0231","1972MON10023","temp_sudoc_thesis_240856","temp_sudoc_thesis_301379","1980PA100024","2012AMIE0055","2001REN10009","2019PA01E057","temp_sudoc_thesis_427697","2013IEPP0065","1981PA131014","temp_sudoc_thesis_529561","2018BORD0224","temp_sudoc_thesis_465735","temp_sudoc_thesis_934612","2011PA131003","1985NICE0011","temp_sudoc_thesis_112084","1998PA100139","1955DIJOD003","2012ENST0076","2016PSLED011","temp_sudoc_thesis_367758","1998REN11004","1991PA090001","temp_sudoc_thesis_617411","temp_sudoc_thesis_253384","temp_sudoc_thesis_556061","temp_sudoc_thesis_196550","1988PA02T111","2003PA090055","1976MON10021","1995AIX24006","2013PA090032","2012AIXM1086","2021REIME003","2000LIL12024","1998PA100127","2020NIME0007","1998LIL12007","1984CLF1D010","1995EHES0049","temp_sudoc_thesis_262866","1999EHESA044","temp_sudoc_thesis_879081","2019SACLV050","2015MONTD012"],[1975,1971,1984,1995,1972,1983,1985,1980,2012,2001,2019,1984,2013,1981,1919,2018,null,1922,2011,1985,1983,1998,1955,2012,2016,1979,1998,1991,1934,1979,1977,1974,1988,2003,1976,1995,2013,2012,2021,2000,1998,2020,1998,1984,1995,1977,1999,1936,2019,2015],["fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","en","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr"],[null,null,null,null,null,null,null,null,null,null,null,null,"fr",null,null,null,null,null,null,null,null,null,null,"en",null,null,null,null,null,null,null,null,null,null,null,null,null,"fr",null,null,null,null,null,null,null,null,null,null,null,null],["Essai d'analyse économique du système de la san...","Une Recherche sur le choix du taux d'actualisat...","L'impact des taux d'intérêt internationaux sur ...","Dynamique des marches avec preferences adaptati...","Le marché des antiquités et l'analyse économique","Transfert de technologie et intensification de ...","Théorie des prix, dynamique et structures des m...","De la hiérarchie des qualifications à la hiérar...","L'influence de la dollarisation sur la croissan...","Superposition des niveaux de collectivités loca...","Stress financier et le cycle des affaires","Valeur symbolique et identitaire du travail et ...","Essais en macroéconomie internationale et théor...","L'internationalisation des chaînes hôtelières f...","La représentation proportionnelle","La transition energétique : Difficultés, implic...","Monnaie et politique monétaire en Indonésie de ...","De l'évolution des relations internationales de...","Les conflits commerciaux et l'organisation mond...","Maîtrise des dépenses publiques et réformes du ...","Demographie de brazzaville","R. Goodwin et l'antagonisme entre salaires et p...","La concurrence du rail et de la route\ncontribut...","Le commerce électronique de biens culturels : c...","Les politiques de développement du solaire phot...","Les transformations du monde rural un paradoxe,...","Une analyse explicative du différentiel de perf...","Essai d'explication de la variation du dollar p...","La production et l'échange au point de vue éner...","L'homogeneisation des conduites sociales au xix...","Bases de rationalisation des programmes de sant...","Formation sociale et mode de developpement econ...","Le contenu en importations des échanges agro-al...","Intermédiation électronique et structuration de...","Les Objectifs et les Stratégies dans l' industr...","Equité, efficacité et stabilité des firmes auto...","La prise des risques financiers : une approche ...","Taux de chang réel et démographie","La gestion des ressources halieutiques au Sénég...","François Quesnay et la naissance de l'économie ...","Les phénomènes d'ancienneté dans les politiques...","Modélisation des risques en présence de valeurs...","L'économie des services de proximité aux person...","L' aide multilatérale\nfacteurs explicatifs et r...","Développement du mezzogiorno et criminalités : ...","Risques humains dans l'entreprise industrielle","Microsimulation des reformes fiscales : trois e...","Les grands courants de la pensée économique chi...","L'expérience KerBabel : une aventure dans la \"n...","Les approches chaos-stochastiques du risque de ..."],[null,null,null,"Market dynamics with adaptative preferences and...",null,null,null,null,"Dollarization and ecuadorian economic growth : ...","Overlapping local governments and public spendi...","Financial stress and the business cycle",null,"Essays in international macroeconomics and mone...",null,null,"Energy transition : Difficulties, implications ...",null,null,"Trade disputes and world trade organization : t...",null,null,"R. Goodwin and the antagonism between wages and...",null,"The electronic commerce of cultural goods : an ...","Public policies for the development of solar ph...",null,"Analysis of differencies in economic performanc...",null,null,null,null,null,"The content of imports of french agricultural e...","Electronic intermediation and industrial channe...",null,null,"Financial risk-taking : a macroeconomic approac...","Real exchange rate and demography","The management of fishery resources in Senegal ...","François Quesnay and the birth of political eco...","Seniority phenomena in firm's wage policies","Risk modeling in the presence of extreme values...","Economics of neighborhood services. The case of...",null,"Development of the mezzogiorno and criminalitie...",null,"Microsimulation of fiscal reforms",null,"The KerBabel experience : an adventure in the '...","Chaos-stochastics approaches of market risk"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],[null,null,null,"Le theme de l'endogenete des preferences a ete ...",null,null,null,null,"Cette thèse analyse l'incapacité de la dollaris...","En France, la politique publique en faveur de l...","Le fil directeur de cette thèse est l’étude du ...",null,"Cette thèse comprend quatre essais en macroécon...",null,null,"L’Europe et, en particulier, la France ont enga...",null,null,"La mondialisation de l’économie causée par le d...",null,null,"Notre travail prend comme point de depart le mo...",null,"Cette thèse se présente sous la forme d’un volu...","Le marché des systèmes photovoltaïques a connu ...",null,"L'Argentine, le Brésil, le Mexique, la Corée du...",null,null,null,null,null,"La p. A. C. A defini un systeme de prix eleve d...",null,null,null,"La montée du poids de la finance est, pour une ...","Cette thèse a pour objectif de caractériser le ...","Le Sénégal fait partie des pays d’Afrique les m...","La recherche porte sur la naissance de l'econom...","L'objet de cette these est de montrer quels son...","Cette thèse propose une nouvelle approche du tr...","Cette these d'economie est consacree aux servic...","Au moment où s’engage un débat fondamental sur ...","Les organisations de type mafieux italiennes so...",null,"Dans ce travail, apres avoir construit un model...",null,"Cette thèse retrace les presque vingt années de...","La complexité des marchés financiers et la recr..."],[null,null,null,"The subject of endgogeneous freferences has bee...",null,null,null,null,"In this work we analyze the incapacity of the d...","In France, incentives towards inter-communal co...","In this thesis, I investigate the implications ...",null,"This thesis includes four essays in internation...",null,null,null,null,null,"The globalisation is based up on the developmen...",null,null,null,null,"This thesis is a volume of 134 pages and includ...","Solar PV systems have experienced strong market...",null,"Contrary to the majority of third nations, five...",null,null,null,null,null,"The common agricultural policy has defined a sy...",null,null,null,"The rise of finance in developed economies is, ...","The aim of this thesis is to characterise the b...","Senegal is one of the African countries that ar...",null,null,"This thesis proposes a new approach to the trea...","This Ph. D. Thesis in economics deals with neig...",null,"The italian mafia-like organisations are often ...",null,null,null,"This thesis retraces the almost twenty years of...","The complexity of financial markets and the res..."],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Économie et sociologie du travail","Sciences économiques","Politique économique et planification","Droit","Sciences économiques","Économie","Droit","Sciences économiques et gestion","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Droit","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences economiques","Sciences économiques","Economie du développement","Sciences économiques","Sciences économiques","Sciences économiques","Droit","Sciences économiques","Sciences économiques"],[null,null,null,"non",null,null,null,null,"non","non","oui",null,"non",null,null,"oui",null,null,"non","non",null,"non",null,"oui","oui",null,"non","non",null,null,null,null,"non","non",null,"non","non","non","oui","non","non","oui","non",null,"non",null,"non",null,"oui","oui"],["Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse de 3e cycle","Thèse d'État","Thèse d'État","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse d'État","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse de 3e cycle","Thèse d'État","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse"],["France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France"],["https://www.sudoc.fr/204180112","https://www.sudoc.fr/022331492","https://www.sudoc.fr/041228766","https://theses.fr/1995CNAM0231","https://www.sudoc.fr/005127025","https://www.sudoc.fr/041170776","https://www.sudoc.fr/022316655","https://www.sudoc.fr/041091809","https://theses.fr/2012AMIE0055","https://theses.fr/2001REN10009","https://theses.fr/2019PA01E057","https://www.sudoc.fr/012193240","https://theses.fr/2013IEPP0065","https://www.sudoc.fr/04677775X","https://www.sudoc.fr/031943977","https://theses.fr/2018BORD0224","https://www.sudoc.fr/076449750","https://www.sudoc.fr/04857760X","https://theses.fr/2011PA131003","https://theses.fr/1985NICE0011","https://www.sudoc.fr/041135830","https://theses.fr/1998PA100139","https://www.sudoc.fr/084379871","https://theses.fr/2012ENST0076","https://theses.fr/2016PSLED011","https://www.sudoc.fr/041061489","https://theses.fr/1998REN11004","https://theses.fr/1991PA090001","https://www.sudoc.fr/047363533","https://www.sudoc.fr/041048660","https://www.sudoc.fr/041048067","https://www.sudoc.fr/040898261","https://theses.fr/1988PA02T111","https://theses.fr/2003PA090055","https://www.sudoc.fr/040918483","https://theses.fr/1995AIX24006","https://theses.fr/2013PA090032","https://theses.fr/2012AIXM1086","https://theses.fr/2021REIME003","https://theses.fr/2000LIL12024","https://theses.fr/1998PA100127","https://theses.fr/2020NIME0007","https://theses.fr/1998LIL12007","https://www.sudoc.fr/249093863","https://theses.fr/1995EHES0049","https://www.sudoc.fr/040926265","https://theses.fr/1999EHESA044","https://www.sudoc.fr/054383161","https://theses.fr/2019SACLV050","https://theses.fr/2015MONTD012"],[[null],["1971PA100085","temp_sudoc_thesis_317618"],[null],[null],[null],[null],["temp_sudoc_thesis_295393","temp_sudoc_thesis_301379","temp_sudoc_thesis_543802"],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],["temp_sudoc_thesis_557097","temp_sudoc_thesis_617411"],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Distribution of theses

<div id="fig-metadata_distribution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-c5bc1cfaeb38b3f72ec2" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-c5bc1cfaeb38b3f72ec2">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,48,26,32,30,35,45,49,35,50,55,61,55,69,68,85,86,92,134,164,216,270,372,322,395,455,451,510,509,507,514,462,454,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,316,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Number of theses: 5","Defense date: 1900 <br> Number of theses: 31","Defense date: 1901 <br> Number of theses: 37","Defense date: 1902 <br> Number of theses: 27","Defense date: 1903 <br> Number of theses: 40","Defense date: 1904 <br> Number of theses: 34","Defense date: 1905 <br> Number of theses: 45","Defense date: 1906 <br> Number of theses: 38","Defense date: 1907 <br> Number of theses: 48","Defense date: 1908 <br> Number of theses: 44","Defense date: 1909 <br> Number of theses: 51","Defense date: 1910 <br> Number of theses: 65","Defense date: 1911 <br> Number of theses: 38","Defense date: 1912 <br> Number of theses: 71","Defense date: 1913 <br> Number of theses: 29","Defense date: 1914 <br> Number of theses: 30","Defense date: 1915 <br> Number of theses: 8","Defense date: 1916 <br> Number of theses: 6","Defense date: 1917 <br> Number of theses: 12","Defense date: 1918 <br> Number of theses: 11","Defense date: 1919 <br> Number of theses: 25","Defense date: 1920 <br> Number of theses: 52","Defense date: 1921 <br> Number of theses: 46","Defense date: 1922 <br> Number of theses: 69","Defense date: 1923 <br> Number of theses: 72","Defense date: 1924 <br> Number of theses: 70","Defense date: 1925 <br> Number of theses: 61","Defense date: 1926 <br> Number of theses: 54","Defense date: 1927 <br> Number of theses: 62","Defense date: 1928 <br> Number of theses: 38","Defense date: 1929 <br> Number of theses: 40","Defense date: 1930 <br> Number of theses: 29","Defense date: 1931 <br> Number of theses: 45","Defense date: 1932 <br> Number of theses: 42","Defense date: 1933 <br> Number of theses: 47","Defense date: 1934 <br> Number of theses: 37","Defense date: 1935 <br> Number of theses: 48","Defense date: 1936 <br> Number of theses: 45","Defense date: 1937 <br> Number of theses: 37","Defense date: 1938 <br> Number of theses: 40","Defense date: 1939 <br> Number of theses: 53","Defense date: 1940 <br> Number of theses: 22","Defense date: 1941 <br> Number of theses: 29","Defense date: 1942 <br> Number of theses: 35","Defense date: 1943 <br> Number of theses: 30","Defense date: 1944 <br> Number of theses: 33","Defense date: 1945 <br> Number of theses: 29","Defense date: 1946 <br> Number of theses: 29","Defense date: 1947 <br> Number of theses: 45","Defense date: 1948 <br> Number of theses: 35","Defense date: 1949 <br> Number of theses: 33","Defense date: 1950 <br> Number of theses: 44","Defense date: 1951 <br> Number of theses: 41","Defense date: 1952 <br> Number of theses: 36","Defense date: 1953 <br> Number of theses: 30","Defense date: 1954 <br> Number of theses: 48","Defense date: 1955 <br> Number of theses: 26","Defense date: 1956 <br> Number of theses: 32","Defense date: 1957 <br> Number of theses: 30","Defense date: 1958 <br> Number of theses: 35","Defense date: 1959 <br> Number of theses: 45","Defense date: 1960 <br> Number of theses: 49","Defense date: 1961 <br> Number of theses: 35","Defense date: 1962 <br> Number of theses: 50","Defense date: 1963 <br> Number of theses: 55","Defense date: 1964 <br> Number of theses: 61","Defense date: 1965 <br> Number of theses: 55","Defense date: 1966 <br> Number of theses: 69","Defense date: 1967 <br> Number of theses: 68","Defense date: 1968 <br> Number of theses: 85","Defense date: 1969 <br> Number of theses: 86","Defense date: 1970 <br> Number of theses: 92","Defense date: 1971 <br> Number of theses: 134","Defense date: 1972 <br> Number of theses: 164","Defense date: 1973 <br> Number of theses: 216","Defense date: 1974 <br> Number of theses: 270","Defense date: 1975 <br> Number of theses: 372","Defense date: 1976 <br> Number of theses: 322","Defense date: 1977 <br> Number of theses: 395","Defense date: 1978 <br> Number of theses: 455","Defense date: 1979 <br> Number of theses: 451","Defense date: 1980 <br> Number of theses: 510","Defense date: 1981 <br> Number of theses: 509","Defense date: 1982 <br> Number of theses: 507","Defense date: 1983 <br> Number of theses: 514","Defense date: 1984 <br> Number of theses: 462","Defense date: 1985 <br> Number of theses: 454","Defense date: 1986 <br> Number of theses: 341","Defense date: 1987 <br> Number of theses: 315","Defense date: 1988 <br> Number of theses: 253","Defense date: 1989 <br> Number of theses: 212","Defense date: 1990 <br> Number of theses: 180","Defense date: 1991 <br> Number of theses: 208","Defense date: 1992 <br> Number of theses: 275","Defense date: 1993 <br> Number of theses: 264","Defense date: 1994 <br> Number of theses: 292","Defense date: 1995 <br> Number of theses: 256","Defense date: 1996 <br> Number of theses: 296","Defense date: 1997 <br> Number of theses: 372","Defense date: 1998 <br> Number of theses: 338","Defense date: 1999 <br> Number of theses: 323","Defense date: 2000 <br> Number of theses: 427","Defense date: 2001 <br> Number of theses: 345","Defense date: 2002 <br> Number of theses: 316","Defense date: 2003 <br> Number of theses: 340","Defense date: 2004 <br> Number of theses: 316","Defense date: 2005 <br> Number of theses: 312","Defense date: 2006 <br> Number of theses: 296","Defense date: 2007 <br> Number of theses: 350","Defense date: 2008 <br> Number of theses: 361","Defense date: 2009 <br> Number of theses: 363","Defense date: 2010 <br> Number of theses: 397","Defense date: 2011 <br> Number of theses: 405","Defense date: 2012 <br> Number of theses: 367","Defense date: 2013 <br> Number of theses: 394","Defense date: 2014 <br> Number of theses: 361","Defense date: 2015 <br> Number of theses: 373","Defense date: 2016 <br> Number of theses: 392","Defense date: 2017 <br> Number of theses: 360","Defense date: 2018 <br> Number of theses: 353","Defense date: 2019 <br> Number of theses: 339","Defense date: 2020 <br> Number of theses: 310","Defense date: 2021 <br> Number of theses: 351","Defense date: 2022 <br> Number of theses: 308","Defense date: 2023 <br> Number of theses: 129","Defense date: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":25.570776255707766,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"9e6de549bdc1b":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"9e6de549bdc1b","visdat":{"9e6de549bdc1b":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 1: Distribution of theses by defense date

</div>

### Distribution of theses by type

<div id="fig-metadata_distribution_type">

<div class="plotly html-widget html-fill-item" id="htmlwidget-59279c44db5f9b62e010" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-59279c44db5f9b62e010">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,3,0,1,2,1,3,14,12,11,18,28,31,43,67,64,104,156,281,242,304,390,371,458,485,470,485,436,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,70,29,30,8,6,12,11,25,52,46,68,72,70,61,54,62,38,40,28,45,42,47,37,48,45,37,39,52,22,29,34,30,33,29,29,45,35,33,44,41,36,30,48,26,30,30,32,45,48,33,49,52,47,43,58,50,57,55,49,67,100,112,114,91,80,91,65,80,52,24,37,29,26,234,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,315,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Type: Thèse <br> Number of theses: 5","Defense date: 1900 <br> Type: Thèse <br> Number of theses: 31","Defense date: 1901 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1902 <br> Type: Thèse <br> Number of theses: 27","Defense date: 1903 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1904 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1905 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1906 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1907 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1908 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1909 <br> Type: Thèse <br> Number of theses: 51","Defense date: 1910 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1911 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1912 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1913 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1914 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1915 <br> Type: Thèse <br> Number of theses: 8","Defense date: 1916 <br> Type: Thèse <br> Number of theses: 6","Defense date: 1917 <br> Type: Thèse <br> Number of theses: 12","Defense date: 1918 <br> Type: Thèse <br> Number of theses: 11","Defense date: 1919 <br> Type: Thèse <br> Number of theses: 25","Defense date: 1920 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1921 <br> Type: Thèse <br> Number of theses: 46","Defense date: 1922 <br> Type: Thèse <br> Number of theses: 68","Defense date: 1923 <br> Type: Thèse <br> Number of theses: 72","Defense date: 1924 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1925 <br> Type: Thèse <br> Number of theses: 61","Defense date: 1926 <br> Type: Thèse <br> Number of theses: 54","Defense date: 1927 <br> Type: Thèse <br> Number of theses: 62","Defense date: 1928 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1929 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1930 <br> Type: Thèse <br> Number of theses: 28","Defense date: 1931 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1932 <br> Type: Thèse <br> Number of theses: 42","Defense date: 1933 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1934 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1935 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1936 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1937 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1938 <br> Type: Thèse <br> Number of theses: 39","Defense date: 1939 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1940 <br> Type: Thèse <br> Number of theses: 22","Defense date: 1941 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1942 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1943 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1944 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1945 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1946 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1947 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1948 <br> Type: Thèse <br> Number of theses: 35","Defense date: 1949 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1950 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1951 <br> Type: Thèse <br> Number of theses: 41","Defense date: 1952 <br> Type: Thèse <br> Number of theses: 36","Defense date: 1953 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1954 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1955 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1956 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1957 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1958 <br> Type: Thèse <br> Number of theses: 32","Defense date: 1959 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1960 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1961 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1962 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1963 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1964 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1965 <br> Type: Thèse <br> Number of theses: 43","Defense date: 1966 <br> Type: Thèse <br> Number of theses: 58","Defense date: 1967 <br> Type: Thèse <br> Number of theses: 50","Defense date: 1968 <br> Type: Thèse <br> Number of theses: 57","Defense date: 1969 <br> Type: Thèse <br> Number of theses: 55","Defense date: 1970 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1971 <br> Type: Thèse <br> Number of theses: 67","Defense date: 1972 <br> Type: Thèse <br> Number of theses: 100","Defense date: 1973 <br> Type: Thèse <br> Number of theses: 112","Defense date: 1974 <br> Type: Thèse <br> Number of theses: 114","Defense date: 1975 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1976 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1977 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1978 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1979 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1980 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1981 <br> Type: Thèse <br> Number of theses: 24","Defense date: 1982 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1983 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1984 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1985 <br> Type: Thèse <br> Number of theses: 234","Defense date: 1986 <br> Type: Thèse <br> Number of theses: 341","Defense date: 1987 <br> Type: Thèse <br> Number of theses: 315","Defense date: 1988 <br> Type: Thèse <br> Number of theses: 253","Defense date: 1989 <br> Type: Thèse <br> Number of theses: 212","Defense date: 1990 <br> Type: Thèse <br> Number of theses: 180","Defense date: 1991 <br> Type: Thèse <br> Number of theses: 208","Defense date: 1992 <br> Type: Thèse <br> Number of theses: 275","Defense date: 1993 <br> Type: Thèse <br> Number of theses: 264","Defense date: 1994 <br> Type: Thèse <br> Number of theses: 292","Defense date: 1995 <br> Type: Thèse <br> Number of theses: 256","Defense date: 1996 <br> Type: Thèse <br> Number of theses: 296","Defense date: 1997 <br> Type: Thèse <br> Number of theses: 372","Defense date: 1998 <br> Type: Thèse <br> Number of theses: 338","Defense date: 1999 <br> Type: Thèse <br> Number of theses: 323","Defense date: 2000 <br> Type: Thèse <br> Number of theses: 427","Defense date: 2001 <br> Type: Thèse <br> Number of theses: 345","Defense date: 2002 <br> Type: Thèse <br> Number of theses: 316","Defense date: 2003 <br> Type: Thèse <br> Number of theses: 340","Defense date: 2004 <br> Type: Thèse <br> Number of theses: 315","Defense date: 2005 <br> Type: Thèse <br> Number of theses: 312","Defense date: 2006 <br> Type: Thèse <br> Number of theses: 296","Defense date: 2007 <br> Type: Thèse <br> Number of theses: 350","Defense date: 2008 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2009 <br> Type: Thèse <br> Number of theses: 363","Defense date: 2010 <br> Type: Thèse <br> Number of theses: 397","Defense date: 2011 <br> Type: Thèse <br> Number of theses: 405","Defense date: 2012 <br> Type: Thèse <br> Number of theses: 367","Defense date: 2013 <br> Type: Thèse <br> Number of theses: 394","Defense date: 2014 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2015 <br> Type: Thèse <br> Number of theses: 373","Defense date: 2016 <br> Type: Thèse <br> Number of theses: 392","Defense date: 2017 <br> Type: Thèse <br> Number of theses: 360","Defense date: 2018 <br> Type: Thèse <br> Number of theses: 353","Defense date: 2019 <br> Type: Thèse <br> Number of theses: 339","Defense date: 2020 <br> Type: Thèse <br> Number of theses: 310","Defense date: 2021 <br> Type: Thèse <br> Number of theses: 351","Defense date: 2022 <br> Type: Thèse <br> Number of theses: 308","Defense date: 2023 <br> Type: Thèse <br> Number of theses: 129","Defense date: NA <br> Type: Thèse <br> Number of theses: 18"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse","legendgroup":"Thèse","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[2,10,7,19,26,32,56,57,91,146,258,219,297,380,365,450,482,467,483,434,219,0],"x":[1963,1964,1966,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,4,4,9,5,11,11,7,13,10,23,23,7,10,6,8,3,3,2,2,1,0],"text":["Defense date: 1963 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1966 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1968 <br> Type: Thèse complémentaire <br> Number of theses: 9","Defense date: 1969 <br> Type: Thèse complémentaire <br> Number of theses: 5","Defense date: 1970 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1971 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1973 <br> Type: Thèse complémentaire <br> Number of theses: 13","Defense date: 1974 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1975 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1976 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1977 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1978 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1979 <br> Type: Thèse complémentaire <br> Number of theses: 6","Defense date: 1980 <br> Type: Thèse complémentaire <br> Number of theses: 8","Defense date: 1981 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1982 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1983 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1984 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1985 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: NA <br> Type: Thèse complémentaire <br> Number of theses: 4"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(183,159,0,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse complémentaire","legendgroup":"Thèse complémentaire","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,1,2,2,3,10,13,18,25,45,47,79,94,143,144,208,292,279,351,406,393,428,375,187,0],"x":[1912,1922,1930,1938,1939,1942,1956,1958,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,1,1,1,1,1,2,3,1,2,1,1,8,10,4,8,6,8,7,11,10,12,52,115,75,89,88,86,99,76,74,55,59,32,0],"text":["Defense date: 1912 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1922 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1930 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1938 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1939 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1942 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1956 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1958 <br> Type: Thèse d'État <br> Number of theses: 3","Defense date: 1960 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1961 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1962 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1963 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1965 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1966 <br> Type: Thèse d'État <br> Number of theses: 4","Defense date: 1967 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1968 <br> Type: Thèse d'État <br> Number of theses: 6","Defense date: 1969 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1970 <br> Type: Thèse d'État <br> Number of theses: 7","Defense date: 1971 <br> Type: Thèse d'État <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1973 <br> Type: Thèse d'État <br> Number of theses: 12","Defense date: 1974 <br> Type: Thèse d'État <br> Number of theses: 52","Defense date: 1975 <br> Type: Thèse d'État <br> Number of theses: 115","Defense date: 1976 <br> Type: Thèse d'État <br> Number of theses: 75","Defense date: 1977 <br> Type: Thèse d'État <br> Number of theses: 89","Defense date: 1978 <br> Type: Thèse d'État <br> Number of theses: 88","Defense date: 1979 <br> Type: Thèse d'État <br> Number of theses: 86","Defense date: 1980 <br> Type: Thèse d'État <br> Number of theses: 99","Defense date: 1981 <br> Type: Thèse d'État <br> Number of theses: 76","Defense date: 1982 <br> Type: Thèse d'État <br> Number of theses: 74","Defense date: 1983 <br> Type: Thèse d'État <br> Number of theses: 55","Defense date: 1984 <br> Type: Thèse d'État <br> Number of theses: 59","Defense date: 1985 <br> Type: Thèse d'État <br> Number of theses: 32","Defense date: NA <br> Type: Thèse d'État <br> Number of theses: 1"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,186,56,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse d'État","legendgroup":"Thèse d'État","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,1,0,0,0,0,0,0,0,4,0,2,1,0,1,1,5,9,0,0],"x":[1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,2004,null],"y":[1,2,2,3,10,13,17,25,45,47,79,94,143,144,204,292,277,350,406,392,427,370,178,1,0],"text":["Defense date: 1963 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1965 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1966 <br> Type: Thèse de 3e cycle <br> Number of theses: 3","Defense date: 1967 <br> Type: Thèse de 3e cycle <br> Number of theses: 10","Defense date: 1968 <br> Type: Thèse de 3e cycle <br> Number of theses: 13","Defense date: 1969 <br> Type: Thèse de 3e cycle <br> Number of theses: 17","Defense date: 1970 <br> Type: Thèse de 3e cycle <br> Number of theses: 25","Defense date: 1971 <br> Type: Thèse de 3e cycle <br> Number of theses: 45","Defense date: 1972 <br> Type: Thèse de 3e cycle <br> Number of theses: 47","Defense date: 1973 <br> Type: Thèse de 3e cycle <br> Number of theses: 79","Defense date: 1974 <br> Type: Thèse de 3e cycle <br> Number of theses: 94","Defense date: 1975 <br> Type: Thèse de 3e cycle <br> Number of theses: 143","Defense date: 1976 <br> Type: Thèse de 3e cycle <br> Number of theses: 144","Defense date: 1977 <br> Type: Thèse de 3e cycle <br> Number of theses: 204","Defense date: 1978 <br> Type: Thèse de 3e cycle <br> Number of theses: 292","Defense date: 1979 <br> Type: Thèse de 3e cycle <br> Number of theses: 277","Defense date: 1980 <br> Type: Thèse de 3e cycle <br> Number of theses: 350","Defense date: 1981 <br> Type: Thèse de 3e cycle <br> Number of theses: 406","Defense date: 1982 <br> Type: Thèse de 3e cycle <br> Number of theses: 392","Defense date: 1983 <br> Type: Thèse de 3e cycle <br> Number of theses: 427","Defense date: 1984 <br> Type: Thèse de 3e cycle <br> Number of theses: 370","Defense date: 1985 <br> Type: Thèse de 3e cycle <br> Number of theses: 178","Defense date: 2004 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: NA <br> Type: Thèse de 3e cycle <br> Number of theses: 3"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de 3e cycle","legendgroup":"Thèse de 3e cycle","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0],"x":[1969,1979,1980,1982,1983,1984,1985],"y":[1,2,1,1,1,5,9],"text":["Defense date: 1969 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1979 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 2","Defense date: 1980 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1982 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1983 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1984 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 5","Defense date: 1985 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 9"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(97,156,255,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de docteur-ingénieur","legendgroup":"Thèse de docteur-ingénieur","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":0.90000000000009095,"base":0,"x":[1977],"y":[4],"text":"Defense date: 1977 <br> Type: Thèse sur travaux <br> Number of theses: 4","type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(245,100,227,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse sur travaux","legendgroup":"Thèse sur travaux","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":25.570776255707766,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Type of thesis","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"9e6de6b1c5a75":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"9e6de6b1c5a75","visdat":{"9e6de6b1c5a75":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 2: Distribution of theses by defence date and type of thesis

</div>

### Availability of abstracts

<div id="fig-metadata_accessible">

<div class="plotly html-widget html-fill-item" id="htmlwidget-2fcbefbc5d75398d33db" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-2fcbefbc5d75398d33db">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,0,3,2,1,0,1,1,1,1,0,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,47,26,32,30,35,45,49,35,49,55,61,54,69,65,83,85,92,133,163,215,269,372,316,392,452,449,509,507,503,510,454,431,55,46,20,21,15,19,20,22,17,5,19,11,13,17,58,58,65,57,37,24,20,34,29,23,13,7,10,5,4,7,3,3,2,3,3,3,0],"text":["Accessible: No <br> Date of defence: 1899 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1900 <br> Number of theses: 31","Accessible: No <br> Date of defence: 1901 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1902 <br> Number of theses: 27","Accessible: No <br> Date of defence: 1903 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1904 <br> Number of theses: 34","Accessible: No <br> Date of defence: 1905 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1906 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1907 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1908 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1909 <br> Number of theses: 51","Accessible: No <br> Date of defence: 1910 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1911 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1912 <br> Number of theses: 71","Accessible: No <br> Date of defence: 1913 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1914 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1915 <br> Number of theses: 8","Accessible: No <br> Date of defence: 1916 <br> Number of theses: 6","Accessible: No <br> Date of defence: 1917 <br> Number of theses: 12","Accessible: No <br> Date of defence: 1918 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1919 <br> Number of theses: 25","Accessible: No <br> Date of defence: 1920 <br> Number of theses: 52","Accessible: No <br> Date of defence: 1921 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1922 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1923 <br> Number of theses: 72","Accessible: No <br> Date of defence: 1924 <br> Number of theses: 70","Accessible: No <br> Date of defence: 1925 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1926 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1927 <br> Number of theses: 62","Accessible: No <br> Date of defence: 1928 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1929 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1930 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1931 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1932 <br> Number of theses: 42","Accessible: No <br> Date of defence: 1933 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1934 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1935 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1936 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1937 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1938 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1939 <br> Number of theses: 53","Accessible: No <br> Date of defence: 1940 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1941 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1942 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1943 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1944 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1945 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1946 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1947 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1948 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1949 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1950 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1951 <br> Number of theses: 41","Accessible: No <br> Date of defence: 1952 <br> Number of theses: 36","Accessible: No <br> Date of defence: 1953 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1954 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1955 <br> Number of theses: 26","Accessible: No <br> Date of defence: 1956 <br> Number of theses: 32","Accessible: No <br> Date of defence: 1957 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1958 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1959 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1960 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1961 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1962 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1963 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1964 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1965 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1966 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1967 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1968 <br> Number of theses: 83","Accessible: No <br> Date of defence: 1969 <br> Number of theses: 85","Accessible: No <br> Date of defence: 1970 <br> Number of theses: 92","Accessible: No <br> Date of defence: 1971 <br> Number of theses: 133","Accessible: No <br> Date of defence: 1972 <br> Number of theses: 163","Accessible: No <br> Date of defence: 1973 <br> Number of theses: 215","Accessible: No <br> Date of defence: 1974 <br> Number of theses: 269","Accessible: No <br> Date of defence: 1975 <br> Number of theses: 372","Accessible: No <br> Date of defence: 1976 <br> Number of theses: 316","Accessible: No <br> Date of defence: 1977 <br> Number of theses: 392","Accessible: No <br> Date of defence: 1978 <br> Number of theses: 452","Accessible: No <br> Date of defence: 1979 <br> Number of theses: 449","Accessible: No <br> Date of defence: 1980 <br> Number of theses: 509","Accessible: No <br> Date of defence: 1981 <br> Number of theses: 507","Accessible: No <br> Date of defence: 1982 <br> Number of theses: 503","Accessible: No <br> Date of defence: 1983 <br> Number of theses: 510","Accessible: No <br> Date of defence: 1984 <br> Number of theses: 454","Accessible: No <br> Date of defence: 1985 <br> Number of theses: 431","Accessible: No <br> Date of defence: 1986 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1987 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1988 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1989 <br> Number of theses: 21","Accessible: No <br> Date of defence: 1990 <br> Number of theses: 15","Accessible: No <br> Date of defence: 1991 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1992 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1993 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1994 <br> Number of theses: 17","Accessible: No <br> Date of defence: 1995 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1996 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1997 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1998 <br> Number of theses: 13","Accessible: No <br> Date of defence: 1999 <br> Number of theses: 17","Accessible: No <br> Date of defence: 2000 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2001 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2002 <br> Number of theses: 65","Accessible: No <br> Date of defence: 2003 <br> Number of theses: 57","Accessible: No <br> Date of defence: 2004 <br> Number of theses: 37","Accessible: No <br> Date of defence: 2005 <br> Number of theses: 24","Accessible: No <br> Date of defence: 2006 <br> Number of theses: 20","Accessible: No <br> Date of defence: 2007 <br> Number of theses: 34","Accessible: No <br> Date of defence: 2008 <br> Number of theses: 29","Accessible: No <br> Date of defence: 2009 <br> Number of theses: 23","Accessible: No <br> Date of defence: 2010 <br> Number of theses: 13","Accessible: No <br> Date of defence: 2011 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2012 <br> Number of theses: 10","Accessible: No <br> Date of defence: 2013 <br> Number of theses: 5","Accessible: No <br> Date of defence: 2014 <br> Number of theses: 4","Accessible: No <br> Date of defence: 2015 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2016 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2017 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2018 <br> Number of theses: 2","Accessible: No <br> Date of defence: 2019 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2020 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2021 <br> Number of theses: 3","Accessible: No <br> Date of defence: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"No","legendgroup":"No","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1954,1962,1965,1967,1968,1969,1971,1972,1973,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023],"y":[1,1,1,3,2,1,1,1,1,1,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,308,129],"text":["Accessible: Yes <br> Date of defence: 1954 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1962 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1965 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1967 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1968 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1969 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1971 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1972 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1973 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1974 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1976 <br> Number of theses: 6","Accessible: Yes <br> Date of defence: 1977 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1978 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1979 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1980 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1981 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1982 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1983 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1984 <br> Number of theses: 8","Accessible: Yes <br> Date of defence: 1985 <br> Number of theses: 23","Accessible: Yes <br> Date of defence: 1986 <br> Number of theses: 286","Accessible: Yes <br> Date of defence: 1987 <br> Number of theses: 269","Accessible: Yes <br> Date of defence: 1988 <br> Number of theses: 233","Accessible: Yes <br> Date of defence: 1989 <br> Number of theses: 191","Accessible: Yes <br> Date of defence: 1990 <br> Number of theses: 165","Accessible: Yes <br> Date of defence: 1991 <br> Number of theses: 189","Accessible: Yes <br> Date of defence: 1992 <br> Number of theses: 255","Accessible: Yes <br> Date of defence: 1993 <br> Number of theses: 242","Accessible: Yes <br> Date of defence: 1994 <br> Number of theses: 275","Accessible: Yes <br> Date of defence: 1995 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 1996 <br> Number of theses: 277","Accessible: Yes <br> Date of defence: 1997 <br> Number of theses: 361","Accessible: Yes <br> Date of defence: 1998 <br> Number of theses: 325","Accessible: Yes <br> Date of defence: 1999 <br> Number of theses: 306","Accessible: Yes <br> Date of defence: 2000 <br> Number of theses: 369","Accessible: Yes <br> Date of defence: 2001 <br> Number of theses: 287","Accessible: Yes <br> Date of defence: 2002 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 2003 <br> Number of theses: 283","Accessible: Yes <br> Date of defence: 2004 <br> Number of theses: 279","Accessible: Yes <br> Date of defence: 2005 <br> Number of theses: 288","Accessible: Yes <br> Date of defence: 2006 <br> Number of theses: 276","Accessible: Yes <br> Date of defence: 2007 <br> Number of theses: 316","Accessible: Yes <br> Date of defence: 2008 <br> Number of theses: 332","Accessible: Yes <br> Date of defence: 2009 <br> Number of theses: 340","Accessible: Yes <br> Date of defence: 2010 <br> Number of theses: 384","Accessible: Yes <br> Date of defence: 2011 <br> Number of theses: 398","Accessible: Yes <br> Date of defence: 2012 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2013 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2014 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2015 <br> Number of theses: 366","Accessible: Yes <br> Date of defence: 2016 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2017 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2018 <br> Number of theses: 351","Accessible: Yes <br> Date of defence: 2019 <br> Number of theses: 336","Accessible: Yes <br> Date of defence: 2020 <br> Number of theses: 307","Accessible: Yes <br> Date of defence: 2021 <br> Number of theses: 348","Accessible: Yes <br> Date of defence: 2022 <br> Number of theses: 308","Accessible: Yes <br> Date of defence: 2023 <br> Number of theses: 129"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Yes","legendgroup":"Yes","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":25.570776255707766,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Accessible","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"9e6de3283580a":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"9e6de3283580a","visdat":{"9e6de3283580a":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 3: Distribution of theses by the availability of abstracts

</div>

</div>

> [!NOTE]
>
> ### The variable `type`
>
> The French education system lacked a standardized Ph.D. system between
> the early 1960s and 1984, the year of the Savary reform, which
> harmonized the Ph.D. system. During this period, various types of
> theses coexisted. For instance, in the mid-1970s, it was common for
> scholars to first complete a “Doctorat de 3e cycle” before pursuing a
> “Doctorat d’État.” As a result, a single author may have produced
> multiple types of theses. <a href="#fig-metadata_distribution_type"
> class="quarto-xref">Figure 2</a> illustrates the distribution of
> theses over time, categorized by type. It should also be noted that
> the inclusion of thesis type in the metadata is not systematically
> ensured. This variability depends on the quality of metadata provided
> by individual institutions, which may affect the reliability of
> classification.

> [!WARNING]
>
> ### Availability of `abstracts`
>
> The practice of providing abstracts started in the 1980s. Prior to
> this period, abstracts were missing (see
> <a href="#fig-metadata_accessible" class="quarto-xref">Figure 3</a>).

## Edges

Each line in the `thesis_edge` table represents a unique edge between a
thesis and an entity. We define an *entity* as any individual or
institution involved in the thesis. The edge table has five 5 columns:

- `thesis_id`: the identifier of a thesis (the same as in
  thesis_metadata). In the edge table, a `thesis_id` can have several
  edges. A `thesis_id` has *at least* two edges: the author and the
  institution where the thesis was defended.  
- `entity_id`: the identifier of an entity. If it exists, it is the
  official “idref”, an unique identifiers created by the ABES (see
  <https://www.idref.fr/>). If not, it is a temporary identifier we have
  created following the strategy we used for `thesis_id`.
- `entity_role`: the role of the entity. A person, for example, may
  serve as an author, supervisor, referee, president, or jury member. In
  addition to identifying the primary institution where the Ph.D. was
  defended, the `entity_role` variable may include supplementary
  information we collected, such as affiliations with other
  institutions, laboratories, or doctoral schools (the organizations
  responsible for overseeing doctoral programs in French universities).
  This detailed information primarily applies to theses recorded in
  theses.fr after 1985. For data sourced from Sudoc, the value
  “etablissements_soutenance_from_info” of `entity_role` may provide
  additional information regarding the institutions associated with the
  thesis.
- `entity_name`: The name of the entity. It is derived from the
  preferred name in the official IdRef notice, or from raw information
  when the entity has no IdRef. See <a href="#sec-cleaning-institutions"
  class="quarto-xref">Section 3.2.5</a> and
  <a href="#sec-cleaning-persons" class="quarto-xref">Section 3.2.6</a>
  for more information about names standardization.  
- `entity_firstname`, the first name of the individual. Coded as missing
  value when the entity is an institution.

> [!NOTE]
>
> ### Entity identifiers
>
> Through the <https://www.idref.fr/> platform, the ABES assigns unique
> identifiers to institutions and individuals involved in research in
> France. This system provides valuable information about entities, such
> as their dates of existence and the various names used to refer to
> entities. For example, see the entry for the former [University of
> Paris](https://www.idref.fr/034526110) that split after 1968. We
> scrapped those information to enrich our institution and individual
> tables (see
> <a href="#sec-idref" class="quarto-xref">Section 3.1.3</a>).

<a href="#tbl-edges" class="quarto-xref">Table 2</a> shows a sample of
the thesis edge table. We identify 100814 edges in total.
<a href="#fig-person-role" class="quarto-xref">Figure 4</a> shows the
distribution of individuals by role.
<a href="#fig-person-institution" class="quarto-xref">Figure 5</a> shows
the distribution of individuals for the top institutions.

<div id="tbl-edges">

Table 2: Sample of the edges table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-e130ecf35de90d59f323" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-e130ecf35de90d59f323">{"x":{"filter":"none","vertical":false,"data":[["1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1985MON10001","1985MON10001","1985MON10001","2010NICE0003","2010NICE0003","2010NICE0003","2012PAUU2021","2012PAUU2021","2012PAUU2021","2012PAUU2021","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","temp_sudoc_thesis_141860","temp_sudoc_thesis_141860","temp_sudoc_thesis_141860","temp_sudoc_thesis_212626","temp_sudoc_thesis_212626","temp_sudoc_thesis_212626","temp_sudoc_thesis_438118","temp_sudoc_thesis_438118","temp_sudoc_thesis_438118"],["153480777","030142199","028949145","030415705","060856076","060856076","129104000","034750703","027548341","026820641","026957620","026967804","031858961","02674628X","034466924","02674628X","250742438","028032837","028978900","14270783X","026403498","034113851","172500494","156729849","026403668","081536828","196669863","145585387","15863621X","050221027","050322184","059907479","117820903","131591436","117820903","034789731","050221027","050322184","059907479","200879022","158989694","241597595","032173938","035210710","086000594","139157581","175955751","176007121","032173938","027787109","164977147","086000594","176007121","035210710","temp_sudoc_person_506037","026403765","026776057","temp_sudoc_person_187208","026374889","027071308","033299951","027361802","026706555"],["author","institution_defence","member","member","member","president","research_partner","author","institution_defence","member","member","member","member","president","research_partner","supervisor","author","institution_defence","supervisor","author","institution_defense","supervisor","author","doctoral_schools","institution_defense","supervisor","author","doctoral_schools","institution_defense","member","member","member","member","member","president","research_partner","reviewer","reviewer","supervisor","author","doctoral_schools","institution_defense","member","member","member","member","member","member","president","research_partner","research_partner","reviewer","reviewer","supervisor","author","institution_defence","supervisor","author","institution_defence","supervisor","author","institution_defence","supervisor"],["Gachitch","Université de Bordeaux (1441-1970)","Pirou","Palmade","Benzacar","Benzacar","Université de Bordeaux. Faculté de droit (1870-1970)","Goulvestre","Université Bordeaux-I (1971-2013)","Delfaud","Labourdette","Lassudrie-Duchêne","Lacour","Bourguinat","Université Bordeaux-I. Faculté de droit, des sciences sociales et politiques (1971-1995)","Bourguinat","Yaseri","Université de Montpellier I (1970-2014)","Ousset","Gordah","Université de Nice (1965-2019)","Ravix","Benaissa","École doctorale sciences sociales et humanités (Pau, Pyrénées Atlantiques)","Université de Pau et des Pays de l'Adour (1970-....)","Bouoiyour","Clain-Chamosset-Yvrard","Ecole doctorale Sciences Economiques et de Gestion d'Aix-Marseille (Aix-en-Provence ; 2000-....)","Aix-Marseille Université (2012-....)","Le Van","Wigniolle","Seegmuller","Nourry","Kamihigashi","Nourry","Groupe de recherche en économie quantitative d'Aix-Marseille","Le Van","Wigniolle","Seegmuller","Charruau","Ecole doctorale SDOSE (Paris)","Université Paris sciences et lettres (2020-....)","Mouhoud","Epaulard","Lafourcade","Fack","Dherbécourt","Bosquet","Mouhoud","Université Paris Dauphine-PSL (1968-....)","Laboratoire d’Economie de Dauphine (Paris)","Lafourcade","Bosquet","Epaulard","Ghazzaoui","Université de Poitiers (1896-...)","Chaîneau","Contreras","École des hautes études en sciences sociales (Paris ; 1975-....)","Piatier","Clark","Université Paris 1 Panthéon-Sorbonne (1971-....)","Barrère"],["Yovan",null,"Gaëtan","Maurice","Joseph","Joseph",null,"Jean-Paul",null,"Pierre","André","Bernard","Claude","Henri",null,"Henri","Hassan Al",null,"Jean","Ahmed Maher",null,"Joël Thomas","Mohamed Anouar",null,null,"Jamal","Lise",null,null,"Cuong","Bertrand","Thomas","Carine","Takashi","Carine",null,"Cuong","Bertrand","Thomas","Paul",null,null,"El Mouhoub","Anne","Miren","Gabrielle","Clément","Clément","El Mouhoub",null,null,"Miren","Clément","Anne","Ali",null,"André","Francisco José",null,"André","Ephraim",null,"Alain"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>entity_id<\/th>\n      <th>entity_role<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":10,"scrollX":true,"columnDefs":[{"name":"thesis_id","targets":0},{"name":"entity_id","targets":1},{"name":"entity_role","targets":2},{"name":"entity_name","targets":3},{"name":"entity_firstname","targets":4}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Top roles

<div id="fig-person-role">

<div class="plotly html-widget html-fill-item" id="htmlwidget-7ce827ade8c7c1a760d0" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-7ce827ade8c7c1a760d0">{"x":{"data":[{"orientation":"h","width":[0.90000000000000036,0.90000000000000036,0.89999999999999991,0.90000000000000013,0.90000000000000036],"base":[0,0,0,0,0],"x":[21019,16000,3960,7273,19288],"y":[5,3,1,2,4],"text":["Role: author <br> Number of individuals: 21019","Role: member <br> Number of individuals: 16000","Role: president <br> Number of individuals: 3960","Role: reviewer <br> Number of individuals: 7273","Role: supervisor <br> Number of individuals: 19288"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":69.406392694063939},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-1050.95,22069.950000000001],"tickmode":"array","ticktext":["0","5000","10000","15000","20000"],"tickvals":[0,5000.0000000000009,10000,15000,20000],"categoryorder":"array","categoryarray":["0","5000","10000","15000","20000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of individuals","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,5.5999999999999996],"tickmode":"array","ticktext":["president","reviewer","member","supervisor","author"],"tickvals":[1,2,3,4,5],"categoryorder":"array","categoryarray":["president","reviewer","member","supervisor","author"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"9e6de75930470":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"9e6de75930470","visdat":{"9e6de75930470":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 4: Top role

</div>

### Top institutions

<div id="fig-person-institution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-30eed458b6bb05caf719" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-30eed458b6bb05caf719">{"x":{"data":[{"orientation":"h","width":[0.89999999999999858,0.89999999999999858,0.89999999999999947,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000013,0.89999999999999991],"base":[0,0,0,0,0,0,0,0,0,0],"x":[3012,1295,903,800,793,779,711,696,579,562],"y":[10,9,8,7,6,5,4,3,2,1],"text":["Role: Université Paris 1 Panthéon-Sorbonne (1971-....) <br> Number of edges: 3012","Role: Université Paris Nanterre <br> Number of edges: 1295","Role: Université de Paris (1896-1968) <br> Number of edges: 903","Role: Université Paris Dauphine-PSL (1968-....) <br> Number of edges: 800","Role: Université de Montpellier I (1970-2014) <br> Number of edges: 793","Role: École des hautes études en sciences sociales (Paris ; 1975-....) <br> Number of edges: 779","Role: Université Toulouse 1 Capitole (1970-2022) <br> Number of edges: 711","Role: Université de Paris (1896-1968). Faculté de droit et des sciences économiques <br> Number of edges: 696","Role: École doctorale d'Économie (Paris ; 2004-....) <br> Number of edges: 579","Role: Université de Nice (1965-2019) <br> Number of edges: 562"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":461.00456621004582},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-150.59999999999999,3162.5999999999999],"tickmode":"array","ticktext":["0","1000","2000","3000"],"tickvals":[0,999.99999999999989,2000,3000],"categoryorder":"array","categoryarray":["0","1000","2000","3000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of edges","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,10.6],"tickmode":"array","ticktext":["Université de Nice (1965-2019)","École doctorale d'Économie (Paris ; 2004-....)","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université Toulouse 1 Capitole (1970-2022)","École des hautes études en sciences sociales (Paris ; 1975-....)","Université de Montpellier I (1970-2014)","Université Paris Dauphine-PSL (1968-....)","Université de Paris (1896-1968)","Université Paris Nanterre","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"tickvals":[1,2,3,4,5,6.0000000000000009,7,8,9,10],"categoryorder":"array","categoryarray":["Université de Nice (1965-2019)","École doctorale d'Économie (Paris ; 2004-....)","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université Toulouse 1 Capitole (1970-2022)","École des hautes études en sciences sociales (Paris ; 1975-....)","Université de Montpellier I (1970-2014)","Université Paris Dauphine-PSL (1968-....)","Université de Paris (1896-1968)","Université Paris Nanterre","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"9e6de19da1ced":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"9e6de19da1ced","visdat":{"9e6de19da1ced":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 5: Top role

</div>

</div>

Note that the two figures represent the raw count of observations in the
edge table and do not account for thesis duplicates. For example, to
determine the exact number of theses published by the Université Paris I
Panthéon-Sorbonne, it is necessary to first address duplicates in the
metadata tables. This can be achieved by merging entries identified as
duplicates using the `duplicates` column.

### Complete Edges Data

The `thesis_edge_complete_data` allows the comparison between original
data as collected on theses.fr and sudoc with the results of our
cleaning process. In addition to the columns of `thesis_edge`, we have 4
additional columns:

- `original_id`: the original identifier of the entity in the raw data.
  This allows to see how temporary identifiers for institutions have
  been cleaned to find the official idref.
- `original_entity_name`: the name of the entity as in the original raw
  data.
- `original_entity_firstname`: the first name of the individual as in
  the original data source.
- `source`: the source of the data. It can be “thesesfr” or “sudoc”.

<a href="#tbl-edges-complete" class="quarto-xref">Table 3</a> shows a
sample of the additional information contained in the
`thesis_edge_complete` table.

<div id="tbl-edges-complete">

Table 3: Sample of the thesis institution table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-f32e72cd5b21c2a84b31" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-f32e72cd5b21c2a84b31">{"x":{"filter":"none","vertical":false,"data":[["1987PA020090","1987PA020090","1987PA020090","temp_sudoc_thesis_687653","temp_sudoc_thesis_687653","temp_sudoc_thesis_687653","temp_sudoc_thesis_693068","temp_sudoc_thesis_693068","temp_sudoc_thesis_693068"],["033228868","026403145","026861992","032347804","027361802","026870851","temp_sudoc_person_502633","034925732","034526110"],[null,"026403145",null,null,"027361802",null,null,"temp_sudoc_institution_285078","temp_sudoc_institution_729329"],["author","institution_defense","supervisor","author","institution_defence","supervisor","author","institution_defence","institution_defence_from_info"],["Scannavino","Université Panthéon-Assas (Paris ; 1970-2021)","Fericelli","Agénor","Université Paris 1 Panthéon-Sorbonne (1971-....)","Fourgeaud","Karlikovitch","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université de Paris (1896-1968)"],["Aimé",null,"Anne-Marie","Pierre-Richard",null,"Claude",null,null,null],["Scannavino","Paris 2","Fericelli","Agénor","Université Paris 1 Panthéon-Sorbonne","Fourgeaud","Karlikovitch","Université de Paris. Faculté de droit","Paris"],["Aimé",null,"Anne-Marie","Pierre-Richard",null,"Claude",null,null,null],["thesesfr","thesesfr","thesesfr","sudoc","sudoc","sudoc","sudoc","sudoc","sudoc"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>entity_id<\/th>\n      <th>original_id<\/th>\n      <th>entity_role<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n      <th>original_entity_name<\/th>\n      <th>original_entity_firstname<\/th>\n      <th>source<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":10,"scrollX":true,"columnDefs":[{"name":"thesis_id","targets":0},{"name":"entity_id","targets":1},{"name":"original_id","targets":2},{"name":"entity_role","targets":3},{"name":"entity_name","targets":4},{"name":"entity_firstname","targets":5},{"name":"original_entity_name","targets":6},{"name":"original_entity_firstname","targets":7},{"name":"source","targets":8}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

## Institutions

In the `thesis_institution` table, each line represents a unique
institution. Institutions are the universities, laboratories, doctoral
schools, and other institutions associated with the theses. The table
contains 1435 institutions and 19 variables. It consists of two core
variables:

- `entity_id`: the unique identifier of the entity (here the
  institution).
- `entity_name`: the name of the entity. When an IdRef exists, the
  `entity_name` comes from the `pref_name` variable of the IdRef
  database.
- `old_id` : the list of the temporary identifiers of the entity that
  has been merged with the `entity_id` (see
  <a href="#sec-cleaning-institutions"
  class="quarto-xref">Section 3.2.5</a> for details on the cleaning
  process).

The other variables are additional information on the institutions
scrapped on [IdRef](https://www.idref.fr/):

- `url`: the IdRef url of the entity.
- `other_labels`: other labels of the entity.
- `date_of_birth`: the date of creation of the entity.
- `date_of_death`: the date of disappearance of the entity.
- `information`: additional information on the entity.
- `replaced_idref`: the identifier of the entity that replaced the
  entity.
- `predecessor`: the predecessor of the entity.
- `predecessor_idref`: the identifier of the predecessor of the entity.
- `successor`: the successor of the entity.
- `successor_idref`: the identifier of the successor of the entity.
- `subordinated`: list of the entities subordinated to the entity.
- `subordinated_idref`: list of the identifiers of the entities
  subordinated to the entity.
- `unit_of`: the entities to which the entity in question is a unit of.
- `unit_of_idref`: the identifier of the entities to which the entity in
  question is unit of.
- `other_link`: other links of the entity.
- `country_name`: the country of the entity.

> [!WARNING]
>
> ### Handling institutions without identifier
>
> An essential aspect of our work involved associating institutions
> without an IdRef identifier to an existing IdRef. This step was
> crucial for standardizing information, particularly regarding the
> names of entities, and for enabling users to accurately assess the
> involvement of a given entity in theses. The process was relatively
> straightforward for the institution table, as it contains only a few
> hundred unique institutions. Consequently, the main
> institutions—universities—are well identified by a unique IdRef in
> most cases.

<a href="#tbl-institution" class="quarto-xref">Table 4</a> shows a
sample of the `thesis_institution` table.

<div id="tbl-institution">

Table 4: Sample of the thesis institution table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-b1e2fbf5d899b249c1a5" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-b1e2fbf5d899b249c1a5">{"x":{"filter":"none","vertical":false,"data":[["026375273","temp_sudoc_institution_725305","183948173","074038567","195479270"],["Télécom Paris (Palaiseau, Essonne ; 1878-....)","Paris 2","Centre d'économie et de management de l'océan Indien (Saint-Denis, Réunion)","Université de Bourgogne. URF des sciences et techniques","Centre d’études en sciences sociales sur les mondes africains, américains et asiatiques (Paris ; 2014-....)"],[[null],[null],[null],[null],[null]],["https://www.idref.fr/026375273.rdf",null,"https://www.idref.fr/183948173.rdf","https://www.idref.fr/074038567.rdf","https://www.idref.fr/195479270.rdf"],["c(\"ENST (Paris) -- (1942-2007)\", \"École nationale supérieure des télécommunic...",null,"c(\"CEMOI\", \"Équipe d'accueil (EA13)\", \"Université de la Réunion. Centre d'éco...","c(\"Université de Bourgogne. Faculté des sciences\", \"Université de Dijon. Facu...",["CESSMA","UMR 245","UMR_D 245"]],["1878",null,"2010-01-01",null,"2014"],[null,null,null,null,null],["c(\"Télécom Paris est un établissement public à caractère scientifique, cultur...",null,"CEMOI = Centre d'économie et de management de l'océan Indien","Adresse : Campus universitaire, bât. Mirande : 9 avenue Alain-Savary, BP 2787...","c(\"Bât. Olympe de Gouges - 8 Rue Albert Einstein 75013 Paris\", \"Unité mixte d..."],["186107218",null,[],[],[]],["École nationale supérieure des postes et télécommunications",null,[],[],[]],["026375265",null,[],[],[]],[[],null,[],[],[]],[[],null,[],[],[]],[[],null,[],[],[]],[[],null,[],[],[]],[["Institut Mines-Télécom","Université Paris-Saclay","Institut polytechnique de Paris"],null,[],[],["Université Paris Diderot - Paris 7","Institut national des langues et civilisations orientales","Institut de recherche pour le développement","Université Paris Cité"]],[["192427156","188120777","238327159"],null,[],[],["027542084","026388715","050165224","236453505"]],[["https://data.hal.science/structure/1048346#foaf:Organization","https://ror.org/01naq7912#foaf:Organization","http://isni.org/isni/0000000121096951","http://data.bnf.fr/ark:/12148/cb11863493k#foaf:Organization","http://viaf.org/viaf/130089636","https://fr.wikipedia.org/wiki/Télécom_Bretagne"],null,"http://viaf.org/viaf/314928916",["http://data.bnf.fr/ark:/12148/cb11999829t#foaf:Organization","http://viaf.org/viaf/123570251","https://fr.wikipedia.org/wiki/Bâtiment_de_la_faculté_des_sciences_de_Dijon"],["https://data.hal.science/structure/1005064#foaf:Organization","https://data.hal.science/structure/450540#foaf:Organization","http://viaf.org/viaf/6758156133216958430003"]],["France",null,null,"France","France"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>old_id<\/th>\n      <th>url<\/th>\n      <th>other_labels<\/th>\n      <th>date_of_birth<\/th>\n      <th>date_of_death<\/th>\n      <th>information<\/th>\n      <th>replaced_idref<\/th>\n      <th>predecessor<\/th>\n      <th>predecessor_idref<\/th>\n      <th>successor<\/th>\n      <th>successor_idref<\/th>\n      <th>subordinated<\/th>\n      <th>subordinated_idref<\/th>\n      <th>unit_of<\/th>\n      <th>unit_of_idref<\/th>\n      <th>other_link<\/th>\n      <th>country_name<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"old_id","targets":2},{"name":"url","targets":3},{"name":"other_labels","targets":4},{"name":"date_of_birth","targets":5},{"name":"date_of_death","targets":6},{"name":"information","targets":7},{"name":"replaced_idref","targets":8},{"name":"predecessor","targets":9},{"name":"predecessor_idref","targets":10},{"name":"successor","targets":11},{"name":"successor_idref","targets":12},{"name":"subordinated","targets":13},{"name":"subordinated_idref","targets":14},{"name":"unit_of","targets":15},{"name":"unit_of_idref","targets":16},{"name":"other_link","targets":17},{"name":"country_name","targets":18}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

## Individuals

In the individuals table, each line represents a unique individual.
Individual are the authors, supervisors and other jury members
associated with the theses. The table contains 27553 individuals and 14
variables:

- `entity_id`: the unique identifier of the individual.
- `entity_name`: the family name of the individual.
- `entity_firstname`: the first name of the individual.
- `gender`: the gender of the individual according to the IdRef
  database.
- `gender_expanded`: the gender of the individual according to the IdRef
  database augmented for missing values with the French census data (see
  details in
  <a href="#sec-cleaning-persons" class="quarto-xref">Section 3.2.6</a>).

The other variables are additional information on the individual
provided by the IdRef database:

- `birth`: the birth date of the individual.
- `country_name`: the country name of the individual.
- `information`: additional information on the individual.
- `organization`: a list of organizations in which the individual
  worked.
- `last_date_org`: the last dates recorded for which the individual was
  still a member of these organizations
- `start_date_org`: the starting dates for each organization in which
  the individual worked.
- `end_date_org`: the ending dates for each organization in which the
  individual worked.
- `other_link`: a list of link to relevant online repository pages of
  the individual.
- `homonym_of`: a list of the `entity_id` of the individual’s homonyms
  (see
  <a href="#sec-cleaning-persons" class="quarto-xref">Section 3.2.6</a>
  for details).

> [!WARNING]
>
> ### Handling missing identifiers for individuals with `homonym_of`
>
> Disambiguating individual entities, when IdRef identifiers were
> missing, proved more challenging than disambiguating institutions. For
> example, it is relatively straightforward to determine that the
> strings “Université Paris I” and “Université Paris I
> Panthéon-Sorbonne” refer to the same institution. In contrast,
> identifying whether “Robert Martin,” who authored a Ph.D. in 1985, is
> the same individual as “Robert Martin,” who supervised a Ph.D. in
> 2022, is far less certain. To assist users in identifying potential
> matches between individuals, the variable `homonym_of` highlights
> cases where two records may represent the same person. For further
> details on the methodology, refer to
> <a href="#sec-cleaning-persons" class="quarto-xref">Section 3.2.6</a>.

<a href="#tbl-person" class="quarto-xref">Table 5</a> shows a sample of
the thesis metadata table.

<div id="tbl-person">

Table 5: Sample of the thesis person table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-a047c539d4da26bc3c4d" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-a047c539d4da26bc3c4d">{"x":{"filter":"none","vertical":false,"data":[["055241220","250011042","106933639","220475709","117689246"],["Dieng","Galle","Tefas","Jung","Pelletier"],["Seydi Ababacar","Marion","Georges","Jean-Luc","Julien"],["male","female",null,"male","male"],["male","female","male","male","male"],["19XX","19XX",null,"19XX","19XX"],[null,null,"France","France","France"],["Maître de conférences de sciences économiques au LEREPS-IERT à Toul...","Directeur du laboratoire C3S (Culture, Sport, Santé, Société) de l'...","Auteur d'une thèse en Sciences économiques à Paris 1 en 2015","Professeur - Etablissement : University of National and World Econo...","Docteur en science économique"],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[["https://orcid.org/0000-0003-1429-783X","http://isni.org/isni/0000000431765954","http://viaf.org/viaf/203817147","https://www.persee.fr/authority/230158"],["http://viaf.org/viaf/418160483936504992404"],["http://isni.org/isni/0000000439717033","http://viaf.org/viaf/211244855"],["https://data.hal.science/author/jean-luc-jung#foaf:Person","https://orcid.org/0000-0002-8795-8056","http://viaf.org/viaf/99151302985348662357"],["http://isni.org/isni/0000000356016063","http://data.bnf.fr/ark:/12148/cb15583747p#foaf:Person","http://viaf.org/viaf/175705423"]],[["055241220","temp_thesefr_person_100950"],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n      <th>gender<\/th>\n      <th>gender_expanded<\/th>\n      <th>birth<\/th>\n      <th>country_name<\/th>\n      <th>information<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"entity_firstname","targets":2},{"name":"gender","targets":3},{"name":"gender_expanded","targets":4},{"name":"birth","targets":5},{"name":"country_name","targets":6},{"name":"information","targets":7},{"name":"organization","targets":8},{"name":"last_date_org","targets":9},{"name":"start_date_org","targets":10},{"name":"end_date_org","targets":11},{"name":"other_link","targets":12},{"name":"homonym_of","targets":13}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Gender

<div id="fig-person_genre">

<div class="plotly html-widget html-fill-item" id="htmlwidget-4878bcd26d25248024a4" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-4878bcd26d25248024a4">{"x":{"data":[{"orientation":"v","width":[0.90000000000000013,0.89999999999999991,0.90000000000000036],"base":[0,0,0],"x":[2,1,3],"y":[70.515007440206148,23.775995354407868,5.7089972053859839],"text":["Gender: male <br> Number of theses: 19429 <br> 70.52%","Gender: female <br> Number of theses: 6551 <br> 23.78%","Gender: Unknown <br> Number of theses: 1573 <br> 5.71%"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":22.648401826484022},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,3.6000000000000001],"tickmode":"array","ticktext":["female","male","Unknown"],"tickvals":[1,2,3],"categoryorder":"array","categoryarray":["female","male","Unknown"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Gender Expanded","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-3.5257503720103074,74.040757812216455],"tickmode":"array","ticktext":["0","20","40","60"],"tickvals":[0,20,40,59.999999999999993],"categoryorder":"array","categoryarray":["0","20","40","60"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"9e6de475bee76":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"9e6de475bee76","visdat":{"9e6de475bee76":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 6: Distribution of individuals by gender

</div>

### Country

<div id="fig-person_country">

![](documentation_french_database_files/figure-commonmark/fig-person_country-1.png)


Figure 7: Distribution of individuals by country (top 10 excluding
France)

</div>

</div>

# Data collection and cleaning process

This section outlines our strategy for constructing the database, which
is divided into two main steps:

- **Scraping:** The first step consists of scraping data from the three
  main sources: Theses.fr, Sudoc, and IdRef.
- **Cleaning:** The second step entails processing and cleaning the raw
  data files to generate five relational tables.

The `R` code is available in the following [GitHub
repository](https://github.com/tdelcey/becoming_economists/tree/main/FR/R).
The following diagram illustrates the relationships between each script.
If you encounter any errors or have questions regarding the data or the
codes, please submit an
[issue](https://github.com/tdelcey/becoming_economists/issues).

<div class="grViz html-widget html-fill-item" id="htmlwidget-6ee2e59bd31d167a646e" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-6ee2e59bd31d167a646e">{"x":{"diagram":"\ndigraph project_dag {\n graph [layout = dot, rankdir = TB]\n \n # Define nodes\n scraping_sudoc_id [label = \"scraping_sudoc_id.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_id.R\"]\n scraping_sudoc_api [label = \"scraping_sudoc_api.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_api.R\"]\n cleaning_sudoc [label = \"cleaning_sudoc.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_sudoc.R\"]\n downloading_theses_fr [label = \"downloading_theses_fr.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/downloading_theses_fr.R\"]\n cleaning_thesesfr [label = \"cleaning_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_thesesfr.R\"]\n merging_database [label = \"merging_sudoc_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/merging_sudoc_thesesfr.R\"]\n idref_institutions [label = \"scraping_idref_institution.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_institution.R\"]\n idref_persons [label = \"scraping_idref_person.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_person.R\"]\n cleaning_metadata [label = \"cleaning_metadata.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_metadata.R\"]\n cleaning_institutions [label = \"cleaning_institutions.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_institutions.R\"]\n cleaning_persons [label = \"cleaning_persons.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_persons.R\"]\n cleaning_edges [label = \"cleaning_edges.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_edges.R\"]\n \n # Define edges\n scraping_sudoc_id -> scraping_sudoc_api\n scraping_sudoc_api -> cleaning_sudoc \n downloading_theses_fr -> cleaning_thesesfr\n cleaning_sudoc -> merging_database\n cleaning_thesesfr -> merging_database\n merging_database -> idref_institutions\n merging_database -> idref_persons\n merging_database -> cleaning_metadata\n idref_institutions -> cleaning_institutions\n idref_persons -> cleaning_persons\n cleaning_metadata -> cleaning_edges\n cleaning_institutions -> cleaning_edges\n cleaning_persons -> cleaning_edges\n}\n","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

## Scraping

### theses.fr

Theses records are registered in [theses.fr](https://theses.fr/) since
1985. Theses.fr data are also stored on
[data.gouv.fr](https://www.data.gouv.fr/fr/datasets/theses-soutenues-en-france-depuis-1985/#/resources)
website. They can be downloaded directly at this
[URL](https://www.data.gouv.fr/fr/datasets/r/eb06a4f5-a9f1-4775-8226-33425c933272).
The set of data we downloaded dated back from January 2024. The
[downloading_theses_fr.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/downloading_theses_fr.R)
script allows to download the `.csv` on data.gouv and to compress and
store it in `.rds` format.

### Sudoc

We systematically collect metadata on French theses archived in the
[Sudoc](https://www.sudoc.fr/) database, focusing on theses in
economics. To identify theses in economics, we employ a dual-query
approach:

- In the main query, we search for theses with a term beginning with
  “econo” in the “Note de Thèse” field, which specifies the discipline
  of the thesis.[^6] The search is restricted to the period from 1900 to
  1985, as theses from subsequent years are systematically cataloged in
  [Theses.fr](https://theses.fr/). [Here is the
  query](https://www.sudoc.abes.fr/cbs//DB=2.1/SET=28/TTL=10/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=econo*&ACT1=-&IKT1=63&TRM1=&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=4&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=fr&ADI_JVU=1900-1985&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+)
  allowing to retrieve thesis records.

- One issue specific to French history is that economic research was
  predominantly conducted within law faculties until the 1960s.
  Consequently, in a second query, we focus on theses where the term
  “droit” (law) appears in the field “Note de Thèse” and a word
  beginning with “econo” is present in the title. This search is
  restricted to the period 1900–1968, aiming to identify theses
  classified as law theses prior to 1968 that likely pertain to
  economics. [Here is the
  query](https://www.sudoc.abes.fr/cbs//DB=2.1/SET=31/TTL=1/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=droit&ACT1=*&IKT1=4&TRM1=econo*&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=1016&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=fr&ADI_JVU=1900-1968&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+),
  allowing to retrieve thesis records.

The
[scraping_sudoc_id.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_id.R)
collects the thesis records URLs. Then, the
[scraping_sudoc_api.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_api.R)
allows to query the [Sudoc
API](https://api.gouv.fr/documentation/api-sudoc) to retrieve structured
metadata for each thesis, including information such as title, author,
defence date, abstract, supervisor and other relevant details. These
metadata are stored in an `.xml` file, which we then parse to extract
the relevant information.[^7]

> [!NOTE]
>
> [scraping_sudoc_api.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_api.R)
> utilizes parallel processing to accelerate data collection. It is
> designed with robust error and exception handling, ensuring efficient
> and reliable data retrieval. Moreover, the script is highly adaptable
> and can be easily used for other query types.

### IdRef

We utilize the IdRef identifiers collected from Sudoc and These.fr to
retrieve additional information about entities, such as date of birth,
gender, last known institutions, institutions’ preferred and alternate
names, and years of existence. The scripts
[scraping_idref_person.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_person.R)
and
[scraping_idref_institution.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_institution.R)
use the IdRef identifiers as input to query the [IdRef
API](https://www.idref.fr/) and organize the retrieved information into
structured tables.

## Cleaning

This section outlines the data cleaning process. Starting with the raw
sources, we clean and harmonize the data to enable seamless merging of
the two datasets, Sudoc and theses.fr. Following this, we construct our
five data tables.

### Sudoc

The
[cleaning_sudoc.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_sudoc.R)
script cleans the Sudoc data. It has two main objectives: managing
duplicated identifiers and transforming the raw Sudoc data into a
structured dataset. The process involves evaluating the data quality and
restructuring the raw sources to ensure consistency and facilitate
future merging with the theses.fr dataset.

The script handles duplicate identifiers, which fall into two
categories:

- True duplicates: these occur when the same dissertation appears
  multiple times with identical identifiers and authors but differing
  defense dates. In such cases, the script retains the most recent
  record, as it is more likely to contain accurate metadata.
- False duplicates: these arise when the same identifier is linked to
  different authors, typically due to data entry errors from ABES. To
  resolve this, the script generates unique identifiers by appending a
  counter to the “national number thesis” field.

Most of the column of the final data are created here from the raw data.
Two variables deserves a particular attention:

1.  `year_defence`:
    - For some theses, multiple defense dates are retrieved for a single
      observation (line). In such cases, the earliest date is selected,
      as it is more likely to correspond to the original, unfinished
      thesis.
    - When dates differ significantly, manual checks are performed.
    - Anomalous dates outside the query range (1899–1985) are cleaned to
      maintain consistency.
2.  `type`:
    - The `type` of the thesis is determined from various Sudoc metadata
      fields, reflecting the diversity of thesis types in the French
      system before the 1984 reform.
    - Thesis types are recoded into consistent categories, such as
      “Thèse d’État” and “Thèse de 3e cycle.” Entries that are not
      doctoral theses (e.g., master’s dissertations) are excluded to
      focus solely on relevant records.
    - If the thesis type cannot be determined, the variable is assigned
      the generic value “Thèse.”

> [!WARNING]
>
> The value “Thèse” of the `Type` variable is default value when we
> cannot identify a specific type of thesis.

Note that the value of `Language` are also standardized to align with
ISO conventions, ensuring compatibility with theses.fr data.

The final dataset is divided into four tables that constitute the
relational database: metadata, edge, person, and institution. For
entities without official identifiers, temporary IDs are generated to
enable future identification and disambiguation. Temporary identifiers
are under the format `temp_X_Y`, X representing the source of the
original information (either “sudoc” or “thesesfr”) and Y being a
randomly generated unique number.

### Theses.fr

The
[cleaning_thesesfr.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/thesesfr_cleaning.R)
script focuses on cleaning and structuring metadata for theses related
to economics, extracted from the theses.fr database. The methodology
closely parallels the approach used for Sudoc: assessing data quality,
standardizing raw data, and preparing the dataset for integration with
Sudoc data.

A specific challenge addressed in this script involves filtering out
theses that were incorrectly classified as economics-related in the
query results. After resolving this issue, the script applies the same
steps as those used for Sudoc data, including the categorization and
harmonization of variables, to ensure consistency and facilitate
merging.

As with the Sudoc data, temporary IDs are generated for entities lacking
official identifiers from IdRef. These temporary IDs support future
identification and disambiguation efforts.

### Merging

The
[merging_database.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/merging_database.R)
script processes four types of tables—theses, edges, persons, and
institutions—generated from both the Sudoc and Theses.fr datasets. The
script merges these tables in pairs to produce four intermediate merged
tables. These intermediate data frames are subsequently cleaned and
standardized in the following scripts.

### Metadata

The script
[cleaning_metadata.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_metadata.R)
is designed to clean and harmonize theses metadata. Metadata from Sudoc
and theses.fr is derived from a variety of local institutions and
individuals, which often results in inconsistencies and errors. This
script focuses on addressing two major challenges: **language
detection** and **duplicates identification**.

1.  **Language detection:** To ensure consistency across metadata about
    titles and abstracts, the script employs the
    [cld3](https://docs.ropensci.org/cld3/reference/cld3.html)
    (Ooms 2024) and
    [fastText](https://mlampros.github.io/fastText/articles/language_identification.html)
    (Bojanowski et al. 2016) models for robust language identification.
    Key tasks include:
    - Verifying that titles and abstracts in French and English fields
      contain text in the correct languages. Discrepancies are resolved
      by reassigning text to appropriate fields.
    - Missing French or English titles and abstracts are supplemented
      using auxiliary columns from the scraped data (`title_other` and
      `abstract_other`) when relevant.
    - Titles and abstracts in full uppercase are converted to sentence
      case to enhance readability.
    - Placeholder text, irrelevant symbols, and uninformative entries
      are removed, with such entries replaced by missing values (NA).
2.  **Duplicates:** Duplicated thesis records are a common issue,
    arising from cross-database redundancy (the same thesis may appear
    in both Sudoc and theses.fr) and intra-database redundancy (a thesis
    may be registered multiple times by different institutions within a
    single database). To address this, we developed a duplicates
    detection algorithm. The core of the process involves grouping
    titles by authors and comparing all possible title pairs within each
    group. We use the [Optimal String Alignment
    (OSA)](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Optimal_string_alignment_distance)
    distance as the primary metric for these comparisons. OSA estimates
    the number of operations (insertions, deletions, substitutions, and
    adjacent character transpositions) needed to align two strings. This
    method is implemented using the `stringdist`
    [package](https://CRAN.R-project.org/package=stringdist) (van der
    Loo 2014). We adjust the distance measure by the number of character
    in the title. Each potential duplicate is manually reviewed. In
    alignment with the project’s overall approach, we do not remove
    duplicates but instead flag them in a new column, `duplicates`.
    <a href="#tbl-duplicates" class="quarto-xref">Table 6</a> provides
    an example of distinct theses in the sources that we flagged as
    duplicates.

<div id="tbl-duplicates">

Table 6: Example of theses identified as duplicates

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-59f8b565827a37d1bafe" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-59f8b565827a37d1bafe">{"x":{"filter":"none","vertical":false,"data":[["1962REN0G002","temp_sudoc_thesis_728474","temp_sudoc_thesis_838672"],[1962,1962,1962],["fr","fr","fr"],[null,null,null],["L'Industrie du granit en Bretagne","L'industrie du granit en Bretagne\nAnnexe","L'industrie du granit en Bretagne"],[null,null,null],[null,null,null],[null,null,null],[null,null,null],[null,null,null],["Sciences économiques","Sciences économiques","Sciences économiques"],[null,null,null],["Thèse","Thèse","Thèse"],["France","France","France"],["https://www.sudoc.fr/064184188","https://www.sudoc.fr/072911263","https://www.sudoc.fr/072911255"],[["1962REN0G002","temp_sudoc_thesis_728474","temp_sudoc_thesis_838672"],["1962REN0G002","temp_sudoc_thesis_728474","temp_sudoc_thesis_838672"],["1962REN0G002","temp_sudoc_thesis_728474","temp_sudoc_thesis_838672"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

> [!NOTE]
>
> Our script allows also for handling duplicates manually. If you spot
> an undetected duplicate, please [let us
> know](https://github.com/tdelcey/becoming_economists/issues).

### Institutions

The script
[cleaning_institution.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_institution.R)
is dedicated to standardizing and improving the quality of institution
data.

Institution names extracted from metadata have been stored in a separate
table, `thesis_institution`. This script focuses on cleaning and
standardizing these names to ensure consistency and accuracy. A key goal
is replacing temporary institution identifiers (`id_sudoc_temp` or
`id_thesesfr_temp`) created in
[merging_database.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/merging_database.R)
with the official IdRef identifiers. This process relies on matching
institution names and thesis defense dates, accounting for historical
changes in institutional structures (e.g., the division of the
University of Paris after 1968) and carefully handling ambiguous cases.

The script employs a manually curated table that associates regular
expressions (RegEx) for institution names with their corresponding IdRef
identifiers. The table also includes the institutions’ dates of creation
(`date_of_birth`) and dissolution (`date_of_death`) to set clear
temporal boundaries for identifier replacement. For instance, if the
institution name matches “University of Paris” and:

- The thesis defense occurred before 1968, the identifier is replaced
  with [the identifier of the historic University of
  Paris](https://www.idref.fr/034526110), as it was the only university
  in Paris at the time.
- If the thesis is defended after 1968, the string “Université de Paris”
  is ambigous since it describes several distinct institutions. In this
  case, we kept the temporary identifier because we are not able to
  resolve the ambiguity.

### Individuals

The script
[cleaning_persons.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_persons.R)
is designed to standardize and enhance the quality of person data.

The script first enriches individual records by incorporating
information from the `idref_person_table`, built from
[scraping_idref_person.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_person.R).
When a name entity is linked to an IdRef identifier, supplementary
details about the individual—such as organization affiliations, birth
date, and relevant links (e.g., Wikipedia pages)—are added from the
IdRef database. Additionally, raw names extracted from Sudoc or
theses.fr are replaced with the standardized names provided by IdRef.

A key focus of the script is addressing inconsistencies in person
identifiers. Challenges include:

- Variations in names: The same individual may appear with slight name
  differences (e.g., “Jean A. Dupont” vs. “Jean Dupont”).
- Duplicate identifiers: A single individual may be associated with
  different identifiers across or within datasets (e.g., as an author in
  Sudoc in 1983 and as a jury member in theses.fr in 1999).

While the script strives to identify and group such cases,
disambiguating person identifiers is constrained by the risk of
homonyms. For example, two individuals with identical names may
represent distinct persons. Due to this ambiguity, it is not possible to
merge identifiers confidently.

To address potential ambiguities, the script introduces a new column,
`homonym_of`, which groups potential homonyms. For each person, the
`homonym_of` field lists the identifiers of individuals with identical
or highly similar names. This approach prevents premature merges while
flagging possible relationships for users to investigate further.

<div id="tbl-duplicates_person">

Table 7: Example of persons identified as homonym

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-241d04fbb1e2f9c365d0" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-241d04fbb1e2f9c365d0">{"x":{"filter":"none","vertical":false,"data":[["057545863","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_101172","temp_thesefr_person_101176","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100967"],["Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon"],["Valérie","Valerie","Valerie","Valerie","Valerie","Valérie","Valérie","Valérie","Valérie","Valérie"],["female",null,null,null,null,null,null,null,null,null],["female","female","female","female","female","female","female","female","female","female"],["1970",null,null,null,null,null,null,null,null,null],["France",null,null,null,null,null,null,null,null,null],["Sociologue, chercheuse INSERM en psychologie sociale (en 2009). - Directrice de recherche Inserm, directrice d'études EHESS, Centre d'étude des mouvements sociaux (en 2023)",null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[["https://orcid.org/0000-0002-5578-1241","http://isni.org/isni/0000000117607245","http://data.bnf.fr/ark:/12148/cb13204778r#foaf:Person","http://viaf.org/viaf/44442640","https://fr.wikipedia.org/wiki/Valérie_Mignon","https://www.persee.fr/authority/213220"],null,null,null,null,null,null,null,null,null],[["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n      <th>gender<\/th>\n      <th>gender_expanded<\/th>\n      <th>birth<\/th>\n      <th>country_name<\/th>\n      <th>information<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"entity_firstname","targets":2},{"name":"gender","targets":3},{"name":"gender_expanded","targets":4},{"name":"birth","targets":5},{"name":"country_name","targets":6},{"name":"information","targets":7},{"name":"organization","targets":8},{"name":"last_date_org","targets":9},{"name":"start_date_org","targets":10},{"name":"end_date_org","targets":11},{"name":"other_link","targets":12},{"name":"homonym_of","targets":13}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

Finally, the script enhances the gender column using data from the IdRef
source. For individuals with missing gender values, we leverage French
census data to predict gender. If a first name is associated with a
single gender in more than 95% of cases, we assign that gender to the
individual.

This approach has the advantage of simplicity but presents obvious
limitations for handling some important cases (e.g., unisex names or
cultural variations). The threshold of 95% is also arbitrary. To clarify
the origin of the information, whether from IdRef or census data, we did
not modify the `gender` column, and we created a new column,
`gender_expanded.`

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-fastText2016b" class="csl-entry">

Bojanowski, Piotr, Edouard Grave, Armand Joulin, Tomas Mikolov, Matthijs
Douze, and Herve Jegou. 2016. “FastText.zip: Compressing Text
Classification Models.” *arXiv Preprint arXiv:1612.03651*.

</div>

<div id="ref-R-cld3" class="csl-entry">

Ooms, Jeroen. 2024. *Cld3: Google’s Compact Language Detector 3*.
<https://docs.ropensci.org/cld3/>.

</div>

<div id="ref-stringdist2014" class="csl-entry">

van der Loo, M. P. J. 2014. “The Stringdist Package for Approximate
String Matching.” *The R Journal* 6: 111–22.
<https://CRAN.R-project.org/package=stringdist>.

</div>

</div>

[^1]: While the focus is on France, both the database and its
    accompanying documentation are presented in English. This decision
    reflects its integration into a larger initiative, which seeks to
    establish a comprehensive global repository of Ph.D. dissertations
    in economics.

[^2]: The edges data are provided in two formats: (1) a ready-to-use
    format with cleaned and standardized information; and (2) a more
    extensive format that allows for comparison between the original
    collected data and the results of the cleaning process.

[^3]: See the English description of the licence
    [here](https://www.etalab.gouv.fr/wp-content/uploads/2018/11/open-licence.pdf).

[^4]: This corresponds to the reform of French PhD and the
    implementation of the “new regime”.

[^5]: Exceptions were made for minimal transformations, such as
    replacing fully uppercase titles and abstracts with standardized
    capitalization, or correcting errors, such as changing the language
    of a title or abstract when it was mistakenly assigned.

[^6]: This RegEx captures terms such as “économie” and “Economique”
    because Sudoc’s search function is case-insensitive and disregards
    accents.

[^7]: The structure of the `.xml` used by the ABES is explained
    [here](https://documentation.abes.fr/sudoc/manuels/administration/aidewebservices/index.html#Sudoc%20MarcXML).
