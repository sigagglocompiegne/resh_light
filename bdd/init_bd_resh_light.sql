/*
Base de données "simplifiée" des réseaux eau et assainissement issues des données concessionnaires
Creation du squelette de la structure (table, séquence, ...)
init_bd_resh_light.sql

GeoCompiegnois - http://geo.compiegnois.fr/
Auteur : Florent Vanhoutte
*/

-- 2021/02/21 : FV / initialisation du code avec comme point de départ le format RAEPA 1.1
-- 2022/04/01 : FV / revision du code avec élargissement à quelques attributs complémentaires du format RAEPA principalement (ex : période de pose, forme section, abréviation matériau (étiquette), maitre d'ouvrage, exploitant) et dans le cadre d'une extension au Grand Compiégnois


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      SUPPRESSION                                                             ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- vue
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canae;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canass;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvae;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvass;
-- fkey
ALTER TABLE IF EXISTS m_reseau_humide.geo_resh_can DROP CONSTRAINT geo_resh_can_idresh_fkey;
ALTER TABLE IF EXISTS m_reseau_humide.geo_resh_ouv DROP CONSTRAINT geo_resh_ouv_idresh_fkey;
ALTER TABLE IF EXISTS m_reseau_humide.an_resh_objet DROP CONSTRAINT lt_resh_natresh_fkey;
-- classe
DROP TABLE IF EXISTS m_reseau_humide.geo_resh_ouv;
DROP TABLE IF EXISTS m_reseau_humide.geo_resh_can;
DROP TABLE IF EXISTS m_reseau_humide.an_resh_objet;
-- domaine de valeur
DROP TABLE IF EXISTS m_reseau_humide.lt_resh_natresh;
-- sequence
DROP SEQUENCE IF EXISTS m_reseau_humide.idresh_seq;



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- **************  Nature du réseau  **************

-- Table: m_reseau_humide.lt_resh_natresh

-- DROP TABLE m_reseau_humide.lt_resh_natresh;

CREATE TABLE m_reseau_humide.lt_resh_natresh
(
  code character varying(7) NOT NULL,
  valeur character varying(80) NOT NULL,
  couleur character varying(7) NOT NULL,
  CONSTRAINT lt_resh_natresh_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_humide.lt_resh_natresh
  IS 'Nature du réseau humide conformément à la liste des réseaux de la NF P98-332';
COMMENT ON COLUMN m_reseau_humide.lt_resh_natresh.code IS 'Code de la liste énumérée relative à la nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.lt_resh_natresh.valeur IS 'Valeur de la liste énumérée relative à la nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.lt_resh_natresh.couleur IS 'Code couleur (hexadecimal) des réseaux enterrés selon la norme NF P 98-332';

INSERT INTO m_reseau_humide.lt_resh_natresh(
            code, valeur, couleur)
    VALUES
('AEP','Eau potable','#00B0F0'),
('ASS','Assainissement et pluvial','#663300'),
('ASSEP','Eaux pluviales','#663300'),
('ASSEU','Eaux usées','#663300'),
('ASSUN','Réseau unitaire','#663300');


-- voir ultérieurement à ajouter des domaines pour harmoniser type d'ouvrage, table des abréviations de matériau etc ... 


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                     SEQUENCE                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- Sequence: m_reseau_humide.idresh_seq
-- DROP SEQUENCE m_reseau_humide.idresh_seq;

CREATE SEQUENCE m_reseau_humide.idresh_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;

  
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                  CLASSE OBJET                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- ##############################################################################################################################################
-- #                                                                      RESEAU                                                                #
-- ##############################################################################################################################################


-- ################################################################ CLASSE RESEAU ##############################################

-- Table: m_reseau_humide.an_resh_objet

-- DROP TABLE m_reseau_humide.an_resh_objet;

CREATE TABLE m_reseau_humide.an_resh_objet
(
  idresh bigint NOT NULL,
  refprod character varying(254),
  natresh character varying(5),
  enservice character varying(1),
  andebpose character varying(4),
  anfinpose character varying(4), 
  sourmaj character varying(100) NOT NULL,  
  datemaj date NOT NULL,
  qualgloc character varying(1) NOT NULL DEFAULT 'C', 
  insee character varying(5),
  mouvrage character varying(100), 
  gexploit character varying(100),
  refcontrat character varying(100),
  libcontrat character varying(254), 
  observ character varying(254),
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,  
  CONSTRAINT an_resh_objet_pkey PRIMARY KEY (idresh)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_humide.an_resh_objet
  IS 'Classe abstraite décrivant un objet d''un réseau humide';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.refprod IS 'Référence producteur de l''entité';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.anfinpose IS 'Année marquant la fin de la période de pose';  
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.an_resh_objet.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';

ALTER TABLE m_reseau_humide.an_resh_objet ALTER COLUMN idresh SET DEFAULT nextval('m_reseau_humide.idresh_seq'::regclass);


-- ################################################################ CLASSE OUV ##############################################

-- Table: m_reseau_humide.geo_resh_ouv

-- DROP TABLE m_reseau_humide.geo_resh_ouv;

CREATE TABLE m_reseau_humide.geo_resh_ouv
(
  idresh bigint NOT NULL,
  fnouv character varying(80) NOT NULL,  
  x numeric(10,3) NOT NULL,
  y numeric(11,3) NOT NULL,
  ztn numeric(7,3) NOT NULL,
  zrad numeric(7,3) NOT NULL,
  geom geometry(Point,2154) NOT NULL,
  CONSTRAINT geo_resh_ouv_pkey PRIMARY KEY (idresh)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_reseau_humide.geo_resh_ouv
  IS 'Classe décrivant un ouvrage d''un réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_resh_ouv.idresh IS 'Identifiant unique d''objet';
COMMENT ON COLUMN m_reseau_humide.geo_resh_ouv.fnouv IS 'Fonction de l''ouvrage du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_resh_ouv.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_resh_ouv.y IS 'Coordonnée Y Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_resh_ouv.ztn IS 'Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)'; 
COMMENT ON COLUMN m_reseau_humide.geo_resh_ouv.zrad IS 'Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)';
COMMENT ON COLUMN m_reseau_humide.geo_resh_ouv.geom IS 'Géométrie ponctuelle de l''objet';


-- ################################################################ CLASSE CANALISATION ##############################################

-- Table: m_reseau_humide.geo_resh_can

-- DROP TABLE m_reseau_humide.geo_resh_can;

CREATE TABLE m_reseau_humide.geo_resh_can
(
  idresh bigint NOT NULL,
  branchemnt character varying(1),
  materiau character varying(80),
  mateabrev character varying(5),
  diametre integer,
  formcana character varying(30),
  modecirc character varying(80),   
  longcalc numeric(7,3) NOT NULL,
  geom geometry(LineString,2154) NOT NULL,
  CONSTRAINT geo_resh_can_pkey PRIMARY KEY (idresh)  
)
WITH (
  OIDS=FALSE
);


COMMENT ON TABLE m_reseau_humide.geo_resh_can
  IS 'Classe décrivant une canalisation d''un réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.idresh IS 'Identifiant unique d''objet';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.branchemnt IS 'Canalisation de branchement individuel (O/N)';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.materiau IS 'Matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.mateabrev IS 'Abréviation du matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.formcana IS 'Forme (Section) de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.modecirc IS 'Mode de circulation de l''eau à l''intérieur de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.longcalc IS 'Longueur calculée de la canalisation en mètre';
COMMENT ON COLUMN m_reseau_humide.geo_resh_can.geom IS 'Géométrie linéaire de l''objet';



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                           FKEY (clé étrangère)                                                               ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- NATURE DU RESEAU

ALTER TABLE m_reseau_humide.an_resh_objet               
  ADD CONSTRAINT lt_resh_natresh_fkey FOREIGN KEY (natresh)
      REFERENCES m_reseau_humide.lt_resh_natresh (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

-- IDRESH

ALTER TABLE m_reseau_humide.geo_resh_can
  ADD CONSTRAINT geo_resh_can_idresh_fkey FOREIGN KEY (idresh)
      REFERENCES m_reseau_humide.an_resh_objet (idresh) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE m_reseau_humide.geo_resh_ouv
  ADD CONSTRAINT geo_resh_ouv_idresh_fkey FOREIGN KEY (idresh)
      REFERENCES m_reseau_humide.an_resh_objet (idresh) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        VUES                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- #################################################################### VUE CANALISATION AE ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_canae

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canae;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canae AS 
 SELECT 
  a.idresh,
  a.refprod,
  a.natresh,
  a.enservice,
  g.branchemnt,
  g.materiau,
  g.mateabrev,  
  g.diametre,
  g.formcana,   
  g.modecirc,   
  g.longcalc,
  a.andebpose,
  a.anfinpose,
  a.sourmaj,  
  a.datemaj,
  a.qualgloc,
  a.insee,
  a.mouvrage,
  a.gexploit,
  a.refcontrat,
  a.libcontrat, 
  a.observ,
  a.dbinsert,  
  a.dbupdate,
  g.geom
  
FROM m_reseau_humide.geo_resh_can g
LEFT JOIN m_reseau_humide.an_resh_objet a
ON g.idresh = a.idresh
WHERE a.natresh = 'AEP'
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canae
  IS 'Canalisation du réseau d''adduction d''eau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.anfinpose IS 'Année marquant la fin de la période de pose';   
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.branchemnt IS 'Canalisation de branchement individuel (O/N)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.materiau IS 'Matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.mateabrev IS 'Abréviation du matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.formcana IS 'Forme (Section) de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.modecirc IS 'Mode de circulation de l''eau à l''intérieur de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.longcalc IS 'Longueur calculée de la canalisation en mètre';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canae.geom IS 'Géométrie linéaire de l''objet';


-- #################################################################### VUE CANALISATION ASS ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_canass

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canass;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canass AS 
 SELECT 
  a.idresh,
  a.refprod,
  a.natresh,
  a.enservice,
  g.branchemnt,
  g.materiau,
  g.mateabrev,  
  g.diametre,
  g.formcana,  
  g.modecirc,   
  g.longcalc,
  a.andebpose,
  a.anfinpose,  
  a.sourmaj,  
  a.datemaj,
  a.qualgloc,
  a.insee,
  a.mouvrage,
  a.gexploit,  
  a.refcontrat,
  a.libcontrat, 
  a.observ,
  a.dbinsert,  
  a.dbupdate,
  g.geom
  
FROM m_reseau_humide.geo_resh_can g
LEFT JOIN m_reseau_humide.an_resh_objet a
ON g.idresh = a.idresh
WHERE a.natresh IN ('ASS', 'ASSEP', 'ASSEU', 'ASSUN')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canass
  IS 'Canalisation du réseau d''assainissement';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.anfinpose IS 'Année marquant la fin de la période de pose';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.branchemnt IS 'Canalisation de branchement individuel (O/N)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.materiau IS 'Matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.mateabrev IS 'Abréviation du matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.formcana IS 'Forme (Section) de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.modecirc IS 'Mode de circulation de l''eau à l''intérieur de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.longcalc IS 'Longueur calculée de la canalisation en mètre';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canass.geom IS 'Géométrie linéaire de l''objet';



-- #################################################################### VUE OUVRAGE AE ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_ouvae

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvae;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvae AS 
 SELECT 
  a.idresh,
  a.refprod,
  a.natresh,
  a.enservice,
  g.fnouv,
  g.x,
  g.y,
  g.ztn,   
  g.zrad,
  a.andebpose,
  a.anfinpose,  
  a.sourmaj,  
  a.datemaj,
  a.qualgloc,
  a.insee,
  a.mouvrage,
  a.gexploit,    
  a.refcontrat,
  a.libcontrat, 
  a.observ,
  a.dbinsert,  
  a.dbupdate,
  g.geom
  
FROM m_reseau_humide.geo_resh_ouv g
LEFT JOIN m_reseau_humide.an_resh_objet a
ON g.idresh = a.idresh
WHERE a.natresh = 'AEP'
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvae
  IS 'Ouvrage du réseau d''adduction d''eau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.anfinpose IS 'Année marquant la fin de la période de pose';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.fnouv IS 'Fonction de l''ouvrage du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.y IS 'Coordonnée Y Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.ztn IS 'Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)'; 
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.zrad IS 'Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvae.geom IS 'Géométrie ponctuelle de l''objet';


-- #################################################################### VUE OUVRAGE ASS ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_ouvass

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvass;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvass AS 
 SELECT 
  a.idresh,
  a.refprod,
  a.natresh,
  a.enservice,
  g.fnouv,
  g.x,
  g.y,
  g.ztn,   
  g.zrad,
  a.andebpose,
  a.anfinpose,  
  a.sourmaj,  
  a.datemaj,
  a.qualgloc,
  a.insee,
  a.mouvrage,
  a.gexploit,    
  a.refcontrat,
  a.libcontrat, 
  a.observ,
  a.dbinsert,  
  a.dbupdate,
  g.geom
  
FROM m_reseau_humide.geo_resh_ouv g
LEFT JOIN m_reseau_humide.an_resh_objet a
ON g.idresh = a.idresh
WHERE a.natresh IN ('ASS', 'ASSEP', 'ASSEU', 'ASSUN')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvass
  IS 'Ouvrage du réseau d''assainissement';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.anfinpose IS 'Année marquant la fin de la période de pose';   
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.fnouv IS 'Fonction de l''ouvrage du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.y IS 'Coordonnée Y Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.ztn IS 'Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)'; 
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.zrad IS 'Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvass.geom IS 'Géométrie ponctuelle de l''objet';



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        DROITS                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


ALTER TABLE m_reseau_humide.lt_resh_natresh
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.lt_resh_natresh TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.lt_resh_natresh TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.lt_resh_natresh TO edit_sig;

ALTER TABLE m_reseau_humide.an_resh_objet
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.an_resh_objet TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.an_resh_objet TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.an_resh_objet TO edit_sig;

ALTER TABLE m_reseau_humide.geo_resh_can
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_resh_can TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_resh_can TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.geo_resh_can TO edit_sig;

ALTER TABLE m_reseau_humide.geo_resh_ouv
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_resh_ouv TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_resh_ouv TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.geo_resh_ouv TO edit_sig;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvae
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvae TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvae TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvae TO edit_sig;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvass
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvass TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvass TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvass TO edit_sig;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canae
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canae TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canae TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canae TO edit_sig;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canass
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canass TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canass TO read_sig;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canass TO edit_sig;
