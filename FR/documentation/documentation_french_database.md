# Documentation - Becoming an economist: France
Thomas Delcey, Aurelien Goutsmedt
2024-12-21

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
  - [Usage and Access](#usage-and-access)
- [Presentation of the tables](#presentation-of-the-tables)
  - [Thesis Metadata](#thesis-metadata)
  - [Edges](#edges)
  - [Institutions](#institutions)
  - [Individuals](#individuals)
- [Data collection and cleaning
  process](#data-collection-and-cleaning-process)
  - [General presentation](#general-presentation)
  - [Scraping](#scraping)
  - [Data collection](#data-collection)
    - [theses.fr](#thesesfr)
    - [SUDoc](#sudoc)
    - [IdRef](#idref)
  - [Cleaning](#cleaning)
    - [SUDoc](#sudoc-1)
    - [Theses.fr](#thesesfr-1)
    - [Merging](#merging)
    - [Metadata](#sec-cleaning-metadata)
    - [Institutions](#sec-cleaning-institutions)
    - [Individuals](#sec-cleaning-persons)
- [Improvements](#improvements)

# Introduction

This database gathers information on Ph.D. in economics defended in
France since 1900.[^1] The output of the french database is a relational
database that connects different data frames. The database is structured
in four main components:

- **Thesis Metadata:** This component contains core details about each
  thesis. Each line represents a thesis record, including information
  such as the title, defense date, abstract, and other relevant details.
- **Edges:** This table links the three previous tables, allowing to
  connect individuals to institutions and to theses.
- **Institutions Data:** This includes all mentioned universities,
  laboratories, doctoral schools, and other institutions associated with
  the theses.
- **Individual Data:** Each line represents an individual involved in
  the thesis, such as authors, supervisors, or jury members.

## Usage and Access

Our database is also under the [CC-BY-4.0
licence](https://creativecommons.org/licenses/by/4.0/). It can be
accessed and used freely by anyone. The data is stored in a [Zenodo
repository](https://doi.org/10.5281/zenodo.14541427). Note that we focus
on Ph.D. in economics and we queries our sources by the field of the
thesis. However, the scripts have been developed with a relative
flexibility and can be adapted to other queries, for instance, for other
disciplines.

If you use our data or our scripts, please cite us as Delcey Thomas, and
Aurélien Goutsmedt. (2024). Becoming an Economist: A Database of French
Economics PhDs. Zenodo. (https://doi.org/10.5281/zenodo.14541427).

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
> Be careful to the fact that some of our cleaning steps are the result
> of the specificities of the data we have extracted. We have checked
> systematically problems in our data and proceeded to manual cleaning
> (whether to remove some problematic titles, identify duplicates, clean
> institutions, etc.). If you are using our code to extract data, you
> should be careful to check the quality of the data you have extracted
> and to adapt the cleaning steps to your data. Don’t hesitate to ask us
> for guidance if you are using our code to extract similar data.

# Presentation of the tables

## Thesis Metadata

The thesis metadata table contains 16 variables:

- `thesis_id`: the unique identifier of the thesis. If it exists, it is
  the officiel “national number of the thesis” created by the Agence
  Bibliographique de l’Enseignement Supérieur (ABES) and the theses.fr
  website. If not, it is a temporary identifier we have created.
- `year_defence`: the year of the thesis defence. It covers the period
  between 1899 and 2023.
- `language_1` and `language_2` are the languages of the thesis. It is a
  harmonized variable of the information on language found in SUDoc and
  These.fr.
- `title_fr`: the title of the thesis in French.
- `title_en`: the title of the thesis in English.
- `title_other`: the title of the thesis in another language.
- `abstract_fr`: the abstract of the thesis in French.
- `abstract_en`: the abstract of the thesis in English.
- `abstract_other`: the abstract of the thesis in another language.
- `field`: the field of the thesis. It is a harmonized variable of the
  respective field variables found in SUDoc and These.fr.
- `accessible`: a binary variable indicating whether the fulltext is
  accessible or not.
- `type`: the type of the thesis. Type can take 6 values: Thèse, Thèse
  d’État, Thèse complémentaire, Thèse de 3e cycle, Thèse de
  docteur-ingénieur, Thèse sur travaux. All categories are categories
  found in SUDoc (see **?@tip-type**).
- `country`: the country where the thesis was defended **(à supprimer
  ?)**.
- `url`: the url of the thesis, linking to the theses.fr website or the
  sudoc.fr website.
- `duplicate_of`: a list of identifiers that are duplicates.

> [!WARNING]
>
> Raw source data had an important rate of error in the title and
> abstract language: title in french were in the english column and vice
> versa. We have corrected this issue by using language prediction
> models. See
> <a href="#sec-cleaning-metadata" class="quarto-xref">Section 3.4.4</a>
> for details.

<a href="#tbl-metadata" class="quarto-xref">Table 1</a> shows a sample
of the thesis metadata table. The thesis metadata table contains 21025
theses.
<a href="#fig-metadata_distribution" class="quarto-xref">Figure 1</a>
shows the distribution of theses over time.

<div id="tbl-metadata">

Table 1: Sample of the metadata table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-3486726ba63dea5a7229" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-3486726ba63dea5a7229">{"x":{"filter":"none","vertical":false,"data":[["1986DIJOE002","1994IEPP0045","1992REN11022","2007NICE0022","temp_sudoc_thesis_518930","2002CAEN0605","temp_sudoc_thesis_729207","2015GREAE003","2014PA131035","temp_sudoc_thesis_865053","1987CAEN0509","1991AIX32016","temp_sudoc_thesis_288184","temp_sudoc_thesis_568451","1989PA010026","2017PSLED049","2017LORR0062","2008PA111018","1992LIL20015","2020PA131035","2000PA010074","2021LYSE1250","1981MON10010","2005IEPP0032","1999PA010047","1989NICE0015","2019SACLA023","2013GRENA028","1967BORUD009","2016BORD0353","2019STRAB023","2018PA01E004","temp_sudoc_thesis_425178","1993PA100007","1997INPT004A","1990AIX24001","2015NANT4028","2011GRENH024","2007GRE21031","1991AIX32046","1998AIX24002","1991NICE0017","temp_sudoc_thesis_432220","temp_sudoc_thesis_271172","2013PEST1153","1987MON10002","2022TOU10005","1986PA030052","2010CERG0471","2010AMIE0052"],[1986,1994,1992,2007,1976,2002,1979,2015,2014,1975,1987,1991,1985,1929,1989,2017,2017,2008,1992,2020,2000,2021,1981,2005,1999,1989,2019,2013,1967,2016,2019,2018,1952,1993,1997,1990,2015,2011,2007,1991,1998,1991,1974,1979,2013,1987,2022,1986,2010,2010],["fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","en","en","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","en","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","en","fr"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,"fr",null,null,null,"en",null,null,null,null,null,null,null,null,"fr",null,null,null,null,null,null,null,null,null,null,null,"fr",null],["Les difficultés de l'agriculture dans la straté...","L'Allemagne et la concurrence : vers une nouvel...","Le meso-système halio-alimentaire européen, ana...","Genre, politiques publiques et travail des femmes","L'intervention de l'etat venezuelien face aux e...","Electeurs, candidats et raisonnement flou","Les representations sociales dans le discours s...","Performativité des indicateurs : indicateurs al...","Les déterminants et les connections du risque d...","Les Apports récents de l'Ecole de Cambridge à l...","Essai sur la manipulation des procédures de cho...","Prix et déséquilibre : formation et dynamique","Analyse des performances d'une entreprise dans ...","Le statut fiscal de la famille en matière d'imp...","Impact macroéconomique des entreprises publiques","Revue et analyse des cadres institutionnels et ...","Essais sur la psychologie économique du comport...","Co-localisation, externalités de connaissance e...","Les determinants du choix d'une technique : le ...","Régulation et marchandisation de l'Etat par la ...","Hétérogénéité des prix et salaires, pouvoir de ...","Analyse économique des comportements en matière...","Le rôle de l'industrie sidérurgique dans l'indu...","= Une analyse des effets de l'organisation en h...","Salariat et retraite aux États-Unis","Le T. O. F. : Fondements théoriques et applicat...","Politiques environnementales et alimentation : ...","Trois essais sur la dynamique des firmes en pré...","Organisation et action des syndicats en Turquie","Les déterminants de la transformation productiv...","La valeur économique de l'information géographi...","Mobilité économique à long terme","L'industrie sidérurgique de la Ruhr\nsa localisa...","Protection sociale et salarisation de la main d...","Les rapports d'échange oléiculteurs-transformat...","Efficience logistique et organisation du travai...","Accès aux marchés étrangers, l'impact de la loc...","Les déterminants et impacts macroéconomiques de...","Les conditions d'émergence des biotechnologies ...","A la recherche d'un cadre institutionnel pour l...","Rigidités de l'offre et degrés d'utilisation de...","Marchés et production : une perspective classique","Les marchés publics, mesure de l'impact industr...","Le commerce des sciages de l'Asie du Sud-Est ve...","Les déterminants spatiaux de la demande et de l...","L'économie de la commercialisation des fruits e...","Three Essays on Corporate Innovation and Shareh...","Haiti. Le travail des femmes ou comment s'enric...","Essais sur l'Accès à l'Enseignement Supérieur","Libéralisation des marchés et stratégies de dév..."],[null,"Germany and competition entering into a new all...","The ec seafood processing meso-system, analysis...","Gender, public policy and women's work. A compu...",null,null,null,"Performativity, alternative indicators and tran...","Credit risk determinants and connections in the...",null,"Essay on the manipulation of collective choice ...","Price and desequilibre : formation and dynamic",null,null,null,"Review and analysis of institutional and regula...","Essays in Economic Psychology of Tax Evasion Be...","Co-location, knowledge spillovers and firms inn...","The decisive elements of a technics choice. The...","Regulation and Commodification of the State thr...","Output prices and wages heterogeneity product m...","Essays on behavioral economics on social protec...",null,"An analysis of the effect of a financial holdin...","Employment relations and retirement in the Unit...",null,"Environmental policy and food consumption : wha...","Three essays on firm dynamics with presence of ...",null,"Drivers of sustainable productive transformatio...","The economic value of geographic information on...","Long run economic mobility",null,null,"Olive growers-manufacturers exchange relationsh...","Logistic efficiency and labor organisation : th...","French agrifood firms access to international m...","Macroeconomic Determinants and Impacts of Migra...","The conditions of emergence of the biotechnolog...","In search of an institutional framexork for int...","Supply rigidities and degrees of production fac...","Markets and production : a classical approach",null,null,"On the spatial determinants of energy demand an...","The economics of the commercialization of fruit...","Three Essays on Corporate Innovation and Shareh...",null,"Essays on Access to Higher Education","Market liberalization and developpement strateg..."],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["La stratégie algérienne de développement économ...","Le système économique de la République fédérale...","Si la transformation des produits de la mer est...","Les répercussions des politiques publiques vari...",null,"Le but de cette thèse est d'appliquer les outil...",null,"Les recherches récentes portant sur les indicat...","Le déclenchement de la dette des Subprime en 20...",null,"Un des principaux problèmes de l'agrégation des...","La theorie des prix fait partie de la theorie g...",null,null,"L'entreprise publique est une réalité plus comp...","Aujourd’hui, l’usage des données lié aux servic...","Le premier Chapitre utilise les acquis de la ps...",null,"La these se donne pour objet d'etudier les dete...","Cette thèse analyse le processus de production...","Cette thèse, essentiellement empirique, étudie ...","Ce travail doctoral en économie appliquée propo...",null,"L'objectif principal de cette thèse est d'exami...","Cette thèse porte sur les articulations entre l...","Les fondements théoriques du T. O. F. Et son év...","Cette thèse étudie les comportements des consom...","La thèse est composée de trois articles de rech...",null,"Le travail de recherche présenté dans cette thè...","L’objectif de cette thèse est de développer u...","La mobilité économique est une des aspirations ...",null,null,"L'oleiculture tunisienne a connu, apres l'indep...","Cette these propose un cadre methodologique pou...","La littérature récente en économie internationa...","Cette thèse propose une évaluation empirique de...","Cette thèse a pour objectif d'examiner l'impact...","Comment expliquer la recurrence des crises mone...","À notre époque de chômage massif et durable en ...","L'objet de cette recherche est de montrer que l...",null,null,"Cette thèse propose une approche quantitative i...","Cette thèse consiste en un ensemble de travaux,...","Le résumé en français n'a pas été communiqué pa...",null,"Les choix éducatifs, et notamment celui de l'ac...",null],[null,"He economic system of the Federal Republic of G...","The processing of sea products dates back to an...","The gender differentiated impacts of public pol...",null,null,null,"Recent research on alternative indicators sugge...","The outbreak of the Subprime debt in 2007, foll...",null,"One important problem relating to preference ag...","The price theory belongs to the general theory ...",null,null,null,"Today, data usage driven by content and service...","The first Chapter uses differential psychology ...",null,"The aim of the thesis consists in the study of ...","This thesis analyzes the process of production,...",null,"This PhD dissertation in applied economics prop...",null,"The main intentention of this paper is to exami...",null,null,"This Ph.D. dissertation focuses on consumers’ b...","The thesis is composed of three research articl...",null,"The analysis we present in this dissertation em...","This thesis aims at developing a method of anal...","Economic mobility constitutes a social aspirati...",null,null,null,"A framework aimed at new organisation and manag...","This last decade international trade literature...","This thesis provides an empirical assessment of...","The aim of this thesis is to examine the impact...","How can the frequency of international monetary...",null,"The prupose of this research is to schow that t...",null,null,"This thesis develops an integrated framework to...",null,"The first chapter studies whether and how corpo...",null,"Educative choices, and the entry in higher educ...",null],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Analyse et politique économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques générales","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Science économique","Sciences économiques","Droit","Sciences économiques","Sciences économiques","Sciences Economiques","Sciences économiques","Sciences économiques","Sciences économiques","Économie","Sciences économiques","Sciences économiques","Sciences économiques. Gouvernance économique","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences politiques et économiques","Sciences économiques","Etudes rurales. Économie","Sciences économiques","Economie internationale","Sciences économiques","Sciences économiques","Science économique","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences Economiques","Sciences économiques","Sciences économiques","Sciences économiques"],["non","non","non","non",null,"non",null,"oui","oui",null,"non","non",null,null,"non","oui","oui","non","non","oui","non","oui",null,"non","non","non","oui","oui",null,"oui","oui","oui",null,"non","non","non","non","oui","non","non","non","non",null,null,"oui","non","non","non","oui","non"],["Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse d'État","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse"],["France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France"],["https://theses.fr/1986DIJOE002","https://theses.fr/1994IEPP0045","https://theses.fr/1992REN11022","https://theses.fr/2007NICE0022","https://www.sudoc.fr/040997650.xml","https://theses.fr/2002CAEN0605","https://www.sudoc.fr/041013093.xml","https://theses.fr/2015GREAE003","https://theses.fr/2014PA131035","https://www.sudoc.fr/06508876X.xml","https://theses.fr/1987CAEN0509","https://theses.fr/1991AIX32016","https://www.sudoc.fr/041247477.xml","https://www.sudoc.fr/015655474.xml","https://theses.fr/1989PA010026","https://theses.fr/2017PSLED049","https://theses.fr/2017LORR0062","https://theses.fr/2008PA111018","https://theses.fr/1992LIL20015","https://theses.fr/2020PA131035","https://theses.fr/2000PA010074","https://theses.fr/2021LYSE1250","https://www.sudoc.fr/041095820.xml","https://theses.fr/2005IEPP0032","https://theses.fr/1999PA010047","https://theses.fr/1989NICE0015","https://theses.fr/2019SACLA023","https://theses.fr/2013GRENA028","https://www.sudoc.fr/084396903.xml","https://theses.fr/2016BORD0353","https://theses.fr/2019STRAB023","https://theses.fr/2018PA01E004","https://www.sudoc.fr/088729966.xml","https://theses.fr/1993PA100007","https://theses.fr/1997INPT004A","https://theses.fr/1990AIX24001","https://theses.fr/2015NANT4028","https://theses.fr/2011GRENH024","https://theses.fr/2007GRE21031","https://theses.fr/1991AIX32046","https://theses.fr/1998AIX24002","https://theses.fr/1991NICE0017","https://www.sudoc.fr/014629658.xml","https://www.sudoc.fr/041065107.xml","https://theses.fr/2013PEST1153","https://theses.fr/1987MON10002","https://theses.fr/2022TOU10005","https://theses.fr/1986PA030052","https://theses.fr/2010CERG0471","https://theses.fr/2010AMIE0052"],[[null],[null],[null],[null],["temp_sudoc_thesis_266308"],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Distribution

<div id="fig-metadata_distribution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-adc781a7d13f279796b2" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-adc781a7d13f279796b2">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,48,26,32,30,35,45,49,35,50,55,61,55,69,68,85,86,92,134,164,216,270,372,322,395,455,451,510,509,507,514,462,454,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,316,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Number of theses: 5","Defense date: 1900 <br> Number of theses: 31","Defense date: 1901 <br> Number of theses: 37","Defense date: 1902 <br> Number of theses: 27","Defense date: 1903 <br> Number of theses: 40","Defense date: 1904 <br> Number of theses: 34","Defense date: 1905 <br> Number of theses: 45","Defense date: 1906 <br> Number of theses: 38","Defense date: 1907 <br> Number of theses: 48","Defense date: 1908 <br> Number of theses: 44","Defense date: 1909 <br> Number of theses: 51","Defense date: 1910 <br> Number of theses: 65","Defense date: 1911 <br> Number of theses: 38","Defense date: 1912 <br> Number of theses: 71","Defense date: 1913 <br> Number of theses: 29","Defense date: 1914 <br> Number of theses: 30","Defense date: 1915 <br> Number of theses: 8","Defense date: 1916 <br> Number of theses: 6","Defense date: 1917 <br> Number of theses: 12","Defense date: 1918 <br> Number of theses: 11","Defense date: 1919 <br> Number of theses: 25","Defense date: 1920 <br> Number of theses: 52","Defense date: 1921 <br> Number of theses: 46","Defense date: 1922 <br> Number of theses: 69","Defense date: 1923 <br> Number of theses: 72","Defense date: 1924 <br> Number of theses: 70","Defense date: 1925 <br> Number of theses: 61","Defense date: 1926 <br> Number of theses: 54","Defense date: 1927 <br> Number of theses: 62","Defense date: 1928 <br> Number of theses: 38","Defense date: 1929 <br> Number of theses: 40","Defense date: 1930 <br> Number of theses: 29","Defense date: 1931 <br> Number of theses: 45","Defense date: 1932 <br> Number of theses: 42","Defense date: 1933 <br> Number of theses: 47","Defense date: 1934 <br> Number of theses: 37","Defense date: 1935 <br> Number of theses: 48","Defense date: 1936 <br> Number of theses: 45","Defense date: 1937 <br> Number of theses: 37","Defense date: 1938 <br> Number of theses: 40","Defense date: 1939 <br> Number of theses: 53","Defense date: 1940 <br> Number of theses: 22","Defense date: 1941 <br> Number of theses: 29","Defense date: 1942 <br> Number of theses: 35","Defense date: 1943 <br> Number of theses: 30","Defense date: 1944 <br> Number of theses: 33","Defense date: 1945 <br> Number of theses: 29","Defense date: 1946 <br> Number of theses: 29","Defense date: 1947 <br> Number of theses: 45","Defense date: 1948 <br> Number of theses: 35","Defense date: 1949 <br> Number of theses: 33","Defense date: 1950 <br> Number of theses: 44","Defense date: 1951 <br> Number of theses: 41","Defense date: 1952 <br> Number of theses: 36","Defense date: 1953 <br> Number of theses: 30","Defense date: 1954 <br> Number of theses: 48","Defense date: 1955 <br> Number of theses: 26","Defense date: 1956 <br> Number of theses: 32","Defense date: 1957 <br> Number of theses: 30","Defense date: 1958 <br> Number of theses: 35","Defense date: 1959 <br> Number of theses: 45","Defense date: 1960 <br> Number of theses: 49","Defense date: 1961 <br> Number of theses: 35","Defense date: 1962 <br> Number of theses: 50","Defense date: 1963 <br> Number of theses: 55","Defense date: 1964 <br> Number of theses: 61","Defense date: 1965 <br> Number of theses: 55","Defense date: 1966 <br> Number of theses: 69","Defense date: 1967 <br> Number of theses: 68","Defense date: 1968 <br> Number of theses: 85","Defense date: 1969 <br> Number of theses: 86","Defense date: 1970 <br> Number of theses: 92","Defense date: 1971 <br> Number of theses: 134","Defense date: 1972 <br> Number of theses: 164","Defense date: 1973 <br> Number of theses: 216","Defense date: 1974 <br> Number of theses: 270","Defense date: 1975 <br> Number of theses: 372","Defense date: 1976 <br> Number of theses: 322","Defense date: 1977 <br> Number of theses: 395","Defense date: 1978 <br> Number of theses: 455","Defense date: 1979 <br> Number of theses: 451","Defense date: 1980 <br> Number of theses: 510","Defense date: 1981 <br> Number of theses: 509","Defense date: 1982 <br> Number of theses: 507","Defense date: 1983 <br> Number of theses: 514","Defense date: 1984 <br> Number of theses: 462","Defense date: 1985 <br> Number of theses: 454","Defense date: 1986 <br> Number of theses: 341","Defense date: 1987 <br> Number of theses: 315","Defense date: 1988 <br> Number of theses: 253","Defense date: 1989 <br> Number of theses: 212","Defense date: 1990 <br> Number of theses: 180","Defense date: 1991 <br> Number of theses: 208","Defense date: 1992 <br> Number of theses: 275","Defense date: 1993 <br> Number of theses: 264","Defense date: 1994 <br> Number of theses: 292","Defense date: 1995 <br> Number of theses: 256","Defense date: 1996 <br> Number of theses: 296","Defense date: 1997 <br> Number of theses: 372","Defense date: 1998 <br> Number of theses: 338","Defense date: 1999 <br> Number of theses: 323","Defense date: 2000 <br> Number of theses: 427","Defense date: 2001 <br> Number of theses: 345","Defense date: 2002 <br> Number of theses: 316","Defense date: 2003 <br> Number of theses: 340","Defense date: 2004 <br> Number of theses: 316","Defense date: 2005 <br> Number of theses: 312","Defense date: 2006 <br> Number of theses: 296","Defense date: 2007 <br> Number of theses: 350","Defense date: 2008 <br> Number of theses: 361","Defense date: 2009 <br> Number of theses: 363","Defense date: 2010 <br> Number of theses: 397","Defense date: 2011 <br> Number of theses: 405","Defense date: 2012 <br> Number of theses: 367","Defense date: 2013 <br> Number of theses: 394","Defense date: 2014 <br> Number of theses: 361","Defense date: 2015 <br> Number of theses: 373","Defense date: 2016 <br> Number of theses: 392","Defense date: 2017 <br> Number of theses: 360","Defense date: 2018 <br> Number of theses: 353","Defense date: 2019 <br> Number of theses: 339","Defense date: 2020 <br> Number of theses: 310","Defense date: 2021 <br> Number of theses: 351","Defense date: 2022 <br> Number of theses: 308","Defense date: 2023 <br> Number of theses: 129","Defense date: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Distribution of theses by defense date","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Defense date","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"ec35d246d8aac":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"ec35d246d8aac","visdat":{"ec35d246d8aac":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 1: Distribution of theses by defense date

</div>

### Distribution by type of thesis

<div id="fig-metadata_distribution_type">

<div class="plotly html-widget html-fill-item" id="htmlwidget-e900437e5086d6443ac2" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-e900437e5086d6443ac2">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,3,0,1,2,1,3,14,12,11,18,28,31,43,67,64,104,156,281,242,304,390,371,458,485,470,485,436,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,70,29,30,8,6,12,11,25,52,46,68,72,70,61,54,62,38,40,28,45,42,47,37,48,45,37,39,52,22,29,34,30,33,29,29,45,35,33,44,41,36,30,48,26,30,30,32,45,48,33,49,52,47,43,58,50,57,55,49,67,100,112,114,91,80,91,65,80,52,24,37,29,26,234,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,315,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Type: Thèse <br> Number of theses: 5","Defense date: 1900 <br> Type: Thèse <br> Number of theses: 31","Defense date: 1901 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1902 <br> Type: Thèse <br> Number of theses: 27","Defense date: 1903 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1904 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1905 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1906 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1907 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1908 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1909 <br> Type: Thèse <br> Number of theses: 51","Defense date: 1910 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1911 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1912 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1913 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1914 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1915 <br> Type: Thèse <br> Number of theses: 8","Defense date: 1916 <br> Type: Thèse <br> Number of theses: 6","Defense date: 1917 <br> Type: Thèse <br> Number of theses: 12","Defense date: 1918 <br> Type: Thèse <br> Number of theses: 11","Defense date: 1919 <br> Type: Thèse <br> Number of theses: 25","Defense date: 1920 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1921 <br> Type: Thèse <br> Number of theses: 46","Defense date: 1922 <br> Type: Thèse <br> Number of theses: 68","Defense date: 1923 <br> Type: Thèse <br> Number of theses: 72","Defense date: 1924 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1925 <br> Type: Thèse <br> Number of theses: 61","Defense date: 1926 <br> Type: Thèse <br> Number of theses: 54","Defense date: 1927 <br> Type: Thèse <br> Number of theses: 62","Defense date: 1928 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1929 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1930 <br> Type: Thèse <br> Number of theses: 28","Defense date: 1931 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1932 <br> Type: Thèse <br> Number of theses: 42","Defense date: 1933 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1934 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1935 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1936 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1937 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1938 <br> Type: Thèse <br> Number of theses: 39","Defense date: 1939 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1940 <br> Type: Thèse <br> Number of theses: 22","Defense date: 1941 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1942 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1943 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1944 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1945 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1946 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1947 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1948 <br> Type: Thèse <br> Number of theses: 35","Defense date: 1949 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1950 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1951 <br> Type: Thèse <br> Number of theses: 41","Defense date: 1952 <br> Type: Thèse <br> Number of theses: 36","Defense date: 1953 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1954 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1955 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1956 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1957 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1958 <br> Type: Thèse <br> Number of theses: 32","Defense date: 1959 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1960 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1961 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1962 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1963 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1964 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1965 <br> Type: Thèse <br> Number of theses: 43","Defense date: 1966 <br> Type: Thèse <br> Number of theses: 58","Defense date: 1967 <br> Type: Thèse <br> Number of theses: 50","Defense date: 1968 <br> Type: Thèse <br> Number of theses: 57","Defense date: 1969 <br> Type: Thèse <br> Number of theses: 55","Defense date: 1970 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1971 <br> Type: Thèse <br> Number of theses: 67","Defense date: 1972 <br> Type: Thèse <br> Number of theses: 100","Defense date: 1973 <br> Type: Thèse <br> Number of theses: 112","Defense date: 1974 <br> Type: Thèse <br> Number of theses: 114","Defense date: 1975 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1976 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1977 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1978 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1979 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1980 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1981 <br> Type: Thèse <br> Number of theses: 24","Defense date: 1982 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1983 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1984 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1985 <br> Type: Thèse <br> Number of theses: 234","Defense date: 1986 <br> Type: Thèse <br> Number of theses: 341","Defense date: 1987 <br> Type: Thèse <br> Number of theses: 315","Defense date: 1988 <br> Type: Thèse <br> Number of theses: 253","Defense date: 1989 <br> Type: Thèse <br> Number of theses: 212","Defense date: 1990 <br> Type: Thèse <br> Number of theses: 180","Defense date: 1991 <br> Type: Thèse <br> Number of theses: 208","Defense date: 1992 <br> Type: Thèse <br> Number of theses: 275","Defense date: 1993 <br> Type: Thèse <br> Number of theses: 264","Defense date: 1994 <br> Type: Thèse <br> Number of theses: 292","Defense date: 1995 <br> Type: Thèse <br> Number of theses: 256","Defense date: 1996 <br> Type: Thèse <br> Number of theses: 296","Defense date: 1997 <br> Type: Thèse <br> Number of theses: 372","Defense date: 1998 <br> Type: Thèse <br> Number of theses: 338","Defense date: 1999 <br> Type: Thèse <br> Number of theses: 323","Defense date: 2000 <br> Type: Thèse <br> Number of theses: 427","Defense date: 2001 <br> Type: Thèse <br> Number of theses: 345","Defense date: 2002 <br> Type: Thèse <br> Number of theses: 316","Defense date: 2003 <br> Type: Thèse <br> Number of theses: 340","Defense date: 2004 <br> Type: Thèse <br> Number of theses: 315","Defense date: 2005 <br> Type: Thèse <br> Number of theses: 312","Defense date: 2006 <br> Type: Thèse <br> Number of theses: 296","Defense date: 2007 <br> Type: Thèse <br> Number of theses: 350","Defense date: 2008 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2009 <br> Type: Thèse <br> Number of theses: 363","Defense date: 2010 <br> Type: Thèse <br> Number of theses: 397","Defense date: 2011 <br> Type: Thèse <br> Number of theses: 405","Defense date: 2012 <br> Type: Thèse <br> Number of theses: 367","Defense date: 2013 <br> Type: Thèse <br> Number of theses: 394","Defense date: 2014 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2015 <br> Type: Thèse <br> Number of theses: 373","Defense date: 2016 <br> Type: Thèse <br> Number of theses: 392","Defense date: 2017 <br> Type: Thèse <br> Number of theses: 360","Defense date: 2018 <br> Type: Thèse <br> Number of theses: 353","Defense date: 2019 <br> Type: Thèse <br> Number of theses: 339","Defense date: 2020 <br> Type: Thèse <br> Number of theses: 310","Defense date: 2021 <br> Type: Thèse <br> Number of theses: 351","Defense date: 2022 <br> Type: Thèse <br> Number of theses: 308","Defense date: 2023 <br> Type: Thèse <br> Number of theses: 129","Defense date: NA <br> Type: Thèse <br> Number of theses: 18"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse","legendgroup":"Thèse","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[2,10,7,19,26,32,56,57,91,146,258,219,297,380,365,450,482,467,483,434,219,0],"x":[1963,1964,1966,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,4,4,9,5,11,11,7,13,10,23,23,7,10,6,8,3,3,2,2,1,0],"text":["Defense date: 1963 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1966 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1968 <br> Type: Thèse complémentaire <br> Number of theses: 9","Defense date: 1969 <br> Type: Thèse complémentaire <br> Number of theses: 5","Defense date: 1970 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1971 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1973 <br> Type: Thèse complémentaire <br> Number of theses: 13","Defense date: 1974 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1975 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1976 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1977 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1978 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1979 <br> Type: Thèse complémentaire <br> Number of theses: 6","Defense date: 1980 <br> Type: Thèse complémentaire <br> Number of theses: 8","Defense date: 1981 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1982 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1983 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1984 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1985 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: NA <br> Type: Thèse complémentaire <br> Number of theses: 4"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(183,159,0,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse complémentaire","legendgroup":"Thèse complémentaire","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,1,2,2,3,10,13,18,25,45,47,79,94,143,144,208,292,279,351,406,393,428,375,187,0],"x":[1912,1922,1930,1938,1939,1942,1956,1958,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,1,1,1,1,1,2,3,1,2,1,1,8,10,4,8,6,8,7,11,10,12,52,115,75,89,88,86,99,76,74,55,59,32,0],"text":["Defense date: 1912 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1922 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1930 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1938 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1939 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1942 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1956 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1958 <br> Type: Thèse d'État <br> Number of theses: 3","Defense date: 1960 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1961 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1962 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1963 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1965 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1966 <br> Type: Thèse d'État <br> Number of theses: 4","Defense date: 1967 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1968 <br> Type: Thèse d'État <br> Number of theses: 6","Defense date: 1969 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1970 <br> Type: Thèse d'État <br> Number of theses: 7","Defense date: 1971 <br> Type: Thèse d'État <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1973 <br> Type: Thèse d'État <br> Number of theses: 12","Defense date: 1974 <br> Type: Thèse d'État <br> Number of theses: 52","Defense date: 1975 <br> Type: Thèse d'État <br> Number of theses: 115","Defense date: 1976 <br> Type: Thèse d'État <br> Number of theses: 75","Defense date: 1977 <br> Type: Thèse d'État <br> Number of theses: 89","Defense date: 1978 <br> Type: Thèse d'État <br> Number of theses: 88","Defense date: 1979 <br> Type: Thèse d'État <br> Number of theses: 86","Defense date: 1980 <br> Type: Thèse d'État <br> Number of theses: 99","Defense date: 1981 <br> Type: Thèse d'État <br> Number of theses: 76","Defense date: 1982 <br> Type: Thèse d'État <br> Number of theses: 74","Defense date: 1983 <br> Type: Thèse d'État <br> Number of theses: 55","Defense date: 1984 <br> Type: Thèse d'État <br> Number of theses: 59","Defense date: 1985 <br> Type: Thèse d'État <br> Number of theses: 32","Defense date: NA <br> Type: Thèse d'État <br> Number of theses: 1"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,186,56,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse d'État","legendgroup":"Thèse d'État","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,1,0,0,0,0,0,0,0,4,0,2,1,0,1,1,5,9,0,0],"x":[1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,2004,null],"y":[1,2,2,3,10,13,17,25,45,47,79,94,143,144,204,292,277,350,406,392,427,370,178,1,0],"text":["Defense date: 1963 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1965 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1966 <br> Type: Thèse de 3e cycle <br> Number of theses: 3","Defense date: 1967 <br> Type: Thèse de 3e cycle <br> Number of theses: 10","Defense date: 1968 <br> Type: Thèse de 3e cycle <br> Number of theses: 13","Defense date: 1969 <br> Type: Thèse de 3e cycle <br> Number of theses: 17","Defense date: 1970 <br> Type: Thèse de 3e cycle <br> Number of theses: 25","Defense date: 1971 <br> Type: Thèse de 3e cycle <br> Number of theses: 45","Defense date: 1972 <br> Type: Thèse de 3e cycle <br> Number of theses: 47","Defense date: 1973 <br> Type: Thèse de 3e cycle <br> Number of theses: 79","Defense date: 1974 <br> Type: Thèse de 3e cycle <br> Number of theses: 94","Defense date: 1975 <br> Type: Thèse de 3e cycle <br> Number of theses: 143","Defense date: 1976 <br> Type: Thèse de 3e cycle <br> Number of theses: 144","Defense date: 1977 <br> Type: Thèse de 3e cycle <br> Number of theses: 204","Defense date: 1978 <br> Type: Thèse de 3e cycle <br> Number of theses: 292","Defense date: 1979 <br> Type: Thèse de 3e cycle <br> Number of theses: 277","Defense date: 1980 <br> Type: Thèse de 3e cycle <br> Number of theses: 350","Defense date: 1981 <br> Type: Thèse de 3e cycle <br> Number of theses: 406","Defense date: 1982 <br> Type: Thèse de 3e cycle <br> Number of theses: 392","Defense date: 1983 <br> Type: Thèse de 3e cycle <br> Number of theses: 427","Defense date: 1984 <br> Type: Thèse de 3e cycle <br> Number of theses: 370","Defense date: 1985 <br> Type: Thèse de 3e cycle <br> Number of theses: 178","Defense date: 2004 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: NA <br> Type: Thèse de 3e cycle <br> Number of theses: 3"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de 3e cycle","legendgroup":"Thèse de 3e cycle","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0],"x":[1969,1979,1980,1982,1983,1984,1985],"y":[1,2,1,1,1,5,9],"text":["Defense date: 1969 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1979 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 2","Defense date: 1980 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1982 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1983 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1984 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 5","Defense date: 1985 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 9"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(97,156,255,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de docteur-ingénieur","legendgroup":"Thèse de docteur-ingénieur","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":0.90000000000009095,"base":0,"x":[1977],"y":[4],"text":"Defense date: 1977 <br> Type: Thèse sur travaux <br> Number of theses: 4","type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(245,100,227,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse sur travaux","legendgroup":"Thèse sur travaux","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Distribution of theses by defense date and type of thesis","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Defense date","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Type of thesis","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"ec35dc80d8df":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"ec35dc80d8df","visdat":{"ec35dc80d8df":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 2: Distribution of theses by defense date and type of thesis

</div>

### Availability of abstracts

<div id="fig-metadata_accessible">

<div class="plotly html-widget html-fill-item" id="htmlwidget-7371766edfb2ee5195a2" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-7371766edfb2ee5195a2">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,0,3,2,1,0,1,1,1,1,0,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,47,26,32,30,35,45,49,35,49,55,61,54,69,65,83,85,92,133,163,215,269,372,316,392,452,449,509,507,503,510,454,431,55,46,20,21,15,19,20,22,17,5,19,11,13,17,58,58,65,57,37,24,20,34,29,23,13,7,10,5,4,7,3,3,2,3,3,3,0],"text":["Accessible: No <br> Date of defence: 1899 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1900 <br> Number of theses: 31","Accessible: No <br> Date of defence: 1901 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1902 <br> Number of theses: 27","Accessible: No <br> Date of defence: 1903 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1904 <br> Number of theses: 34","Accessible: No <br> Date of defence: 1905 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1906 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1907 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1908 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1909 <br> Number of theses: 51","Accessible: No <br> Date of defence: 1910 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1911 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1912 <br> Number of theses: 71","Accessible: No <br> Date of defence: 1913 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1914 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1915 <br> Number of theses: 8","Accessible: No <br> Date of defence: 1916 <br> Number of theses: 6","Accessible: No <br> Date of defence: 1917 <br> Number of theses: 12","Accessible: No <br> Date of defence: 1918 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1919 <br> Number of theses: 25","Accessible: No <br> Date of defence: 1920 <br> Number of theses: 52","Accessible: No <br> Date of defence: 1921 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1922 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1923 <br> Number of theses: 72","Accessible: No <br> Date of defence: 1924 <br> Number of theses: 70","Accessible: No <br> Date of defence: 1925 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1926 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1927 <br> Number of theses: 62","Accessible: No <br> Date of defence: 1928 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1929 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1930 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1931 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1932 <br> Number of theses: 42","Accessible: No <br> Date of defence: 1933 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1934 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1935 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1936 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1937 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1938 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1939 <br> Number of theses: 53","Accessible: No <br> Date of defence: 1940 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1941 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1942 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1943 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1944 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1945 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1946 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1947 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1948 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1949 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1950 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1951 <br> Number of theses: 41","Accessible: No <br> Date of defence: 1952 <br> Number of theses: 36","Accessible: No <br> Date of defence: 1953 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1954 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1955 <br> Number of theses: 26","Accessible: No <br> Date of defence: 1956 <br> Number of theses: 32","Accessible: No <br> Date of defence: 1957 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1958 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1959 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1960 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1961 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1962 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1963 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1964 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1965 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1966 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1967 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1968 <br> Number of theses: 83","Accessible: No <br> Date of defence: 1969 <br> Number of theses: 85","Accessible: No <br> Date of defence: 1970 <br> Number of theses: 92","Accessible: No <br> Date of defence: 1971 <br> Number of theses: 133","Accessible: No <br> Date of defence: 1972 <br> Number of theses: 163","Accessible: No <br> Date of defence: 1973 <br> Number of theses: 215","Accessible: No <br> Date of defence: 1974 <br> Number of theses: 269","Accessible: No <br> Date of defence: 1975 <br> Number of theses: 372","Accessible: No <br> Date of defence: 1976 <br> Number of theses: 316","Accessible: No <br> Date of defence: 1977 <br> Number of theses: 392","Accessible: No <br> Date of defence: 1978 <br> Number of theses: 452","Accessible: No <br> Date of defence: 1979 <br> Number of theses: 449","Accessible: No <br> Date of defence: 1980 <br> Number of theses: 509","Accessible: No <br> Date of defence: 1981 <br> Number of theses: 507","Accessible: No <br> Date of defence: 1982 <br> Number of theses: 503","Accessible: No <br> Date of defence: 1983 <br> Number of theses: 510","Accessible: No <br> Date of defence: 1984 <br> Number of theses: 454","Accessible: No <br> Date of defence: 1985 <br> Number of theses: 431","Accessible: No <br> Date of defence: 1986 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1987 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1988 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1989 <br> Number of theses: 21","Accessible: No <br> Date of defence: 1990 <br> Number of theses: 15","Accessible: No <br> Date of defence: 1991 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1992 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1993 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1994 <br> Number of theses: 17","Accessible: No <br> Date of defence: 1995 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1996 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1997 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1998 <br> Number of theses: 13","Accessible: No <br> Date of defence: 1999 <br> Number of theses: 17","Accessible: No <br> Date of defence: 2000 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2001 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2002 <br> Number of theses: 65","Accessible: No <br> Date of defence: 2003 <br> Number of theses: 57","Accessible: No <br> Date of defence: 2004 <br> Number of theses: 37","Accessible: No <br> Date of defence: 2005 <br> Number of theses: 24","Accessible: No <br> Date of defence: 2006 <br> Number of theses: 20","Accessible: No <br> Date of defence: 2007 <br> Number of theses: 34","Accessible: No <br> Date of defence: 2008 <br> Number of theses: 29","Accessible: No <br> Date of defence: 2009 <br> Number of theses: 23","Accessible: No <br> Date of defence: 2010 <br> Number of theses: 13","Accessible: No <br> Date of defence: 2011 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2012 <br> Number of theses: 10","Accessible: No <br> Date of defence: 2013 <br> Number of theses: 5","Accessible: No <br> Date of defence: 2014 <br> Number of theses: 4","Accessible: No <br> Date of defence: 2015 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2016 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2017 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2018 <br> Number of theses: 2","Accessible: No <br> Date of defence: 2019 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2020 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2021 <br> Number of theses: 3","Accessible: No <br> Date of defence: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"No","legendgroup":"No","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1954,1962,1965,1967,1968,1969,1971,1972,1973,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023],"y":[1,1,1,3,2,1,1,1,1,1,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,308,129],"text":["Accessible: Yes <br> Date of defence: 1954 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1962 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1965 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1967 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1968 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1969 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1971 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1972 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1973 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1974 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1976 <br> Number of theses: 6","Accessible: Yes <br> Date of defence: 1977 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1978 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1979 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1980 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1981 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1982 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1983 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1984 <br> Number of theses: 8","Accessible: Yes <br> Date of defence: 1985 <br> Number of theses: 23","Accessible: Yes <br> Date of defence: 1986 <br> Number of theses: 286","Accessible: Yes <br> Date of defence: 1987 <br> Number of theses: 269","Accessible: Yes <br> Date of defence: 1988 <br> Number of theses: 233","Accessible: Yes <br> Date of defence: 1989 <br> Number of theses: 191","Accessible: Yes <br> Date of defence: 1990 <br> Number of theses: 165","Accessible: Yes <br> Date of defence: 1991 <br> Number of theses: 189","Accessible: Yes <br> Date of defence: 1992 <br> Number of theses: 255","Accessible: Yes <br> Date of defence: 1993 <br> Number of theses: 242","Accessible: Yes <br> Date of defence: 1994 <br> Number of theses: 275","Accessible: Yes <br> Date of defence: 1995 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 1996 <br> Number of theses: 277","Accessible: Yes <br> Date of defence: 1997 <br> Number of theses: 361","Accessible: Yes <br> Date of defence: 1998 <br> Number of theses: 325","Accessible: Yes <br> Date of defence: 1999 <br> Number of theses: 306","Accessible: Yes <br> Date of defence: 2000 <br> Number of theses: 369","Accessible: Yes <br> Date of defence: 2001 <br> Number of theses: 287","Accessible: Yes <br> Date of defence: 2002 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 2003 <br> Number of theses: 283","Accessible: Yes <br> Date of defence: 2004 <br> Number of theses: 279","Accessible: Yes <br> Date of defence: 2005 <br> Number of theses: 288","Accessible: Yes <br> Date of defence: 2006 <br> Number of theses: 276","Accessible: Yes <br> Date of defence: 2007 <br> Number of theses: 316","Accessible: Yes <br> Date of defence: 2008 <br> Number of theses: 332","Accessible: Yes <br> Date of defence: 2009 <br> Number of theses: 340","Accessible: Yes <br> Date of defence: 2010 <br> Number of theses: 384","Accessible: Yes <br> Date of defence: 2011 <br> Number of theses: 398","Accessible: Yes <br> Date of defence: 2012 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2013 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2014 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2015 <br> Number of theses: 366","Accessible: Yes <br> Date of defence: 2016 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2017 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2018 <br> Number of theses: 351","Accessible: Yes <br> Date of defence: 2019 <br> Number of theses: 336","Accessible: Yes <br> Date of defence: 2020 <br> Number of theses: 307","Accessible: Yes <br> Date of defence: 2021 <br> Number of theses: 348","Accessible: Yes <br> Date of defence: 2022 <br> Number of theses: 308","Accessible: Yes <br> Date of defence: 2023 <br> Number of theses: 129"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Yes","legendgroup":"Yes","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Availability of abstracts","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Accessible","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Accessible","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"ec35d4e73ff03":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"ec35d4e73ff03","visdat":{"ec35d4e73ff03":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 3: Availability of abstracts

</div>

</div>

> [!NOTE]
>
> ### The variable `type`
>
> Note that the French education system did not have a harmonized
> Ph.D. system between the early 1960s and 1984, date of the Sauvy
> reform that harmonized the Ph.D. system. During this period, various
> types of theses existed before. It was usual in the mid 1970s to start
> with a “Doctorat de 3e cycle” before making a “Doctorat d’Etat”. Thus,
> one author can have several types of theses.
> <a href="#fig-metadata_distribution_type"
> class="quarto-xref">Figure 2</a> shows the distribution of theses over
> time by the type of thesis. Note also that we cannot ensure that the
> practice of mentioning the type of thesis in the metadata is
> systematic: it depends of the quality of the metadata provided by the
> institutions.

> [!WARNING]
>
> ### Availability of `abstracts`
>
> The practice of providing abstracts in the metadata started in the
> 1980s. Before this date, the availability of abstracts is nearly null
> (see
> <a href="#fig-metadata_accessible" class="quarto-xref">Figure 3</a>).

## Edges

Each line in the edge table is a unique edge between a thesis and an
entity. We define entity as any individual or institution involved in
the thesis. The edge table has 5:

- `thesis_id`: the identifiers of a thesis (the same than in
  `thesis_medata`). In the edge table, a `thesis_id` can have several
  edges. A `thesis_id` has at least two edges: the author and the
  institution in which the thesis was defended.
- `entity_id`: the identifiers of an entity.
- `entity_role`: the role of the entity. A person can be either an
  author, a supervisor, a referee, a president or a member of jury. In
  addition to the main institution in which the Ph.D. was defended, the
  `entity_role` can contain additional information we were able to
  collect such as the other institutions, laboratories, doctoral schools
  (the institution organizing the doctorate in french university). Note
  that it concerns only theses collected in these.fr after 1985. For
  SUDoc, the value `etablissements_soutenance_from_info` may provide
  additional information on the institution.
- `entity_firstname`: The name of the entity. Each entity has a
  `entity_name`. Note that the entity identifiers is unique but the
  entity name is not unique. For instance, two different persons can
  have the same name. When available, an individual can have a
  `entity_firstname`.

> [!WARNING]
>
> Most of our effort in building the database was to delete duplicates
> in entities so that users can easily estimate the involvement of an
> entity in theses. It is the case for most institutions which are well
> identified by an unique idref. Unfortunately, it was harder to
> disambiguous individual entities. To illustrate this point, it is very
> easy to spot that the string “Université Paris I” and “Université
> Paris I Panthéon-Sorbonne” are the same entity but we cannot be sure
> that “Thomas Delcey” authoring a Ph.D in 2021 is the same person than
> “Thomas Delcey” supervising a Ph.D. in 2022. The variable `homonym_of`
> helps the users to spot potential duplicates. See details in
> <a href="#sec-cleaning-persons" class="quarto-xref">Section 3.4.6</a>.

<a href="#tbl-edges" class="quarto-xref">Table 2</a> shows a sample of
the thesis edge table. We identify 107633 edges in total.
<a href="#fig-person-role" class="quarto-xref">Figure 4</a> shows the
distribution of individuals by role.
<a href="#fig-person-institution" class="quarto-xref">Figure 5</a> shows
the distribution of individuals for the top institutions.

<div id="tbl-edges">

Table 2: Sample of the edges table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-937932587ec8b4d38a4a" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-937932587ec8b4d38a4a">{"x":{"filter":"none","vertical":false,"data":[["temp_sudoc_thesis_680262","temp_sudoc_thesis_895892","2015BORD0230","temp_sudoc_thesis_654723","temp_sudoc_thesis_131858","2020EHES0027","2006PA090047","1914BORUD611","2021EHES0090","2000AIX24015","2014PA090003","1972NICE0001","1993PA010006","2017PSLED081","1992PA020116","1996EHES0102","2021UBFCG009","temp_sudoc_thesis_919079","2018TOU10058","temp_sudoc_thesis_251991","2018LYSE2103","2020GRALE002","2015BORD0102","2004NICE0035","1999LIL12007","temp_sudoc_thesis_251943","1995AIX24005","temp_sudoc_thesis_412035","1997TOU10019","temp_sudoc_thesis_936702","2011PA030030","2021UPASI006","2020UPSLD023","2016USPCA151","1986ORLE0508","1984PA010087","2006BOR40030","1996EPXX0052","2015BORD0293","2008PA010017","temp_sudoc_thesis_398967","2017PSLED052","2022COAZ0049","2021PA01E038","1995CNAM0235","2022BORD0102","2016PA020026","2022UPSLD011","2018PA01E007","1976MON10042"],["029884942","027361802","029302102","035020997","02778715X","191199524","115601007","129104000","158881540","075187337","158989694","026403498","050061488","192452339","031826881","026374889","166736406","026403765","157279111","087793903","02640334X","149284713","034563962","034461736","026404184","02809509X","057763690","027071308","176731431","103961852","157720675","177626143","058468609","02880905X","02691607X","temp_sudoc_person_165020","029302102","231304730","068679386","026739461","027297519","137149034","117013714","165593520","temp_thesefr_person_100336","07730442X","181558017","032173938","229669921","028032837"],["institution_defence","institution_defence","supervisor","supervisor","institution_defence","reviewer","author","research_partner","member","author","doctoral_schools","institution_defence","author","member","author","institution_defense","member","institution_defence","doctoral_schools","institution_defence","research_partner","doctoral_schools","reviewer","research_partner","institution_defense","institution_defence_from_info","author","supervisor","author","institution_defence","doctoral_schools","research_partner","reviewer","president","supervisor","author","supervisor","author","supervisor","supervisor","institution_defence_from_info","member","reviewer","research_partner","supervisor","reviewer","member","president","member","institution_defence_from_info"],["Université de Grenoble (1339-1970). Faculté de droit et des sciences économiques (1896-1970)","Université Paris 1 Panthéon-Sorbonne (1971-....)","Bélis-Bergouignan","Jeanneney","Université de Rennes 1 (1969-2022)","Elicin Arikan","Moeller","Université de Bordeaux. Faculté de droit (1870-1970)","Schmutz","Manzi","Ecole doctorale SDOSE (Paris)","Université de Nice (1965-2019)","Bec","Bonsang","Poirier","École des hautes études en sciences sociales (Paris ; 1975-....)","Bouamra-Mechemache","Université de Poitiers (1896-...)","Toulouse School of Economics","Université d'Aix-Marseille. Faculté de droit et des sciences économiques (1896-1973)","Université Lumière (Lyon ; 1969-....)","École doctorale sciences économiques (Grenoble ; 1999-....)","Héraud","Centre d'Etudes en Macroéconomie et Finance Internationale (Nice)","Université Lille 1 - Sciences et technologies (Villeneuve-d'Ascq ; 1970-2017)","Université de Strasbourg (1538-1970)","Haas","Piatier","Meddahi","Université des sciences sociales (Grenoble ; 1970-1990)","École doctorale Études anglophones, germanophones et européennes (2009-2019 ; Paris)","Réseaux, innovation, territoires et mondialisation (Sceaux, Haut-de-Seine)","Darné","Cingolani","Haudeville","Khouini","Bélis-Bergouignan","Gamrowski","Ferrari","Bordes","Université de Toulouse (1896-1968)","De Vreyer","Mandel","Paris-Jourdan Sciences Économiques (2005-....)","Salomon","Roussel","Wilson","Mouhoud","Schumacher","Université de Montpellier I (1970-2014)"],[null,null,"Marie-Claude","Jean-Marcel",null,"Yeşeren","Markus",null,"Benoit","Stéphane",null,null,"Frédérique","Eric","Jean-Pierre",null,"Zohra",null,null,null,null,null,"Jean-Alain",null,null,null,"Sandrine","André","Nour",null,null,null,"Olivier","Patrick","Bernard","Rafika","Marie-Claude","Bertrand","Sylvie","Christian",null,"Philippe","Antoine",null,"Jean-Jacques","Sébastien","Nicholas","El Mouhoub","Ingmar",null]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>entity_id<\/th>\n      <th>entity_role<\/th>\n      <th>entity_name<\/th>\n      <th>entity_firstname<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"thesis_id","targets":0},{"name":"entity_id","targets":1},{"name":"entity_role","targets":2},{"name":"entity_name","targets":3},{"name":"entity_firstname","targets":4}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Top roles

<div id="fig-person-role">

<div class="plotly html-widget html-fill-item" id="htmlwidget-a6ca5620cae51cc0848e" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-a6ca5620cae51cc0848e">{"x":{"data":[{"orientation":"h","width":[0.90000000000000036,0.90000000000000036,0.89999999999999991,0.90000000000000013,0.90000000000000036],"base":[0,0,0,0,0],"x":[21031,16001,3960,7273,19292],"y":[5,3,1,2,4],"text":["Role: author <br> Number of individuals: 21031","Role: member <br> Number of individuals: 16001","Role: president <br> Number of individuals: 3960","Role: reviewer <br> Number of individuals: 7273","Role: supervisor <br> Number of individuals: 19292"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":69.406392694063939},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-1051.55,22082.549999999999],"tickmode":"array","ticktext":["0","5000","10000","15000","20000"],"tickvals":[0,5000,10000,15000,20000],"categoryorder":"array","categoryarray":["0","5000","10000","15000","20000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of individuals","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,5.5999999999999996],"tickmode":"array","ticktext":["president","reviewer","member","supervisor","author"],"tickvals":[1,2,3,4,5],"categoryorder":"array","categoryarray":["president","reviewer","member","supervisor","author"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"ec35d9246d29":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"ec35d9246d29","visdat":{"ec35d9246d29":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 4: Top role

</div>

### Top institutions

<div id="fig-person-institution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-e9337846392062d2dbbc" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-e9337846392062d2dbbc">{"x":{"data":[{"orientation":"h","width":[0.89999999999999858,0.89999999999999858,0.89999999999999947,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000013,0.89999999999999991],"base":[0,0,0,0,0,0,0,0,0,0],"x":[4415,1901,1175,1104,1074,944,933,918,828,743],"y":[10,9,8,7,6,5,4,3,2,1],"text":["Role: Université Paris 1 Panthéon-Sorbonne (1971-....) <br> Number of edges: 4415","Role: Université Paris Nanterre <br> Number of edges: 1901","Role: Université de Montpellier I (1970-2014) <br> Number of edges: 1175","Role: Université Paris Dauphine-PSL (1968-....) <br> Number of edges: 1104","Role: Université de Grenoble (1339-1970). Faculté de droit et des sciences économiques (1896-1970) <br> Number of edges: 1074","Role: Université des sciences sociales (Grenoble ; 1970-1990) <br> Number of edges: 944","Role: Université de Paris (1896-1968) <br> Number of edges: 933","Role: Université Toulouse 1 Capitole (1970-2022) <br> Number of edges: 918","Role: École des hautes études en sciences sociales (Paris ; 1975-....) <br> Number of edges: 828","Role: Université de Paris (1896-1968). Faculté de droit et des sciences économiques <br> Number of edges: 743"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":548.67579908675816},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-220.75,4635.75],"tickmode":"array","ticktext":["0","1000","2000","3000","4000"],"tickvals":[0,1000,2000,3000,4000],"categoryorder":"array","categoryarray":["0","1000","2000","3000","4000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of edges","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,10.6],"tickmode":"array","ticktext":["Université de Paris (1896-1968). Faculté de droit et des sciences économiques","École des hautes études en sciences sociales (Paris ; 1975-....)","Université Toulouse 1 Capitole (1970-2022)","Université de Paris (1896-1968)","Université des sciences sociales (Grenoble ; 1970-1990)","Université de Grenoble (1339-1970). Faculté de droit et des sciences économiques (1896-1970)","Université Paris Dauphine-PSL (1968-....)","Université de Montpellier I (1970-2014)","Université Paris Nanterre","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"tickvals":[1,2,3,4,5,6.0000000000000009,7,8,9,10],"categoryorder":"array","categoryarray":["Université de Paris (1896-1968). Faculté de droit et des sciences économiques","École des hautes études en sciences sociales (Paris ; 1975-....)","Université Toulouse 1 Capitole (1970-2022)","Université de Paris (1896-1968)","Université des sciences sociales (Grenoble ; 1970-1990)","Université de Grenoble (1339-1970). Faculté de droit et des sciences économiques (1896-1970)","Université Paris Dauphine-PSL (1968-....)","Université de Montpellier I (1970-2014)","Université Paris Nanterre","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"ec35d50987f9c":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"ec35d50987f9c","visdat":{"ec35d50987f9c":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 5: Top role

</div>

</div>

## Institutions

The thesis institution table contains 1790 institutions. Institutions
are the universities, laboratories, doctoral schools, and other
institutions associated with the theses.

The thesis institution table contains 19 variables. It consists of two
core variables:

- `entity_id`: the unique identifier of the entity (here the
  institution).
- `entity_name`: the name of the entity.

The other variables are additional information on the institution
provided by the IdRef database:

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

<a href="#tbl-institution" class="quarto-xref">Table 3</a> shows a
sample of the thesis institution table.

<div id="tbl-institution">

Table 3: Sample of the thesis institution table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-e694db0ccc27d36a2a87" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-e694db0ccc27d36a2a87">{"x":{"filter":"none","vertical":false,"data":[["temp_thesefr_institution_100575","temp_thesefr_institution_100254","temp_sudoc_institution_843966","027309320","temp_sudoc_institution_131016"],["Laboratoire dynamiques sociales et recomposition des espaces","Centre d'Économie et de Management de l'Océan Indien / CEMOI","Caen","École polytechnique (Palaiseau, Essonne ; 1795-....)","Lausanne"],[[null],[null],[null],[null],[null]],[null,null,null,"https://www.idref.fr/027309320.rdf",null],[null,null,null,["École impériale polytechnique","École polytechnique (Paris)","École polytechnique (France)","École royale polytechnique (Paris)","Ecole impériale polytechnique (Paris)"],null],[null,null,null,"1795",null],[null,null,null,null,null],[null,null,null,"c(\"L’École polytechnique, fondée en 1795, est u...",null],[null,null,null,["026375419","081371039"],null],[null,null,null,["École royale du génie de Mézières","École centrale des travaux publics"],null],[null,null,null,["152048774","028635442"],null],[null,null,null,[],null],[null,null,null,[],null],[null,null,null,[],null],[null,null,null,[],null],[null,null,null,["Université Paris-Saclay","Institut polytechnique de Paris"],null],[null,null,null,["188120777","238327159"],null],[null,null,null,["https://data.hal.science/structure/300340#foaf:Organization","https://ror.org/05hy3tk52#foaf:Organization","http://isni.org/isni/0000000121581279","http://data.bnf.fr/ark:/12148/cb11863505r#foaf:Organization","http://viaf.org/viaf/130890647","https://fr.wikipedia.org/wiki/École_polytechnique_(France)"],null],[null,null,null,"France",null]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>old_id<\/th>\n      <th>url<\/th>\n      <th>other_labels<\/th>\n      <th>date_of_birth<\/th>\n      <th>date_of_death<\/th>\n      <th>information<\/th>\n      <th>replaced_idref<\/th>\n      <th>predecessor<\/th>\n      <th>predecessor_idref<\/th>\n      <th>successor<\/th>\n      <th>successor_idref<\/th>\n      <th>subordinated<\/th>\n      <th>subordinated_idref<\/th>\n      <th>unit_of<\/th>\n      <th>unit_of_idref<\/th>\n      <th>other_link<\/th>\n      <th>country_name<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"old_id","targets":2},{"name":"url","targets":3},{"name":"other_labels","targets":4},{"name":"date_of_birth","targets":5},{"name":"date_of_death","targets":6},{"name":"information","targets":7},{"name":"replaced_idref","targets":8},{"name":"predecessor","targets":9},{"name":"predecessor_idref","targets":10},{"name":"successor","targets":11},{"name":"successor_idref","targets":12},{"name":"subordinated","targets":13},{"name":"subordinated_idref","targets":14},{"name":"unit_of","targets":15},{"name":"unit_of_idref","targets":16},{"name":"other_link","targets":17},{"name":"country_name","targets":18}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

## Individuals

The thesis person table contains 14 variables. The four core variables
are:

- `entity_id`: the unique identifier of the individual.
- `entity_name`: the name of the individual.
- `entity_firstname`: the first name of the individual.
- `gender`: the gender of the individual according to the IdRef
  database.
- `gender_expanded`: the gender of the individual according to the IdRef
  database augmented for missing values with the French census data (see
  details in <a href="#sec-cleaning-institutions"
  class="quarto-xref">Section 3.4.5</a>).

The other variables are additional information on the individual
provided by the IdRef database:

- `birth`: the birth date of the individual.
- `country`: the country of the individual.
- `info`: additional information on the individual.
- `organization`: the organization of the individual.
- `last_date_org`: the last date of the organization.
- `start_date_org`: the start date of the organization.
- `end_date_org`: the end date of the organization.
- `other_link`: other links of the individual.
- `country_name`: the country name of the individual.
- `homonym_of`: the identifier of the homonyms in the database.

<a href="#tbl-person" class="quarto-xref">Table 4</a> shows a sample of
the thesis metadata table.

<div id="tbl-person">

Table 4: Sample of the thesis person table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-82f7f5ded62ae7944755" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-82f7f5ded62ae7944755">{"x":{"filter":"none","vertical":false,"data":[["M.","Udo","Madeleine De","Tristan-Pierre","Luc"],["203155742","229361544","270971742","071359877","157927547"],["Adam","Broll","Bryas","Maury","Paugam"],["male","male","female","male",null],["male","male","female","male","male"],[null,"19XX","1889","19XX","1985"],["France",null,"France","France","France"],["Auteur d'une thèse en Sciences économiques à Paris 1 en 2021","Auteur d'une thèse en Sciences Economiques Dauphine à Université Paris sciences et lettres en 2022","Professeur d'économie à Paris 1 (en 2001)","Titulaire d'un doctorat en droit","Haut magistrat, à la fois érudit local, poète et historien."],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[["http://viaf.org/viaf/216150565767206252781"],["http://isni.org/isni/0000000350321702","http://viaf.org/viaf/203941903"],["http://isni.org/isni/0000000049933849","http://data.bnf.fr/ark:/12148/cb11170681d#foaf:Person","https://viaf.org/viaf/68841589"],["http://isni.org/isni/0000000002396767","http://data.bnf.fr/ark:/12148/cb15803299d#foaf:Person","http://viaf.org/viaf/61883463","https://www.persee.fr/authority/1580214"],["https://orcid.org/0000-0002-0640-1775","http://isni.org/isni/0000000390835134","http://data.bnf.fr/ark:/12148/cb16933263b#foaf:Person","http://viaf.org/viaf/284487400"]],[[null],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_firstname<\/th>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>gender<\/th>\n      <th>gender_expanded<\/th>\n      <th>birth<\/th>\n      <th>country_name<\/th>\n      <th>info<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_firstname","targets":0},{"name":"entity_id","targets":1},{"name":"entity_name","targets":2},{"name":"gender","targets":3},{"name":"gender_expanded","targets":4},{"name":"birth","targets":5},{"name":"country_name","targets":6},{"name":"info","targets":7},{"name":"organization","targets":8},{"name":"last_date_org","targets":9},{"name":"start_date_org","targets":10},{"name":"end_date_org","targets":11},{"name":"other_link","targets":12},{"name":"homonym_of","targets":13}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Gender

<div id="fig-person_genre">

<div class="plotly html-widget html-fill-item" id="htmlwidget-a51fc142cc8a45db7cf5" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-a51fc142cc8a45db7cf5">{"x":{"data":[{"orientation":"v","width":[0.90000000000000013,0.89999999999999991,0.90000000000000036],"base":[0,0,0],"x":[2,1,3],"y":[70.515007440206148,23.775995354407868,5.7089972053859839],"text":["Gender: male <br> Number of theses: 19429 <br> % : 70.52","Gender: female <br> Number of theses: 6551 <br> % : 23.78","Gender: Unknown <br> Number of theses: 1573 <br> % : 5.71"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":22.648401826484022},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,3.6000000000000001],"tickmode":"array","ticktext":["female","male","Unknown"],"tickvals":[1,2,3],"categoryorder":"array","categoryarray":["female","male","Unknown"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"gender_expanded","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-3.5257503720103074,74.040757812216455],"tickmode":"array","ticktext":["0","20","40","60"],"tickvals":[0,20,40,59.999999999999993],"categoryorder":"array","categoryarray":["0","20","40","60"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"ec35d29c8cfa3":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"ec35d29c8cfa3","visdat":{"ec35d29c8cfa3":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


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

The data collection process is divided into two main steps:

- **Scraping:** The first step consists of scraping data from the three
  main sources: Theses.fr, SUDoc, and IdRef.
- **Cleaning:** The second step involves cleaning the raw data files to
  create the final database.

We focus here on a general presentation, focusing the methodological
choices we made.

## General presentation

<div class="grViz html-widget html-fill-item" id="htmlwidget-79e16d3a4a119f399d48" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-79e16d3a4a119f399d48">{"x":{"diagram":"\ndigraph project_dag {\n graph [layout = dot, rankdir = TB]\n \n # Define nodes\n scraping_sudoc_id [label = \"scraping_sudoc_id.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_id.R\"]\n scraping_sudoc_api [label = \"scraping_sudoc_api.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_sudoc_api.R\"]\n cleaning_sudoc [label = \"cleaning_sudoc.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_sudoc.R\"]\n downloading_theses_fr [label = \"downloading_theses_fr.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/downloading_theses_fr.R\"]\n cleaning_thesesfr [label = \"cleaning_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_thesesfr.R\"]\n merging_database [label = \"merging_sudoc_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/merging_sudoc_thesesfr.R\"]\n idref_institutions [label = \"scraping_idref_institution.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_institution.R\"]\n idref_persons [label = \"scraping_idref_person.R\", shape = box, style = filled, fillcolor = lightblue, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/scraping_idref_person.R\"]\n cleaning_metadata [label = \"cleaning_thesis_metada.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_thesis_metada.R\"]\n cleaning_institutions [label = \"cleaning_institutions.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_institutions.R\"]\n cleaning_persons [label = \"cleaning_persons.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_persons.R\"]\n cleaning_edges [label = \"cleaning_edges.R\", shape = box, style = filled, fillcolor = lightyellow, URL = \"https://github.com/tdelcey/becoming_economists/blob/main/FR/R/cleaning_edges.R\"]\n \n # Define edges\n scraping_sudoc_id -> scraping_sudoc_api\n scraping_sudoc_api -> cleaning_sudoc \n downloading_theses_fr -> cleaning_thesesfr\n cleaning_sudoc -> merging_database\n cleaning_thesesfr -> merging_database\n merging_database -> idref_institutions\n merging_database -> idref_persons\n merging_database -> cleaning_metadata\n idref_institutions -> cleaning_institutions\n idref_persons -> cleaning_persons\n cleaning_metadata -> cleaning_edges\n cleaning_institutions -> cleaning_edges\n cleaning_persons -> cleaning_edges\n}\n","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

## Scraping

The data used in this project comes from three mains sources:

- **Theses.fr:** <https://theses.fr/>
- **SUDoc:** <https://www.sudoc.fr/>
- **IdRef:** <https://www.idref.fr/>

These sources are the result of the work of the
[ABES](https://abes.fr/l-abes/presentation/) (l’Agence bibliographique
de l’enseignement supérieur) who produced metadata and APIs regarding
research and superior education. The data of the three sources
mentionned above are under the [Etabab “Open
Licence”](https://www.etalab.gouv.fr/licence-ouverte-open-licence/).[^2]

- [Theses.fr](https://theses.fr/) is a comprehensive repository for PhD
  dissertations defended in French institutions since 1985.[^3] It
  includes metadata such as the title of the dissertation, author, date
  of defense, institution, supervisor, abstract, etc.. The database
  covers a wide range of disciplines, providing access, in some cases,
  to digital theses.

- [SUDoc](https://www.SUDoc%20.fr/) stands for Système Universitaire de
  Documentation. It is a union catalog that includes references to
  various documents held in French academic and research libraries. It
  covers books, journal articles, dissertations, and other academic
  works. The SUDoc database includes metadata like title, author,
  publication date, and library locations where the documents can be
  found. It’s a key resource for academic research in France, providing
  a broad overview of available scholarly materials. Regarding PhD, it
  allows to find dissertations defended before 1985, and to recover
  relevant metadata.

- [IdRef](https://www.idref.fr/) stands for Identifiants et Référentiels
  pour l’Enseignement supérieur et la Recherche. It is a database
  focused on managing and standardizing the names and identifiers of
  authors and other contributors to academic and research works. It
  provides authority control for names used in academic cataloging,
  ensuring consistency and aiding in accurate attribution of works.
  IdRef is used in conjunction with SUDoc and other databases to support
  the management of bibliographic data in the French higher education
  and research sectors. In our project, it allows us to find additional
  data on individuals and institutions.

## Data collection

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

### SUDoc

We systematically collect metadata on French dissertations archived in
the [SUDoc](https://www.sudoc.fr/) database, focusing on theses in
economics through two distinct query strategies:

- First query: We search for dissertations with a term starting with
  “econo” in the “Note de Thèse” field, which denotes the thesis
  discipline. This keyword captures terms like “économie” or
  “Economique” since SUDoc ’s search function is case-insensitive and
  ignores accents. The time frame is limited to 1900–1985, as
  dissertations from later years are systematically cataloged in
  [Theses.fr](https://theses.fr/). [Here is the
  query](https://www.sudoc.abes.fr/cbs//DB=2.1/SET=28/TTL=10/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=econo*&ACT1=-&IKT1=63&TRM1=&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=4&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=fr&ADI_JVU=1900-1985&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+),
  allowing to retrieve thesis records.

- Second query: We search for dissertations where “droit” (law) is
  specified in the “Note de Thèse” field, and where a term starting with
  “econo” appears in the title. This search is limited to 1900-1968 to
  capture dissertations classified as law theses before 1968 that likely
  focus on economics. [Here is the
  query](https://www.sudoc.abes.fr/cbs//DB=2.1/SET=31/TTL=1/CMD?ACT=SRCHM&MATCFILTER=Y&MATCSET=Y&NOSCAN=Y&PARSE_MNEMONICS=N&PARSE_OPWORDS=N&PARSE_OLDSETS=N&IMPLAND=Y&ACT0=SRCHA&screen_mode=Recherche&IKT0=63&TRM0=droit&ACT1=*&IKT1=4&TRM1=econo*&ACT2=%2B&IKT2=63&TRM2=&ACT3=%2B&IKT3=1016&TRM3=&SRT=YOP&ADI_TAA=&ADI_LND=fr&ADI_JVU=1900-1968&ADI_MAT=Y&ILN_DEP_BIB=DEP&NOT_USED_ADI_BIB=+),
  allowing to retrieve thesis records.

The
[scraping_sudoc_id.R](../scripts/scraping_scripts/FR/scraping_SUDoc%20_id.R)
collects the thesis records URLs. Then, the
[scraping_sudoc_api.R](../scripts/scraping_scripts/FR/scraping_SUDoc%20_api.R)
allows to query the [SUDoc
API](https://api.gouv.fr/documentation/api-SUDoc) to retrieve structured
metadata for each thesis, including information such as title, author,
defence date, abstract, supervisor and other relevant details. These
metadata are stored in an `.xml` file, which we then parse to extract
the relevant information. The `.xml` is structured according to “tags”
and “codes” that are explained
[here](https://documentation.abes.fr/sudoc/manuels/administration/aidewebservices/index.html#SUDoc%20MarcXML).

> [!NOTE]
>
> [scraping_sudoc_api.R](../scripts/scraping_scripts/FR/scraping_SUDoc%20_api.R)
> used parallel processing to speed up the data collection process. The
> script is optimized to handle errors and exceptions, ensuring robust
> data collection. It can be easily adapted to other queries.

### IdRef

We use the idref identifiers, collected in sudoc and these.fr sources,
to retrieve additional information on individuals (e.g., date of birth,
nationality, gender, last known institutions) and institutions (e.g.,
institutions preferred and alternate names, years of existence). The
[scraping_idref_person.R](../scripts/scraping_scripts/FR/scraping_idref_person.R)
and
[scraping_idref_institution.R](../scripts/scraping_scripts/FR/scraping_idref_institution.R)
scripts use the idref identifiers as input to query those pieces of
information in the [IdRef API](https://www.idref.fr/) and organized them
in structured tables.

## Cleaning

Our data-cleaning approach focuses on ensuring consistency and quality
while preserving the integrity of the original data. We relies on two
principles to build this database:

- **no data transformation**: our work is mainly a data collection,
  categorization, and cleaning work. We tried as less as possible to
  transform the data or limit the transformation to minimal and
  impactless transformation. To put it differently, we did not touch the
  cell values of the original data, mainly the encoded variables.

- **disambiguation**: we tried to disambiguate the entities (thesis,
  authors, etc.) as much as possible. Disambiguation refers to the
  process of identifying and distinguishing between different entities
  that may have the same name. We tried to provide a unique identifier
  for each entity. The identifiers of the Agence Bibliographique de
  l’Enseignement Supérieur (ABSES) was the main source of unique
  identifiers (idref, nnt, etc.). When their identifiers were not
  available or disambiguaion was not possible, we created our own
  temporary unique identifiers.

The first step is to clean the data from the raw sources and harmonize
the data structure to facilitate the merging of the two datasets. The
output of this step is the three database dividing information into four
tables: metadata, person, institution and their relationships.

### SUDoc

The cleaning process for SUDPC data in
[1_FR_sudoc_cleaning.R](./scripts/cleaning_scripts/FR/1_FR_SUDoc%20_cleaning.R)
has two main objectives: first, it is managing identifiers duplicates.
Second, we transform raw sources from sudoc to a structured dataset. We
evaluate the quality of data and then we structure the raw source to
ensure consistency and the future merging with theses.fr data.

#### Duplicate Management

The script manages identifiers duplicates, which fall into two
categories:

- True duplicates: These occur when the same thesis is listed multiple
  times with identical identifiers and authors but differing defence
  dates. The process retains the most recent record as it is more likely
  to reflect the correct metadata.
- False duplicates: These occur when the same identifier is shared by
  different authors, often due to data entry errors. To resolve these,
  unique identifiers are created by appending a counter to the nnt,
  ensuring data integrity without introducing ambiguity.

#### Data Standardization

Most of the variables of the final data are created here from the raw
data. Two variables deserves a particular attention:

- `year_defence`: For some theses, we retrieve multiples different dates
  of defence. We choose the oldest date for theses with multiple dates,
  as the earliest date is more likely to reflect an unfinished thesis.
  We also manually check when the two dates were not close to each
  other. We also clean anomalous dates outside the query range
  (1899–1985).
- `type`: Another important variable created here is the `type` of the
  thesis, since the French systems had various kinds of thesis between
  the 1960s and the 1984 reform. We use different raw sources of sudoc
  metadata to spot the type of thesis. Thesis types are recoded into
  consistent categories (e.g., “Thèse d’État”, “Thèse de 3e cycle”).
  Records that are not doctoral theses (e.g., master’s dissertations)
  are filtered out to focus exclusively on relevant entries. Note that
  if we cannot spot a particular type of thesis, the variable takes the
  generic value “Thèse”. Language codes are also standardized to align
  with ISO conventions and ensure compatibility with these.fr data.

> [!WARNING]
>
> The value “Thèse” of the `Type` variable is default value when we
> cannot spot a particular type of thesis.

The final dataset is split into the four tables that make up the
relational database (metadata, edge, person, and institution). Temporary
IDs are generated for entities without official identifiers to
facilitate later identification and disambiguation.

### Theses.fr

The
[2_FR_thesesfr_cleaning.R](./scripts/cleaning_scripts/FR/2_FR_thesesfr_cleaning.R)
is dedicated to cleaning and structuring metadata for theses related to
economics extracted from the Theses.fr database. The strategy is the
same as for SUDoc: checking the quality of data and transforming raw
sources into a structured dataset and prepare the dataset for
integration with SUDoc data. The only particular point in this script is
that we had to remove some theses that were not related to economics but
were wrongly categorized as such in our query. We then proceed to the
same steps as for SUDoc data, categorizing and harmonizing variables, to
prepare the merging. Again, temporary IDs are generated for entities
without official identifiers to facilitate later identification and
disambiguation.

### Merging

The
[3_FR_merging_database.R](./scripts/cleaning_scripts/FR/3_FR_merging_database.R)
merge the set of tables created from the SUDoc and Theses.fr source.
There is no particular difficulty in this script. We do not handle
duplicates in this script, as we will do it in the next steps.

### Metadata

The
[4_FR_cleaning_thesis_metadata.R](./scripts/cleaning_scripts/FR/4_FR_cleaning_thesis_metadata.R)
script is designed to clean metadata information. Sudoc and these.fr
sources gathered information inputted by various local institutions and
individuals, leading to inconsistencies and errors. The script addresses
several key challenges:

- **Language detection:** Language consistency is verified across the
  metadata by leveraging both the
  [cld3](https://docs.ropensci.org/cld3/reference/cld3.html) \[@R-cld3\]
  and
  [fastText](https://mlampros.github.io/fastText/articles/language_identification.html)
  \[@fastText2016b\] models for robust identification. Language
  consistency is verified across the metadata. Titles and abstracts are
  checked to ensure that French and English columns contain text
  matching their intended language. Discrepancies are resolved by
  reassigning text to the correct fields. For cases where either French
  or English titles and abstracts are missing, the script employs
  auxiliary columns originally scraped (`title_other` and
  `abstract_other`) to fill gaps when relevant. Titles and abstracts
  written in full uppercase are transformed into sentence case to
  enhance readability. Placeholder text and irrelevant symbols are also
  removed, with uninformative entries replaced by missing values (NA).
- **Duplicate:** We found many duplicate thesis records in the metadata.
  It is explained both by the fact that the same thesis can be
  registered in both Sudoc and Theses.fr and by the fact that the same
  thesis can be registered several times in the same database by
  different institutions. We manage duplicates by developping a
  duplicate detection algorithm. The core of the detection process
  involves grouping titles by authors and comparing all possible title
  pairs within each group. The Optimal String Alignment (OSA) distance
  is used as the primary metric for this comparison. OSA is a robust
  variant of the Levenshtein distance that estimate the number of
  actions necessary to match two strings (character insertions,
  deletions, substitutions, and adjacent character transpositions). The
  less the distance is, the more the two strings are similar. We also
  use a normalized OSA distance taking into account the titles lengths.
  Each potential duplicates is checked by eye and we ensured to capture
  most true positives and to avoid any false positives. Finally,
  consistently with the general approach of the project, we did not
  remove the duplicates but we flagged them in a new column
  `duplicates`.
  <a href="#tbl-duplicates" class="quarto-xref">Table 5</a> shows an
  example of two duplicates.

<div id="tbl-duplicates">

Table 5: Example of two duplicates

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-19331d681765854a1445" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-19331d681765854a1445">{"x":{"filter":"none","vertical":false,"data":[["1962REN0G002","temp_sudoc_thesis_204701"],[1962,1962],["fr","fr"],[null,null],["L'Industrie du granit en Bretagne","L'industrie du granit en Bretagne"],[null,null],[null,null],[null,null],[null,null],[null,null],["Sciences économiques","Sciences économiques"],[null,null],["Thèse","Thèse"],["France","France"],["https://www.sudoc.fr/064184188.xml","https://www.sudoc.fr/072911255.xml"],[["temp_sudoc_thesis_204701","temp_sudoc_thesis_114312"],["1962REN0G002","temp_sudoc_thesis_114312"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>thesis_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"thesis_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

> [!NOTE]
>
> Our script can handle duplicate manually. If you spot an undetected
> duplicate, please [let us
> know](https://github.com/tdelcey/becoming_economist).

### Institutions

The
[5_FR_cleaning_institution.R](./scripts/cleaning_scripts/FR/4_FR_cleaning_institution.R)
script aims to standardize and improve the quality of institution data.

So far, any institution names mentioned in the metadata have been
extracted and stored in a separate table. This script focuses on
cleaning and standardizing these names to ensure consistency and
accuracy in the dataset. Our goal is to replace temporary institution
identifiers (id_temp) we have created in
[3_FR_merging_database.R](./scripts/cleaning_scripts/FR/3_FR_merging_database.R)
with the official IdRef identifiers (id_ref) to ensure consistency and
accuracy in the dataset. This replacement relies on matching the
institution names and thesis defense dates. The process accounts for
historical changes in institutional structures (e.g., the splitting of
the University of Paris after 1968), ensuring that ambiguous cases are
handled carefully.

The core of the script is a manually defined table that associates
regular expressions (regex) for institution names with their
corresponding idref identifiers. This table also includes the dates of
creation (`date_of_birth`) and dissolution (`date_of_death`) of
institutions to set clear boundaries for replacement. For instance, if
an institution’s name matches “University of Paris” and the thesis was
defended before 1970, the identifier is replaced with that of the
historic University of Paris, as it was the only university in Paris at
the time.

> [!WARNING]
>
> We kept the temporary identifier and did not assign an idref
> institution names when we were enable to resolve the ambiguity. For
> instance, we kept the temporary identifier if the thesis is defended
> in 2022 and the institution name is ambigous (for instance,
> “Université de Paris” could be the University of Paris I
> Panthéon-Sorbonne or the University of Paris II Panthéon-Assas).

### Individuals

The
[6_FR_cleaning_persons.R](./scripts/cleaning_scripts/FR/5_FR_cleaning_persons.R)
script aims to standardize and improve the quality of person data.

First, this script adds information on individuals from the
idref_person_table. When a name entity is associated to an idref
identifier, the script adds supplementary information on the person
provided by the IdRef database (organization, birth date, relevant links
such as wikipedia pages, etc.). We also replace the raw names (found in
sudoc or these.fr) by the names provided by idref source.

Second, we try to clean and unify person identifiers. We know that the
same person can have slightly different names (e.g., “Jean A. Dupont”
and “Jean Dupont”) or that the same person can have the same names but
different identifiers. It is particularly important for person present
in both SUDoc and Theses.fr databases. For instance, the same person can
be the author of a thesis in SUDoc in 1983 and a member of the jury of
thesis found in these.fr in 1999. Contrary to institution tables,
however, we are enable to disambiguate person identifiers because of the
risk of homonyms. In other words, if two persons have the same string
names, we cannot be sure that they are the same person. Two authors of
two different theses could have the same name or it could be the same
person doing two theses. We create a new column `homonym_of` that group
potential homonyms. For each person, the variable `homonym_of` gives the
list of person identifiers that are her homonyms.

> [!WARNING]
>
> There is an important risk that a same person has different
> identifiers in the database. Potential candidates can be spotted by
> the `homonym_of` variable. Currently, our script is not able to
> disambiguate the homonyms manually. This is one feature that we need
> to add in the future.

# Improvements

[^1]: While focusing on France, the database and his documentation are
    in english. It is because this project is part of a broader
    initiative entitled *Becoming an economists* that aim at building a
    comprehensive database of Ph.D. in economics accross the world.

[^2]: See the English description of the licence
    [here](https://www.etalab.gouv.fr/wp-content/uploads/2018/11/open-licence.pdf).

[^3]: This corresponds to the reform of French PhD and the
    implementation of the “new regime”.
