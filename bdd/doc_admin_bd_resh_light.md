![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base simplifiée des réseaux humides

## Principes
* **généralité**
 
* **résumé fonctionnel**


## Schéma fonctionnel

![schema_fonctionnel](img/schema_fonctionnel_resh_light.png)

## Dépendances (non critiques)

La base de données simplifié des réseaux humides ne présente aucune dépendance à des données tierces (référentiel ou métier).

## Classes d'objets

L'ensemble des classes d'objets de gestion sont stockées dans le schéma m_reseau_humide.

 ### classes d'objets de gestion :
  
   `an_resh_objet` : Classe abstraite décrivant un objet d''un réseau humide.
   
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
