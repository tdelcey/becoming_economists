# Documentation - Becoming an economist: France
Thomas Delcey, Aurelien Goutsmedt
2025-01-09

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

<div class="datatables html-widget html-fill-item" id="htmlwidget-46dd300ba9b4e4d870f0" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-46dd300ba9b4e4d870f0">{"x":{"filter":"none","vertical":false,"data":[["2008PA010015","2002GRE21026","temp_sudoc_thesis_370841","2013BOR40066","1982PA090056","2002PA010055","temp_sudoc_thesis_273452","2007EHES0051","2015BORD0332","2016PA01E020","temp_sudoc_thesis_357535","temp_sudoc_thesis_284780","temp_sudoc_thesis_796231","2019IPPAX006","temp_sudoc_thesis_336805","1998AIX24003","2018LILUS010","1990PA030055","1983PA100162","1994IEPP0038","temp_sudoc_thesis_176832","temp_sudoc_thesis_706069","1981MON10037","2001LIL12020","2022PA01E034","1983PA090075","1993PA080754","1907REN0G017","2020MONTD034","1992PA122002","1986PA020062","1984PA010023","2014STRAJ013","2022COAZ0040","1985PA100283","2011GRENE006","2018PESC0059","temp_sudoc_thesis_875970","1993DIJOE012","1978PA100050","temp_sudoc_thesis_299696","temp_sudoc_thesis_763070","2014CLF10431","1998CLF10202","1954BORUD002","2021EHES0036","2006PA030056","1993PA080818","1997NICE0023","temp_sudoc_thesis_978419"],[2008,2002,1974,2013,1982,2002,1979,2007,2015,2016,1931,1980,1982,2019,1983,1998,2018,1990,1983,1994,1904,1974,1981,2001,2022,1983,1993,1907,2020,1992,1986,1984,2014,2022,1985,2011,2018,1985,1993,1978,1947,1975,2014,1998,1954,2021,2006,1993,1997,1937],["fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","en","en","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","en","fr","fr","fr","fr"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Impact du vieillissement démographique sur le s...","Du travail à temps partiel contraint au temps c...","Autofinancement de l'entreprise en expansion\nPe...","Gestion et place du CROUS dans le logement étud...","La restructuration des dettes extérieures d'emp...","Croissance, investissement, spécialisation et r...","De quelques attitudes theoriques devant la cris...","Les firmes transnationales et l'institution soc...","La mondialisation favorise-t-elle la criminalit...","Les emplois salariés dans les services à la per...","L'Évolution de l'économie rurale de la Manche d...","Theorie de la transition des modes de productio...","Les implications de la sante communautaire en t...","Essais sur les effets des règles d'assurance ch...","Problématique de l'industrialisation et rapport...","Une analyse de la compétitivité pour la logisti...","Pollution de l'air et arrêts cardiaques hors hô...","Le régionalisme et la régionalisation comme sol...","La localisation spatiale des activités","L'interventionnisme économique des collectivité...","Etude d'économie rurale et sociale\nl'émigration...","Le Développement agricole africain et la dynami...","Etude contributive de l'agriculture à la mise e...","L'économie de la disponibilité temporelle au tr...","Les compétences dans les pays à revenu faible e...","La gestion municipale du cadre de vie et la soc...","La place de la Chine dans la nouvelle intégrati...","Les idées économiques de Sully et leurs applica...","Des permis à circuler échangeables pour une mob...","Contribution à l'élaboration d'un observatoire ...","La faisabilité économique du nucléaire dans les...","Politiques monétaristes et dynamiques financièr...","Approches méthodologiques pour l'évaluation bén...","Caractéristiques du réseau de collaboration et ...","La promotion d'une petite industrie nationale a...","Industrie localisée au Brésil : les arrangement...","Économie informelle et les politiques d’emploi ...","Essai d'intégration de la notion d'espace écono...","Modélisation et optimisation des capacités et s...","Mobilité internationale de la force de travail ...","Les Idées économiques dans l'Encyclopédie","L'intérêt du consommateur","Essais sur la sécurité alimentaire en Afrique s...","Promotion des exportations et croissance de l’o...","La bourse des valeurs mobilières de Bordeaux","Mode de garde du jeune enfant, travail des mère...","Mondialisation et transformation des marchés du...","Le mode d'insertion international du Brésil dan...","L'analyse économique de la politique du crédit ...","Le Règlement du prix de vente des fonds de comm..."],["The impact of ageing on French pension system :...","Constrained part-time work at chosen time : bey...",null,"Social housing for students in france : a dilem...",null,"Growth, investment, specialization and North-So...",null,"The transnational corporations and the social-h...","Does globalization foster criminality ? : Study...","Wage employment in the sector of services to in...",null,null,null,"Essays on Labor Market Effets of Unemployment I...",null,"Competitive analysis of logistical client service","Air pollution and out-of-hospital cardiac arres...","Regionalismus and regionalizations as solutions...",null,"Local governments' interventionism and firms' l...",null,null,null,null,"Skills in Low- and Middle-Income Countries",null,"The place of china in the new economic integrat...",null,"Tradable Mobility Permits for a sustainable urb...","Contribution to elaboration of an observatory o...","The economic faisability of nuclear in developp...",null,"Methodological approaches for the benefit-risk ...","Collaboration network characteristics and inven...",null,"Industry located in Brazil : the agreement loca...","Informal economy and employment policies in Alg...",null,"Modeling and optimization of European refining ...",null,null,null,"Essays on Food Security in Sub-Saharan Africa :...","Export promotion and aggregate output growth in...",null,"Childcare arrangements, maternal labor outcomes...","Globalization and transformation of labor marke...","The international mode of insertion of brazil i...","Economic analysis of the credit policy in the o...",null],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Le financement du système de retraite par répar...","Depuis vingt ans, le travail à temps partiel a ...",null,"Promulguée en 2001, la LOLF assigne aux CROUS l...",null,"Le processus de régionalisation s'accompagne d'...",null,"Notre thèse porte sur les firmes transnationale...","Les travaux sur les déterminants de la criminal...","L'objet de cette thèse est l'analyse quantitati...",null,null,null,"Ma thèse étudie comment le design de l’assuranc...",null,"Cette étude a pour objet d'analyser le rôle de ...","L'arrêt cardiaque est un problème majeur de san...",null,null,"Depuis la mise en oeuvre de la décentralisation...",null,null,null,"L'objet de la thèse est d'appréhender d'un poin...","Cette thèse contribue à la littérature sur la m...",null,"L'objectif de ce travail est de mettre au point...",null,"Réduire la place de la voiture dans les villes ...","Dans les pays en voie de developpement, c'est l...","Le present travail a pour objectif d'etudier l'...",null,"L'évaluation des bénéfices et des risques des m...","Cette thèse présente trois essais sur les résea...",null,"Dans cette thèse nous analysons l'évolution et ...","Cette thèse porte principalement sur l’impact d...",null,"La profonde restructuration du raffinage europé...",null,null,null,"La crise alimentaire de 2008 a suscité un regai...","Dans cette thèse, il est étudié la relation ent...",null,"Le paysage de la famille et de la vie professio...","Le thème de la « mondialisation » est devenu, d...","Cette these se veut une reflexion sur l'inserti...","L'indonesie peut etre qualifiee comme une econo...",null],[null,null,null,"Since 2001, LOLF reinforced New Public Manageme...",null,null,null,"Our thesis relates to the transnational corpora...","Studies on the determinants of crime generally ...","This dissertation aims to carry out a quantitat...",null,null,null,"In my dissertation, I explore several features ...",null,null,"Cardiac arrest is an important public issue. It...",null,null,"Since the \"decentralisation laws\" (1982), inves...",null,null,null,null,"This thesis contributes to the literature on sk...",null,"This study is concerned with the place of china...",null,"Reducing car use in cities without taxing motor...","In developping countries, medium-term has made ...",null,null,"The benefit-risk evaluation of new medicines pl...","This dissertation presents three essays on inve...",null,"This thesis concerns the evolution and mutation...","This thesis focuses on impact evaluation of emp...",null,"The substantial restructuring of the european r...",null,null,null,"This doctoral thesis is in line with the renewe...","In this thesis, we have studied the relationshi...",null,"The landscape of family and work-life has chang...","Nowadays, the Globalization has become a key co...","This thesis is a reflection on the insertion of...","Indonesia can be characterized as a bank-center...",null],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Sciences économiques","Sciences économiques","Économie et administration des entreprises","Sciences économiques","Sciences économiques","Économie","Sciences économiques","Économie de l'environnement","Sciences économiques","Sciences économiques","Droit","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Épidémiologie, économie de la santé et prévention","Sciences économiques","Sciences économiques","Sciences économiques","Droit","Économie","Sciences économiques","Economie des ressources humaines","Sciences économiques","Sciences économiques","Sciences économiques","Droit","Sciences Économiques","Sciences économiques","Sciences économiques","Sciences économiques","Droit et économie de la santé","Sciences economiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Science économique","Sciences économiques","Droit","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Analyse et politique économiques","Économie","Science économique","Sciences économiques","Droit"],["non","non",null,"oui",null,"non",null,"non","oui","oui",null,null,null,"oui",null,"non","oui","non",null,"non",null,null,null,"non","oui",null,"non",null,"oui","non","non",null,"non","oui","non","oui","oui",null,"non",null,null,null,"oui","non",null,"non","non","non","non",null],["Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse d'État","Thèse de 3e cycle","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse de 3e cycle","Thèse d'État","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse"],["France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France"],["https://theses.fr/2008PA010015","https://theses.fr/2002GRE21026","https://www.sudoc.fr/009727140.xml","https://theses.fr/2013BOR40066","https://www.sudoc.fr/041192230.xml","https://theses.fr/2002PA010055","https://www.sudoc.fr/041047958.xml","https://theses.fr/2007EHES0051","https://theses.fr/2015BORD0332","https://theses.fr/2016PA01E020","https://www.sudoc.fr/084515244.xml","https://www.sudoc.fr/041041011.xml","https://www.sudoc.fr/041414799.xml","https://theses.fr/2019IPPAX006","https://www.sudoc.fr/04117044X.xml","https://theses.fr/1998AIX24003","https://theses.fr/2018LILUS010","https://theses.fr/1990PA030055","https://www.sudoc.fr/041193342.xml","https://theses.fr/1994IEPP0038","https://www.sudoc.fr/048384941.xml","https://www.sudoc.fr/065088026.xml","https://www.sudoc.fr/041099176.xml","https://theses.fr/2001LIL12020","https://theses.fr/2022PA01E034","https://www.sudoc.fr/041140524.xml","https://theses.fr/1993PA080754","https://www.sudoc.fr/062444875.xml","https://theses.fr/2020MONTD034","https://theses.fr/1992PA122002","https://theses.fr/1986PA020062","https://www.sudoc.fr/041173074.xml","https://theses.fr/2014STRAJ013","https://theses.fr/2022COAZ0040","https://theses.fr/1985PA100283","https://theses.fr/2011GRENE006","https://theses.fr/2018PESC0059","https://www.sudoc.fr/013107151.xml","https://theses.fr/1993DIJOE012","https://www.sudoc.fr/041012771.xml","https://www.sudoc.fr/08438445X.xml","https://www.sudoc.fr/001973290.xml","https://theses.fr/2014CLF10431","https://theses.fr/1998CLF10202","https://www.sudoc.fr/126712603.xml","https://theses.fr/2021EHES0036","https://theses.fr/2006PA030056","https://theses.fr/1993PA080818","https://theses.fr/1997NICE0023","https://www.sudoc.fr/067599893.xml"],[[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],["temp_sudoc_thesis_176832","temp_sudoc_thesis_505332"],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Distribution of theses

<div id="fig-metadata_distribution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-df44d141d691a663b6c9" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-df44d141d691a663b6c9">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,48,26,32,30,35,45,49,35,50,55,61,55,69,68,85,86,92,134,164,216,270,372,322,395,455,451,510,509,507,514,462,454,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,316,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Number of theses: 5","Defense date: 1900 <br> Number of theses: 31","Defense date: 1901 <br> Number of theses: 37","Defense date: 1902 <br> Number of theses: 27","Defense date: 1903 <br> Number of theses: 40","Defense date: 1904 <br> Number of theses: 34","Defense date: 1905 <br> Number of theses: 45","Defense date: 1906 <br> Number of theses: 38","Defense date: 1907 <br> Number of theses: 48","Defense date: 1908 <br> Number of theses: 44","Defense date: 1909 <br> Number of theses: 51","Defense date: 1910 <br> Number of theses: 65","Defense date: 1911 <br> Number of theses: 38","Defense date: 1912 <br> Number of theses: 71","Defense date: 1913 <br> Number of theses: 29","Defense date: 1914 <br> Number of theses: 30","Defense date: 1915 <br> Number of theses: 8","Defense date: 1916 <br> Number of theses: 6","Defense date: 1917 <br> Number of theses: 12","Defense date: 1918 <br> Number of theses: 11","Defense date: 1919 <br> Number of theses: 25","Defense date: 1920 <br> Number of theses: 52","Defense date: 1921 <br> Number of theses: 46","Defense date: 1922 <br> Number of theses: 69","Defense date: 1923 <br> Number of theses: 72","Defense date: 1924 <br> Number of theses: 70","Defense date: 1925 <br> Number of theses: 61","Defense date: 1926 <br> Number of theses: 54","Defense date: 1927 <br> Number of theses: 62","Defense date: 1928 <br> Number of theses: 38","Defense date: 1929 <br> Number of theses: 40","Defense date: 1930 <br> Number of theses: 29","Defense date: 1931 <br> Number of theses: 45","Defense date: 1932 <br> Number of theses: 42","Defense date: 1933 <br> Number of theses: 47","Defense date: 1934 <br> Number of theses: 37","Defense date: 1935 <br> Number of theses: 48","Defense date: 1936 <br> Number of theses: 45","Defense date: 1937 <br> Number of theses: 37","Defense date: 1938 <br> Number of theses: 40","Defense date: 1939 <br> Number of theses: 53","Defense date: 1940 <br> Number of theses: 22","Defense date: 1941 <br> Number of theses: 29","Defense date: 1942 <br> Number of theses: 35","Defense date: 1943 <br> Number of theses: 30","Defense date: 1944 <br> Number of theses: 33","Defense date: 1945 <br> Number of theses: 29","Defense date: 1946 <br> Number of theses: 29","Defense date: 1947 <br> Number of theses: 45","Defense date: 1948 <br> Number of theses: 35","Defense date: 1949 <br> Number of theses: 33","Defense date: 1950 <br> Number of theses: 44","Defense date: 1951 <br> Number of theses: 41","Defense date: 1952 <br> Number of theses: 36","Defense date: 1953 <br> Number of theses: 30","Defense date: 1954 <br> Number of theses: 48","Defense date: 1955 <br> Number of theses: 26","Defense date: 1956 <br> Number of theses: 32","Defense date: 1957 <br> Number of theses: 30","Defense date: 1958 <br> Number of theses: 35","Defense date: 1959 <br> Number of theses: 45","Defense date: 1960 <br> Number of theses: 49","Defense date: 1961 <br> Number of theses: 35","Defense date: 1962 <br> Number of theses: 50","Defense date: 1963 <br> Number of theses: 55","Defense date: 1964 <br> Number of theses: 61","Defense date: 1965 <br> Number of theses: 55","Defense date: 1966 <br> Number of theses: 69","Defense date: 1967 <br> Number of theses: 68","Defense date: 1968 <br> Number of theses: 85","Defense date: 1969 <br> Number of theses: 86","Defense date: 1970 <br> Number of theses: 92","Defense date: 1971 <br> Number of theses: 134","Defense date: 1972 <br> Number of theses: 164","Defense date: 1973 <br> Number of theses: 216","Defense date: 1974 <br> Number of theses: 270","Defense date: 1975 <br> Number of theses: 372","Defense date: 1976 <br> Number of theses: 322","Defense date: 1977 <br> Number of theses: 395","Defense date: 1978 <br> Number of theses: 455","Defense date: 1979 <br> Number of theses: 451","Defense date: 1980 <br> Number of theses: 510","Defense date: 1981 <br> Number of theses: 509","Defense date: 1982 <br> Number of theses: 507","Defense date: 1983 <br> Number of theses: 514","Defense date: 1984 <br> Number of theses: 462","Defense date: 1985 <br> Number of theses: 454","Defense date: 1986 <br> Number of theses: 341","Defense date: 1987 <br> Number of theses: 315","Defense date: 1988 <br> Number of theses: 253","Defense date: 1989 <br> Number of theses: 212","Defense date: 1990 <br> Number of theses: 180","Defense date: 1991 <br> Number of theses: 208","Defense date: 1992 <br> Number of theses: 275","Defense date: 1993 <br> Number of theses: 264","Defense date: 1994 <br> Number of theses: 292","Defense date: 1995 <br> Number of theses: 256","Defense date: 1996 <br> Number of theses: 296","Defense date: 1997 <br> Number of theses: 372","Defense date: 1998 <br> Number of theses: 338","Defense date: 1999 <br> Number of theses: 323","Defense date: 2000 <br> Number of theses: 427","Defense date: 2001 <br> Number of theses: 345","Defense date: 2002 <br> Number of theses: 316","Defense date: 2003 <br> Number of theses: 340","Defense date: 2004 <br> Number of theses: 316","Defense date: 2005 <br> Number of theses: 312","Defense date: 2006 <br> Number of theses: 296","Defense date: 2007 <br> Number of theses: 350","Defense date: 2008 <br> Number of theses: 361","Defense date: 2009 <br> Number of theses: 363","Defense date: 2010 <br> Number of theses: 397","Defense date: 2011 <br> Number of theses: 405","Defense date: 2012 <br> Number of theses: 367","Defense date: 2013 <br> Number of theses: 394","Defense date: 2014 <br> Number of theses: 361","Defense date: 2015 <br> Number of theses: 373","Defense date: 2016 <br> Number of theses: 392","Defense date: 2017 <br> Number of theses: 360","Defense date: 2018 <br> Number of theses: 353","Defense date: 2019 <br> Number of theses: 339","Defense date: 2020 <br> Number of theses: 310","Defense date: 2021 <br> Number of theses: 351","Defense date: 2022 <br> Number of theses: 308","Defense date: 2023 <br> Number of theses: 129","Defense date: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":25.570776255707766,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"6b5c5a94570b":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"6b5c5a94570b","visdat":{"6b5c5a94570b":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 1: Distribution of theses by defense date

</div>

### Distribution of theses by type

<div id="fig-metadata_distribution_type">

<div class="plotly html-widget html-fill-item" id="htmlwidget-14127648c57bcc7b3c19" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-14127648c57bcc7b3c19">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,3,0,1,2,1,3,14,12,11,18,28,31,43,67,64,104,156,281,242,304,390,371,458,485,470,485,436,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,70,29,30,8,6,12,11,25,52,46,68,72,70,61,54,62,38,40,28,45,42,47,37,48,45,37,39,52,22,29,34,30,33,29,29,45,35,33,44,41,36,30,48,26,30,30,32,45,48,33,49,52,47,43,58,50,57,55,49,67,100,112,114,91,80,91,65,80,52,24,37,29,26,234,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,315,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Type: Thèse <br> Number of theses: 5","Defense date: 1900 <br> Type: Thèse <br> Number of theses: 31","Defense date: 1901 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1902 <br> Type: Thèse <br> Number of theses: 27","Defense date: 1903 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1904 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1905 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1906 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1907 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1908 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1909 <br> Type: Thèse <br> Number of theses: 51","Defense date: 1910 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1911 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1912 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1913 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1914 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1915 <br> Type: Thèse <br> Number of theses: 8","Defense date: 1916 <br> Type: Thèse <br> Number of theses: 6","Defense date: 1917 <br> Type: Thèse <br> Number of theses: 12","Defense date: 1918 <br> Type: Thèse <br> Number of theses: 11","Defense date: 1919 <br> Type: Thèse <br> Number of theses: 25","Defense date: 1920 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1921 <br> Type: Thèse <br> Number of theses: 46","Defense date: 1922 <br> Type: Thèse <br> Number of theses: 68","Defense date: 1923 <br> Type: Thèse <br> Number of theses: 72","Defense date: 1924 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1925 <br> Type: Thèse <br> Number of theses: 61","Defense date: 1926 <br> Type: Thèse <br> Number of theses: 54","Defense date: 1927 <br> Type: Thèse <br> Number of theses: 62","Defense date: 1928 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1929 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1930 <br> Type: Thèse <br> Number of theses: 28","Defense date: 1931 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1932 <br> Type: Thèse <br> Number of theses: 42","Defense date: 1933 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1934 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1935 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1936 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1937 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1938 <br> Type: Thèse <br> Number of theses: 39","Defense date: 1939 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1940 <br> Type: Thèse <br> Number of theses: 22","Defense date: 1941 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1942 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1943 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1944 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1945 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1946 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1947 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1948 <br> Type: Thèse <br> Number of theses: 35","Defense date: 1949 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1950 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1951 <br> Type: Thèse <br> Number of theses: 41","Defense date: 1952 <br> Type: Thèse <br> Number of theses: 36","Defense date: 1953 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1954 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1955 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1956 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1957 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1958 <br> Type: Thèse <br> Number of theses: 32","Defense date: 1959 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1960 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1961 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1962 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1963 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1964 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1965 <br> Type: Thèse <br> Number of theses: 43","Defense date: 1966 <br> Type: Thèse <br> Number of theses: 58","Defense date: 1967 <br> Type: Thèse <br> Number of theses: 50","Defense date: 1968 <br> Type: Thèse <br> Number of theses: 57","Defense date: 1969 <br> Type: Thèse <br> Number of theses: 55","Defense date: 1970 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1971 <br> Type: Thèse <br> Number of theses: 67","Defense date: 1972 <br> Type: Thèse <br> Number of theses: 100","Defense date: 1973 <br> Type: Thèse <br> Number of theses: 112","Defense date: 1974 <br> Type: Thèse <br> Number of theses: 114","Defense date: 1975 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1976 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1977 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1978 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1979 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1980 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1981 <br> Type: Thèse <br> Number of theses: 24","Defense date: 1982 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1983 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1984 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1985 <br> Type: Thèse <br> Number of theses: 234","Defense date: 1986 <br> Type: Thèse <br> Number of theses: 341","Defense date: 1987 <br> Type: Thèse <br> Number of theses: 315","Defense date: 1988 <br> Type: Thèse <br> Number of theses: 253","Defense date: 1989 <br> Type: Thèse <br> Number of theses: 212","Defense date: 1990 <br> Type: Thèse <br> Number of theses: 180","Defense date: 1991 <br> Type: Thèse <br> Number of theses: 208","Defense date: 1992 <br> Type: Thèse <br> Number of theses: 275","Defense date: 1993 <br> Type: Thèse <br> Number of theses: 264","Defense date: 1994 <br> Type: Thèse <br> Number of theses: 292","Defense date: 1995 <br> Type: Thèse <br> Number of theses: 256","Defense date: 1996 <br> Type: Thèse <br> Number of theses: 296","Defense date: 1997 <br> Type: Thèse <br> Number of theses: 372","Defense date: 1998 <br> Type: Thèse <br> Number of theses: 338","Defense date: 1999 <br> Type: Thèse <br> Number of theses: 323","Defense date: 2000 <br> Type: Thèse <br> Number of theses: 427","Defense date: 2001 <br> Type: Thèse <br> Number of theses: 345","Defense date: 2002 <br> Type: Thèse <br> Number of theses: 316","Defense date: 2003 <br> Type: Thèse <br> Number of theses: 340","Defense date: 2004 <br> Type: Thèse <br> Number of theses: 315","Defense date: 2005 <br> Type: Thèse <br> Number of theses: 312","Defense date: 2006 <br> Type: Thèse <br> Number of theses: 296","Defense date: 2007 <br> Type: Thèse <br> Number of theses: 350","Defense date: 2008 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2009 <br> Type: Thèse <br> Number of theses: 363","Defense date: 2010 <br> Type: Thèse <br> Number of theses: 397","Defense date: 2011 <br> Type: Thèse <br> Number of theses: 405","Defense date: 2012 <br> Type: Thèse <br> Number of theses: 367","Defense date: 2013 <br> Type: Thèse <br> Number of theses: 394","Defense date: 2014 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2015 <br> Type: Thèse <br> Number of theses: 373","Defense date: 2016 <br> Type: Thèse <br> Number of theses: 392","Defense date: 2017 <br> Type: Thèse <br> Number of theses: 360","Defense date: 2018 <br> Type: Thèse <br> Number of theses: 353","Defense date: 2019 <br> Type: Thèse <br> Number of theses: 339","Defense date: 2020 <br> Type: Thèse <br> Number of theses: 310","Defense date: 2021 <br> Type: Thèse <br> Number of theses: 351","Defense date: 2022 <br> Type: Thèse <br> Number of theses: 308","Defense date: 2023 <br> Type: Thèse <br> Number of theses: 129","Defense date: NA <br> Type: Thèse <br> Number of theses: 18"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse","legendgroup":"Thèse","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[2,10,7,19,26,32,56,57,91,146,258,219,297,380,365,450,482,467,483,434,219,0],"x":[1963,1964,1966,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,4,4,9,5,11,11,7,13,10,23,23,7,10,6,8,3,3,2,2,1,0],"text":["Defense date: 1963 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1966 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1968 <br> Type: Thèse complémentaire <br> Number of theses: 9","Defense date: 1969 <br> Type: Thèse complémentaire <br> Number of theses: 5","Defense date: 1970 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1971 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1973 <br> Type: Thèse complémentaire <br> Number of theses: 13","Defense date: 1974 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1975 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1976 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1977 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1978 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1979 <br> Type: Thèse complémentaire <br> Number of theses: 6","Defense date: 1980 <br> Type: Thèse complémentaire <br> Number of theses: 8","Defense date: 1981 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1982 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1983 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1984 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1985 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: NA <br> Type: Thèse complémentaire <br> Number of theses: 4"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(183,159,0,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse complémentaire","legendgroup":"Thèse complémentaire","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,1,2,2,3,10,13,18,25,45,47,79,94,143,144,208,292,279,351,406,393,428,375,187,0],"x":[1912,1922,1930,1938,1939,1942,1956,1958,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,1,1,1,1,1,2,3,1,2,1,1,8,10,4,8,6,8,7,11,10,12,52,115,75,89,88,86,99,76,74,55,59,32,0],"text":["Defense date: 1912 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1922 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1930 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1938 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1939 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1942 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1956 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1958 <br> Type: Thèse d'État <br> Number of theses: 3","Defense date: 1960 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1961 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1962 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1963 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1965 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1966 <br> Type: Thèse d'État <br> Number of theses: 4","Defense date: 1967 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1968 <br> Type: Thèse d'État <br> Number of theses: 6","Defense date: 1969 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1970 <br> Type: Thèse d'État <br> Number of theses: 7","Defense date: 1971 <br> Type: Thèse d'État <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1973 <br> Type: Thèse d'État <br> Number of theses: 12","Defense date: 1974 <br> Type: Thèse d'État <br> Number of theses: 52","Defense date: 1975 <br> Type: Thèse d'État <br> Number of theses: 115","Defense date: 1976 <br> Type: Thèse d'État <br> Number of theses: 75","Defense date: 1977 <br> Type: Thèse d'État <br> Number of theses: 89","Defense date: 1978 <br> Type: Thèse d'État <br> Number of theses: 88","Defense date: 1979 <br> Type: Thèse d'État <br> Number of theses: 86","Defense date: 1980 <br> Type: Thèse d'État <br> Number of theses: 99","Defense date: 1981 <br> Type: Thèse d'État <br> Number of theses: 76","Defense date: 1982 <br> Type: Thèse d'État <br> Number of theses: 74","Defense date: 1983 <br> Type: Thèse d'État <br> Number of theses: 55","Defense date: 1984 <br> Type: Thèse d'État <br> Number of theses: 59","Defense date: 1985 <br> Type: Thèse d'État <br> Number of theses: 32","Defense date: NA <br> Type: Thèse d'État <br> Number of theses: 1"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,186,56,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse d'État","legendgroup":"Thèse d'État","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,1,0,0,0,0,0,0,0,4,0,2,1,0,1,1,5,9,0,0],"x":[1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,2004,null],"y":[1,2,2,3,10,13,17,25,45,47,79,94,143,144,204,292,277,350,406,392,427,370,178,1,0],"text":["Defense date: 1963 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1965 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1966 <br> Type: Thèse de 3e cycle <br> Number of theses: 3","Defense date: 1967 <br> Type: Thèse de 3e cycle <br> Number of theses: 10","Defense date: 1968 <br> Type: Thèse de 3e cycle <br> Number of theses: 13","Defense date: 1969 <br> Type: Thèse de 3e cycle <br> Number of theses: 17","Defense date: 1970 <br> Type: Thèse de 3e cycle <br> Number of theses: 25","Defense date: 1971 <br> Type: Thèse de 3e cycle <br> Number of theses: 45","Defense date: 1972 <br> Type: Thèse de 3e cycle <br> Number of theses: 47","Defense date: 1973 <br> Type: Thèse de 3e cycle <br> Number of theses: 79","Defense date: 1974 <br> Type: Thèse de 3e cycle <br> Number of theses: 94","Defense date: 1975 <br> Type: Thèse de 3e cycle <br> Number of theses: 143","Defense date: 1976 <br> Type: Thèse de 3e cycle <br> Number of theses: 144","Defense date: 1977 <br> Type: Thèse de 3e cycle <br> Number of theses: 204","Defense date: 1978 <br> Type: Thèse de 3e cycle <br> Number of theses: 292","Defense date: 1979 <br> Type: Thèse de 3e cycle <br> Number of theses: 277","Defense date: 1980 <br> Type: Thèse de 3e cycle <br> Number of theses: 350","Defense date: 1981 <br> Type: Thèse de 3e cycle <br> Number of theses: 406","Defense date: 1982 <br> Type: Thèse de 3e cycle <br> Number of theses: 392","Defense date: 1983 <br> Type: Thèse de 3e cycle <br> Number of theses: 427","Defense date: 1984 <br> Type: Thèse de 3e cycle <br> Number of theses: 370","Defense date: 1985 <br> Type: Thèse de 3e cycle <br> Number of theses: 178","Defense date: 2004 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: NA <br> Type: Thèse de 3e cycle <br> Number of theses: 3"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de 3e cycle","legendgroup":"Thèse de 3e cycle","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0],"x":[1969,1979,1980,1982,1983,1984,1985],"y":[1,2,1,1,1,5,9],"text":["Defense date: 1969 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1979 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 2","Defense date: 1980 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1982 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1983 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1984 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 5","Defense date: 1985 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 9"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(97,156,255,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de docteur-ingénieur","legendgroup":"Thèse de docteur-ingénieur","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":0.90000000000009095,"base":0,"x":[1977],"y":[4],"text":"Defense date: 1977 <br> Type: Thèse sur travaux <br> Number of theses: 4","type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(245,100,227,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse sur travaux","legendgroup":"Thèse sur travaux","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":25.570776255707766,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Type of thesis","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"6b5c5642df47":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"6b5c5642df47","visdat":{"6b5c5642df47":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 2: Distribution of theses by defence date and type of thesis

</div>

### Availability of abstracts

<div id="fig-metadata_accessible">

<div class="plotly html-widget html-fill-item" id="htmlwidget-938f71cc6027d05fedd2" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-938f71cc6027d05fedd2">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,0,3,2,1,0,1,1,1,1,0,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,47,26,32,30,35,45,49,35,49,55,61,54,69,65,83,85,92,133,163,215,269,372,316,392,452,449,509,507,503,510,454,431,55,46,20,21,15,19,20,22,17,5,19,11,13,17,58,58,65,57,37,24,20,34,29,23,13,7,10,5,4,7,3,3,2,3,3,3,0],"text":["Accessible: No <br> Date of defence: 1899 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1900 <br> Number of theses: 31","Accessible: No <br> Date of defence: 1901 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1902 <br> Number of theses: 27","Accessible: No <br> Date of defence: 1903 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1904 <br> Number of theses: 34","Accessible: No <br> Date of defence: 1905 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1906 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1907 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1908 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1909 <br> Number of theses: 51","Accessible: No <br> Date of defence: 1910 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1911 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1912 <br> Number of theses: 71","Accessible: No <br> Date of defence: 1913 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1914 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1915 <br> Number of theses: 8","Accessible: No <br> Date of defence: 1916 <br> Number of theses: 6","Accessible: No <br> Date of defence: 1917 <br> Number of theses: 12","Accessible: No <br> Date of defence: 1918 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1919 <br> Number of theses: 25","Accessible: No <br> Date of defence: 1920 <br> Number of theses: 52","Accessible: No <br> Date of defence: 1921 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1922 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1923 <br> Number of theses: 72","Accessible: No <br> Date of defence: 1924 <br> Number of theses: 70","Accessible: No <br> Date of defence: 1925 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1926 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1927 <br> Number of theses: 62","Accessible: No <br> Date of defence: 1928 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1929 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1930 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1931 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1932 <br> Number of theses: 42","Accessible: No <br> Date of defence: 1933 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1934 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1935 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1936 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1937 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1938 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1939 <br> Number of theses: 53","Accessible: No <br> Date of defence: 1940 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1941 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1942 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1943 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1944 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1945 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1946 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1947 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1948 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1949 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1950 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1951 <br> Number of theses: 41","Accessible: No <br> Date of defence: 1952 <br> Number of theses: 36","Accessible: No <br> Date of defence: 1953 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1954 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1955 <br> Number of theses: 26","Accessible: No <br> Date of defence: 1956 <br> Number of theses: 32","Accessible: No <br> Date of defence: 1957 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1958 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1959 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1960 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1961 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1962 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1963 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1964 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1965 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1966 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1967 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1968 <br> Number of theses: 83","Accessible: No <br> Date of defence: 1969 <br> Number of theses: 85","Accessible: No <br> Date of defence: 1970 <br> Number of theses: 92","Accessible: No <br> Date of defence: 1971 <br> Number of theses: 133","Accessible: No <br> Date of defence: 1972 <br> Number of theses: 163","Accessible: No <br> Date of defence: 1973 <br> Number of theses: 215","Accessible: No <br> Date of defence: 1974 <br> Number of theses: 269","Accessible: No <br> Date of defence: 1975 <br> Number of theses: 372","Accessible: No <br> Date of defence: 1976 <br> Number of theses: 316","Accessible: No <br> Date of defence: 1977 <br> Number of theses: 392","Accessible: No <br> Date of defence: 1978 <br> Number of theses: 452","Accessible: No <br> Date of defence: 1979 <br> Number of theses: 449","Accessible: No <br> Date of defence: 1980 <br> Number of theses: 509","Accessible: No <br> Date of defence: 1981 <br> Number of theses: 507","Accessible: No <br> Date of defence: 1982 <br> Number of theses: 503","Accessible: No <br> Date of defence: 1983 <br> Number of theses: 510","Accessible: No <br> Date of defence: 1984 <br> Number of theses: 454","Accessible: No <br> Date of defence: 1985 <br> Number of theses: 431","Accessible: No <br> Date of defence: 1986 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1987 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1988 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1989 <br> Number of theses: 21","Accessible: No <br> Date of defence: 1990 <br> Number of theses: 15","Accessible: No <br> Date of defence: 1991 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1992 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1993 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1994 <br> Number of theses: 17","Accessible: No <br> Date of defence: 1995 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1996 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1997 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1998 <br> Number of theses: 13","Accessible: No <br> Date of defence: 1999 <br> Number of theses: 17","Accessible: No <br> Date of defence: 2000 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2001 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2002 <br> Number of theses: 65","Accessible: No <br> Date of defence: 2003 <br> Number of theses: 57","Accessible: No <br> Date of defence: 2004 <br> Number of theses: 37","Accessible: No <br> Date of defence: 2005 <br> Number of theses: 24","Accessible: No <br> Date of defence: 2006 <br> Number of theses: 20","Accessible: No <br> Date of defence: 2007 <br> Number of theses: 34","Accessible: No <br> Date of defence: 2008 <br> Number of theses: 29","Accessible: No <br> Date of defence: 2009 <br> Number of theses: 23","Accessible: No <br> Date of defence: 2010 <br> Number of theses: 13","Accessible: No <br> Date of defence: 2011 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2012 <br> Number of theses: 10","Accessible: No <br> Date of defence: 2013 <br> Number of theses: 5","Accessible: No <br> Date of defence: 2014 <br> Number of theses: 4","Accessible: No <br> Date of defence: 2015 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2016 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2017 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2018 <br> Number of theses: 2","Accessible: No <br> Date of defence: 2019 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2020 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2021 <br> Number of theses: 3","Accessible: No <br> Date of defence: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"No","legendgroup":"No","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1954,1962,1965,1967,1968,1969,1971,1972,1973,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023],"y":[1,1,1,3,2,1,1,1,1,1,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,308,129],"text":["Accessible: Yes <br> Date of defence: 1954 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1962 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1965 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1967 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1968 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1969 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1971 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1972 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1973 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1974 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1976 <br> Number of theses: 6","Accessible: Yes <br> Date of defence: 1977 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1978 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1979 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1980 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1981 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1982 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1983 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1984 <br> Number of theses: 8","Accessible: Yes <br> Date of defence: 1985 <br> Number of theses: 23","Accessible: Yes <br> Date of defence: 1986 <br> Number of theses: 286","Accessible: Yes <br> Date of defence: 1987 <br> Number of theses: 269","Accessible: Yes <br> Date of defence: 1988 <br> Number of theses: 233","Accessible: Yes <br> Date of defence: 1989 <br> Number of theses: 191","Accessible: Yes <br> Date of defence: 1990 <br> Number of theses: 165","Accessible: Yes <br> Date of defence: 1991 <br> Number of theses: 189","Accessible: Yes <br> Date of defence: 1992 <br> Number of theses: 255","Accessible: Yes <br> Date of defence: 1993 <br> Number of theses: 242","Accessible: Yes <br> Date of defence: 1994 <br> Number of theses: 275","Accessible: Yes <br> Date of defence: 1995 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 1996 <br> Number of theses: 277","Accessible: Yes <br> Date of defence: 1997 <br> Number of theses: 361","Accessible: Yes <br> Date of defence: 1998 <br> Number of theses: 325","Accessible: Yes <br> Date of defence: 1999 <br> Number of theses: 306","Accessible: Yes <br> Date of defence: 2000 <br> Number of theses: 369","Accessible: Yes <br> Date of defence: 2001 <br> Number of theses: 287","Accessible: Yes <br> Date of defence: 2002 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 2003 <br> Number of theses: 283","Accessible: Yes <br> Date of defence: 2004 <br> Number of theses: 279","Accessible: Yes <br> Date of defence: 2005 <br> Number of theses: 288","Accessible: Yes <br> Date of defence: 2006 <br> Number of theses: 276","Accessible: Yes <br> Date of defence: 2007 <br> Number of theses: 316","Accessible: Yes <br> Date of defence: 2008 <br> Number of theses: 332","Accessible: Yes <br> Date of defence: 2009 <br> Number of theses: 340","Accessible: Yes <br> Date of defence: 2010 <br> Number of theses: 384","Accessible: Yes <br> Date of defence: 2011 <br> Number of theses: 398","Accessible: Yes <br> Date of defence: 2012 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2013 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2014 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2015 <br> Number of theses: 366","Accessible: Yes <br> Date of defence: 2016 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2017 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2018 <br> Number of theses: 351","Accessible: Yes <br> Date of defence: 2019 <br> Number of theses: 336","Accessible: Yes <br> Date of defence: 2020 <br> Number of theses: 307","Accessible: Yes <br> Date of defence: 2021 <br> Number of theses: 348","Accessible: Yes <br> Date of defence: 2022 <br> Number of theses: 308","Accessible: Yes <br> Date of defence: 2023 <br> Number of theses: 129"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Yes","legendgroup":"Yes","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":25.570776255707766,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Accessible","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"6b5c215f1b4a":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"6b5c215f1b4a","visdat":{"6b5c215f1b4a":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 3: Distribution of theses by the availability of abstracts

</div>

</div>

> [!NOTE]
>
> ### The variable `type`
>
> It is important to note that the French education system lacked a
> standardized Ph.D. system between the early 1960s and 1984, the year
> of the Savary reform, which harmonized the Ph.D. system. During this
> period, various types of theses coexisted. For instance, in the
> mid-1970s, it was common for scholars to first complete a “Doctorat de
> 3e cycle” before pursuing a “Doctorat d’État.” As a result, a single
> author may have produced multiple types of theses.
> <a href="#fig-metadata_distribution_type"
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
  thesis_metadata). In the edge table, a thesis_id can have several
  edges. A `thesis_id` has *at least* two edges: the author and the
  institution where the thesis was defended.  
- `entity_id`: the identifier of an entity. If it exists, it is the
  official “idref”, an unique identifiers created by the ABES (see
  <https://www.idref.fr/>). If not, it is a temporary identifier we have
  created following the strategy we used for `thesis_id` (see
  **?@sec-temp-identifiers**).
- `entity_role`: he role of the entity. A person can be an author, a
  supervisor, a referee, a president, or a jury member. In addition to
  the main institution where the Ph.D. was defended, the `entity_role`
  may include additional information we collected, such as other
  institutions, laboratories, and doctoral schools (the institutions
  organizing doctorates in French universities). Note that this mainly
  applies to theses collected in these.fr after 1985. For Sudoc, the
  value “etablissements_soutenance_from_info” of `entity_role` may
  provide additional information about the institution.
- `entity_name`: The name of the entity. Each entity has a
  `entity_name`. Note that the entity identifiers is unique but the
  entity name is not unique.
- `entity_firstname`, the first name of the individual. Coded as missing
  value when the entity is an institution.

> [!NOTE]
>
> ### Entity identifiers
>
> Through the <https://www.idref.fr/> plateform, the ABES assigns unique
> identifiers to institutions and individuals involved in research in
> France. This system provides valuable information about entities, such
> as their dates of existence and the various names used to refer to
> entities. For example, see the entry for the former [University of
> Paris](https://www.idref.fr/034526110) that splitted after 1968. We
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

<div class="datatables html-widget html-fill-item" id="htmlwidget-783947841393f1414079" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-783947841393f1414079">{"x":{"filter":"none","vertical":false,"data":[["2009EHES0126","2005LYO22016","temp_sudoc_thesis_890646","1980PA100017","2007CORT1039","temp_sudoc_thesis_125651","2017PA01E063","1952REN10014","1978NAN20010","2017PA100073","1989GRE21018","temp_sudoc_thesis_678387","1981BOR1D302","1984PA010154","2019IPPAX016","2002NICE0041","2014CERG0710","2010PA111015","temp_sudoc_thesis_417214","temp_sudoc_thesis_483958","2022ORLE1035","1997EHES0115","2021IPPAX039","2010PA010080","2016SACLV001","2019AZUR0030","2023LYO20026","2018BORD0258","2020EHES0177","2010IEPP0046","2023NANU3002","2014PA11T043","1999AMIE0051","2016PA01E037","temp_sudoc_thesis_772902","2021ORLE3170","temp_sudoc_thesis_472260","2010AIX24023","2015PA010010","2016BORD0220","2019PA01E053","temp_sudoc_thesis_437160","2016EHES0100","2018BORD0123","1926BORUD007","2020PA01E062","temp_sudoc_thesis_150332","temp_sudoc_thesis_891816","2018IEPP0019","2010BOR40028"],["069316716","102446237","temp_sudoc_person_697379","026762420","057219982","026403552","027361802","026910462","026403412","123329183","087665891","02674628X","026772345","temp_sudoc_person_353672","18368575X","026403498","059552549","071395040","034526110","091578183","109899431","026374889","257815619","027361802","060504900","058557733","098226754","033314462","167023047","027918459","12291127X","074509942","031260470","165850264","026374889","19215365X","temp_sudoc_person_289718","081384289","027361802","139009310","178110531","02809509X","033197563","123009901","203219031","059336536","026403145","temp_sudoc_person_584041","234069724","059790067"],["supervisor","author","author","supervisor","supervisor","institution_defence","institution_defense","supervisor","institution_defence","member","supervisor","author","member","author","president","institution_defense","member","supervisor","institution_defence_from_info","author","supervisor","institution_defense","member","institution_defense","supervisor","reviewer","reviewer","reviewer","doctoral_schools","institution_defense","president","supervisor","supervisor","doctoral_schools","institution_defence","member","supervisor","member","institution_defense","reviewer","president","institution_defence_from_info","member","member","author","supervisor","institution_defence","author","member","reviewer"],["Caillaud","Deymier","Yousfi","Caire","Castellani","Université de Paris VIII (1969-....)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Guitton","Université de Nancy II (1970-2012)","Pentecôte","Judet","Bourguinat","Cathelineau","Rakotoarivelo","Gossner","Université de Nice (1965-2019)","Dumas","Ben Youssef","Université de Paris (1896-1968)","Bonafous","Galanti","École des hautes études en sciences sociales (Paris ; 1975-....)","Opromolla","Université Paris 1 Panthéon-Sorbonne (1971-....)","O'connor","Deffains","Engelmann","Roubaud","École doctorale de l'École des hautes études en sciences sociales","Institut d'études politiques (Paris ; 1945-....)","Wolff","Ville","Diatkine","École doctorale d'Économie (Paris ; 2004-....)","École des hautes études en sciences sociales (Paris ; 1975-....)","Benoit","Mestre","Péguin-Feissolle","Université Paris 1 Panthéon-Sorbonne (1971-....)","Combes-Motel","Bas","Université de Strasbourg (1538-1970)","Piketty","Maisonnave","Jullien","Langot","Université Panthéon-Assas (Paris ; 1970-2021)","Tourmente","Mattozzi","Beaumais"],["Bernard","Ghislaine","Abdelkérim","Guy","Michel",null,null,"Henri",null,"Jean-Sébastien","Pierre","Henri","Jean","Havoson","Olivier",null,"Christelle","Adel",null,"Maurice","Sébastien",null,"Luca David",null,"Martin","Bruno","Jan","François",null,null,"François-Charles","Isabelle","Sylvie",null,null,"Sylvain",null,"Anne",null,"Pascale","María",null,"Thomas","Hélène","Jean","François",null,"Daniel","Andrea","Olivier"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>entity_id<\/th>\n      <th>entity_role<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"thesis_id","targets":0},{"name":"entity_id","targets":1},{"name":"entity_role","targets":2},{"name":"entity_name","targets":3},{"name":"entity_firstname","targets":4}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Top roles

<div id="fig-person-role">

<div class="plotly html-widget html-fill-item" id="htmlwidget-95f3cac5004029e70956" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-95f3cac5004029e70956">{"x":{"data":[{"orientation":"h","width":[0.90000000000000036,0.90000000000000036,0.89999999999999991,0.90000000000000013,0.90000000000000036],"base":[0,0,0,0,0],"x":[21019,16000,3960,7273,19288],"y":[5,3,1,2,4],"text":["Role: author <br> Number of individuals: 21019","Role: member <br> Number of individuals: 16000","Role: president <br> Number of individuals: 3960","Role: reviewer <br> Number of individuals: 7273","Role: supervisor <br> Number of individuals: 19288"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":69.406392694063939},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-1050.95,22069.950000000001],"tickmode":"array","ticktext":["0","5000","10000","15000","20000"],"tickvals":[0,5000.0000000000009,10000,15000,20000],"categoryorder":"array","categoryarray":["0","5000","10000","15000","20000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of individuals","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,5.5999999999999996],"tickmode":"array","ticktext":["president","reviewer","member","supervisor","author"],"tickvals":[1,2,3,4,5],"categoryorder":"array","categoryarray":["president","reviewer","member","supervisor","author"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"6b5c25fbe39b":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"6b5c25fbe39b","visdat":{"6b5c25fbe39b":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 4: Top role

</div>

### Top institutions

<div id="fig-person-institution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-3cfe17a0b19906041d75" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-3cfe17a0b19906041d75">{"x":{"data":[{"orientation":"h","width":[0.89999999999999858,0.89999999999999858,0.89999999999999947,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000013,0.89999999999999991],"base":[0,0,0,0,0,0,0,0,0,0],"x":[3012,1295,903,800,793,779,711,696,579,562],"y":[10,9,8,7,6,5,4,3,2,1],"text":["Role: Université Paris 1 Panthéon-Sorbonne (1971-....) <br> Number of edges: 3012","Role: Université Paris Nanterre <br> Number of edges: 1295","Role: Université de Paris (1896-1968) <br> Number of edges: 903","Role: Université Paris Dauphine-PSL (1968-....) <br> Number of edges: 800","Role: Université de Montpellier I (1970-2014) <br> Number of edges: 793","Role: École des hautes études en sciences sociales (Paris ; 1975-....) <br> Number of edges: 779","Role: Université Toulouse 1 Capitole (1970-2022) <br> Number of edges: 711","Role: Université de Paris (1896-1968). Faculté de droit et des sciences économiques <br> Number of edges: 696","Role: École doctorale d'Économie (Paris ; 2004-....) <br> Number of edges: 579","Role: Université de Nice (1965-2019) <br> Number of edges: 562"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":461.00456621004582},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-150.59999999999999,3162.5999999999999],"tickmode":"array","ticktext":["0","1000","2000","3000"],"tickvals":[0,999.99999999999989,2000,3000],"categoryorder":"array","categoryarray":["0","1000","2000","3000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of edges","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,10.6],"tickmode":"array","ticktext":["Université de Nice (1965-2019)","École doctorale d'Économie (Paris ; 2004-....)","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université Toulouse 1 Capitole (1970-2022)","École des hautes études en sciences sociales (Paris ; 1975-....)","Université de Montpellier I (1970-2014)","Université Paris Dauphine-PSL (1968-....)","Université de Paris (1896-1968)","Université Paris Nanterre","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"tickvals":[1,2,3,4,5,6.0000000000000009,7,8,9,10],"categoryorder":"array","categoryarray":["Université de Nice (1965-2019)","École doctorale d'Économie (Paris ; 2004-....)","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université Toulouse 1 Capitole (1970-2022)","École des hautes études en sciences sociales (Paris ; 1975-....)","Université de Montpellier I (1970-2014)","Université Paris Dauphine-PSL (1968-....)","Université de Paris (1896-1968)","Université Paris Nanterre","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"6b5c22839be1":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"6b5c22839be1","visdat":{"6b5c22839be1":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 5: Top role

</div>

</div>

Note that the two figures are the raw count of observations in the edge
table and do not handle duplicates. For instance, if you want to count
the exact number of theses published by the Université Paris I
Panthéon-Sorbonne, you need first to handle duplicates in the metadata
tables (by merging those identified as duplicates with the column
`duplicates`)

### Complete Edges Data

The `thesis_edge_complete_data` allows the comparison between original
data as collected on theses.fr and sudoc with the results of our
cleaning process. In addition to the columns of `thesis_edge`, we find 4
additional columns

## Institutions

In the thesis institution table, each line represents a unique
institution. Institutions are the universities, laboratories, doctoral
schools, and other institutions associated with the theses. The table
1435 institutions and 19 variables. It consists of two core variables:

- `entity_id`: the unique identifier of the entity (here the
  institution).
- `entity_name`: the name of the entity.

The other variables are additional information on the institution
scrapped from the idref system:

- `url`: the url of the entity.
- `scraped_id`: the identifier of the entity in the scraped data.
- `pref_name`: the preferred name of the entity.
- `other_labels`: other labels of the entity.
- `country`: the country of the entity.
- `date_of_birth`: the date of birth of the entity.
- `date_of_death`: the date of death of the entity.
- `information`: additional information on the entity.
- `replaced_idref`: the identifier of the entity that replaced the
  entity.
- `predecessor`: the predecessor of the entity.
- `predecessor_idref`: the identifier of the predecessor of the entity.
- `successor`: the successor of the entity.
- `successor_idref`: the identifier of the successor of the entity.
- `subordinated`: the subordinated entity.
- `subordinated_idref`: the identifier of the subordinated entity.
- `unit_of`: the unit of the entity.
- `unit_of_idref`: the identifier of the unit of the entity.
- `other_link`: other links of the entity.
- `info`: additional information on the entity.
- `country_name`: the country name of the entity.

> [!WARNING]
>
> ### Handling duplicates for institutions
>
> One important part of our work here was to remove duplicates in
> entities so that users can easily estimate the involvement of an
> entity in theses. This process was straightforward for the institution
> table since there is only few hundred unique institutions. The main
> institutions, the university, are thus well identified by a unique
> idref.

<a href="#tbl-institution" class="quarto-xref">Table 3</a> shows a
sample of the thesis institution table.

<div id="tbl-institution">

Table 3: Sample of the thesis institution table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-f86b3c52e8c3979885ed" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-f86b3c52e8c3979885ed">{"x":{"filter":"none","vertical":false,"data":[["145585387","026430983","026430940","027412482","033782520"],["Ecole doctorale Sciences Economiques et de Gestion d'Aix-Marseille (Aix-en-Provence ; 2000-....)","Universitat de Barcelona","Universität Basel","Université de Bourgogne. UFR de droit et  science politique","Institut d'économie industrielle (Toulouse)"],[[null],[null],[null],["temp_sudoc_institution_119050","temp_sudoc_institution_121806","temp_sudoc_institution_123131","temp_sudoc_institution_154458","temp_sudoc_institution_158307","temp_sudoc_institution_160689","temp_sudoc_institution_172938","temp_sudoc_institution_182488","temp_sudoc_institution_183884","temp_sudoc_institution_199439","temp_sudoc_institution_201386","temp_sudoc_institution_206116","temp_sudoc_institution_212865","temp_sudoc_institution_215241","temp_sudoc_institution_225839","temp_sudoc_institution_230359","temp_sudoc_institution_233661","temp_sudoc_institution_234845","temp_sudoc_institution_259828","temp_sudoc_institution_268973","temp_sudoc_institution_284644","temp_sudoc_institution_320668","temp_sudoc_institution_334880","temp_sudoc_institution_341066","temp_sudoc_institution_343853","temp_sudoc_institution_354324","temp_sudoc_institution_355816","temp_sudoc_institution_381632","temp_sudoc_institution_382513","temp_sudoc_institution_385787","temp_sudoc_institution_392050","temp_sudoc_institution_395257","temp_sudoc_institution_407946","temp_sudoc_institution_411112","temp_sudoc_institution_435027","temp_sudoc_institution_444228","temp_sudoc_institution_452480","temp_sudoc_institution_459262","temp_sudoc_institution_469498","temp_sudoc_institution_472041","temp_sudoc_institution_476721","temp_sudoc_institution_477004","temp_sudoc_institution_490809","temp_sudoc_institution_495671","temp_sudoc_institution_512438","temp_sudoc_institution_526860","temp_sudoc_institution_531587","temp_sudoc_institution_532457","temp_sudoc_institution_533215","temp_sudoc_institution_533974","temp_sudoc_institution_539993","temp_sudoc_institution_542843","temp_sudoc_institution_544270","temp_sudoc_institution_547039","temp_sudoc_institution_552600","temp_sudoc_institution_554924","temp_sudoc_institution_562280","temp_sudoc_institution_569610","temp_sudoc_institution_572847","temp_sudoc_institution_585312","temp_sudoc_institution_590052","temp_sudoc_institution_590976","temp_sudoc_institution_615287","temp_sudoc_institution_619725","temp_sudoc_institution_635114","temp_sudoc_institution_640000","temp_sudoc_institution_663805","temp_sudoc_institution_668599","temp_sudoc_institution_674326","temp_sudoc_institution_676606","temp_sudoc_institution_688092","temp_sudoc_institution_704234","temp_sudoc_institution_704772","temp_sudoc_institution_705154","temp_sudoc_institution_722515","temp_sudoc_institution_725889","temp_sudoc_institution_728143","temp_sudoc_institution_752969","temp_sudoc_institution_766299","temp_sudoc_institution_779273","temp_sudoc_institution_783282","temp_sudoc_institution_785288","temp_sudoc_institution_787859","temp_sudoc_institution_799164","temp_sudoc_institution_801445","temp_sudoc_institution_805372","temp_sudoc_institution_812181","temp_sudoc_institution_816231","temp_sudoc_institution_830679","temp_sudoc_institution_837580","temp_sudoc_institution_844739","temp_sudoc_institution_847405","temp_sudoc_institution_858970","temp_sudoc_institution_862624","temp_sudoc_institution_867210","temp_sudoc_institution_872002","temp_sudoc_institution_873393","temp_sudoc_institution_883507","temp_sudoc_institution_883924","temp_sudoc_institution_891400","temp_sudoc_institution_891607","temp_sudoc_institution_895074","temp_sudoc_institution_897250","temp_sudoc_institution_918629","temp_sudoc_institution_932751","temp_sudoc_institution_936116","temp_sudoc_institution_945382","temp_sudoc_institution_956009","temp_sudoc_institution_963401","temp_sudoc_institution_967829","temp_sudoc_institution_985032","temp_sudoc_institution_987616","temp_sudoc_institution_988267","temp_sudoc_institution_998876"],[null]],["https://www.idref.fr/145585387.rdf","https://www.idref.fr/026430983.rdf","https://www.idref.fr/026430940.rdf","https://www.idref.fr/027412482.rdf","https://www.idref.fr/033782520.rdf"],[["ED 372"],["c(\"Université de Barcelone\", \"Universidad de Ba..."],["c(\"Université de Bâle\", \"Universitas Basiliensi..."],["c(\"Université de Bourgogne. Faculté de droit et..."],["c(\"IDEI\", \"Université des sciences sociales (To..."]],["2000","1450","1460",null,null],[null,null,null,null,null],[["c(\"Adresse : Château Lafarge, Route des Milles,..."],[],["Université fondée en 1460"],["Adresse : 4 bd Gabriel, 21100 Dijon"],[]],[["17544000X"],["027648753","096197331","128938978"],["028153316"],["091877245","110438833"],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[["http://viaf.org/viaf/220389213"],["http://isni.org/isni/0000000121083261","http://data.bnf.fr/ark:/12148/cb118679781#foaf:Organization","http://viaf.org/viaf/149973203"],["http://isni.org/isni/0000000121903151","http://data.bnf.fr/ark:/12148/cb118679750#foaf:Organization","http://viaf.org/viaf/155492003"],["http://isni.org/isni/0000000121847479","http://data.bnf.fr/ark:/12148/cb118798951#foaf:Organization","http://viaf.org/viaf/265650209"],["https://data.hal.science/structure/199449#foaf:Organization","https://ror.org/023xbne13#foaf:Organization","http://isni.org/isni/0000000091974396","http://data.bnf.fr/ark:/12148/cb124610447#foaf:Organization","http://viaf.org/viaf/134778758","https://fr.wikipedia.org/wiki/Institut_d'économie_industrielle"]],["France","Spain",null,"France","France"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>old_id<\/th>\n      <th>url<\/th>\n      <th>other_labels<\/th>\n      <th>date_of_birth<\/th>\n      <th>date_of_death<\/th>\n      <th>information<\/th>\n      <th>replaced_idref<\/th>\n      <th>predecessor<\/th>\n      <th>predecessor_idref<\/th>\n      <th>successor<\/th>\n      <th>successor_idref<\/th>\n      <th>subordinated<\/th>\n      <th>subordinated_idref<\/th>\n      <th>unit_of<\/th>\n      <th>unit_of_idref<\/th>\n      <th>other_link<\/th>\n      <th>country_name<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"old_id","targets":2},{"name":"url","targets":3},{"name":"other_labels","targets":4},{"name":"date_of_birth","targets":5},{"name":"date_of_death","targets":6},{"name":"information","targets":7},{"name":"replaced_idref","targets":8},{"name":"predecessor","targets":9},{"name":"predecessor_idref","targets":10},{"name":"successor","targets":11},{"name":"successor_idref","targets":12},{"name":"subordinated","targets":13},{"name":"subordinated_idref","targets":14},{"name":"unit_of","targets":15},{"name":"unit_of_idref","targets":16},{"name":"other_link","targets":17},{"name":"country_name","targets":18}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

## Individuals

In the individuals table, each line represents a unique individuals.
Individual are the authors, supervisors and other jury members
associated with the theses. The table 1435 individuals and 19 variables:

- `entity_id`: the unique identifier of the individual.
- `entity_name`: the name of the individual.
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
- `country`: the country of the individual.
- `info`: additional information on the individual.
- `organizations`: a list of organizations in which the individual
  worked.
- `last_date_org`: a list of the last date **WHAT IS IT**.
- `start_date_org`: a list of the the start date **WHAT IS IT**.
- `end_date_org`: a list of the **WHAT IS IT**.
- `other_link`: a list of link to relevant online repository pages of
  the individual.
- `country_name`: the country name of the individual.
- `homonym_of`: a list of the `entity_id` of the individual’s homonyms.

> [!WARNING]
>
> ### Handling duplicates for individuals with `homonym_of`
>
> It was more challenging to disambiguate individual entities in
> comparison to institutions. To illustrate this, it is relatively easy
> to determine that the strings “Université Paris I” and “Université
> Paris I Panthéon-Sorbonne” represent the same entity. However, we
> cannot be certain that “Thomas Delcey,” who authored a Ph.D. in 2021,
> is the same person as “Thomas Delcey,” who supervised a Ph.D. in 2022.
> The variable `homonym_of` helps the users to spot potential
> duplicates. See details about the methodology in
> <a href="#sec-cleaning-persons" class="quarto-xref">Section 3.2.6</a>.

<a href="#tbl-person" class="quarto-xref">Table 4</a> shows a sample of
the thesis metadata table.

<div id="tbl-person">

Table 4: Sample of the thesis person table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-a57be1ad60771ec4ec2e" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-a57be1ad60771ec4ec2e">{"x":{"filter":"none","vertical":false,"data":[["Steven","Sandra","Susana","Atiqa","Ahuitzotl Héctor"],["146229592","075755564","185776353","temp_thesefr_person_100039","233345507"],["Ongena","Sebag","Carpio","El Ouarzazi","Moreno Moreno"],["male","female",null,null,"male"],["male","female","female",null,"male"],[null,null,null,null,"1978"],[null,null,"Venezuela",null,"Mexico"],["Titulaire d'un doctorat en Philosophie de l'éco...","Titulaire d'une thèse de doctorat, mention Scie...","Maître de Conférences, Université d’Angers en 2...",null,"Auteur d'une Thèse de 3e cycle en Sciences écon..."],[[],[],[],null,[]],[[],[],[],null,[]],[[],[],[],null,[]],[[],[],[],null,[]],[["https://orcid.org/0000-0002-8381-0062","http://isni.org/isni/0000000115852490","http://viaf.org/viaf/1074423","https://www.persee.fr/authority/272051"],"http://viaf.org/viaf/216116655","http://viaf.org/viaf/316669003",null,"http://viaf.org/viaf/176154981841467741790"],[[null],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_firstname<\/th>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>gender<\/th>\n      <th>gender_expanded<\/th>\n      <th>birth<\/th>\n      <th>country_name<\/th>\n      <th>info<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_firstname","targets":0},{"name":"entity_id","targets":1},{"name":"entity_name","targets":2},{"name":"gender","targets":3},{"name":"gender_expanded","targets":4},{"name":"birth","targets":5},{"name":"country_name","targets":6},{"name":"info","targets":7},{"name":"organization","targets":8},{"name":"last_date_org","targets":9},{"name":"start_date_org","targets":10},{"name":"end_date_org","targets":11},{"name":"other_link","targets":12},{"name":"homonym_of","targets":13}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Gender

<div id="fig-person_genre">

<div class="plotly html-widget html-fill-item" id="htmlwidget-a9a44fb9b5079a7026ca" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-a9a44fb9b5079a7026ca">{"x":{"data":[{"orientation":"v","width":[0.90000000000000013,0.89999999999999991,0.90000000000000036],"base":[0,0,0],"x":[2,1,3],"y":[70.515007440206148,23.775995354407868,5.7089972053859839],"text":["Gender: male <br> Number of theses: 19429 <br> % : 70.52","Gender: female <br> Number of theses: 6551 <br> % : 23.78","Gender: Unknown <br> Number of theses: 1573 <br> % : 5.71"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":22.648401826484022},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,3.6000000000000001],"tickmode":"array","ticktext":["female","male","Unknown"],"tickvals":[1,2,3],"categoryorder":"array","categoryarray":["female","male","Unknown"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"gender_expanded","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-3.5257503720103074,74.040757812216455],"tickmode":"array","ticktext":["0","20","40","60"],"tickvals":[0,20,40,59.999999999999993],"categoryorder":"array","categoryarray":["0","20","40","60"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"6b5c6c3aef8":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"6b5c6c3aef8","visdat":{"6b5c6c3aef8":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


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
  data files to generate four relational tables.

The `R` code is available in the following [GitHub
repository](https://github.com/tdelcey/becoming_economists/FR/R). The
following diagram illustrates the relationships between each script. If
you encounter any errors or have questions regarding the data or the
codes, please submit an
[issue](https://github.com/tdelcey/becoming_economists/issue).

<div class="grViz html-widget html-fill-item" id="htmlwidget-c0fec33a2d2dfbc5b65c" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-c0fec33a2d2dfbc5b65c">{"x":{"diagram":"\ndigraph project_dag {\n graph [layout = dot, rankdir = TB]\n \n # Define nodes\n scraping_sudoc_id [label = \"scraping_sudoc_id.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_id.R\"]\n scraping_sudoc_api [label = \"scraping_sudoc_api.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_api.R\"]\n cleaning_sudoc [label = \"cleaning_sudoc.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_sudoc.R\"]\n downloading_theses_fr [label = \"downloading_theses_fr.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/downloading_theses_fr.R\"]\n cleaning_thesesfr [label = \"cleaning_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_thesesfr.R\"]\n merging_database [label = \"merging_sudoc_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/merging_sudoc_thesesfr.R\"]\n idref_institutions [label = \"scraping_idref_institution.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_institution.R\"]\n idref_persons [label = \"scraping_idref_person.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_person.R\"]\n cleaning_metadata [label = \"cleaning_metadata.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_metadata.R\"]\n cleaning_institutions [label = \"cleaning_institutions.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_institutions.R\"]\n cleaning_persons [label = \"cleaning_persons.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_persons.R\"]\n cleaning_edges [label = \"cleaning_edges.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_edges.R\"]\n \n # Define edges\n scraping_sudoc_id -> scraping_sudoc_api\n scraping_sudoc_api -> cleaning_sudoc \n downloading_theses_fr -> cleaning_thesesfr\n cleaning_sudoc -> merging_database\n cleaning_thesesfr -> merging_database\n merging_database -> idref_institutions\n merging_database -> idref_persons\n merging_database -> cleaning_metadata\n idref_institutions -> cleaning_institutions\n idref_persons -> cleaning_persons\n cleaning_metadata -> cleaning_edges\n cleaning_institutions -> cleaning_edges\n cleaning_persons -> cleaning_edges\n}\n","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

## Scraping

### theses.fr

Theses records are registered in [theses.fr](https://theses.fr/) since
1985. Theses.fr data are also stored on
[data.gouv.fr](https://www.data.gouv.fr/fr/datasets/theses-soutenues-en-france-depuis-1985/#/resources)
website. They can be downloaded directly at this
[URL](https://www.data.gouv.fr/fr/datasets/r/eb06a4f5-a9f1-4775-8226-33425c933272).
The
[downloading_theses_fr.R](../scripts/scraping_scripts/FR/downloading_theses_fr.R)
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
  query](https://www.sudoc.abes.fr/cbs//DB=2.1/SET=28/TTL=10/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=econo*&ACT1=-&IKT1=63&TRM1=&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=4&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=fr&ADI_JVU=1900-1985&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+),
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
[scraping_sudoc_id.R](https://github.com/tdelcey/becoming_economists/FR/R/scraping_Sudoc%20_id.R)
collects the thesis records URLs. Then, the
[scraping_sudoc_api.R](https://github.com/tdelcey/becoming_economists/FR/R/scraping_Sudoc%20_api.R)
allows to query the [Sudoc
API](https://api.gouv.fr/documentation/api-sudoc) to retrieve structured
metadata for each thesis, including information such as title, author,
defence date, abstract, supervisor and other relevant details. These
metadata are stored in an `.xml` file, which we then parse to extract
the relevant information.[^7]

> [!NOTE]
>
> [scraping_sudoc_api.R](https://github.com/tdelcey/becoming_economists/FR/R/scraping_Sudoc%20_api.R)
> utilizes parallel processing to accelerate the data collection
> process. It is designed with robust error and exception handling,
> ensuring efficient and reliable data retrieval. Moreover, the script
> is highly adaptable and can be easily modified for other query types.

### IdRef

We utilize the IdRef identifiers collected from Sudoc and These.fr to
retrieve additional information about entities, such as date of birth,
nationality, gender, last known institutions, institutions’ preferred
and alternate names, and years of existence. The scripts
[scraping_idref_person.R](https://github.com/tdelcey/becoming_economists/FR/R/scraping_idref_person.R)
and
[scraping_idref_institution.R](https://github.com/tdelcey/becoming_economists/FR/R/scraping_idref_institution.R)
use the IdRef identifiers as input to query the [IdRef
API](https://www.idref.fr/) and organize the retrieved information into
structured tables.

## Cleaning

This section outlines the data cleaning process. Starting with the raw
sources, we clean and harmonize the data to enable seamless merging of
the two datasets, Sudoc and These.fr. Following this, we construct our
four data tables.

### Sudoc

The script
[cleaning_sucoc.R](./scripts/cleaning_scripts/FR/cleaning_sucoc.R)
cleans the Sudoc data. It has two main objectives: managing duplicate
identifiers and transforming the raw Sudoc sources into a structured
dataset. The process involves evaluating the data quality and
restructuring the raw sources to ensure consistency and facilitate
future merging with the These.fr dataset.

The script handles duplicate identifiers, which fall into two
categories:

- True duplicates: these occur when the same dissertation appears
  multiple times with identical identifiers and authors but differing
  defense dates. In such cases, the script retains the most recent
  record, as it is more likely to contain accurate metadata.
- False duplicates: these arise when the same identifier is linked to
  different authors, typically due to data entry errors from ABES. To
  resolve this, the script generates unique identifiers by appending a
  counter to the nnt field.

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
> cannot spot a particular type of thesis.

Note that the value of `Language` are also standardized to align with
ISO conventions, ensuring compatibility with These.fr data.

The final dataset is divided into four tables that constitute the
relational database: metadata, edge, person, and institution. For
entities without official identifiers, temporary IDs are generated to
enable future identification and disambiguation.

### Theses.fr

The
[cleaning_thesesfr.R](https://github.com/tdelcey/becoming_economists/FR/R/thesesfr_cleaning.R)
focuses on cleaning and structuring metadata for theses related to
economics extracted from the Theses.fr database. The approach mirrors
that used for Sudoc: evaluating data quality, transforming raw sources
into a structured dataset, and preparing the dataset for integration
with Sudoc data.

A specific challenge addressed in this script involves removing theses
that were incorrectly categorized as economics-related in the query
results. Once this correction is made, the script follows the same steps
as those applied to Sudoc data, including the categorization and
harmonization of variables, to ensure consistency and facilitate
merging.

As with Sudoc, temporary IDs are generated for entities without official
identifiers to enable future identification and disambiguation.

### Merging

There is no particular difficulty in this script. The
[merging_database.R](https://github.com/tdelcey/becoming_economists/FR/R/merging_database.R)
merge the set of tables created from the Sudoc and Theses.fr source.

### Metadata

The script
[cleaning_metadata.R](https://github.com/tdelcey/becoming_economists/FR/R/cleaning_metadata.R)
is designed to clean and harmonize metadata information. Metadata from
Sudoc and Theses.fr originates from various local institutions and
individuals, often resulting in inconsistencies and errors. This script
addresses two key challenges: language and duplicate detections.

1.  **Language detection:** To ensure consistency across textual
    metadata, the script employs the
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
2.  **Duplicate:** Duplicate thesis records are a common issue, arising
    from cross-database redundancy (the same thesis may appear in both
    Sudoc and Theses.fr) and intra-database redundancy (a thesis may be
    registered multiple times by different institutions within a single
    database). To address this, we developed a duplicate detection
    algorithm. The core of the process involves grouping titles by
    authors and comparing all possible title pairs within each group. We
    use the Optimal String Alignment (OSA) distance as the primary
    metric for these comparisons. OSA estimates the number of operations
    (insertions, deletions, substitutions, and adjacent character
    transpositions) needed to align two strings. This method is
    implemented using the `stringdist`
    [package](https://CRAN.R-project.org/package=stringdist) (van der
    Loo 2014). Each potential duplicate is manually reviewed. In
    alignment with the project’s overall approach, we do not remove
    duplicates but instead flag them in a new column, `duplicates`.
    <a href="#tbl-duplicates" class="quarto-xref">Table 5</a> provides
    an example of distinct theses in the sources that we flagged as
    duplicates.

<div id="tbl-duplicates">

Table 5: Example of theses identified as duplicates

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-6e5255f827d0996664b4" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-6e5255f827d0996664b4">{"x":{"filter":"none","vertical":false,"data":[["1962REN0G002","temp_sudoc_thesis_114312","temp_sudoc_thesis_204701"],[1962,1962,1962],["fr","fr","fr"],[null,null,null],["L'Industrie du granit en Bretagne","L'industrie du granit en Bretagne\nAnnexe","L'industrie du granit en Bretagne"],[null,null,null],[null,null,null],[null,null,null],[null,null,null],[null,null,null],["Sciences économiques","Sciences économiques","Sciences économiques"],[null,null,null],["Thèse","Thèse","Thèse"],["France","France","France"],["https://www.sudoc.fr/064184188.xml","https://www.sudoc.fr/072911263.xml","https://www.sudoc.fr/072911255.xml"],[["1962REN0G002","temp_sudoc_thesis_114312","temp_sudoc_thesis_204701"],["1962REN0G002","temp_sudoc_thesis_114312","temp_sudoc_thesis_204701"],["1962REN0G002","temp_sudoc_thesis_114312","temp_sudoc_thesis_204701"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

> [!NOTE]
>
> Our script can also handle duplicate manually. If you spot an
> undetected duplicate, please [let us
> know](https://github.com/tdelcey/becoming_economist).

### Institutions

The script
[cleaning_institution.R](https://github.com/tdelcey/becoming_economists/FR/R/cleaning_institution.R)
is dedicated to standardizing and improving the quality of institution
data.

Institution names extracted from metadata have been stored in a separate
table. This script focuses on cleaning and standardizing these names to
ensure consistency and accuracy. A key goal is replacing temporary
institution identifiers (`id_temp`) we have created in
[merging_database.R](https://github.com/tdelcey/becoming_economists/FR/R/merging_database.R)
with the official IdRef identifiers This process relies on matching
institution names and thesis defense dates, accounting for historical
changes in institutional structures (e.g., the division of the
University of Paris after 1968) and carefully handling ambiguous cases.

The script employs a manually curated table that associates regular
expressions (RegEx) for institution names with their corresponding IdRef
identifiers. The table also includes the institutions’ dates of creation
(`date_of_birth`) and dissolution (`date_of_death`) to set clear
temporal boundaries for identifier replacement. For instance, if the
institution name matches “University of Paris” and:

- The thesis defense occurred before 1970, the identifier is replaced
  with that of the historic University of Paris, as it was the only
  university in Paris at the time.
- If the thesis is defended after 1968, the string “Université de Paris”
  is ambigous since it describes several distinct institutions. In this
  case, we kept the temporary identifier because we are not able to
  resolve the ambiguity.

### Individuals

The script
[cleaning_persons.R](https://github.com/tdelcey/becoming_economists/FR/R/cleaning_persons.R)
is designed to standardize and enhance the quality of person data.

The script first enriches individual records by incorporating
information from the `idref_person_table`. When a name entity is linked
to an IdRef identifier, supplementary details about the individual—such
as organization affiliations, birth date, and relevant links (e.g.,
Wikipedia pages)—are added from the IdRef database. Additionally, raw
names extracted from Sudoc or Theses.fr are replaced with the
standardized names provided by IdRef.

A key focus of the script is addressing inconsistencies in person
identifiers. Challenges include:

- Variations in names: The same individual may appear with slight name
  differences (e.g., “Jean A. Dupont” vs. “Jean Dupont”).
- Duplicate identifiers: A single individual may be associated with
  different identifiers across or within datasets (e.g., as an author in
  Sudoc in 1983 and as a jury member in Theses.fr in 1999).

While the script strives to identify and group such cases,
disambiguating person identifiers is constrained by the risk of
homonyms. For example, two individuals with identical names may
represent distinct persons (e.g., two authors of different theses) or
the same person (e.g., one individual completing two theses). Due to
this ambiguity, it is not always possible to merge identifiers
confidently.

To address potential ambiguities, the script introduces a new column,
`homonym_of`, which groups potential homonyms. For each person, the
homonym_of field lists the identifiers of individuals with identical or
highly similar names. This approach prevents premature merges while
flagging possible relationships for users to investigate further.

<div id="tbl-duplicates_person">

Table 6: Example of persons identified as homonym

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-af2dedb4eca4ddb2254b" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-af2dedb4eca4ddb2254b">{"x":{"filter":"none","vertical":false,"data":[["Valerie","Valerie","Valerie","Valerie","Valérie","Valérie","Valérie","Valérie","Valérie"],["temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_101172","temp_thesefr_person_101176","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100967"],["Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon"],[null,null,null,null,null,null,null,null,null],["female","female","female","female","female","female","female","female","female"],[null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null],[["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172"],["057545863","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_100967","temp_thesefr_person_101172","temp_thesefr_person_101176"],["057545863","temp_thesefr_person_100625","temp_thesefr_person_100629","temp_thesefr_person_100677","temp_thesefr_person_100680","temp_thesefr_person_100882","temp_thesefr_person_100887","temp_thesefr_person_101172","temp_thesefr_person_101176"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_firstname<\/th>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>gender<\/th>\n      <th>gender_expanded<\/th>\n      <th>birth<\/th>\n      <th>country_name<\/th>\n      <th>info<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_firstname","targets":0},{"name":"entity_id","targets":1},{"name":"entity_name","targets":2},{"name":"gender","targets":3},{"name":"gender_expanded","targets":4},{"name":"birth","targets":5},{"name":"country_name","targets":6},{"name":"info","targets":7},{"name":"organization","targets":8},{"name":"last_date_org","targets":9},{"name":"start_date_org","targets":10},{"name":"end_date_org","targets":11},{"name":"other_link","targets":12},{"name":"homonym_of","targets":13}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

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
not modify the `gender` column, we create a new column,
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

[^6]: This RegEx captures terms such as “économie” and “économique”
    because Sudoc’s search function is case-insensitive and disregards
    accents.

[^7]: The structure of the `.xml` used by the ABES is explained
    [here](https://documentation.abes.fr/sudoc/manuels/administration/aidewebservices/index.html#Sudoc%20MarcXML).
