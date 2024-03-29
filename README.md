![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Modèle simplifié des réseaux eau et assainissement

Spécification du modèle de données simplifié relatif aux réseaux d'eau et d'assainissement sur le territoire de l'Agglomération de la Région de Compiègne.

- [Script d'initialisation de la base de données](bdd/init_bd_resh_light.sql) 
- [Documentation d'administration de la base](bdd/doc_admin_bd_resh_light.md) 

## Contexte

L’ARC est compétent sur les différents réseaux humides, à savoir  l'eau potable (production / distribution) et l'assainissement (unitaire, eau usée, pluvial urbain).
L'exploitation de ces compétences est externalisée auprès de différents opérateurs, essentiellement au travers de plusieurs délégations de services publics. Ces dernières peuvent concerner des emprises territoriales variables pour un même type de réseau (certains contrats sont communaux tandis que d'autres regroupent plusieurs communes).

La connaissance dépend donc de plusieurs exploitants qui produisent des données au travers de leurs systèmes d'information puis les diffusent à la collectivité sous forme de fichiers structurés spécifiques. Cette situation conduit à des données hétèrogènes du point de vue informatique et ne permet pas de disposer d'une vision unifiée des réseaux dont la collectivité est compétente.

Un standard informatique RAEPA de la COVADIS tente d'amener un premier niveau de standardisation mais apparait après analyse, comme insuffisant pour rendre compte d'une qualité descriptive satisfaisante du patrimoine. Une démarche nationale de l'ASTEE à laquelle l'agglomération participe, vise à réviser ce standard sur un niveau de contenu plus adéquat sur les conditions techniques d'échanges de données "riches" entre les différents intervenants.

Dans l'attente et afin de substituer un patchwork de données provenant pour l'essentiel de plans DAO datés, l'ARC a mené des travaux visant à concevoir un modèle de données simplifié. Celui-ci, prend appui sur les données sources des concessionnaires titulaires de contrats sur le territoire de l'agglomération et la connaissance du standard RAEPA actuel.

Les attendus de connaissance pour ce modèle simplifié concernent donc sommairement :
* la position cartographique des ouvrages du réseaux (canalisation, installation)
* la classe de précision cartographique au sens DT-DICT lorsqu'elle est renseignée (C à défaut)
* la nature et les cotes terrain naturel / radier de l'installation ponctuelle (avaloir, regard, plaque pleine ...)
* le diamètre, matériau et forme de la section de la canalisation
* le maitre d'ouvrage, l'exploitant et la référence / nom du contrat
* année ou période de pose
* les métadonnées qualités (date de la source ...)

Les données relevant de ce modèle simplifié ont vocation à être intégrées pour diffusion dans :
* une application généraliste de connaissance sommaire de l'ensemble des réseaux
* une application dédiée aux réseaux d'eau et assainissement permettant d'adapter une réprésentation métier et associer d'autres informations du domaine 
