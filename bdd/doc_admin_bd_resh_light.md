![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base simplifiée des réseaux humides

## Principes

La base simplifiée des réseaux eau et assainissement est une base ayant pour objet l'obtention d'une vision harmonisée et simplifiée des différents réseaux délégués.
La base est alimentée **exclusivement** à partir des données transmises sous forme de fichiers structurés par les exploitants et selon leurs propres formats.
En raison de la forte hétérogéneité des sources (classes, attributs, domaines de valeurs), la base simplifiée de la collectivité s'appuie pour l'essentiel sur les libéllés exploitants sans recherche de structuration de domaines de valeur, les usages sommaires à l'aval étant compatibles à ce stade.

Sur la modélisation, la base comprend 3 classes relationnelles, 1 superclasse objet de réseau, 2 classes géométriques enfants, l'une pour les canalisations (linéaire), l'autre pour les ouvrages (ponctuel). En complément, 1 seul domaine de valeur structuré est organisé pour typer la nature du réseau humide en s'appuyant sur la liste de codes du standard STAR-DT. Sur cette base de liste, 4 vues matérialisées d'exploitation reconstituent les données respectivement pour les réseaux d'eau et assainissement (canalisation et ouvrage).

## Schéma fonctionnel

![schema_fonctionnel](img/schema_fonctionnel_resh_light.png)

## Dépendances (non critiques)

La base de données simplifié des réseaux humides ne présente aucune dépendance à des données tierces (référentiel ou métier).

## Classes d'objets

L'ensemble des classes d'objets de gestion sont stockées dans le schéma m_reseau_humide.

 ### Classes d'objets de gestion
  
   `an_resh_objet` : Classe abstraite décrivant un objet d''un réseau humide
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idresh|Identifiant unique d'objet|bigint| |
|refprod|Référence producteur de l'entité|character varying(254)| |
|natresh|Nature du réseau humide|character varying(5)| |
|enservice|Objet en service ou non (abandonné)|character varying(1)| |
|andebpose|Année marquant le début de la période de pose|character varying(4)| |
|anfinpose|Année marquant la fin de la période de pose|character varying(4)| |
|sourmaj|Source de la mise à jour|character varying(100)| |
|datemaj|Date de la dernière mise à jour des informations|date| |
|qualgloc|Qualité de la géolocalisation (XYZ)|character varying(1)|C|
|insee|Code INSEE|character varying(5)| |
|mouvrage|Maître d'ouvrage du réseau|character varying(100)| |
|gexploit|Gestionnaire exploitant du réseau|character varying(100)| |
|refcontrat|Références du contrat de délégation|character varying(100)| |
|libcontrat|Nom du contrat de délégation|character varying(254)| |
|observ|Observations|character varying(254)| |
|dbinsert|Horodatage de l'intégration en base de l'objet|timestamp without time zone| |
|dbupdate|Horodatage de la mise à jour en base de l'objet|timestamp without time zone| |

Particularité(s) à noter :
* Une clé primaire existe sur le champ idresh
* Une clé étrangère existe sur le champ natresh vers le domaine de valeur considéré

---

   `geo_resh_can` : Classe décrivant une canalisation d'un réseau humide

|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idresh|Identifiant unique d'objet|bigint| |
|branchemnt|Canalisation de branchement individuel (O/N)|character varying(1)| |
|materiau|Matériau de la canalisation|character varying(80)| |
|mateabrev|Abréviation du matériau de la canalisation|character varying(5)| |
|diametre|Diamètre nominal de la canalisation (en millimètres)|integer| |
|formcana|Forme (Section) de la canalisation|character varying(30)| |
|modecirc|Mode de circulation de l'eau à l'intérieur de la canalisation|character varying(80)| |
|longcalc|Longueur calculée de la canalisation en mètre|numeric(7,3)| |
|geom|Géométrie linéaire de l'objet|geometry(LineString,2154)| |

Particularité(s) à noter :
* Une clé primaire existe sur le champ idresh
* Une clé étrangère existe sur le champ idresh vers l'attribut du même nom de la classe an_resh_objet

---

   `geo_resh_ouv` : Classe décrivant un ouvrage d'un réseau humide

|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idresh|Identifiant unique d'objet|bigint| |
|fnouv|Fonction de l'ouvrage du réseau humide|character varying(80)| |
|x|Coordonnée X Lambert 93 (en mètres)|numeric(10,3)| |
|y|Coordonnée Y Lambert 93 (en mètres)|numeric(11,3)| |
|ztn|Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)|numeric(7,3)| |
|zrad|Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)|numeric(7,3)| |
|geom|Géométrie ponctuelle de l'objet|geometry(Point,2154)| |

Particularité(s) à noter :
* Une clé primaire existe sur le champ idresh
* Une clé étrangère existe sur le champ idresh vers l'attribut du même nom de la classe an_resh_objet

 ### Domaine de valeur

   `lt_resh_natresh` : Nature du réseau humide conformément à la liste des réseaux de la NF P98-332

|Code | Valeur | Couleur | 
|:---|:---|:---|
|AEP|Eau potable|#00B0F0|
|ASS|Assainissement et pluvial|#663300|
|ASSEP|Eaux pluviales|#663300|
|ASSEU|Eaux usées|#663300|
|ASSUN|Réseau unitaire|#663300|

 ## Vues d'exploitation
 
 4 vues **matérialisées** sont intégrées au schéma métier pour rendre compte des données canalisations et ouvrages par réseau AEP ou ASS :
 
 |Nom | Description |
 |:---|:---|
 |geo_vm_resh_ouvae|Ouvrage du réseau d'adduction d'eau|
 |geo_vm_resh_canae|Canalisation du réseau d'adduction d'eau|
 |geo_vm_resh_ouvass|Ouvrage du réseau d'assainissement|
 |geo_vm_resh_canass|Canalisation du réseau d'assainissement|
 
  6 vues **matérialisées** pour rendre compte des données canalisations et ouvrages par sous type de réseau ASS (UN, EU, EP) :
 
 |Nom | Description |
 |:---|:---|
 |geo_vm_resh_ouvasseu|Ouvrage du réseau d'assainissement des eaux usées|
 |geo_vm_resh_canasseu|Canalisation du réseau d'assainissement des eaux usées|
 |geo_vm_resh_ouvassun|Ouvrage du réseau d'assainissement unitaire|
 |geo_vm_resh_canassun|Canalisation du réseau d'assainissement unitaire|
 |geo_vm_resh_ouvassep|Ouvrage du réseau d'assainissement des eaux pluviales|
 |geo_vm_resh_canassep|Canalisation du réseau d'assainissement des eaux pluviales|
 
