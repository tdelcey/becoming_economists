# Documentation - Becoming an economist: France
Thomas Delcey, Aurelien Goutsmedt
2026-11-24

<link href="documentation_french_database_files/libs/htmltools-fill-0.5.9/fill.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/htmlwidgets-1.6.4/htmlwidgets.js"></script>
<link href="documentation_french_database_files/libs/datatables-css-0.0.0/datatables-crosstalk.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/datatables-binding-0.34.0/datatables.js"></script>
<script src="documentation_french_database_files/libs/jquery-3.6.0/jquery-3.6.0.min.js"></script>
<link href="documentation_french_database_files/libs/dt-core-1.13.6/css/jquery.dataTables.min.css" rel="stylesheet" />
<link href="documentation_french_database_files/libs/dt-core-1.13.6/css/jquery.dataTables.extra.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/dt-core-1.13.6/js/jquery.dataTables.min.js"></script>
<link href="documentation_french_database_files/libs/crosstalk-1.2.2/css/crosstalk.min.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/crosstalk-1.2.2/js/crosstalk.min.js"></script>
<script src="documentation_french_database_files/libs/viz-1.8.2/viz.js"></script>
<link href="documentation_french_database_files/libs/DiagrammeR-styles-0.2/styles.css" rel="stylesheet" />
<script src="documentation_french_database_files/libs/grViz-binding-1.0.12/grViz.js"></script>

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
    - [Individuals](#sec-cleaning-individuals)

<a href="https://doi.org/10.5281/zenodo.14541426"
data-fig-align="center"><img
src="https://zenodo.org/badge/DOI/10.5281/zenodo.14541426.svg" /></a>

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
repository](https://doi.org/10.5281/zenodo.14541426). While the database
focuses on Ph.D. dissertations in economics and queries sources based on
the field of the thesis, the scripts have been designed with
flexibility. They can be adapted for other queries involving notably
different disciplines.

If you use our data or scripts, please cite the following reference:
“Delcey Thomas, and Aurélien Goutsmedt. (2024). Becoming an Economist: A
Database of French Economics PhDs. Zenodo.
https://doi.org/10.5281/zenodo.14541426”

``` bibtex
@article{
  title={Becoming an Economist: A Database of French Economics PhDs},
  author={Delcey, Thomas and Goutsmedt, Aurélien},
  journal={Zenodo},
  year={2024},
  doi={https://doi.org/10.5281/zenodo.14541426}
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

The `thesis_metadata` table contains 20 variables:

- `thesis_id`: the unique identifier of the thesis. If it exists, it is
  the official “national number of the thesis” created by the ABES and
  the theses.fr website. If not, it is a temporary identifier we have
  created.
- `year_defence`: the year of the thesis defense. Our database covers
  the period 1899-2023.
- `author`: the first name and last name of the author of the thesis.
- `author_id`: the identifier of the author. If it exists, it is the
  official “idref” created by the ABES. If not, it is a temporary
  identifier we have created.
- `title_fr`: the title of the thesis in French.
- `title_en`: the title of the thesis in English.
- `title_other`: the title of the thesis in another language.
- `abstract_fr`: the abstract of the thesis in French.
- `abstract_en`: the abstract of the thesis in English.
- `abstract_other`: the abstract of the thesis in another language.
- `language` and `language_2` are the languages of the thesis. The
  variable is harmonized to make the information on language found in
  Sudoc and These.fr compatible.
- `institution_thesis_name`: the name of the institution where the
  thesis was defended. The name is standardized using IdRef preferred
  name.
- `institution_thesis_id`: the identifier of the institution where the
  thesis was defended. If it exists, it is the official “idref” created
  by the ABES. If not, it is a temporary identifier we have created.
- `country`: the country where the thesis was defended, i.e. France.
  <!-- Cela va servir quand on va merger avec les autres bases de données, donc faut le garder pour la cohérence -->
- `field`: the field of the thesis (such as “Sciences économiques”). The
  field remains unaltered by our work and can take on a wide range of
  values, as indicated by the number of distinct entries (696).
- `type`: the type of the thesis. Type can take 6 values: Thèse, Thèse
  d’État, Thèse complémentaire, Thèse de 3e cycle, Thèse de
  docteur-ingénieur, Thèse sur travaux. All categories are derived from
  categories found in Sudoc.
- `accessible`: a binary variable indicating whether the fulltext is
  accessible or not (data coming only from theses.fr).
- `url`: the url of the thesis on [theses.fr](https://theses.fr/) or
  [Sudoc](https://www.sudoc.fr/) websites
- `duplicates`: a list of `thesis_id` that indicate duplicated thesis.
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
> information (either “sudoc” or “thesesfr”), Y the type of record
> (“thesis”, “individual” or “institution”), followed by a hash of the
> record (for a thesis, its Sudoc url; for an entity, the thesis
> identifier, its role, name and first name). The same record thus keeps
> the same identifier from one version of the database to the next
> (before November 2026, these identifiers were random numbers
> regenerated at each update). We refer to these identifiers as
> temporary because they may be replaced in future updates by ABES
> identifiers, either as ABES updates its sources or as we improve our
> cleaning process.

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

<div class="datatables html-widget html-fill-item" id="htmlwidget-c78be26286de41e6e534" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-c78be26286de41e6e534">{"x":{"filter":"none","vertical":false,"data":[["2000PA100024","temp_sudoc_thesis_147374a762cfc3b2","2019PA01E009","2021UPSLD029","1983BOR1D335","1998EHES0123","2022UPSLM059","1978PA090068","1997PA131036","2016SACLS117","temp_sudoc_thesis_dae46211aeb078f2","2022UPSLD063","1985CLF1D020","2020EHES0190","temp_sudoc_thesis_1b1253928c9343d5","temp_sudoc_thesis_7d5bc9d6be0f6c64","2010IEPP0024","1992PA080619","temp_sudoc_thesis_428b90348c51a01a","temp_sudoc_thesis_431cd0820fb44d69","2016NANT3025","1984PA010097","temp_sudoc_thesis_640f1e009cb0f98c","temp_sudoc_thesis_621f8f0070ce5926","2010PA010022","temp_sudoc_thesis_99bb0add30b74343","temp_sudoc_thesis_0f8dbf209740bbf5","temp_sudoc_thesis_1efbad9dd1c3a12e","1997PA010077","2014PA010095","1989AIX32033","1991AIX24011","1999TOU10003","temp_sudoc_thesis_a2b82b23cf3bdf85","temp_sudoc_thesis_116aea9164c9aaaf","1998PA010007","1995IEPP0012","2003IEPP0033","2003DIJOMU11","2005DIJOE001","1995TOU10029","1954PA020233","2003STR1EC08","2006ENST0025","2005AIX32001","1986STR10009","1991PA100100","2006STETT079","1984MON10062","2006PA010031"],[2000,1945,2019,2021,1983,1998,2022,1978,1997,2016,1922,2022,1985,2020,1912,1978,2010,1992,1975,1929,2016,1984,1973,1983,2010,1976,1985,1967,1997,2014,1989,1991,1999,1975,1983,1998,1995,2003,2003,2005,1995,1954,2003,2006,2005,1986,1991,2006,1984,2006],["Christine, Lyon","Pierre, Garnier","Ariane, Charpin","Amine, Raboun","Olivier, Scherpereel","Abdenour, Sahmoun","Guillaume, Dupéret","Luc, Castellvi","Laurence, Balla","Karine, Tade","Henri, Regnault","Cécile, Gayet","Jean-Pierre, Revéret","Oscar David, Barrera Rodriguez","Eugène, Carré","Jean-Marie, Faraggi","Pierre, Boulanger","Florent, Gabriel","David, Jessula","Claire, Raymond-Duchosal","Lesya, Nadzon","Mokhtar, Larbi","Joaquim Marinheiro, Alberto","José, Vernia","Dramane, Coulibaly","Kahtan, Syoufi","Olivier, Dupont","Alain, Guize","Saïd, Souam","Cléo, Chassonnery-Zaïgouche","Pierre-Yves, Denniel","Dieudonné, Mboukou Mboungou","Olivier, Thomas","Philippe, Auverny-Bennetot","Pierre, Chatain","Françoise, Rivière","Christos, Bagavos","Chang, Huh","Christine, Binquet","Alexandrina, Platonova","Seglaro Abel, Somé","Louis, Malassis","François, Cochard","Chiraz, Karamtiz","Luc, Tardieu","Mohamed Farid Ahmed Mourad, Ibrahim","Christophe, Darmangeat","Sylvie, Chalaye","Amadou, Dembele","Catherine, Billard"],["075173522","083941215","241571189","261909991","236135899","231305214","268134995","195626702","034584277","193263920","092858287","167339052","030708702","254185347","192095919","temp_sudoc_individual_dccd5b3c18362c4b","096971940","055825656","083765298","06705353X","203620186","078019621","temp_sudoc_individual_2abf7368050aa885","temp_sudoc_individual_e1701d89c30c0ad2","112691382","temp_sudoc_individual_337241f21d3cd3a4","034874526","temp_sudoc_individual_a82ca95f3b6aa5fc","057785848","14698918X","temp_thesefr_individual_3aacd1697a9a43f0","191875252","069030669","03107667X","266664962","114215073","23132765X","090952162","075868164","085045918","177817402","027003590","078384303","115676368","086304887","203634691","139415327","114626758","254881246","113710364"],["Les règles de contenu local de la production, s...","La comptabilité\nalgèbre du droit et méthode d'o...","Essais sur la théorie de la décision et l'effic...","Liquidité des Marchés Actions : Coûts de Transa...","Mutations de l'économie de plantation dans le s...","Utilisation d'une nouvelle approche de la mesur...","Surveiller… et punir ? Trois paradigmes de scie...","L'efficience du marché des changes dans le cadr...","Le leadership industriel : pouvoir, compétitivi...","Impact des projets de coopération décentralisée...","La condition juridique du bâtard au Moyen Age","Assurance et accès aux soins des personnes à ba...","La gestion des pêcheries de poisson de fond de ...","Manipulation de l’information et des données : ...","Etude démographique du département de la Vienne...","Fonction de distribution dans le marché des com...","D’une PAC à une autre : refonder les institutio...","La determination solipsiste du prix et le retou...","Les Banques centrales de la Communauté Economiq...","Les Etrangers en Suisse\n(étude géographique, dé...","Consommation d'énergie et politique de préventi...","L'emigration rurale et le developpement economi...","Les Effets démo-économiques de l'émigration\nana...","Essai sur la théorie de la dominance économique...","Essais sur les transferts internationaux : une ...","Les ressources publiques et developpement en syrie","Diagnostic du systeme educatif et perspectives ...","Etude des enchères pétrolières","Instruments et mécanismes des politiques de la ...","Expliquer, quantifier, prouver : une histoire d...","Le concept d'organisation : du système aux modè...","Système des transports et équilibre du développ...","La conjonction de contrats et conventions comme...","L'intégration économique régionale en Europe\nla...","La Compagnie Française des Pétroles et la socié...","Effet des dépenses publiques d'infrastructures ...","La participation des femmes à l'activité profes...",null,"Evaluation des stratégies de dépistage et de pr...","Projets d'investissement dans l'industrie pétro...","Entrepreneurs et développement économique franç...","Essai sur les structures et les résultats d'exp...",null,"Indices de prix pour les services de la télépho...","Analyse économique du savoir entrepreneurial","La démographie et les problèmes de l'emploi en ...","Essai sur la théorie de l'échange inégal","Méthodologie pour l'observation des dynamiques ...","L'évolution des politiques alimentaires au Séné...","Dépenses publiques, localisation des capitaux e..."],["Local content rules of production, symptoms of ...",null,"Essays on decision theory and economic efficiency","Stock Market Liquidity : Transaction Costs, Cro...",null,"The use of a new measure of productive efficien...","Discipline… and punish ? Three economic and soc...",null,"Industrial leadership : power, competitiveness,...","The impact of decentralized cooperation on the ...",null,"Insurance and access to health care for low-inc...",null,"Information and data manipulation in political ...",null,null,"From a broad to a targeted CAP : designing sust...","The solipstic determination of price and the re...",null,null,"Energy consumption and pollution prevention pol...",null,null,null,"Essays on international remittances : a macroec...",null,null,null,"Instruments and mechanisms of competition polic...","No English title available","The concept of organization : from system to mo...","Transportation system and balance of urban and ...","The conjunction of contrats and conventions as ...",null,null,"Effects of public expenditures in infrastructur...","Women's participation in the labour force : eco...","Le rôle de l'Etat et ses limites dans le dévelo...","Assessment of the strategies for preventing, di...","Oil and gas investment projects in the frame of...","French entrepreneurs and economic development i...",null,"Régulation de la pollution diffuse : études exp...","A price index for the french mobile telephony m...","An economic analysis of entrepreneurial knowledge","Demography and the problems of employment in Eg...","Essay on the theory of unequal trade","Methodology for the observation of localised in...",null,"Public spendings, location of capital and tax c..."],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],[null,null,"Cette thèse de doctorat s’intéresse à deux thèm...","Cette thèse propose trois contributions origina...",null,"En france, le cancer colo-rectal est la deuxiem...","La thèse étudie le Libor, taux central du march...",null,"La vie des grands secteurs industriels est regu...","Des premiers jumelages à la coopération décentr...",null,"En France, l'existence d'un ticket modérateur s...","Dans un cadre théorique construit à partir de l...","L'accès à l'information est essentiel pour plus...",null,null,"Le modèle agricole européen suit, depuis le Tra...","L'incapacite de la theorie neo-classique d'expl...",null,null,"La thèse porte sur la consommation d'énergie et...",null,null,null,"Cette thèse apporte quatre essais sur la littér...",null,null,null,"Notre thèse est composée de trois parties. La p...","A la suite des travaux de Becker (1955), de nom...","On se propose d'approndir le concept d'organisa...","L'economie congolaise souffre de nombreuses mal...","Cette thèse a pour objet de montrer dans quelle...",null,null,"La thèse a pour objectif d'étudier l'effet des ...","La participation des femmes mariées à l'activit...","Après la crise de 1997, le rôle de l'Etat dans ...","Un dépistage sérologique des femmes non immunis...","Dans cette thèse sont évaluées les perspectives...","Par une étude des théories de l'entrepreneur et...",null,"Durant les vingt dernières années, de nouveaux ...","Le marché français de la téléphonie mobile se c...","Cette thèse propose d'explorer les liens qui ex...","L'accroissement de la population égyptienne, s'...","Vingt ans après la parution de \"l'échange inéga...","Cette thèse propose une méthodologie pour la mi...",null,"L'ambition de la thèse est d'envisager les effe..."],[null,null,"This doctoral thesis focuses on two distinct th...","This paper-based thesis is composed of three au...",null,"After pulmonary localisation, colo-rectal cance...","The thesis studies Libor, the central rate of t...",null,"Industrial organizations are often characterize...","From the first twinning to decentralized cooper...",null,"In France, a copayment on essential health care...",null,"Access to information is essential for several ...",null,null,"This research work consists of two parts, each ...","The unfitness of neo-classical theory to explai...",null,null,"The thesis focuses on energy consumption and po...",null,null,null,null,null,null,null,"Our thesis consists in three parts. The first p...","No English summary available.","We propose to examine thorougly the concept of ...","Congo's economy suffers various weakness, some ...","This thesis intends to show to which extent the...",null,null,"The aim of the thesis is to study the effect of...","Women's participation in the labour force doesn...",null,null,"This PhD thesis evaluates the perspectives of t...","Through a study of the theories of the entrepre...",null,"In the last two decades, new policy instruments...","In this research we develop an understanding of...","This study explores the relationship between kn...","Egyptian population growth, accelerated dramati...","Twenty years after the release of \"the unequal ...","This thesis proposes a methodology for the set ...",null,null],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["fr","fr","en","en","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr"],[null,null,null,null,null,null,null,null,null,null,null,"en",null,null,null,null,null,null,null,null,null,null,null,null,"fr",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Université Paris Nanterre","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université Paris sciences et lettres (2020-....)","Université Bordeaux-I (1971-2013)","École des hautes études en sciences sociales (Paris ; 1975-....)","Université Paris sciences et lettres (2020-....)","Université Paris Dauphine-PSL (1968-....)","Université Sorbonne Paris Nord (Bobigny, Villetaneuse, Seine-Saint-Denis ; 1970-....)","Université Paris-Saclay (2015-2019)","Université de Caen. Faculté de droit et des sciences politiques","Université Paris sciences et lettres (2020-....)","Université de Clermont I (Clermont-Ferrand ; 1976-2016)","École des hautes études en sciences sociales (Paris ; 1975-....)","Université de Poitiers. Faculté de droit et des sciences économiques (1896-1970)","Université Panthéon-Assas (Paris ; 1970-2021)","Institut d'études politiques (Paris ; 1945-....)","Université de Paris VIII (1969-....)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université de Genève (Suisse). Faculté des sciences économiques et sociales (1914-2014)","Université de Nantes (1962-2021)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université de Bourgogne (1970-....)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université Lumière (Lyon ; 1969-....)","Université de Bourgogne (1970-....)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Université Paul Cézanne (1973-2011)","Université Aix-Marseille II (1969-2011)","Université Toulouse 1 Capitole (1970-2022)","Université des sciences sociales (Grenoble ; 1970-1990)","Université des sciences sociales (Grenoble ; 1970-1990)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Institut d'études politiques (Paris ; 1945-....)","Institut d'études politiques (Paris ; 1945-....)","Université de Bourgogne (1970-....)","Université de Bourgogne (1970-....)","Université Toulouse 1 Capitole (1970-2022)","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université Louis Pasteur (Strasbourg) (1971-2008)","Télécom Paris (Palaiseau, Essonne ; 1878-....)","Université Paul Cézanne (1973-2011)","Université Louis Pasteur (Strasbourg) (1971-2008)","Université Paris Nanterre","Université Jean Monnet (Saint-Étienne ; 1969-....)","Université de Montpellier I (1970-2014)","Université Paris 1 Panthéon-Sorbonne (1971-....)"],["026403587","034925732","027361802","241597595","027548341","026374889","241597595","027787109","02640463X","188120777","030931509","241597595","028032829","026374889","272667803","026403145","027918459","026403552","027361802","028143469","026403447","027361802","027361802","02819005X","027361802","027361802","02640334X","02819005X","027361802","027361802","026403153","026402882","026404354","103961852","103961852","027361802","027918459","027918459","02819005X","02819005X","026404354","034925732","026404540","026375273","026403153","026404540","026403587","028209966","028032837","027361802"],["France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France"],["Sciences économiques","Droit","Sciences économiques","Sciences Economiques","Économie du développement","Sciences économiques","Economie","Sciences économiques","Sciences économiques","Sciences économiques","Sciences politiques et économiques","Sciences Economiques","Sciences Economiques","Analyse et politique économiques","Sciences politiques et économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques et sociales","Sciences économiques","Sciences économiques","Économie","Économie mathématique et économétrie","Sciences économiques","Sciences économiques","Sciences économiques","Mathématiques appliquées à l'économie","Sciences économiques","Sciences économiques","Sciences économiques","Economie des transports","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Santé publique. Épidémiologie. Économie de la santé et prévention","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Economie des systèmes d'information","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques. Économie rurale et agroalimentaire","Sciences économiques"],["Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse d'État","Thèse","Thèse","Thèse de 3e cycle","Thèse de 3e cycle","Thèse de 3e cycle","Thèse","Thèse de 3e cycle","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse d'État","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse"],["non",null,"oui","oui",null,"non","oui",null,"non","oui",null,"oui","non","non",null,null,"non","non",null,null,"oui",null,null,null,"non",null,null,null,"non","oui","non","non","non",null,null,"non","non","non","non","non","non",null,"non","non","non","non","non","non",null,"non"],["https://theses.fr/2000PA100024","https://www.sudoc.fr/025144278","https://theses.fr/2019PA01E009","https://theses.fr/2021UPSLD029","https://www.sudoc.fr/126699860","https://theses.fr/1998EHES0123","https://theses.fr/2022UPSLM059","https://www.sudoc.fr/041059395","https://theses.fr/1997PA131036","https://theses.fr/2016SACLS117","https://www.sudoc.fr/010806016","https://theses.fr/2022UPSLD063","https://theses.fr/1985CLF1D020","https://theses.fr/2020EHES0190","https://www.sudoc.fr/032019211","https://www.sudoc.fr/163230498","https://theses.fr/2010IEPP0024","https://theses.fr/1992PA080619","https://www.sudoc.fr/040909395","https://www.sudoc.fr/064983919","https://theses.fr/2016NANT3025","https://www.sudoc.fr/041225163","https://www.sudoc.fr/065087429","https://www.sudoc.fr/041213289","https://theses.fr/2010PA010022","https://www.sudoc.fr/040925536","https://www.sudoc.fr/041164849","https://www.sudoc.fr/122117859","https://theses.fr/1997PA010077","https://theses.fr/2014PA010095","https://theses.fr/1989AIX32033","https://theses.fr/1991AIX24011","https://theses.fr/1999TOU10003","https://www.sudoc.fr/04089553X","https://www.sudoc.fr/041163958","https://theses.fr/1998PA010007","https://theses.fr/1995IEPP0012","https://theses.fr/2003IEPP0033","https://theses.fr/2003DIJOMU11","https://theses.fr/2005DIJOE001","https://theses.fr/1995TOU10029","https://www.sudoc.fr/193335794","https://theses.fr/2003STR1EC08","https://theses.fr/2006ENST0025","https://theses.fr/2005AIX32001","https://theses.fr/1986STR10009","https://theses.fr/1991PA100100","https://theses.fr/2006STETT079","https://www.sudoc.fr/004999460","https://theses.fr/2006PA010031"],[[null],["temp_sudoc_thesis_147374a762cfc3b2","temp_sudoc_thesis_2b981b85231c0c0f"],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>author<\/th>\n      <th>author_id<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>institution_thesis_name<\/th>\n      <th>institution_thesis_id<\/th>\n      <th>country<\/th>\n      <th>field<\/th>\n      <th>type<\/th>\n      <th>accessible<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"author","targets":2},{"name":"author_id","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"language","targets":10},{"name":"language_2","targets":11},{"name":"institution_thesis_name","targets":12},{"name":"institution_thesis_id","targets":13},{"name":"country","targets":14},{"name":"field","targets":15},{"name":"type","targets":16},{"name":"accessible","targets":17},{"name":"url","targets":18},{"name":"duplicates","targets":19}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Distribution of theses

<div id="fig-metadata_distribution">

![](documentation_french_database_files/figure-commonmark/fig-metadata_distribution-1.png)

Figure 1: Distribution of theses by defense date

</div>

### Distribution of theses by type

<div id="fig-metadata_distribution_type">

![](documentation_french_database_files/figure-commonmark/fig-metadata_distribution_type-1.png)

Figure 2: Distribution of theses by defence date and type of thesis

</div>

### Availability of abstracts

<div id="fig-metadata_accessible">

![](documentation_french_database_files/figure-commonmark/fig-metadata_accessible-1.png)

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
  institution where the thesis was defended.\
- `entity_id`: the identifier of an entity. If it exists, it is the
  official “idref”, an unique identifiers created by the ABES (see
  <https://www.idref.fr/>). If not, it is a temporary identifier we have
  created following the strategy we used for `thesis_id`.
- `entity_role`: the role of the entity. An individual, for example, may
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
  <a href="#sec-cleaning-individuals"
  class="quarto-xref">Section 3.2.6</a> for more information about names
  standardization.\
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
the thesis edge table. We identify 100813 edges in total.
<a href="#fig-individual-role" class="quarto-xref">Figure 4</a> shows
the distribution of individuals by role.
<a href="#fig-individual-institution" class="quarto-xref">Figure 5</a>
shows the distribution of individuals for the top institutions.

<div id="tbl-edges">

Table 2: Sample of the edges table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-6c4976922dfe7b65f684" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-6c4976922dfe7b65f684">{"x":{"filter":"none","vertical":false,"data":[["1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1923BORUD005","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1974BOR1D015","1985MON10001","1985MON10001","1985MON10001","2010NICE0003","2010NICE0003","2010NICE0003","2012PAUU2021","2012PAUU2021","2012PAUU2021","2012PAUU2021","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2015AIXM2018","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","2022UPSLD011","temp_sudoc_thesis_0b6b4a4352e0c959","temp_sudoc_thesis_0b6b4a4352e0c959","temp_sudoc_thesis_0b6b4a4352e0c959","temp_sudoc_thesis_212f1abbfe38232c","temp_sudoc_thesis_212f1abbfe38232c","temp_sudoc_thesis_212f1abbfe38232c","temp_sudoc_thesis_64390b7a421c82f0","temp_sudoc_thesis_64390b7a421c82f0","temp_sudoc_thesis_64390b7a421c82f0"],["153480777","030142199","028949145","030415705","060856076","060856076","129104000","034750703","027548341","026820641","026957620","026967804","031858961","02674628X","034466924","02674628X","250742438","028032837","028978900","14270783X","026403498","034113851","172500494","156729849","026403668","081536828","196669863","145585387","15863621X","050221027","050322184","059907479","117820903","131591436","117820903","034789731","050221027","050322184","059907479","200879022","158989694","241597595","032173938","035210710","086000594","139157581","175955751","176007121","032173938","027787109","164977147","086000594","176007121","035210710","079124518","103961852","028030214","194569039","103961852","084987367","temp_sudoc_individual_0038b274a7770be5","026402882","086808737"],["author","institution_defence","member","member","member","president","research_partner","author","institution_defence","member","member","member","member","president","research_partner","supervisor","author","institution_defence","supervisor","author","institution_defence","supervisor","author","doctoral_school","institution_defence","supervisor","author","doctoral_school","institution_defence","member","member","member","member","member","president","research_partner","reviewer","reviewer","supervisor","author","doctoral_school","institution_defence","member","member","member","member","member","member","president","research_partner","research_partner","reviewer","reviewer","supervisor","author","institution_defence","supervisor","author","institution_defence","supervisor","author","institution_defence_from_info","supervisor"],["Gachitch","Université de Bordeaux (1441-1970)","Pirou","Palmade","Benzacar","Benzacar","Université de Bordeaux. Faculté de droit (1870-1970)","Goulvestre","Université Bordeaux-I (1971-2013)","Delfaud","Labourdette","Lassudrie-Duchêne","Lacour","Bourguinat","Université Bordeaux-I. Faculté de droit, des sciences sociales et politiques (1971-1995)","Bourguinat","Yaseri","Université de Montpellier I (1970-2014)","Ousset","Gordah","Université de Nice (1965-2019)","Ravix","Benaissa","École doctorale sciences sociales et humanités (Pau, Pyrénées Atlantiques)","Université de Pau et des Pays de l'Adour (1970-....)","Bouoiyour","Clain-Chamosset-Yvrard","Ecole doctorale Sciences Economiques et de Gestion d'Aix-Marseille (Aix-en-Provence ; 2000-....)","Aix-Marseille Université (2012-....)","Le Van","Wigniolle","Seegmuller","Nourry","Kamihigashi","Nourry","Groupe de recherche en économie quantitative d'Aix-Marseille","Le Van","Wigniolle","Seegmuller","Charruau","Ecole doctorale SDOSE (Paris)","Université Paris sciences et lettres (2020-....)","Mouhoud","Epaulard","Lafourcade","Fack","Dherbécourt","Bosquet","Mouhoud","Université Paris Dauphine-PSL (1968-....)","Laboratoire d’Economie de Dauphine (Paris)","Lafourcade","Bosquet","Epaulard","Babassana","Université des sciences sociales (Grenoble ; 1970-1990)","Dessau","Ou","Université des sciences sociales (Grenoble ; 1970-1990)","Pennec","Zographos","Université Aix-Marseille II (1969-2011)","L'huillier"],["Yovan",null,"Gaëtan","Maurice","Joseph","Joseph",null,"Jean-Paul",null,"Pierre","André","Bernard","Claude","Henri",null,"Henri","Hassan Al",null,"Jean","Ahmed Maher",null,"Joël Thomas","Mohamed Anouar",null,null,"Jamal","Lise",null,null,"Cuong","Bertrand","Thomas","Carine","Takashi","Carine",null,"Cuong","Bertrand","Thomas","Paul",null,null,"El Mouhoub","Anne","Miren","Gabrielle","Clément","Clément","El Mouhoub",null,null,"Miren","Clément","Anne","Hilaire",null,"Jean","Young Hwan",null,"Pierre","Michel",null,"Daniel"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>entity_id<\/th>\n      <th>entity_role<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":10,"scrollX":true,"columnDefs":[{"name":"thesis_id","targets":0},{"name":"entity_id","targets":1},{"name":"entity_role","targets":2},{"name":"entity_name","targets":3},{"name":"entity_firstname","targets":4}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Top roles

<div id="fig-individual-role">

![](documentation_french_database_files/figure-commonmark/fig-individual-role-1.png)

Figure 4: Top role

</div>

### Top institutions

<div id="fig-individual-institution">

![](documentation_french_database_files/figure-commonmark/fig-individual-institution-1.png)

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

<div class="datatables html-widget html-fill-item" id="htmlwidget-7c31d5f0ca0bead57874" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-7c31d5f0ca0bead57874">{"x":{"filter":"none","vertical":false,"data":[["1987PA020090","1987PA020090","1987PA020090","temp_sudoc_thesis_a794edc4698e2d91","temp_sudoc_thesis_a794edc4698e2d91","temp_sudoc_thesis_a794edc4698e2d91","temp_sudoc_thesis_a96a2877bdf15d3e","temp_sudoc_thesis_a96a2877bdf15d3e","temp_sudoc_thesis_a96a2877bdf15d3e"],["033228868","026403145","026861992","temp_sudoc_individual_f450fc74cce9679c","027361802","058609172","temp_sudoc_individual_053214100672e9c1","034925732","034526110"],[null,"026403145",null,null,"027361802",null,null,"034925732","temp_sudoc_institution_62e5c67458ee0410"],["author","institution_defence","supervisor","author","institution_defence","supervisor","author","institution_defence","institution_defence_from_info"],["Scannavino","Université Panthéon-Assas (Paris ; 1970-2021)","Fericelli","Savel","Université Paris 1 Panthéon-Sorbonne (1971-....)","Parent","Goepfert","Université de Paris (1896-1968). Faculté de droit et des sciences économiques","Université de Paris (1896-1968)"],["Aimé",null,"Anne-Marie","Frederique",null,"Jean","René",null,null],["Scannavino","Paris 2","Fericelli","SAVEL","Université Paris 1 Panthéon-Sorbonne","Parent","Goepfert","Université de Paris","Paris"],["Aimé",null,"Anne-Marie","FREDERIQUE",null,"Jean","René",null,null],["thesesfr","thesesfr","thesesfr","sudoc","sudoc","sudoc","sudoc","sudoc","sudoc"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>entity_id<\/th>\n      <th>original_id<\/th>\n      <th>entity_role<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n      <th>original_entity_name<\/th>\n      <th>original_entity_firstname<\/th>\n      <th>source<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":10,"scrollX":true,"columnDefs":[{"name":"thesis_id","targets":0},{"name":"entity_id","targets":1},{"name":"original_id","targets":2},{"name":"entity_role","targets":3},{"name":"entity_name","targets":4},{"name":"entity_firstname","targets":5},{"name":"original_entity_name","targets":6},{"name":"original_entity_firstname","targets":7},{"name":"source","targets":8}],"order":[],"autoWidth":false,"orderClasses":false,"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

## Institutions

In the `thesis_institution` table, each line represents a unique
institution. Institutions are the universities, laboratories, doctoral
schools, and other institutions associated with the theses. The table
contains 1434 institutions and 19 variables. It consists of two core
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

<div class="datatables html-widget html-fill-item" id="htmlwidget-cd72512e0d9dbb1245f7" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-cd72512e0d9dbb1245f7">{"x":{"filter":"none","vertical":false,"data":[["026375273","temp_sudoc_institution_c68abe419732ea3c","183948173","074038567","195479270"],["Télécom Paris (Palaiseau, Essonne ; 1878-....)","Lille","Centre d'économie et de management de l'océan Indien (Saint-Denis, Réunion)","Université de Bourgogne. URF des sciences et techniques","Centre d’études en sciences sociales sur les mondes africains, américains et asiatiques (Paris ; 2014-....)"],[[null],[null],[null],[null],[null]],["https://www.idref.fr/026375273.rdf",null,"https://www.idref.fr/183948173.rdf","https://www.idref.fr/074038567.rdf","https://www.idref.fr/195479270.rdf"],["c(\"ENST (Paris) -- (1942-2007)\", \"École nationale supérieure des télécommunic...",null,"c(\"CEMOI\", \"Équipe d'accueil (EA13)\", \"Université de la Réunion. Centre d'éco...","c(\"Université de Bourgogne. Faculté des sciences\", \"Université de Dijon. Facu...",["CESSMA","UMR 245","UMR_D 245"]],["1878",null,"2010-01-01",null,"2014"],[null,null,null,null,null],["c(\"Télécom Paris est un établissement public à caractère scientifique, cultur...",null,"CEMOI = Centre d'économie et de management de l'océan Indien","Adresse : Campus universitaire, bât. Mirande : 9 avenue Alain-Savary, BP 2787...","c(\"Bât. Olympe de Gouges - 8 Rue Albert Einstein 75013 Paris\", \"Unité mixte d..."],["186107218",null,[],[],[]],["École nationale supérieure des postes et télécommunications",null,[],[],[]],["026375265",null,[],[],[]],[[],null,[],[],[]],[[],null,[],[],[]],[[],null,[],[],[]],[[],null,[],[],[]],[["Institut Mines-Télécom","Université Paris-Saclay","Institut polytechnique de Paris"],null,[],[],["Université Paris Diderot - Paris 7","Institut national des langues et civilisations orientales","Institut de recherche pour le développement","Université Paris Cité"]],[["192427156","188120777","238327159"],null,[],[],["027542084","026388715","050165224","236453505"]],[["https://data.hal.science/structure/1048346#foaf:Organization","https://ror.org/01naq7912#foaf:Organization","http://isni.org/isni/0000000121096951","http://data.bnf.fr/ark:/12148/cb11863493k#foaf:Organization","http://viaf.org/viaf/130089636","https://fr.wikipedia.org/wiki/Télécom_Bretagne"],null,"http://viaf.org/viaf/314928916",["http://data.bnf.fr/ark:/12148/cb11999829t#foaf:Organization","http://viaf.org/viaf/123570251","https://fr.wikipedia.org/wiki/Bâtiment_de_la_faculté_des_sciences_de_Dijon"],["https://data.hal.science/structure/1005064#foaf:Organization","https://data.hal.science/structure/450540#foaf:Organization","http://viaf.org/viaf/6758156133216958430003"]],["France",null,null,"France","France"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>old_id<\/th>\n      <th>url<\/th>\n      <th>other_labels<\/th>\n      <th>date_of_birth<\/th>\n      <th>date_of_death<\/th>\n      <th>information<\/th>\n      <th>replaced_idref<\/th>\n      <th>predecessor<\/th>\n      <th>predecessor_idref<\/th>\n      <th>successor<\/th>\n      <th>successor_idref<\/th>\n      <th>subordinated<\/th>\n      <th>subordinated_idref<\/th>\n      <th>unit_of<\/th>\n      <th>unit_of_idref<\/th>\n      <th>other_link<\/th>\n      <th>country_name<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"old_id","targets":2},{"name":"url","targets":3},{"name":"other_labels","targets":4},{"name":"date_of_birth","targets":5},{"name":"date_of_death","targets":6},{"name":"information","targets":7},{"name":"replaced_idref","targets":8},{"name":"predecessor","targets":9},{"name":"predecessor_idref","targets":10},{"name":"successor","targets":11},{"name":"successor_idref","targets":12},{"name":"subordinated","targets":13},{"name":"subordinated_idref","targets":14},{"name":"unit_of","targets":15},{"name":"unit_of_idref","targets":16},{"name":"other_link","targets":17},{"name":"country_name","targets":18}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

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
  details in <a href="#sec-cleaning-individuals"
  class="quarto-xref">Section 3.2.6</a>).

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
  (see <a href="#sec-cleaning-individuals"
  class="quarto-xref">Section 3.2.6</a> for details).

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
> cases where two records may represent the same individual. For further
> details on the methodology, refer to
> <a href="#sec-cleaning-individuals"
> class="quarto-xref">Section 3.2.6</a>.

<a href="#tbl-individual" class="quarto-xref">Table 5</a> shows a sample
of the thesis metadata table.

<div id="tbl-individual">

Table 5: Sample of the thesis individual table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-fdb1fa57408533daf4b7" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-fdb1fa57408533daf4b7">{"x":{"filter":"none","vertical":false,"data":[["055241220","250011042","106933639","220475709","117689246"],["Dieng","Galle","Tefas","Jung","Pelletier"],["Seydi Ababacar","Marion","Georges","Jean-Luc","Julien"],["male","female",null,"male","male"],["male","female","male","male","male"],["19XX","19XX",null,"19XX","19XX"],[null,null,"France","France","France"],[null,"A soutenu une thèse en Sciences économiques à Paris 1 en 1990",null,"Biologiste marin. Maître de conférences à l'Université de Bretagne ...","En poste à l'Agence nationale pour l'amélioration des conditions de..."],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[["https://orcid.org/0000-0003-1429-783X","http://isni.org/isni/0000000431765954","http://viaf.org/viaf/203817147","https://www.persee.fr/authority/230158"],["http://viaf.org/viaf/418160483936504992404"],["http://isni.org/isni/0000000439717033","http://viaf.org/viaf/211244855"],["https://data.hal.science/author/jean-luc-jung#foaf:Person","https://orcid.org/0000-0002-8795-8056","http://viaf.org/viaf/99151302985348662357"],["http://isni.org/isni/0000000356016063","http://data.bnf.fr/ark:/12148/cb15583747p#foaf:Person","http://viaf.org/viaf/175705423"]],[["055241220","temp_thesefr_individual_33c9f174528a800e"],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n      <th>gender<\/th>\n      <th>gender_expanded<\/th>\n      <th>birth<\/th>\n      <th>country_name<\/th>\n      <th>information<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"entity_firstname","targets":2},{"name":"gender","targets":3},{"name":"gender_expanded","targets":4},{"name":"birth","targets":5},{"name":"country_name","targets":6},{"name":"information","targets":7},{"name":"organization","targets":8},{"name":"last_date_org","targets":9},{"name":"start_date_org","targets":10},{"name":"end_date_org","targets":11},{"name":"other_link","targets":12},{"name":"homonym_of","targets":13}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Gender

<div id="fig-individual_genre">

![](documentation_french_database_files/figure-commonmark/fig-individual_genre-1.png)

Figure 6: Distribution of individuals by gender

</div>

### Country

<div id="fig-individual_country">

![](documentation_french_database_files/figure-commonmark/fig-individual_country-1.png)

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

<div class="grViz html-widget html-fill-item" id="htmlwidget-72fc70562187cae0a478" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-72fc70562187cae0a478">{"x":{"diagram":"\ndigraph project_dag {\n graph [layout = dot, rankdir = TB]\n \n # Define nodes\n scraping_sudoc_id [label = \"scraping_sudoc_id.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_id.R\"]\n scraping_sudoc_api [label = \"scraping_sudoc_api.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_api.R\"]\n cleaning_sudoc [label = \"cleaning_sudoc.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_sudoc.R\"]\n downloading_theses_fr [label = \"downloading_theses_fr.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/downloading_theses_fr.R\"]\n cleaning_thesesfr [label = \"cleaning_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_thesesfr.R\"]\n merging_database [label = \"merging_sudoc_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/merging_sudoc_thesesfr.R\"]\n idref_institutions [label = \"scraping_idref_institution.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_institution.R\"]\n idref_persons [label = \"scraping_idref_person.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_person.R\"]\n cleaning_metadata [label = \"cleaning_metadata.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_metadata.R\"]\n cleaning_institutions [label = \"cleaning_institutions.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_institutions.R\"]\n cleaning_individuals [label = \"cleaning_individuals.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_individuals.R\"]\n cleaning_edges [label = \"cleaning_edges.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_edges.R\"]\n adding_columns [label = \"adding_columns_metadata.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/adding_columns_metadata.R\"]\n \n # Define edges\n scraping_sudoc_id -> scraping_sudoc_api\n scraping_sudoc_api -> cleaning_sudoc \n downloading_theses_fr -> cleaning_thesesfr\n cleaning_sudoc -> merging_database\n cleaning_thesesfr -> merging_database\n merging_database -> idref_institutions\n merging_database -> idref_persons\n merging_database -> cleaning_metadata\n idref_institutions -> cleaning_institutions\n idref_persons -> cleaning_individuals\n cleaning_metadata -> cleaning_edges\n cleaning_institutions -> cleaning_edges\n cleaning_individuals -> cleaning_edges\n cleaning_edges -> adding_columns\n}\n","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

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
relational database: metadata, edge, individual, and institution. For
entities without official identifiers, temporary IDs are generated to
enable future identification and disambiguation. Temporary identifiers
are under the format `temp_X_Y`, X representing the source of the
original information (either “sudoc” or “thesesfr”) and Y the type of
record, followed by a hash of the record that keeps the identifier
stable across versions (see “Temporary identifiers” above).

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
script processes four types of tables—theses, edges, individuals, and
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
    [package](https://CRAN.R-project.org/package=stringdist)
    (<span class="nocase">van der Loo</span> 2014). We adjust the
    distance measure by the number of character in the title. Each
    potential duplicate is manually reviewed. In alignment with the
    project’s overall approach, we do not remove duplicates but instead
    flag them in a new column, `duplicates`.
    <a href="#tbl-duplicates" class="quarto-xref">Table 6</a> provides
    an example of distinct theses in the sources that we flagged as
    duplicates.

<div id="tbl-duplicates">

Table 6: Example of theses identified as duplicates

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-020d4f25790be072f31b" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-020d4f25790be072f31b">{"x":{"filter":"none","vertical":false,"data":[["1962REN0G002","temp_sudoc_thesis_6bd8c60326796d90","temp_sudoc_thesis_e9f3344929c6d473"],[1962,1962,1962],["Michel, Pierre","Michel, Pierre","Michel, Pierre"],["164479848","164479848","164479848"],["L'Industrie du granit en Bretagne","L'industrie du granit en Bretagne","L'industrie du granit en Bretagne\nAnnexe"],[null,null,null],[null,null,null],[null,null,null],[null,null,null],[null,null,null],["fr","fr","fr"],[null,null,null],["Université de Rennes. Faculté de droit et des sciences économiques (1896-1969)","Université de Rennes (1896-1969)","Université de Rennes (1896-1969)"],["035647191","074314807","074314807"],["France","France","France"],["Sciences économiques","Sciences économiques","Sciences économiques"],["Thèse","Thèse","Thèse"],[null,null,null],["https://www.sudoc.fr/064184188","https://www.sudoc.fr/072911255","https://www.sudoc.fr/072911263"],[["1962REN0G002","temp_sudoc_thesis_6bd8c60326796d90","temp_sudoc_thesis_e9f3344929c6d473"],["1962REN0G002","temp_sudoc_thesis_6bd8c60326796d90","temp_sudoc_thesis_e9f3344929c6d473"],["1962REN0G002","temp_sudoc_thesis_6bd8c60326796d90","temp_sudoc_thesis_e9f3344929c6d473"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>author<\/th>\n      <th>author_id<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>institution_thesis_name<\/th>\n      <th>institution_thesis_id<\/th>\n      <th>country<\/th>\n      <th>field<\/th>\n      <th>type<\/th>\n      <th>accessible<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"author","targets":2},{"name":"author_id","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"language","targets":10},{"name":"language_2","targets":11},{"name":"institution_thesis_name","targets":12},{"name":"institution_thesis_id","targets":13},{"name":"country","targets":14},{"name":"field","targets":15},{"name":"type","targets":16},{"name":"accessible","targets":17},{"name":"url","targets":18},{"name":"duplicates","targets":19}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

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
[cleaning_individuals.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_individuals.R)
is designed to standardize and enhance the quality of individual data.

The script first enriches individual records by incorporating
information from the `idref_individual_table`, built from
[scraping_idref_person.R](https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_person.R).
When a name entity is linked to an IdRef identifier, supplementary
details about the individual—such as organization affiliations, birth
date, and relevant links (e.g., Wikipedia pages)—are added from the
IdRef database. Additionally, raw names extracted from Sudoc or
theses.fr are replaced with the standardized names provided by IdRef.

A key focus of the script is addressing inconsistencies in individual
identifiers. Challenges include:

- Variations in names: The same individual may appear with slight name
  differences (e.g., “Jean A. Dupont” vs. “Jean Dupont”).
- Duplicate identifiers: A single individual may be associated with
  different identifiers across or within datasets (e.g., as an author in
  Sudoc in 1983 and as a jury member in theses.fr in 1999).

While the script strives to identify and group such cases,
disambiguating individual identifiers is constrained by the risk of
homonyms. For example, two individuals with identical names may
represent distinct individuals. Due to this ambiguity, it is not
possible to merge identifiers confidently.

To address potential ambiguities, the script introduces a new column,
`homonym_of`, which groups potential homonyms. For each individual, the
`homonym_of` field lists the identifiers of individuals with identical
or highly similar names. This approach prevents premature merges while
flagging possible relationships for users to investigate further.

<div id="tbl-duplicates_individual">

Table 7: Example of individuals identified as homonym

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-0a6082731f06a16cd720" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-0a6082731f06a16cd720">{"x":{"filter":"none","vertical":false,"data":[["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173"],["Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon","Mignon"],["Valérie","Valerie","Valerie","Valerie","Valerie","Valérie","Valérie","Valérie","Valérie","Valérie"],["female",null,null,null,null,null,null,null,null,null],["female","female","female","female","female","female","female","female","female","female"],["1970",null,null,null,null,null,null,null,null,null],["France",null,null,null,null,null,null,null,null,null],["Professeure d'économie à l'Université Paris Nanterre (en 2023)",null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[[],null,null,null,null,null,null,null,null,null],[["https://orcid.org/0000-0002-5578-1241","http://isni.org/isni/0000000117607245","http://data.bnf.fr/ark:/12148/cb13204778r#foaf:Person","http://viaf.org/viaf/44442640","https://fr.wikipedia.org/wiki/Valérie_Mignon","https://www.persee.fr/authority/213220"],null,null,null,null,null,null,null,null,null],[["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"],["057545863","temp_thesefr_individual_05de3433ae861998","temp_thesefr_individual_167b9aa4572ebfe7","temp_thesefr_individual_1be2086d9d9b1ebc","temp_thesefr_individual_2a7b678393e74123","temp_thesefr_individual_7ef56770e3bbf89d","temp_thesefr_individual_a5503fd62ab262fa","temp_thesefr_individual_b09c39e4ef750173","temp_thesefr_individual_bad833f61869c87a","temp_thesefr_individual_e9c9356815e8c5a3"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n      <th>gender<\/th>\n      <th>gender_expanded<\/th>\n      <th>birth<\/th>\n      <th>country_name<\/th>\n      <th>information<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"entity_firstname","targets":2},{"name":"gender","targets":3},{"name":"gender_expanded","targets":4},{"name":"birth","targets":5},{"name":"country_name","targets":6},{"name":"information","targets":7},{"name":"organization","targets":8},{"name":"last_date_org","targets":9},{"name":"start_date_org","targets":10},{"name":"end_date_org","targets":11},{"name":"other_link","targets":12},{"name":"homonym_of","targets":13}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

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

<div id="refs" class="references csl-bib-body hanging-indent">

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

<span class="nocase">van der Loo, M. P. J.</span> 2014. “The Stringdist
Package for Approximate String Matching.” *The R Journal* 6: 111–22.
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
