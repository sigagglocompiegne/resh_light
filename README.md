![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# resh_light
Base de données simplifiée des réseaux eau et assainissement

## Contexte

L’ARC est compétent sur les différents réseaux humides : potable (production / distribution) ; assainissement (unitaire, eau usée, pluvial urbain).
La gestion de ces compétences est externalisée auprès de différents exploitants essentiellement au travers de plusieurs délégations de services publics. Ces dernières peuvent concerner des emprises territoriales variables pour un même type de réseau (certains contrats sont communaux tandis que d'autres regroupent plusieurs communes).

Les conditions de connaissances de l'exploitation dependent donc de plusieurs exploitants qui produisent des données dans leurs systèmes d'information puis les diffusent à la collectivité sous cette forme. Cette situation conduit à des données hétèrogènes en terme de structure informatique et ne permet pas de disposer d'une vision unifiée des réseaux dont la collectivité est compétente.

Un standard informatique RAEPA de la COVADIS tente d'amener un premier niveau de standardisation mais apparait après analyse comme insuffisant pour rendre compte d'une qualité descriptive satisfaisante du patrimoine. Une démarche nationale de l'ASTEE que l'agglomération à rejoint, vise à réviser ce standard sur un niveau de contenu plus adéquat afin de faciliter les conditions techniques d'échanges de données "riches" entre les différents opérateurs des réseaux humides.

Dans l'attente, l'ARC a mené des travaux visant à concevoir un modèle de données simplifié au regard du standard RAEPA actuel et des données sources diffusées par les concesionnaires privés titulaires de contrats sur le territoire de l'agglomération.

Les attendus de connaissance pour ce modèle simplifié concernent donc sommairement :
* la position cartographique des ouvrages du réseaux (canalisation, installation)
* la classe de précision cartographique au sens DT-DICT lorsqu'elle est renseignée (C à défaut)
* la nature et les cotes terrain naturel / radier de l'installation ponctuelle (avaloir, regard, plaque pleine ...)
* le diamètre, matériau de la canalisation
* l'exploitant et la référence de contrat
* les métadonnées qualités (date de la source ...)
