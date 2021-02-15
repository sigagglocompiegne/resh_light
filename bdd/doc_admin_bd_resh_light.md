![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base simplifiée des réseaux humides

## Principes

La base simplifiée des réseaux eau et assainissement est une base ayant pour objet de disposer d'une vision harmonisée et simplifiée des différents réseaux délégués.
La base est alimentée **exclusivement** à partir des données transmises sous forme de fichiers structurés par les exploitants et selon leurs propres formats.
En raison de la forte hétérogéneité des sources (classes, attributs, domaines de valeurs), la base simplifiée de la collectivité s'appuiera pour l'essentiel sur les libéllés des valeurs exploitants sans chercher à constituer des domaines de valeur structurés, les usages sommaires à l'aval étant compatibles à ce stade.

Sur la modélisation, la base comprend 3 classes relationnelles, 1 superclasse objet de réseau, 2 classes géomatriques enfants, l'une pour les canalisations (linéaire), l'autre pour les ouvrage (ponctuel). En complément, 1 seul domaine de valeur structuré est organisé pour typer la nature du réseau humide en s'appuyant sur la liste de codes du standard STAR-DT. Sur cette base de liste, 4 vues matérialisées d'exploitation reconstituent les données pour les réseaux d'eau et assainissement (canalisation et ouvrage).

## Schéma fonctionnel

![schema_fonctionnel](img/schema_fonctionnel_resh_light.png)

## Dépendances (non critiques)

La base de données simplifié des réseaux humides ne présente aucune dépendance à des données tierces (référentiel ou métier).

## Classes d'objets

L'ensemble des classes d'objets de gestion sont stockées dans le schéma m_reseau_humide.

 ### classes d'objets de gestion :
  
   `an_resh_objet` : Classe abstraite décrivant un objet d''un réseau humide
   
|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idresh|Identifiant unique d'objet|bigint| |
|refprod|Référence producteur de l'entité|character varying(254)| |
|natresh|Nature du réseau humide|character varying(5)| |
|enservice|Objet en service ou non (abandonné)|character varying(1)| |
|sourmaj|Source de la mise à jour|character varying(100)| |
|datemaj|Date de la dernière mise à jour des informations|date| |
|qualgloc|Qualité de la géolocalisation (XYZ)|character varying(1)| |
|insee|Code INSEE|character varying(5)| |
|refcontrat|Références du contrat de délégation|character varying(254)| |
|observ|Observations|character varying(254)| |
|dbinsert|Horodatage de l'intégration en base de l'objet|timestamp without time zone| |
|dbupdate|Horodatage de la mise à jour en base de l'objet|timestamp without time zone| |

Particularité(s) à noter :
* Une clé primaire existe sur le champ idresh
---

   `geo_resh_can` : Classe décrivant une canalisation d'un réseau humide

|Nom attribut | Définition | Type | Valeurs par défaut |
|:---|:---|:---|:---|
|idresh|Identifiant unique d'objet|bigint| |
|branchemnt|Canalisation de branchement individuel (O/N)|character varying(1)| |
|materiau|Matériau de la canalisation|character varying(80)| |
|diametre|Diamètre nominal de la canalisation (en millimètres)|integer| |
|modecirc|Mode de circulation de l'eau à l'intérieur de la canalisation|character varying(80)| |
|longcalc|Longueur calculée de la canalisation en mètre|numeric(7,3)| |
|geom|Géométrie linéaire de l'objet|geometry(LineString,2154)| |

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

