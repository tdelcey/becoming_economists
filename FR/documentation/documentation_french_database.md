# Documentation - Becoming an economist: France
Thomas Delcey, Aurelien Goutsmedt
2024-11-30

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
  - [Scrapping](#scrapping)
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

Our database is also under an open licence (**WHICH ONE**). It can be
accessed and used freely by anyone. The data is stored in the [XXX
repository](https://osf.io/). Note that we focus on Ph.D. in economics
and we queries our sources by the field of the thesis. However, the
scipts have been developped with a relative flexibility and can be
adapted to other queries, for instance, for other disciplines.

If you use our data or our scripts, please cite us using the following
bib reference:

``` bibtex
@article{delcey2022becoming,
  title={Becoming an Economist: A Database of French Economics PhDs},
  author={Goutsmedt, Aurelien, Delcey, Thomas},
  journal={Working Paper},
  year={2024}
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

<div class="datatables html-widget html-fill-item" id="htmlwidget-72a6d7f7027ef130493e" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-72a6d7f7027ef130493e">{"x":{"filter":"none","vertical":false,"data":[["temp_sudoc_thesis_106762","1983PA010051","2020STRAB011","1997PA131026","1971PA090105","temp_sudoc_thesis_862063","2014BORD0387","1997DUNK0011","temp_sudoc_thesis_194638","1985CLF1D041","temp_sudoc_thesis_499247","2015PA010005","temp_sudoc_thesis_255138","1925NAFD0010","temp_sudoc_thesis_400506","1984NICE0003","1999REN10006","2002PA082057","2013TOU10025","temp_sudoc_thesis_597306","2019PA01E017","2021AMIE0049","2011AIX24020","temp_sudoc_thesis_201986","1991PA090008","2013PA040098","2001DIJOE002","2022LIMO0143","2017USPCC047","2010BOR40021","2003TOU10036","1991ORLE0002","temp_sudoc_thesis_418791","temp_sudoc_thesis_432477","temp_sudoc_thesis_921342","temp_sudoc_thesis_458798","temp_sudoc_thesis_139451","2007PAUU2002","2023NANU3013","temp_sudoc_thesis_832227","temp_sudoc_thesis_969686","1990PA100093","2016AIXM2026","2022CYUN1116","temp_sudoc_thesis_735857","2018PA01E041","2001PA111014","2017PSLED022","1981PA100060","1996EHES0062"],[1909,1983,2020,1997,1971,1972,2014,1997,1975,1985,1954,2015,1984,1925,1912,1984,1999,2002,2013,1973,2019,2021,2011,1974,1991,2013,2001,2022,2017,2010,2003,1991,1975,1947,1985,1982,1969,2007,2023,1950,1985,1990,2016,2022,1966,2018,2001,2017,1981,1996],["fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","en","fr","fr","fr","fr","fr","fr","en","en","fr","fr","fr","fr","fr","fr","fr","fr","fr","en","fr","fr","fr","fr","en","fr","en","fr","fr","fr","fr"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Le bilan au point de vue comptable et juridique","L'économie française et la spécialisation inter...","De Mill à Kant : l'éthique utilitariste de Henr...","L'intégration financière internationale en pers...","Les effets des changements technologiques sur l...","Le marché des huiles essentielles de lavande et...","Analyse théorique de la gouvernance et du dével...","Appropriabilité de l'information scientifique e...","L'initiation économique des adultes","Relance autonome ou relance harmonisée face à l...","Les réglements successoraux depuis les réformes...","Le rôle du pétrole dans le développement économ...","Politiques d'habitat en Algérie\nincohérences éc...","Les criées municipales en province\ncontribution...","La fraude en matière d'enregistrement et de mut...","Essai d'interprétation des facteurs de producti...","Chocs asymétriques, rigidités salariales et pro...","De l'impact de l'information sur la croissance ...","Essais sur l'économie de l'innovation et droits...","La Répartition des médecins libéraux français s...","Choix, préférences et bien-être","Le Leadership institutionnel, vers un leadershi...","La nature des investissements en capital humain...","La décision financière de la grande firme","Optimalité, crédibilité, coordination : essais ...","« Histoire des politiques sociales d’une grande...","Le panier de biens et de services de santé : un...","Essais sur la confiance et les résultats financ...","Les complexités de la réforme du système d'irri...","L'indépendance financière des Pays en développe...","Consommation, persistance des habitudes et effe...","Dynamique de l'économie mondiale et intégration...","Les problèmes de la production porcine en France","Les Idées économiques dans l'Encyclopédie","Prevision comportement des decideurs publics et...","Planification de developpement de l'economie gr...","Essai sur la signification politique du cinéma\n...","Numérisation des biens culturels : piratage et ...","Sur-éducation et trajectoires sur le marché du ...","Les Doctrines économiques en Espagne sous le de...","L'integration economique et politique de la tur...","Théorie du cycle de vie, croissance et endettement","Les implications du processus de libéralisation...","Trois Essais en Economie Politique en Afrique S...","Le Coût des mesures de sécurité dans les secteu...","Les inégalités spatiales en France : une analys...","Les politiques d'appui au \"secteur informel\" : ...","Retraite et risque financier","Dysfonctionnements des processus d'informatisation","La redefinition de la tarification de l'electri..."],[null,null,"From Mill to Kant : the utilitarian ethics of H...","The international financial integration in pers...",null,null,"Theoretical Analysis of Governance and Sustaina...","Appropriability of scientific and technical inf...",null,null,null,"The role of petroleum in economic development a...",null,null,null,null,null,"From the impact of information on agricultural ...","Essays on the economics of innovation and intel...",null,"Choices, Preferences, and Welfare","Institutional leadership, towards institutional...","Human capital investments and the design of  la...",null,"Optimality, credibility, coordination. Essays i...","The history of social strategies in a big champ...","A managerial approach to the \"basket of health ...","Essays on trust and financial outcomes","The reform complexities of the irrigation water...","The financial independence of the developing co...","Consumption, habit persistence and monetary pol...","The dynamics of world economy and regional inte...",null,null,null,null,null,null,"Overeducation and labour market trajectories",null,null,"Life cycle theory, growth and indebtedness","Implications of the interest rate liberalizatio...","Three Essays on Political Economy in Sub-Sahara...",null,"French spatial inequalities in an historical pe...","Supporting politics to the informal sector : so...","Pension Plan Risk",null,"The redefinition of electricity pricing in cong..."],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],[null,null,"Notre travail doctoral comporte deux volets dép...","A partir d'une analyse de l'integration financi...",null,null,"Les acteurs institutionnels du développement ém...","L'information scientifique et technique constit...",null,"A l'heure où les Politiques de relance autonome...",null,"Cette thèse a pour objectif d’étudier l’impact ...",null,null,null,null,"L'objet de la thèse est d'évaluer les coûts en ...","La démarche vise à montrer que l'information en...","L'innovation a reçu beaucoup d'attention de la ...",null,"Les préférences révélées lient choix, préférenc...","Pionnier de la renaissance moderne dans le mond...","L'éducation est un investissement qui trouve so...",null,"L'enjeu de la première partie de la thèse est m...","C’est à travers une succession de crises rappro...","Le préambule de la Constitution de 1946 consacr...","Cette thèse vise à évaluer l'impact des institu...","La gestion de l‘eau d’irrigation en Egypte repo...","La connaissance de la nature, de l'évolution et...","Cette thèse a pour ambition d'améliorer la comp...","La thèse étudie la relation entre les transform...",null,null,null,null,"La thèse est divisée en deux parties : 1- Agoni...","Le développement de la micro-informatique et la...","La sur-éducation correspond à la situation d'in...",null,null,null,"La libéralisation des taux d’intérêt est une ét...","Il existe des inégalités de revenu considérable...",null,"Cette thèse a un double objectif. En premier li...",null,"Le premier chapitre examine les caractéristique...",null,"Developpe il y a plus de 45 ans par edf, la ges..."],[null,null,"Our doctoral work has two mutually dependent co...","From an analysis of the international financial...",null,null,"Institutional actors of development use to expr...","Scientific and technical information is an orga...",null,null,null,"This PhD thesis aims at studying the impact of ...",null,null,null,null,null,null,"Innovation has received much attention from eco...",null,"Revealed preferences link choices, preferences,...","A pioneer of the modern renaissance in the Arab...","Education is an investment that has its return ...",null,"The first part of the thesis deals with methodo...","It is throughout a great number of consecutive ...",null,"This thesis aims to evaluate the impact of inst...","The irrigation water sector in Egypt relies on ...","The knowledge of the nature, the evolution and ...","This thesis aims at improving the understanding...","The thesis studies the relationships between th...",null,null,null,null,null,"The development of computerising and the global...","Overeducation is defined as the situation of in...",null,null,null,"Interest rate liberalization is an important st...","There are tremendous income inequalities betwee...",null,"This thesis has a dual purpose. First, it prese...",null,"Chapter one examines the long run statistical c...",null,"Marginal cost pricing theory date since the wol..."],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],["Droit","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques. Sciences sociales du monde rural","Sciences economiques","Sciences économiques. Economie industrielle","Économie","Sciences économiques","Droit","Sciences economiques","Sciences économiques","Droit","Droit","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Économie","Sciences économiques","Sciences économiques. Économie","Sciences économiques","Sciences économiques","Sciences économiques","Histoire économique","Sciences économiques","Sciences economiques","Sciences économiques. Changement social et mutations économiques","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques","Droit","Sciences économiques","Sciences économiques","Sciences politiques","Sciences économiques","Sciences économiques","Droit","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques - EM2PSI","Droit","Économie","Sciences économiques","Sciences économiques","Sciences économiques","Sciences économiques"],[null,null,"oui","non",null,null,"oui","non",null,"non",null,"oui",null,null,null,null,"non","non","non",null,"oui","oui","oui",null,"non","non","non","oui","oui","non","non","non",null,null,null,null,null,"non","oui",null,null,"non","non","non",null,"oui","non","oui",null,"non"],["Thèse","Thèse d'État","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse d'État","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse d'État","Thèse","Thèse d'État","Thèse d'État","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse","Thèse de 3e cycle","Thèse"],["France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France","France"],["https://www.sudoc.fr/047429933.xml","https://www.sudoc.fr/041424662.xml","https://theses.fr/2020STRAB011","https://theses.fr/1997PA131026","https://www.sudoc.fr/197408966.xml","https://www.sudoc.fr/096287411.xml","https://theses.fr/2014BORD0387","https://theses.fr/1997DUNK0011","https://www.sudoc.fr/06508859X.xml","https://theses.fr/1985CLF1D041","https://www.sudoc.fr/048219770.xml","https://theses.fr/2015PA010005","https://www.sudoc.fr/041170024.xml","https://www.sudoc.fr/067607640.xml","https://www.sudoc.fr/023653256.xml","https://www.sudoc.fr/04121529X.xml","https://theses.fr/1999REN10006","https://theses.fr/2002PA082057","https://theses.fr/2013TOU10025","https://www.sudoc.fr/065087720.xml","https://theses.fr/2019PA01E017","https://theses.fr/2021AMIE0049","https://theses.fr/2011AIX24020","https://www.sudoc.fr/006479081.xml","https://theses.fr/1991PA090008","https://theses.fr/2013PA040098","https://theses.fr/2001DIJOE002","https://theses.fr/2022LIMO0143","https://theses.fr/2017USPCC047","https://theses.fr/2010BOR40021","https://theses.fr/2003TOU10036","https://theses.fr/1991ORLE0002","https://www.sudoc.fr/040906884.xml","https://www.sudoc.fr/08438445X.xml","https://www.sudoc.fr/041256662.xml","https://www.sudoc.fr/04113768X.xml","https://www.sudoc.fr/077233212.xml","https://theses.fr/2007PAUU2002","https://theses.fr/2023NANU3013","https://www.sudoc.fr/084384875.xml","https://www.sudoc.fr/041237676.xml","https://theses.fr/1990PA100093","https://theses.fr/2016AIXM2026","https://theses.fr/2022CYUN1116","https://www.sudoc.fr/118816489.xml","https://theses.fr/2018PA01E041","https://theses.fr/2001PA111014","https://theses.fr/2017PSLED022","https://www.sudoc.fr/041068955.xml","https://theses.fr/1996EHES0062"],[[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null],[null]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>these_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"these_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Distribution

<div id="fig-metadata_distribution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-01c319c6e50958c438db" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-01c319c6e50958c438db">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,48,26,32,30,35,45,49,35,50,55,61,55,69,68,85,86,92,134,164,216,270,372,322,395,455,451,510,509,507,514,462,454,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,316,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Number of theses: 5","Defense date: 1900 <br> Number of theses: 31","Defense date: 1901 <br> Number of theses: 37","Defense date: 1902 <br> Number of theses: 27","Defense date: 1903 <br> Number of theses: 40","Defense date: 1904 <br> Number of theses: 34","Defense date: 1905 <br> Number of theses: 45","Defense date: 1906 <br> Number of theses: 38","Defense date: 1907 <br> Number of theses: 48","Defense date: 1908 <br> Number of theses: 44","Defense date: 1909 <br> Number of theses: 51","Defense date: 1910 <br> Number of theses: 65","Defense date: 1911 <br> Number of theses: 38","Defense date: 1912 <br> Number of theses: 71","Defense date: 1913 <br> Number of theses: 29","Defense date: 1914 <br> Number of theses: 30","Defense date: 1915 <br> Number of theses: 8","Defense date: 1916 <br> Number of theses: 6","Defense date: 1917 <br> Number of theses: 12","Defense date: 1918 <br> Number of theses: 11","Defense date: 1919 <br> Number of theses: 25","Defense date: 1920 <br> Number of theses: 52","Defense date: 1921 <br> Number of theses: 46","Defense date: 1922 <br> Number of theses: 69","Defense date: 1923 <br> Number of theses: 72","Defense date: 1924 <br> Number of theses: 70","Defense date: 1925 <br> Number of theses: 61","Defense date: 1926 <br> Number of theses: 54","Defense date: 1927 <br> Number of theses: 62","Defense date: 1928 <br> Number of theses: 38","Defense date: 1929 <br> Number of theses: 40","Defense date: 1930 <br> Number of theses: 29","Defense date: 1931 <br> Number of theses: 45","Defense date: 1932 <br> Number of theses: 42","Defense date: 1933 <br> Number of theses: 47","Defense date: 1934 <br> Number of theses: 37","Defense date: 1935 <br> Number of theses: 48","Defense date: 1936 <br> Number of theses: 45","Defense date: 1937 <br> Number of theses: 37","Defense date: 1938 <br> Number of theses: 40","Defense date: 1939 <br> Number of theses: 53","Defense date: 1940 <br> Number of theses: 22","Defense date: 1941 <br> Number of theses: 29","Defense date: 1942 <br> Number of theses: 35","Defense date: 1943 <br> Number of theses: 30","Defense date: 1944 <br> Number of theses: 33","Defense date: 1945 <br> Number of theses: 29","Defense date: 1946 <br> Number of theses: 29","Defense date: 1947 <br> Number of theses: 45","Defense date: 1948 <br> Number of theses: 35","Defense date: 1949 <br> Number of theses: 33","Defense date: 1950 <br> Number of theses: 44","Defense date: 1951 <br> Number of theses: 41","Defense date: 1952 <br> Number of theses: 36","Defense date: 1953 <br> Number of theses: 30","Defense date: 1954 <br> Number of theses: 48","Defense date: 1955 <br> Number of theses: 26","Defense date: 1956 <br> Number of theses: 32","Defense date: 1957 <br> Number of theses: 30","Defense date: 1958 <br> Number of theses: 35","Defense date: 1959 <br> Number of theses: 45","Defense date: 1960 <br> Number of theses: 49","Defense date: 1961 <br> Number of theses: 35","Defense date: 1962 <br> Number of theses: 50","Defense date: 1963 <br> Number of theses: 55","Defense date: 1964 <br> Number of theses: 61","Defense date: 1965 <br> Number of theses: 55","Defense date: 1966 <br> Number of theses: 69","Defense date: 1967 <br> Number of theses: 68","Defense date: 1968 <br> Number of theses: 85","Defense date: 1969 <br> Number of theses: 86","Defense date: 1970 <br> Number of theses: 92","Defense date: 1971 <br> Number of theses: 134","Defense date: 1972 <br> Number of theses: 164","Defense date: 1973 <br> Number of theses: 216","Defense date: 1974 <br> Number of theses: 270","Defense date: 1975 <br> Number of theses: 372","Defense date: 1976 <br> Number of theses: 322","Defense date: 1977 <br> Number of theses: 395","Defense date: 1978 <br> Number of theses: 455","Defense date: 1979 <br> Number of theses: 451","Defense date: 1980 <br> Number of theses: 510","Defense date: 1981 <br> Number of theses: 509","Defense date: 1982 <br> Number of theses: 507","Defense date: 1983 <br> Number of theses: 514","Defense date: 1984 <br> Number of theses: 462","Defense date: 1985 <br> Number of theses: 454","Defense date: 1986 <br> Number of theses: 341","Defense date: 1987 <br> Number of theses: 315","Defense date: 1988 <br> Number of theses: 253","Defense date: 1989 <br> Number of theses: 212","Defense date: 1990 <br> Number of theses: 180","Defense date: 1991 <br> Number of theses: 208","Defense date: 1992 <br> Number of theses: 275","Defense date: 1993 <br> Number of theses: 264","Defense date: 1994 <br> Number of theses: 292","Defense date: 1995 <br> Number of theses: 256","Defense date: 1996 <br> Number of theses: 296","Defense date: 1997 <br> Number of theses: 372","Defense date: 1998 <br> Number of theses: 338","Defense date: 1999 <br> Number of theses: 323","Defense date: 2000 <br> Number of theses: 427","Defense date: 2001 <br> Number of theses: 345","Defense date: 2002 <br> Number of theses: 316","Defense date: 2003 <br> Number of theses: 340","Defense date: 2004 <br> Number of theses: 316","Defense date: 2005 <br> Number of theses: 312","Defense date: 2006 <br> Number of theses: 296","Defense date: 2007 <br> Number of theses: 350","Defense date: 2008 <br> Number of theses: 361","Defense date: 2009 <br> Number of theses: 363","Defense date: 2010 <br> Number of theses: 397","Defense date: 2011 <br> Number of theses: 405","Defense date: 2012 <br> Number of theses: 367","Defense date: 2013 <br> Number of theses: 394","Defense date: 2014 <br> Number of theses: 361","Defense date: 2015 <br> Number of theses: 373","Defense date: 2016 <br> Number of theses: 392","Defense date: 2017 <br> Number of theses: 360","Defense date: 2018 <br> Number of theses: 353","Defense date: 2019 <br> Number of theses: 339","Defense date: 2020 <br> Number of theses: 310","Defense date: 2021 <br> Number of theses: 351","Defense date: 2022 <br> Number of theses: 308","Defense date: 2023 <br> Number of theses: 129","Defense date: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Distribution of theses by defense date","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Defense date","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"41882b92478e":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"41882b92478e","visdat":{"41882b92478e":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 1: Distribution of theses by defense date

</div>

### Distribution by type of thesis

<div id="fig-metadata_distribution_type">

<div class="plotly html-widget html-fill-item" id="htmlwidget-ea04681b438acfb9de62" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-ea04681b438acfb9de62">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,3,0,1,2,1,3,14,12,11,18,28,31,43,67,64,104,156,281,242,304,390,371,458,485,470,485,436,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,70,29,30,8,6,12,11,25,52,46,68,72,70,61,54,62,38,40,28,45,42,47,37,48,45,37,39,52,22,29,34,30,33,29,29,45,35,33,44,41,36,30,48,26,30,30,32,45,48,33,49,52,47,43,58,50,57,55,49,67,100,112,114,91,80,91,65,80,52,24,37,29,26,234,341,315,253,212,180,208,275,264,292,256,296,372,338,323,427,345,316,340,315,312,296,350,361,363,397,405,367,394,361,373,392,360,353,339,310,351,308,129,0],"text":["Defense date: 1899 <br> Type: Thèse <br> Number of theses: 5","Defense date: 1900 <br> Type: Thèse <br> Number of theses: 31","Defense date: 1901 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1902 <br> Type: Thèse <br> Number of theses: 27","Defense date: 1903 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1904 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1905 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1906 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1907 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1908 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1909 <br> Type: Thèse <br> Number of theses: 51","Defense date: 1910 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1911 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1912 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1913 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1914 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1915 <br> Type: Thèse <br> Number of theses: 8","Defense date: 1916 <br> Type: Thèse <br> Number of theses: 6","Defense date: 1917 <br> Type: Thèse <br> Number of theses: 12","Defense date: 1918 <br> Type: Thèse <br> Number of theses: 11","Defense date: 1919 <br> Type: Thèse <br> Number of theses: 25","Defense date: 1920 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1921 <br> Type: Thèse <br> Number of theses: 46","Defense date: 1922 <br> Type: Thèse <br> Number of theses: 68","Defense date: 1923 <br> Type: Thèse <br> Number of theses: 72","Defense date: 1924 <br> Type: Thèse <br> Number of theses: 70","Defense date: 1925 <br> Type: Thèse <br> Number of theses: 61","Defense date: 1926 <br> Type: Thèse <br> Number of theses: 54","Defense date: 1927 <br> Type: Thèse <br> Number of theses: 62","Defense date: 1928 <br> Type: Thèse <br> Number of theses: 38","Defense date: 1929 <br> Type: Thèse <br> Number of theses: 40","Defense date: 1930 <br> Type: Thèse <br> Number of theses: 28","Defense date: 1931 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1932 <br> Type: Thèse <br> Number of theses: 42","Defense date: 1933 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1934 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1935 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1936 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1937 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1938 <br> Type: Thèse <br> Number of theses: 39","Defense date: 1939 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1940 <br> Type: Thèse <br> Number of theses: 22","Defense date: 1941 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1942 <br> Type: Thèse <br> Number of theses: 34","Defense date: 1943 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1944 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1945 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1946 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1947 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1948 <br> Type: Thèse <br> Number of theses: 35","Defense date: 1949 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1950 <br> Type: Thèse <br> Number of theses: 44","Defense date: 1951 <br> Type: Thèse <br> Number of theses: 41","Defense date: 1952 <br> Type: Thèse <br> Number of theses: 36","Defense date: 1953 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1954 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1955 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1956 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1957 <br> Type: Thèse <br> Number of theses: 30","Defense date: 1958 <br> Type: Thèse <br> Number of theses: 32","Defense date: 1959 <br> Type: Thèse <br> Number of theses: 45","Defense date: 1960 <br> Type: Thèse <br> Number of theses: 48","Defense date: 1961 <br> Type: Thèse <br> Number of theses: 33","Defense date: 1962 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1963 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1964 <br> Type: Thèse <br> Number of theses: 47","Defense date: 1965 <br> Type: Thèse <br> Number of theses: 43","Defense date: 1966 <br> Type: Thèse <br> Number of theses: 58","Defense date: 1967 <br> Type: Thèse <br> Number of theses: 50","Defense date: 1968 <br> Type: Thèse <br> Number of theses: 57","Defense date: 1969 <br> Type: Thèse <br> Number of theses: 55","Defense date: 1970 <br> Type: Thèse <br> Number of theses: 49","Defense date: 1971 <br> Type: Thèse <br> Number of theses: 67","Defense date: 1972 <br> Type: Thèse <br> Number of theses: 100","Defense date: 1973 <br> Type: Thèse <br> Number of theses: 112","Defense date: 1974 <br> Type: Thèse <br> Number of theses: 114","Defense date: 1975 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1976 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1977 <br> Type: Thèse <br> Number of theses: 91","Defense date: 1978 <br> Type: Thèse <br> Number of theses: 65","Defense date: 1979 <br> Type: Thèse <br> Number of theses: 80","Defense date: 1980 <br> Type: Thèse <br> Number of theses: 52","Defense date: 1981 <br> Type: Thèse <br> Number of theses: 24","Defense date: 1982 <br> Type: Thèse <br> Number of theses: 37","Defense date: 1983 <br> Type: Thèse <br> Number of theses: 29","Defense date: 1984 <br> Type: Thèse <br> Number of theses: 26","Defense date: 1985 <br> Type: Thèse <br> Number of theses: 234","Defense date: 1986 <br> Type: Thèse <br> Number of theses: 341","Defense date: 1987 <br> Type: Thèse <br> Number of theses: 315","Defense date: 1988 <br> Type: Thèse <br> Number of theses: 253","Defense date: 1989 <br> Type: Thèse <br> Number of theses: 212","Defense date: 1990 <br> Type: Thèse <br> Number of theses: 180","Defense date: 1991 <br> Type: Thèse <br> Number of theses: 208","Defense date: 1992 <br> Type: Thèse <br> Number of theses: 275","Defense date: 1993 <br> Type: Thèse <br> Number of theses: 264","Defense date: 1994 <br> Type: Thèse <br> Number of theses: 292","Defense date: 1995 <br> Type: Thèse <br> Number of theses: 256","Defense date: 1996 <br> Type: Thèse <br> Number of theses: 296","Defense date: 1997 <br> Type: Thèse <br> Number of theses: 372","Defense date: 1998 <br> Type: Thèse <br> Number of theses: 338","Defense date: 1999 <br> Type: Thèse <br> Number of theses: 323","Defense date: 2000 <br> Type: Thèse <br> Number of theses: 427","Defense date: 2001 <br> Type: Thèse <br> Number of theses: 345","Defense date: 2002 <br> Type: Thèse <br> Number of theses: 316","Defense date: 2003 <br> Type: Thèse <br> Number of theses: 340","Defense date: 2004 <br> Type: Thèse <br> Number of theses: 315","Defense date: 2005 <br> Type: Thèse <br> Number of theses: 312","Defense date: 2006 <br> Type: Thèse <br> Number of theses: 296","Defense date: 2007 <br> Type: Thèse <br> Number of theses: 350","Defense date: 2008 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2009 <br> Type: Thèse <br> Number of theses: 363","Defense date: 2010 <br> Type: Thèse <br> Number of theses: 397","Defense date: 2011 <br> Type: Thèse <br> Number of theses: 405","Defense date: 2012 <br> Type: Thèse <br> Number of theses: 367","Defense date: 2013 <br> Type: Thèse <br> Number of theses: 394","Defense date: 2014 <br> Type: Thèse <br> Number of theses: 361","Defense date: 2015 <br> Type: Thèse <br> Number of theses: 373","Defense date: 2016 <br> Type: Thèse <br> Number of theses: 392","Defense date: 2017 <br> Type: Thèse <br> Number of theses: 360","Defense date: 2018 <br> Type: Thèse <br> Number of theses: 353","Defense date: 2019 <br> Type: Thèse <br> Number of theses: 339","Defense date: 2020 <br> Type: Thèse <br> Number of theses: 310","Defense date: 2021 <br> Type: Thèse <br> Number of theses: 351","Defense date: 2022 <br> Type: Thèse <br> Number of theses: 308","Defense date: 2023 <br> Type: Thèse <br> Number of theses: 129","Defense date: NA <br> Type: Thèse <br> Number of theses: 18"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse","legendgroup":"Thèse","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[2,10,7,19,26,32,56,57,91,146,258,219,297,380,365,450,482,467,483,434,219,0],"x":[1963,1964,1966,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,4,4,9,5,11,11,7,13,10,23,23,7,10,6,8,3,3,2,2,1,0],"text":["Defense date: 1963 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1966 <br> Type: Thèse complémentaire <br> Number of theses: 4","Defense date: 1968 <br> Type: Thèse complémentaire <br> Number of theses: 9","Defense date: 1969 <br> Type: Thèse complémentaire <br> Number of theses: 5","Defense date: 1970 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1971 <br> Type: Thèse complémentaire <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1973 <br> Type: Thèse complémentaire <br> Number of theses: 13","Defense date: 1974 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1975 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1976 <br> Type: Thèse complémentaire <br> Number of theses: 23","Defense date: 1977 <br> Type: Thèse complémentaire <br> Number of theses: 7","Defense date: 1978 <br> Type: Thèse complémentaire <br> Number of theses: 10","Defense date: 1979 <br> Type: Thèse complémentaire <br> Number of theses: 6","Defense date: 1980 <br> Type: Thèse complémentaire <br> Number of theses: 8","Defense date: 1981 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1982 <br> Type: Thèse complémentaire <br> Number of theses: 3","Defense date: 1983 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1984 <br> Type: Thèse complémentaire <br> Number of theses: 2","Defense date: 1985 <br> Type: Thèse complémentaire <br> Number of theses: 1","Defense date: NA <br> Type: Thèse complémentaire <br> Number of theses: 4"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(183,159,0,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse complémentaire","legendgroup":"Thèse complémentaire","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,1,2,2,3,10,13,18,25,45,47,79,94,143,144,208,292,279,351,406,393,428,375,187,0],"x":[1912,1922,1930,1938,1939,1942,1956,1958,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,null],"y":[1,1,1,1,1,1,2,3,1,2,1,1,8,10,4,8,6,8,7,11,10,12,52,115,75,89,88,86,99,76,74,55,59,32,0],"text":["Defense date: 1912 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1922 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1930 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1938 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1939 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1942 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1956 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1958 <br> Type: Thèse d'État <br> Number of theses: 3","Defense date: 1960 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1961 <br> Type: Thèse d'État <br> Number of theses: 2","Defense date: 1962 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1963 <br> Type: Thèse d'État <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1965 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1966 <br> Type: Thèse d'État <br> Number of theses: 4","Defense date: 1967 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1968 <br> Type: Thèse d'État <br> Number of theses: 6","Defense date: 1969 <br> Type: Thèse d'État <br> Number of theses: 8","Defense date: 1970 <br> Type: Thèse d'État <br> Number of theses: 7","Defense date: 1971 <br> Type: Thèse d'État <br> Number of theses: 11","Defense date: 1972 <br> Type: Thèse d'État <br> Number of theses: 10","Defense date: 1973 <br> Type: Thèse d'État <br> Number of theses: 12","Defense date: 1974 <br> Type: Thèse d'État <br> Number of theses: 52","Defense date: 1975 <br> Type: Thèse d'État <br> Number of theses: 115","Defense date: 1976 <br> Type: Thèse d'État <br> Number of theses: 75","Defense date: 1977 <br> Type: Thèse d'État <br> Number of theses: 89","Defense date: 1978 <br> Type: Thèse d'État <br> Number of theses: 88","Defense date: 1979 <br> Type: Thèse d'État <br> Number of theses: 86","Defense date: 1980 <br> Type: Thèse d'État <br> Number of theses: 99","Defense date: 1981 <br> Type: Thèse d'État <br> Number of theses: 76","Defense date: 1982 <br> Type: Thèse d'État <br> Number of theses: 74","Defense date: 1983 <br> Type: Thèse d'État <br> Number of theses: 55","Defense date: 1984 <br> Type: Thèse d'État <br> Number of theses: 59","Defense date: 1985 <br> Type: Thèse d'État <br> Number of theses: 32","Defense date: NA <br> Type: Thèse d'État <br> Number of theses: 1"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,186,56,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse d'État","legendgroup":"Thèse d'État","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,1,0,0,0,0,0,0,0,4,0,2,1,0,1,1,5,9,0,0],"x":[1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,2004,null],"y":[1,2,2,3,10,13,17,25,45,47,79,94,143,144,204,292,277,350,406,392,427,370,178,1,0],"text":["Defense date: 1963 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: 1964 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1965 <br> Type: Thèse de 3e cycle <br> Number of theses: 2","Defense date: 1966 <br> Type: Thèse de 3e cycle <br> Number of theses: 3","Defense date: 1967 <br> Type: Thèse de 3e cycle <br> Number of theses: 10","Defense date: 1968 <br> Type: Thèse de 3e cycle <br> Number of theses: 13","Defense date: 1969 <br> Type: Thèse de 3e cycle <br> Number of theses: 17","Defense date: 1970 <br> Type: Thèse de 3e cycle <br> Number of theses: 25","Defense date: 1971 <br> Type: Thèse de 3e cycle <br> Number of theses: 45","Defense date: 1972 <br> Type: Thèse de 3e cycle <br> Number of theses: 47","Defense date: 1973 <br> Type: Thèse de 3e cycle <br> Number of theses: 79","Defense date: 1974 <br> Type: Thèse de 3e cycle <br> Number of theses: 94","Defense date: 1975 <br> Type: Thèse de 3e cycle <br> Number of theses: 143","Defense date: 1976 <br> Type: Thèse de 3e cycle <br> Number of theses: 144","Defense date: 1977 <br> Type: Thèse de 3e cycle <br> Number of theses: 204","Defense date: 1978 <br> Type: Thèse de 3e cycle <br> Number of theses: 292","Defense date: 1979 <br> Type: Thèse de 3e cycle <br> Number of theses: 277","Defense date: 1980 <br> Type: Thèse de 3e cycle <br> Number of theses: 350","Defense date: 1981 <br> Type: Thèse de 3e cycle <br> Number of theses: 406","Defense date: 1982 <br> Type: Thèse de 3e cycle <br> Number of theses: 392","Defense date: 1983 <br> Type: Thèse de 3e cycle <br> Number of theses: 427","Defense date: 1984 <br> Type: Thèse de 3e cycle <br> Number of theses: 370","Defense date: 1985 <br> Type: Thèse de 3e cycle <br> Number of theses: 178","Defense date: 2004 <br> Type: Thèse de 3e cycle <br> Number of theses: 1","Defense date: NA <br> Type: Thèse de 3e cycle <br> Number of theses: 3"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de 3e cycle","legendgroup":"Thèse de 3e cycle","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0],"x":[1969,1979,1980,1982,1983,1984,1985],"y":[1,2,1,1,1,5,9],"text":["Defense date: 1969 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1979 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 2","Defense date: 1980 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1982 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1983 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 1","Defense date: 1984 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 5","Defense date: 1985 <br> Type: Thèse de docteur-ingénieur <br> Number of theses: 9"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(97,156,255,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse de docteur-ingénieur","legendgroup":"Thèse de docteur-ingénieur","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":0.90000000000009095,"base":0,"x":[1977],"y":[4],"text":"Defense date: 1977 <br> Type: Thèse sur travaux <br> Number of theses: 4","type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(245,100,227,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Thèse sur travaux","legendgroup":"Thèse sur travaux","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Distribution of theses by defense date and type of thesis","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Defense date","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Type of thesis","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"418857ad6048":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"418857ad6048","visdat":{"418857ad6048":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 2: Distribution of theses by defense date and type of thesis

</div>

### Availability of abstracts

<div id="fig-metadata_accessible">

<div class="plotly html-widget html-fill-item" id="htmlwidget-f9fe3ed8bba9a1862d35" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-f9fe3ed8bba9a1862d35">{"x":{"data":[{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,null],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,0,3,2,1,0,1,1,1,1,0,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,0],"x":[1899,1900,1901,1902,1903,1904,1905,1906,1907,1908,1909,1910,1911,1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1974,1975,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,null],"y":[5,31,37,27,40,34,45,38,48,44,51,65,38,71,29,30,8,6,12,11,25,52,46,69,72,70,61,54,62,38,40,29,45,42,47,37,48,45,37,40,53,22,29,35,30,33,29,29,45,35,33,44,41,36,30,47,26,32,30,35,45,49,35,49,55,61,54,69,65,83,85,92,133,163,215,269,372,316,392,452,449,509,507,503,510,454,431,55,46,20,21,15,19,20,22,17,5,19,11,13,17,58,58,65,57,37,24,20,34,29,23,13,7,10,5,4,7,3,3,2,3,3,3,0],"text":["Accessible: No <br> Date of defence: 1899 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1900 <br> Number of theses: 31","Accessible: No <br> Date of defence: 1901 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1902 <br> Number of theses: 27","Accessible: No <br> Date of defence: 1903 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1904 <br> Number of theses: 34","Accessible: No <br> Date of defence: 1905 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1906 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1907 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1908 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1909 <br> Number of theses: 51","Accessible: No <br> Date of defence: 1910 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1911 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1912 <br> Number of theses: 71","Accessible: No <br> Date of defence: 1913 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1914 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1915 <br> Number of theses: 8","Accessible: No <br> Date of defence: 1916 <br> Number of theses: 6","Accessible: No <br> Date of defence: 1917 <br> Number of theses: 12","Accessible: No <br> Date of defence: 1918 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1919 <br> Number of theses: 25","Accessible: No <br> Date of defence: 1920 <br> Number of theses: 52","Accessible: No <br> Date of defence: 1921 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1922 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1923 <br> Number of theses: 72","Accessible: No <br> Date of defence: 1924 <br> Number of theses: 70","Accessible: No <br> Date of defence: 1925 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1926 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1927 <br> Number of theses: 62","Accessible: No <br> Date of defence: 1928 <br> Number of theses: 38","Accessible: No <br> Date of defence: 1929 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1930 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1931 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1932 <br> Number of theses: 42","Accessible: No <br> Date of defence: 1933 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1934 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1935 <br> Number of theses: 48","Accessible: No <br> Date of defence: 1936 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1937 <br> Number of theses: 37","Accessible: No <br> Date of defence: 1938 <br> Number of theses: 40","Accessible: No <br> Date of defence: 1939 <br> Number of theses: 53","Accessible: No <br> Date of defence: 1940 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1941 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1942 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1943 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1944 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1945 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1946 <br> Number of theses: 29","Accessible: No <br> Date of defence: 1947 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1948 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1949 <br> Number of theses: 33","Accessible: No <br> Date of defence: 1950 <br> Number of theses: 44","Accessible: No <br> Date of defence: 1951 <br> Number of theses: 41","Accessible: No <br> Date of defence: 1952 <br> Number of theses: 36","Accessible: No <br> Date of defence: 1953 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1954 <br> Number of theses: 47","Accessible: No <br> Date of defence: 1955 <br> Number of theses: 26","Accessible: No <br> Date of defence: 1956 <br> Number of theses: 32","Accessible: No <br> Date of defence: 1957 <br> Number of theses: 30","Accessible: No <br> Date of defence: 1958 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1959 <br> Number of theses: 45","Accessible: No <br> Date of defence: 1960 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1961 <br> Number of theses: 35","Accessible: No <br> Date of defence: 1962 <br> Number of theses: 49","Accessible: No <br> Date of defence: 1963 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1964 <br> Number of theses: 61","Accessible: No <br> Date of defence: 1965 <br> Number of theses: 54","Accessible: No <br> Date of defence: 1966 <br> Number of theses: 69","Accessible: No <br> Date of defence: 1967 <br> Number of theses: 65","Accessible: No <br> Date of defence: 1968 <br> Number of theses: 83","Accessible: No <br> Date of defence: 1969 <br> Number of theses: 85","Accessible: No <br> Date of defence: 1970 <br> Number of theses: 92","Accessible: No <br> Date of defence: 1971 <br> Number of theses: 133","Accessible: No <br> Date of defence: 1972 <br> Number of theses: 163","Accessible: No <br> Date of defence: 1973 <br> Number of theses: 215","Accessible: No <br> Date of defence: 1974 <br> Number of theses: 269","Accessible: No <br> Date of defence: 1975 <br> Number of theses: 372","Accessible: No <br> Date of defence: 1976 <br> Number of theses: 316","Accessible: No <br> Date of defence: 1977 <br> Number of theses: 392","Accessible: No <br> Date of defence: 1978 <br> Number of theses: 452","Accessible: No <br> Date of defence: 1979 <br> Number of theses: 449","Accessible: No <br> Date of defence: 1980 <br> Number of theses: 509","Accessible: No <br> Date of defence: 1981 <br> Number of theses: 507","Accessible: No <br> Date of defence: 1982 <br> Number of theses: 503","Accessible: No <br> Date of defence: 1983 <br> Number of theses: 510","Accessible: No <br> Date of defence: 1984 <br> Number of theses: 454","Accessible: No <br> Date of defence: 1985 <br> Number of theses: 431","Accessible: No <br> Date of defence: 1986 <br> Number of theses: 55","Accessible: No <br> Date of defence: 1987 <br> Number of theses: 46","Accessible: No <br> Date of defence: 1988 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1989 <br> Number of theses: 21","Accessible: No <br> Date of defence: 1990 <br> Number of theses: 15","Accessible: No <br> Date of defence: 1991 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1992 <br> Number of theses: 20","Accessible: No <br> Date of defence: 1993 <br> Number of theses: 22","Accessible: No <br> Date of defence: 1994 <br> Number of theses: 17","Accessible: No <br> Date of defence: 1995 <br> Number of theses: 5","Accessible: No <br> Date of defence: 1996 <br> Number of theses: 19","Accessible: No <br> Date of defence: 1997 <br> Number of theses: 11","Accessible: No <br> Date of defence: 1998 <br> Number of theses: 13","Accessible: No <br> Date of defence: 1999 <br> Number of theses: 17","Accessible: No <br> Date of defence: 2000 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2001 <br> Number of theses: 58","Accessible: No <br> Date of defence: 2002 <br> Number of theses: 65","Accessible: No <br> Date of defence: 2003 <br> Number of theses: 57","Accessible: No <br> Date of defence: 2004 <br> Number of theses: 37","Accessible: No <br> Date of defence: 2005 <br> Number of theses: 24","Accessible: No <br> Date of defence: 2006 <br> Number of theses: 20","Accessible: No <br> Date of defence: 2007 <br> Number of theses: 34","Accessible: No <br> Date of defence: 2008 <br> Number of theses: 29","Accessible: No <br> Date of defence: 2009 <br> Number of theses: 23","Accessible: No <br> Date of defence: 2010 <br> Number of theses: 13","Accessible: No <br> Date of defence: 2011 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2012 <br> Number of theses: 10","Accessible: No <br> Date of defence: 2013 <br> Number of theses: 5","Accessible: No <br> Date of defence: 2014 <br> Number of theses: 4","Accessible: No <br> Date of defence: 2015 <br> Number of theses: 7","Accessible: No <br> Date of defence: 2016 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2017 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2018 <br> Number of theses: 2","Accessible: No <br> Date of defence: 2019 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2020 <br> Number of theses: 3","Accessible: No <br> Date of defence: 2021 <br> Number of theses: 3","Accessible: No <br> Date of defence: NA <br> Number of theses: 26"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"No","legendgroup":"No","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"orientation":"v","width":[0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095,0.90000000000009095],"base":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"x":[1954,1962,1965,1967,1968,1969,1971,1972,1973,1974,1976,1977,1978,1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023],"y":[1,1,1,3,2,1,1,1,1,1,6,3,3,2,1,2,4,4,8,23,286,269,233,191,165,189,255,242,275,251,277,361,325,306,369,287,251,283,279,288,276,316,332,340,384,398,357,389,357,366,389,357,351,336,307,348,308,129],"text":["Accessible: Yes <br> Date of defence: 1954 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1962 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1965 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1967 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1968 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1969 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1971 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1972 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1973 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1974 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1976 <br> Number of theses: 6","Accessible: Yes <br> Date of defence: 1977 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1978 <br> Number of theses: 3","Accessible: Yes <br> Date of defence: 1979 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1980 <br> Number of theses: 1","Accessible: Yes <br> Date of defence: 1981 <br> Number of theses: 2","Accessible: Yes <br> Date of defence: 1982 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1983 <br> Number of theses: 4","Accessible: Yes <br> Date of defence: 1984 <br> Number of theses: 8","Accessible: Yes <br> Date of defence: 1985 <br> Number of theses: 23","Accessible: Yes <br> Date of defence: 1986 <br> Number of theses: 286","Accessible: Yes <br> Date of defence: 1987 <br> Number of theses: 269","Accessible: Yes <br> Date of defence: 1988 <br> Number of theses: 233","Accessible: Yes <br> Date of defence: 1989 <br> Number of theses: 191","Accessible: Yes <br> Date of defence: 1990 <br> Number of theses: 165","Accessible: Yes <br> Date of defence: 1991 <br> Number of theses: 189","Accessible: Yes <br> Date of defence: 1992 <br> Number of theses: 255","Accessible: Yes <br> Date of defence: 1993 <br> Number of theses: 242","Accessible: Yes <br> Date of defence: 1994 <br> Number of theses: 275","Accessible: Yes <br> Date of defence: 1995 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 1996 <br> Number of theses: 277","Accessible: Yes <br> Date of defence: 1997 <br> Number of theses: 361","Accessible: Yes <br> Date of defence: 1998 <br> Number of theses: 325","Accessible: Yes <br> Date of defence: 1999 <br> Number of theses: 306","Accessible: Yes <br> Date of defence: 2000 <br> Number of theses: 369","Accessible: Yes <br> Date of defence: 2001 <br> Number of theses: 287","Accessible: Yes <br> Date of defence: 2002 <br> Number of theses: 251","Accessible: Yes <br> Date of defence: 2003 <br> Number of theses: 283","Accessible: Yes <br> Date of defence: 2004 <br> Number of theses: 279","Accessible: Yes <br> Date of defence: 2005 <br> Number of theses: 288","Accessible: Yes <br> Date of defence: 2006 <br> Number of theses: 276","Accessible: Yes <br> Date of defence: 2007 <br> Number of theses: 316","Accessible: Yes <br> Date of defence: 2008 <br> Number of theses: 332","Accessible: Yes <br> Date of defence: 2009 <br> Number of theses: 340","Accessible: Yes <br> Date of defence: 2010 <br> Number of theses: 384","Accessible: Yes <br> Date of defence: 2011 <br> Number of theses: 398","Accessible: Yes <br> Date of defence: 2012 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2013 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2014 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2015 <br> Number of theses: 366","Accessible: Yes <br> Date of defence: 2016 <br> Number of theses: 389","Accessible: Yes <br> Date of defence: 2017 <br> Number of theses: 357","Accessible: Yes <br> Date of defence: 2018 <br> Number of theses: 351","Accessible: Yes <br> Date of defence: 2019 <br> Number of theses: 336","Accessible: Yes <br> Date of defence: 2020 <br> Number of theses: 307","Accessible: Yes <br> Date of defence: 2021 <br> Number of theses: 348","Accessible: Yes <br> Date of defence: 2022 <br> Number of theses: 308","Accessible: Yes <br> Date of defence: 2023 <br> Number of theses: 129"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"name":"Yes","legendgroup":"Yes","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":43.105022831050235},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Availability of abstracts","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1892.3049999999998,2029.6950000000002],"tickmode":"array","ticktext":["1920","1960","2000"],"tickvals":[1920,1960,2000],"categoryorder":"array","categoryarray":["1920","1960","2000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Accessible","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-25.700000000000003,539.70000000000005],"tickmode":"array","ticktext":["0","100","200","300","400","500"],"tickvals":[-3.5527136788005009e-15,100,200,300,400,500.00000000000006],"categoryorder":"array","categoryarray":["0","100","200","300","400","500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Number of theses","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Accessible","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"41886fe63":{"x":{},"y":{},"fill":{},"text":{},"type":"bar"}},"cur_data":"41886fe63","visdat":{"41886fe63":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


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
the thesis edge table. We identify 91057 edges in total.
<a href="#fig-person-role" class="quarto-xref">Figure 4</a> shows the
distribution of individuals by role.
<a href="#fig-person-institution" class="quarto-xref">Figure 5</a> shows
the distribution of individuals for the top institutions.

<div id="tbl-edges">

Table 2: Sample of the edges table

<div class="cell-output-display">

<div class="datatables html-widget html-fill-item" id="htmlwidget-bf8a089eb58b845807a7" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-bf8a089eb58b845807a7">{"x":{"filter":"none","vertical":false,"data":[["158482573","027077950","264102789","262207788","262252805","203092449","20023269X","083456813","079232361","116552077","157279111","034976191","088911594","116552077","034526110","088705218","084678763","270490736","temp_sudoc_person_101090","034228268","050174673","027064026","029212375","231749724","147296781","061677396","092416446","122143205","059092408","030178444","026967804","197449573","026402882","02640463X","090168372","050222996","026404540","02674712X","119170302","074053043","027361802","258280239","119736179","240648315","085574546","195015622","131171623","179504703","103961852","151897344"],["Madignier","Pollin","Mebenga M'enam","Goubier","Berto Villas-Boas","Triolaire","TSE-R (Toulouse)","Silic","Bouville","Centre d'économie de la Sorbonne (Paris ; 2006-....)","Toulouse School of Economics","Baranzini","Benvegnu","Centre d'économie de la Sorbonne (Paris ; 2006-....)","Université de Paris (1896-1968)","Trommetter","Belhaj","De Rosa Leiva","Foy","Treillet","Boutillier","Penouil","Petit","Moreno","École doctorale Sciences et Ingénierie (Evry ; 2008-2015)","Algan","Larue","Jaunaux","Buquet","Alexandria university (Alexandrie, Égypte ; 1952-...)","Lassudrie-Duchêne","Bergaentzle","Université Aix-Marseille II (1969-2011)","Université Sorbonne Paris Nord (Bobigny, Villetaneuse, Seine-Saint-Denis ; 1970-....)","Sekri","Aubert","Université Louis Pasteur (Strasbourg) (1971-2008)","Boussard","Morlaix","Bilger","Université Paris 1 Panthéon-Sorbonne (1971-....)","Tybur","Le Goff","Université Grenoble Alpes (2020-....)","Berrou","Asensio Júdez","Treillard","Ben Aïssa","Université des sciences sociales (Grenoble ; 1970-1990)","Demontès"],["2011MON10043","2015PA100169","2021ORLE3162","2000BOR40013","2021IPPAX117","1977PA100062","2020TOU10014","2004LYO22005","temp_sudoc_thesis_907098","2014PA010089","2012TOU10011","2017PA01E029","2011ENMP0110","2016PA01E030","temp_sudoc_thesis_253308","2012GRENE017","2003PA090058","2023EHES0035","temp_sudoc_thesis_353362","2016ARTO0105","2019PA100057","1964BORUD010","2015USPCD026","1981PA090001","2008EVRY0011","2018PSLEH063","2009DIJOE001","2007PA090049","temp_sudoc_thesis_744038","2021GRALE008","1975BOR1D011","2023UPSLD013","temp_sudoc_thesis_125335","1982PA131018","temp_sudoc_thesis_143392","2018UBFCG004","temp_sudoc_thesis_288049","1991PA010040","1999DIJOE001","temp_sudoc_thesis_166354","temp_sudoc_thesis_795466","2021IEPP0011","2019PA01E040","2021GRALE005","2018BORD0258","1997DIJOE018","1961BORUD009","2018AIXM0187","temp_sudoc_thesis_991108","temp_sudoc_thesis_720278"],["author","president","author","member","member","member","research_partner","author","author","research_partner","doctoral_schools","member","author","research_partner","institution_defence_from_info","president","author","author","author","member","member","member","president","author","doctoral_schools","president","author","author","supervisor","institution_defense","member","member","institution_defence_from_info","institution_defence","author","member","institution_defence_from_info","supervisor","author","author","institution_defence_from_info","reviewer","supervisor","institution_defense","member","supervisor","member","reviewer","institution_defence_from_info","author"],["Antoine","Jean-Paul","Robert","René","Sofia","G.",null,"Dario","Jean-Marc",null,null,"Roberto","Nicolas",null,null,"Michel","Hanène","Mauricio","Paul","Stéphanie","Michel","Marc","Pascal","Herman",null,"Yann","Solène","Laure","Léon",null,"Bernard","Claire",null,null,"Nacer-Eddine","Francis",null,"Jean-Marc","Sophie","François",null,"Joshua","Richard",null,"Jean-Philippe","Lucinio","Jacques","Safouane",null,"Emile"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>these_id<\/th>\n      <th>entity_role<\/th>\n      <th>entity_firstname<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"these_id","targets":2},{"name":"entity_role","targets":3},{"name":"entity_firstname","targets":4}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100],"rowCallback":"function(row, data, displayNum, displayIndex, dataIndex) {\n}"}},"evals":["options.rowCallback"],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Top roles

<div id="fig-person-role">

<div class="plotly html-widget html-fill-item" id="htmlwidget-a0d26f6bc5eaf72ed19b" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-a0d26f6bc5eaf72ed19b">{"x":{"data":[{"orientation":"h","width":[0.90000000000000036,0.90000000000000036,0.89999999999999991,0.90000000000000013,0.90000000000000036],"base":[0,0,0,0,0],"x":[21031,16001,3960,7273,19292],"y":[5,3,1,2,4],"text":["Role: author <br> Number of individuals: 21031","Role: member <br> Number of individuals: 16001","Role: president <br> Number of individuals: 3960","Role: reviewer <br> Number of individuals: 7273","Role: supervisor <br> Number of individuals: 19292"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":69.406392694063939},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-1051.55,22082.549999999999],"tickmode":"array","ticktext":["0","5000","10000","15000","20000"],"tickvals":[0,5000,10000,15000,20000],"categoryorder":"array","categoryarray":["0","5000","10000","15000","20000"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of individuals","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,5.5999999999999996],"tickmode":"array","ticktext":["president","reviewer","member","supervisor","author"],"tickvals":[1,2,3,4,5],"categoryorder":"array","categoryarray":["president","reviewer","member","supervisor","author"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"41883ec44e03":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"41883ec44e03","visdat":{"41883ec44e03":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


Figure 4: Top role

</div>

### Top institutions

<div id="fig-person-institution">

<div class="plotly html-widget html-fill-item" id="htmlwidget-c789294e97d1dcd88fa7" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-c789294e97d1dcd88fa7">{"x":{"data":[{"orientation":"h","width":[0.89999999999999858,0.89999999999999858,0.89999999999999947,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000013,0.89999999999999991],"base":[0,0,0,0,0,0,0,0,0,0],"x":[1454,915,580,556,537,500,490,414,310,301],"y":[10,9,8,7,6,5,4,3,2,1],"text":["Role: Université Paris 1 Panthéon-Sorbonne (1971-....) <br> Number of edges: 1454","Role: Université de Paris (1896-1968) <br> Number of edges: 915","Role: École doctorale d'Économie (Paris ; 2004-....) <br> Number of edges: 580","Role: Université Paris Nanterre <br> Number of edges: 556","Role: Université de Grenoble (1339-1970). Faculté de droit et des sciences économiques (1896-1970) <br> Number of edges: 537","Role: Université de Bourgogne (1970-....) <br> Number of edges: 500","Role: Université des sciences sociales (Grenoble ; 1970-1990) <br> Number of edges: 490","Role: Université de Montpellier I (1970-2014) <br> Number of edges: 414","Role: Université de Bourgogne. UFR de droit et  science politique <br> Number of edges: 310","Role: Université Sorbonne Paris Nord (Bobigny, Villetaneuse, Seine-Saint-Denis ; 1970-....) <br> Number of edges: 301"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":548.67579908675816},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-72.700000000000003,1526.7],"tickmode":"array","ticktext":["0","500","1000","1500"],"tickvals":[0,500.00000000000006,1000,1500],"categoryorder":"array","categoryarray":["0","500","1000","1500"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Number of edges","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,10.6],"tickmode":"array","ticktext":["Université Sorbonne Paris Nord (Bobigny, Villetaneuse, Seine-Saint-Denis ; 1970-....)","Université de Bourgogne. UFR de droit et  science politique","Université de Montpellier I (1970-2014)","Université des sciences sociales (Grenoble ; 1970-1990)","Université de Bourgogne (1970-....)","Université de Grenoble (1339-1970). Faculté de droit et des sciences économiques (1896-1970)","Université Paris Nanterre","École doctorale d'Économie (Paris ; 2004-....)","Université de Paris (1896-1968)","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"tickvals":[1,2,3,4,5,6.0000000000000009,7,8,9,10],"categoryorder":"array","categoryarray":["Université Sorbonne Paris Nord (Bobigny, Villetaneuse, Seine-Saint-Denis ; 1970-....)","Université de Bourgogne. UFR de droit et  science politique","Université de Montpellier I (1970-2014)","Université des sciences sociales (Grenoble ; 1970-1990)","Université de Bourgogne (1970-....)","Université de Grenoble (1339-1970). Faculté de droit et des sciences économiques (1896-1970)","Université Paris Nanterre","École doctorale d'Économie (Paris ; 2004-....)","Université de Paris (1896-1968)","Université Paris 1 Panthéon-Sorbonne (1971-....)"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"418859097e02":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"418859097e02","visdat":{"418859097e02":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


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

<div class="datatables html-widget html-fill-item" id="htmlwidget-955a8a29d40be95d03f0" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-955a8a29d40be95d03f0">{"x":{"filter":"none","vertical":false,"data":[["078053064","033700222","temp_sudoc_institution_598732","028035747","034792937"],["Marchés, organisations, institutions et stratégies d'acteurs - UMR MOISA (Montpellier)","Université de Fribourg (Fribourg, Suisse). Faculté des sciences économiques et sociales et du management","Rennes","Université Laval (Québec, Canada)","Université Marc Bloch (Strasbourg). UFR des sciences historiques"],[["183160037","183751183","18376398X","183765591","183765591"],[null],[null],[null],[null]],["https://www.idref.fr/078053064.rdf","https://www.idref.fr/033700222.rdf",null,"https://www.idref.fr/028035747.rdf","https://www.idref.fr/034792937.rdf"],[["MOISA","UMR MOISA","Institut national de la recherche agronomique (France). Unité mixte de recherche (1110)","Ecole nationale supérieure agronomique (Montpellier). Unité mixte de recherche Marchés, organisations, institutions et stratégies d'acteurs"],["Universität Freiburg (Freiburg, Schweiz). Wirtschafts- und sozialwissenschaftliche Fakultät","Université de Fribourg (Fribourg, Suisse). Faculté des sciences économiques et sociales"],null,["Université de Laval","Laval university (Québec, Canada)"],["Université Marc Bloch (Strasbourg). UER de sciences historiques","Université Marc Bloch (Strasbourg). Faculté des sciences historiques","Université des sciences humaines. UFR des sciences historiques"]],["2001-01-01","1989",null,"1852","1969"],[null,null,null,null,"2009"],[[],[],null,"Université canadienne fondée à Québec (Québec) ...",[]],[["183160037","183751183","18376398X","183765591"],[],null,["026596474","106945513","142548766"],"096185058"],[[],"Université de Fribourg. Faculté de droit et des sciences économiques et sociales",null,[],[]],[[],"027936244",null,[],[]],[[],[],null,[],[]],[[],[],null,[],[]],[[],[],null,[],[]],[[],[],null,[],[]],[[],[],null,[],[]],[[],[],null,[],[]],[["http://data.bnf.fr/ark:/12148/cb14412200n#foaf:Organization","http://viaf.org/viaf/132779464","http://viaf.org/viaf/313574965","http://viaf.org/viaf/314926203","http://viaf.org/viaf/314926497","http://viaf.org/viaf/314926531"],["http://isni.org/isni/0000000121792869","http://data.bnf.fr/ark:/12148/cb12454081z#foaf:Organization","http://viaf.org/viaf/146496487"],null,["https://data.hal.science/structure/93488#foaf:Organization","https://ror.org/04sjchr03#foaf:Organization","http://isni.org/isni/0000000123765207","http://data.bnf.fr/ark:/12148/cb118813410#foaf:Organization","http://viaf.org/viaf/173750576","https://fr.wikipedia.org/wiki/Laval_(Québec)"],["http://data.bnf.fr/ark:/12148/cb12550969s#foaf:Organization","http://viaf.org/viaf/267396275"]],["France",null,null,"Canada","France"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>old_id<\/th>\n      <th>url<\/th>\n      <th>other_labels<\/th>\n      <th>date_of_birth<\/th>\n      <th>date_of_death<\/th>\n      <th>information<\/th>\n      <th>replaced_idref<\/th>\n      <th>predecessor<\/th>\n      <th>predecessor_idref<\/th>\n      <th>successor<\/th>\n      <th>successor_idref<\/th>\n      <th>subordinated<\/th>\n      <th>subordinated_idref<\/th>\n      <th>unit_of<\/th>\n      <th>unit_of_idref<\/th>\n      <th>other_link<\/th>\n      <th>country_name<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_id","targets":0},{"name":"entity_name","targets":1},{"name":"old_id","targets":2},{"name":"url","targets":3},{"name":"other_labels","targets":4},{"name":"date_of_birth","targets":5},{"name":"date_of_death","targets":6},{"name":"information","targets":7},{"name":"replaced_idref","targets":8},{"name":"predecessor","targets":9},{"name":"predecessor_idref","targets":10},{"name":"successor","targets":11},{"name":"successor_idref","targets":12},{"name":"subordinated","targets":13},{"name":"subordinated_idref","targets":14},{"name":"unit_of","targets":15},{"name":"unit_of_idref","targets":16},{"name":"other_link","targets":17},{"name":"country_name","targets":18}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

## Individuals

The thesis person table contains 16 variables. The four core variables
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

<div class="datatables html-widget html-fill-item" id="htmlwidget-fec6e04cc039f35f45e5" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-fec6e04cc039f35f45e5">{"x":{"filter":"none","vertical":false,"data":[["Constantin","Jean-Pierre","José Alberto","Bassem","Ouidad"],["219437378","03176374X","033316457","083193898","194936155"],["Abena Nguema","Aubin","Valente Carvalhais De Sousa","Kamar","Tangi"],["male","male",null,"male",null],["male","male",null,"male","female"],[null,"1939","1952","1972",null],["http://sws.geonames.org/3017382/","http://sws.geonames.org/3017382/","http://sws.geonames.org/2264397/","http://sws.geonames.org/3017382/",null],["France","France","Portugal","France",null],[[],["Mathématicien. En poste à l'École polytechnique, Université de Paris IX Dauphine (en 1982). Coéditeur de la collection \"Annals of the CEREMADE\" publiée chez Birkhäuser (en 1983)"],[],["Docteur en sciences économiques"],["Titulaire d'une thèse de doctorat en Sciences économiques (Paris 8, 2016)"]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[["http://isni.org/isni/0000000043096162","http://viaf.org/viaf/21724222"],["http://www.wikidata.org/entity/Q1685166","http://isni.org/isni/0000000115801634","http://data.bnf.fr/ark:/12148/cb12291852b#foaf:Person","http://viaf.org/viaf/108948028","https://fr.wikipedia.org/wiki/Jean-Pierre_Aubin","https://www.persee.fr/authority/1574179"],["http://isni.org/isni/0000000364462389","http://data.bnf.fr/ark:/12148/cb12419457k#foaf:Person","http://viaf.org/viaf/228705699"],["http://isni.org/isni/0000000054739186","http://data.bnf.fr/ark:/12148/cb15073801k#foaf:Person","http://viaf.org/viaf/2759516"],["http://viaf.org/viaf/90147602677857642300"]],[["219437378","temp_thesefr_person_100046"],null,null,null,null],[null,"thesesfr","thesesfr","thesesfr","thesesfr"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>entity_firstname<\/th>\n      <th>entity_id<\/th>\n      <th>entity_name<\/th>\n      <th>gender<\/th>\n      <th>gender_expended<\/th>\n      <th>birth<\/th>\n      <th>country<\/th>\n      <th>country_name<\/th>\n      <th>info<\/th>\n      <th>organization<\/th>\n      <th>last_date_org<\/th>\n      <th>start_date_org<\/th>\n      <th>end_date_org<\/th>\n      <th>other_link<\/th>\n      <th>homonym_of<\/th>\n      <th>source<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"name":"entity_firstname","targets":0},{"name":"entity_id","targets":1},{"name":"entity_name","targets":2},{"name":"gender","targets":3},{"name":"gender_expended","targets":4},{"name":"birth","targets":5},{"name":"country","targets":6},{"name":"country_name","targets":7},{"name":"info","targets":8},{"name":"organization","targets":9},{"name":"last_date_org","targets":10},{"name":"start_date_org","targets":11},{"name":"end_date_org","targets":12},{"name":"other_link","targets":13},{"name":"homonym_of","targets":14},{"name":"source","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

<div class="panel-tabset">

### Gender

<div id="fig-person_genre">

<div class="plotly html-widget html-fill-item" id="htmlwidget-0aa19cd07cdd18d57b46" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-0aa19cd07cdd18d57b46">{"x":{"data":[{"orientation":"v","width":[0.90000000000000013,0.89999999999999991,0.90000000000000036],"base":[0,0,0],"x":[2,1,3],"y":[64.64631800529888,22.785177657605342,12.56850433709578],"text":["Gender: male <br> Number of theses: 17812 <br> % : 64.65","Gender: female <br> Number of theses: 6278 <br> % : 22.79","Gender: Unknown <br> Number of theses: 3463 <br> % : 12.57"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(135,206,235,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.228310502283104,"r":7.3059360730593621,"b":40.182648401826491,"l":22.648401826484022},"font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,3.6000000000000001],"tickmode":"array","ticktext":["female","male","Unknown"],"tickvals":[1,2,3],"categoryorder":"array","categoryarray":["female","male","Unknown"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"gender_expended","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-3.2323159002649442,67.878633905563831],"tickmode":"array","ticktext":["0","20","40","60"],"tickvals":[0,20,39.999999999999993,60],"categoryorder":"array","categoryarray":["0","20","40","60"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"41883e961adc":{"x":{},"y":{},"text":{},"type":"bar"}},"cur_data":"41883e961adc","visdat":{"41883e961adc":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>


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

<div class="grViz html-widget html-fill-item" id="htmlwidget-13c2463ce158186cca47" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-13c2463ce158186cca47">{"x":{"diagram":"\ndigraph project_dag {\n graph [layout = dot, rankdir = TB]\n \n # Define nodes\n scraping_sudoc_id [label = \"scraping_sudoc_id.R\", shape = box, style = filled, fillcolor = lightblue]\n scraping_sudoc_api [label = \"scraping_sudoc_api.R\", shape = box, style = filled, fillcolor = lightblue]\n cleaning_sudoc [label = \"cleaning_sudoc.R\", shape = box, style = filled, fillcolor = lightyellow]\n downloading_theses_fr [label = \"downloading_theses_fr.R\", shape = box, style = filled, fillcolor = lightblue]\n cleaning_thesesfr [label = \"cleaning_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow]\n merging_database [label = \"merging_sudoc_thesesfr.R\", shape = box, style = filled, fillcolor = lightyellow]\n idref_institutions [label = \"scraping_idref_institution.R\", shape = box, style = filled, fillcolor = lightblue]\n idref_persons [label = \"scraping_idref_person.R\", shape = box, style = filled, fillcolor = lightblue]\n cleaning_metadata [label = \"cleaning_thesis_metada.R\", shape = box, style = filled, fillcolor = lightyellow]\n cleaning_institutions [label = \"cleaning_institutions.R\", shape = box, style = filled, fillcolor = lightyellow]\n cleaning_persons [label = \"cleaning_persons.R\", shape = box, style = filled, fillcolor = lightyellow]\n cleaning_edges [label = \"cleaning_edges.R\", shape = box, style = filled, fillcolor = lightyellow]\n \n # Define edges\n scraping_sudoc_id -> scraping_sudoc_api\n scraping_sudoc_api -> cleaning_sudoc \n downloading_theses_fr -> cleaning_thesesfr\n cleaning_sudoc -> merging_database\n cleaning_thesesfr -> merging_database\n merging_database -> idref_institutions\n merging_database -> idref_persons\n merging_database -> cleaning_metadata\n idref_institutions -> cleaning_institutions\n idref_persons -> cleaning_persons\n cleaning_metadata -> cleaning_edges\n cleaning_institutions -> cleaning_edges\n cleaning_persons -> cleaning_edges\n}\n","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

## Scrapping

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
[1_FR_sudoc_cleaning.R](.\scripts/cleaning_scripts/FR/1_FR_SUDoc%20_cleaning.R)
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
[2_FR_thesesfr_cleaning.R](.\scripts/cleaning_scripts/FR/2_FR_thesesfr_cleaning.R)
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
[3_FR_merging_database.R](.\scripts/cleaning_scripts/FR/3_FR_merging_database.R)
merge the set of tables created from the SUDoc and Theses.fr source.
There is no particular difficulty in this script. We do not handle
duplicates in this script, as we will do it in the next steps.

### Metadata

The
[4_FR_cleaning_thesis_metadata.R](.\scripts/cleaning_scripts/FR/4_FR_cleaning_thesis_metadata.R)
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

<div class="datatables html-widget html-fill-item" id="htmlwidget-652832562cff62fb3b7d" style="width:100%;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-652832562cff62fb3b7d">{"x":{"filter":"none","vertical":false,"data":[["2021LIMO0083"],[2021],["fr"],[null],["Trois essais sur la composition des conseils d'administration et la gouvernance d'entreprise efficace."],["Three Essays on bank board composition and effective corporate governance"],[null],["L'objectif de cette thèse est d'examiner deux mécanismes pour promouvoir la bonne gouvernance d'entreprise dans les établissements bancaires, notamment l'actionnariat salarié et la présence de représentants des obligataires au conseil d'administration de la banque. Au chapitre 1, nous examinons si un actionnariat salarié plus important conduit à une diminution du risque bancaire. À partir d'un échantillon de banques européennes, nous constatons que l'ensemble de l’actionnariat salarié, ainsi que chacune de ses composantes (l’actionnariat des dirigeants et l’actionnariat des non-dirigeants), réduit significativement le risque d'insolvabilité des banques. Notre étude est la première à examiner si l’actionnariat des non-dirigeants, en plus de l’actionnariat des dirigeants, a un impact sur la prise de risque bancaire. De plus, nos résultats mettent en lumière les canaux par lesquels l'actionnariat salarié affecte le risque d'une banque. Nous démontrons que non seulement l’actionnariat des dirigeants, mais aussi l’actionnariat des non-dirigeants conduit à un niveau inférieur de risque. Le chapitre 2 complète le chapitre 1 en examinant si la politique nationale de soutien suggérée par la Commission européenne est efficace pour promouvoir les programmes d'actionnariat salarié (ESOP) dans les banques européennes. Nous constatons que les mesures de soutien sont efficaces pour promouvoir l'ESOP dans les banques à participation multiple, et ce indépendamment de l'opacité bancaire et de la protection des actionnaires. En revanche, elles ne sont efficaces pour promouvoir l'ESOP dans les banques à participation restreinte que si les banques sont transparentes ou situées dans des pays où la protection des actionnaires est plus forte. Notre conclusion suggère que les autorités devraient améliorer la protection des actionnaires et la transparence bancaire afin d'améliorer l'efficacité des mesures de soutien aux programmes d'actionnariat salarié. Au chapitre 3, nous examinons si l'influence des représentants des obligataires au sein du conseil d'administration des banques est un mécanisme efficace de discipline de marché pour réduire la prise de risque bancaire. Nos résultats empiriques montrent que l'influence des représentants des obligataires réduit significativement toutes les dimensions du risque bancaire sans réduire la rentabilité. Notre étude est la première à considérer les représentants des obligataires comme un dispositif de discipline de marché pour limiter la prise de risque excessive des banques. Nous contribuons à la littérature sur la gouvernance d'entreprise pour les banques en soulignant le rôle potentiellement important des représentants des obligataires dans la résolution de l'interaction complexe des problèmes d'agence auxquels sont confrontées les nombreuses parties prenantes au sein des banques. Notre conclusion a des implications importantes pour les régulateurs et les partisans d'une réforme de la gouvernance bancaire qui promeuvent le rôle de la discipline de marché et des conseils d'administration dans le contrôle de la prise de risque bancaire."],["The target of this thesis is to examine two mechanisms to promote good corporate governance in banking firms, including employee ownership and the presence of bondholder representatives in a bank's board. In Chapter 1, we examine whether a greater level of employee ownership leads to lower bank risk. Using a sample of European banks, we find that the total employee ownership, as well as each of its components (executive and non-executive ownership), significantly reduce banks’ risk. Our study is the first to investigate whether non-executive ownership, in addition to executive ownership, has an impact on bank risk-taking. Moreover, our results shed light on the channels through which employee ownership affects a bank’s risk. We demonstrate that not only executive ownership, but also non-executive ownership leads to a lower level of non-performing loans ratio. Chapter 2 complements Chapter 1 by examining whether the national supportive policy suggested by the European Commission is effective to promote employee share ownership programs (ESOP) in European banks. We find that supportive measures are effective to promote ESOP in widely-held banks independently of bank opacity and shareholder protection, but they are only effective to promote ESOP in closely-held banks if banks are transparent or located in countries with stronger shareholder protection. Our finding suggests that authorities should improve shareholder protection and bank transparency to enhance the effectiveness of supportive measures for employee ownership programs. In Chapter 3, we examine whether the influence of bondholder representatives on the board of directors of banks is an effective market discipline mechanism to reduce bank risk-taking. Our empirical results provide evidence that the influence of bondholder representatives significantly reduces all dimensions of bank risk without reducing profitability. Our study is the first to consider bondholder representatives as a market discipline device to limit excessive firm risk-taking. We contribute to the corporate governance literature for banks by highlighting the potentially important role of bondholder representatives in addressing the complex interplay of agency problems faced by the many stakeholders relevant to banks. Our finding has significant implications for regulators and corporate governance reform proponents promoting the role of market discipline and boards in controlling bank risk-taking."],[null],["Sciences economiques"],["oui"],["Thèse"],["France"],["https://theses.fr/2021LIMO0083"],[["2018LIMO0044"]]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>these_id<\/th>\n      <th>year_defence<\/th>\n      <th>language<\/th>\n      <th>language_2<\/th>\n      <th>title_fr<\/th>\n      <th>title_en<\/th>\n      <th>title_other<\/th>\n      <th>abstract_fr<\/th>\n      <th>abstract_en<\/th>\n      <th>abstract_other<\/th>\n      <th>field<\/th>\n      <th>accessible<\/th>\n      <th>type<\/th>\n      <th>country<\/th>\n      <th>url<\/th>\n      <th>duplicates<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"scrollX":true,"columnDefs":[{"className":"dt-right","targets":1},{"name":"these_id","targets":0},{"name":"year_defence","targets":1},{"name":"language","targets":2},{"name":"language_2","targets":3},{"name":"title_fr","targets":4},{"name":"title_en","targets":5},{"name":"title_other","targets":6},{"name":"abstract_fr","targets":7},{"name":"abstract_en","targets":8},{"name":"abstract_other","targets":9},{"name":"field","targets":10},{"name":"accessible","targets":11},{"name":"type","targets":12},{"name":"country","targets":13},{"name":"url","targets":14},{"name":"duplicates","targets":15}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[5,10,25,50,100]}},"evals":[],"jsHooks":[]}</script>

</div>

</div>

> [!NOTE]
>
> Our script can handle duplicate manually. If you spot an undetected
> duplicate, please [let us
> know](https://github.com/tdelcey/becoming_economist).

### Institutions

The
[5_FR_cleaning_institution.R](.\scripts/cleaning_scripts/FR/4_FR_cleaning_institution.R)
script aims to standardize and improve the quality of institution data.

So far, any institution names mentioned in the metadata have been
extracted and stored in a separate table. This script focuses on
cleaning and standardizing these names to ensure consistency and
accuracy in the dataset. Our goal is to replace temporary institution
identifiers (id_temp) we have created in
[3_FR_merging_database.R](.\scripts/cleaning_scripts/FR/3_FR_merging_database.R)
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
[6_FR_cleaning_persons.R](.\scripts/cleaning_scripts/FR/5_FR_cleaning_persons.R)
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
