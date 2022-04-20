/*
Base de données "simplifiée" des réseaux eau et assainissement issues des données concessionnaires
Creation du squelette de la structure (table, séquence, ...)
init_bd_resh_light.sql

GeoCompiegnois - http://geo.compiegnois.fr/
Auteur : Florent Vanhoutte
*/

-- 2021/02/21 : FV / initialisation du code avec comme point de départ le format RAEPA 1.1
-- 2022/04/01 : FV / revision du code avec élargissement à quelques attributs complémentaires du format RAEPA principalement (ex : période de pose, forme section, abréviation matériau (étiquette), maitre d'ouvrage, exploitant) et dans le cadre d'une extension au Grand Compiégnois
-- 2022/04/13 : FV / ajout vues spécifiques par sstyle assainissement (UN, EU, EP)
-- 2022/04/15 : FV / ajout vue spécifique sstype assainissement indéterminé + ajustements droits

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      SUPPRESSION                                                             ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- vue
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canae;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canass;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canasseu;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canassun;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canassep;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_canassnr;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvae;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvass;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvasseu;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvassun;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvassep;
DROP MATERIALIZED VIEW IF EXISTS m_reseau_humide.geo_vm_resh_ouvassnr;


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


-- #################################################################### VUE CANALISATION ASSEU ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_canasseu

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canasseu;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canasseu AS 
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
WHERE a.natresh IN ('ASSEU')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canasseu
  IS 'Canalisation du réseau d''assainissement des eaux usées';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.anfinpose IS 'Année marquant la fin de la période de pose';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.branchemnt IS 'Canalisation de branchement individuel (O/N)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.materiau IS 'Matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.mateabrev IS 'Abréviation du matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.formcana IS 'Forme (Section) de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.modecirc IS 'Mode de circulation de l''eau à l''intérieur de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.longcalc IS 'Longueur calculée de la canalisation en mètre';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canasseu.geom IS 'Géométrie linéaire de l''objet';


-- #################################################################### VUE OUVRAGE ASSEU ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_ouvasseu

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvasseu;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvasseu AS 
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
WHERE a.natresh IN ('ASSEU')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvasseu
  IS 'Ouvrage du réseau d''assainissement des eaux usées';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.anfinpose IS 'Année marquant la fin de la période de pose';   
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.fnouv IS 'Fonction de l''ouvrage du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.y IS 'Coordonnée Y Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.ztn IS 'Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)'; 
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.zrad IS 'Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvasseu.geom IS 'Géométrie ponctuelle de l''objet';


-- #################################################################### VUE CANALISATION ASSUN ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_canassun

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassun;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassun AS 
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
WHERE a.natresh IN ('ASSUN')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassun
  IS 'Canalisation du réseau d''assainissement unitaire';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.anfinpose IS 'Année marquant la fin de la période de pose';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.branchemnt IS 'Canalisation de branchement individuel (O/N)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.materiau IS 'Matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.mateabrev IS 'Abréviation du matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.formcana IS 'Forme (Section) de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.modecirc IS 'Mode de circulation de l''eau à l''intérieur de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.longcalc IS 'Longueur calculée de la canalisation en mètre';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassun.geom IS 'Géométrie linéaire de l''objet';


-- #################################################################### VUE OUVRAGE ASSUN ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_ouvassun

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassun;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassun AS 
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
WHERE a.natresh IN ('ASSUN')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassun
  IS 'Ouvrage du réseau d''assainissement unitaire';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.anfinpose IS 'Année marquant la fin de la période de pose';   
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.fnouv IS 'Fonction de l''ouvrage du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.y IS 'Coordonnée Y Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.ztn IS 'Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)'; 
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.zrad IS 'Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassun.geom IS 'Géométrie ponctuelle de l''objet';

-- #################################################################### VUE CANALISATION ASSEP ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_canassep

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassep;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassep AS 
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
WHERE a.natresh IN ('ASSEP')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassep 
  IS 'Canalisation du réseau d''assainissement des eaux pluviales';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.anfinpose IS 'Année marquant la fin de la période de pose';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.branchemnt IS 'Canalisation de branchement individuel (O/N)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.materiau IS 'Matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.mateabrev IS 'Abréviation du matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.formcana IS 'Forme (Section) de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.modecirc IS 'Mode de circulation de l''eau à l''intérieur de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.longcalc IS 'Longueur calculée de la canalisation en mètre';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassep.geom IS 'Géométrie linéaire de l''objet';


-- #################################################################### VUE OUVRAGE ASSEP ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_ouvassep

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassep;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassep AS 
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
WHERE a.natresh IN ('ASSEP')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassep
  IS 'Ouvrage du réseau d''assainissement des eaux pluviales';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.anfinpose IS 'Année marquant la fin de la période de pose';   
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.fnouv IS 'Fonction de l''ouvrage du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.y IS 'Coordonnée Y Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.ztn IS 'Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)'; 
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.zrad IS 'Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassep.geom IS 'Géométrie ponctuelle de l''objet';

-- #################################################################### VUE CANALISATION ASSNR ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_canassnr

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassnr;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassnr AS 
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
WHERE a.natresh IN ('ASS')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassnr 
  IS 'Canalisation du réseau d''assainissement (sous-type indéterminé)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.anfinpose IS 'Année marquant la fin de la période de pose';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.branchemnt IS 'Canalisation de branchement individuel (O/N)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.materiau IS 'Matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.mateabrev IS 'Abréviation du matériau de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.diametre IS 'Diamètre nominal de la canalisation (en millimètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.formcana IS 'Forme (Section) de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.modecirc IS 'Mode de circulation de l''eau à l''intérieur de la canalisation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.longcalc IS 'Longueur calculée de la canalisation en mètre';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_canassnr.geom IS 'Géométrie linéaire de l''objet';


-- #################################################################### VUE OUVRAGE ASSNR ###############################################
        
-- View: m_reseau_humide.geo_vm_resh_ouvassnr

-- DROP MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassnr;

CREATE MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassnr AS 
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
WHERE a.natresh IN ('ASS')
ORDER BY a.idresh;

COMMENT ON MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassnr
  IS 'Ouvrage du réseau d''assainissement (sous-type indéterminé)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.idresh IS 'Identifiant unique d''objet';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.refprod IS 'Référence producteur de l''entité';  
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.natresh IS 'Nature du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.enservice IS 'Objet en service ou non (abandonné)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.andebpose IS 'Année marquant le début de la période de pose';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.anfinpose IS 'Année marquant la fin de la période de pose';   
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.sourmaj IS 'Source de la mise à jour';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.datemaj IS 'Date de la dernière mise à jour des informations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.qualgloc IS 'Qualité de la géolocalisation (XYZ)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.insee IS 'Code INSEE';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.mouvrage IS 'Maître d''ouvrage du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.gexploit IS 'Gestionnaire exploitant du réseau';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.refcontrat IS 'Référence du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.libcontrat IS 'Nom du contrat de délégation';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.observ IS 'Observations';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.fnouv IS 'Fonction de l''ouvrage du réseau humide';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.y IS 'Coordonnée Y Lambert 93 (en mètres)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.ztn IS 'Altimétrie du terrain naturel (en mètres, Référentiel NGFIGN69)'; 
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.zrad IS 'Altimétrie de la cote radier (en mètres, Référentiel NGFIGN69)';
COMMENT ON COLUMN m_reseau_humide.geo_vm_resh_ouvassnr.geom IS 'Géométrie ponctuelle de l''objet';


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        DROITS                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


ALTER TABLE m_reseau_humide.lt_resh_natresh
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.lt_resh_natresh TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.lt_resh_natresh TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.lt_resh_natresh TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.lt_resh_natresh TO sig_edit;

ALTER TABLE m_reseau_humide.an_resh_objet
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.an_resh_objet TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.an_resh_objet TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.an_resh_objet TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.an_resh_objet TO sig_edit;
 
ALTER TABLE m_reseau_humide.geo_resh_can
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_resh_can TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_resh_can TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_resh_can TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_resh_can TO sig_edit;

ALTER TABLE m_reseau_humide.geo_resh_ouv
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_resh_ouv TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_resh_ouv TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_resh_ouv TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_resh_ouv TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canae
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canae TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canae TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canae TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canae TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvae
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvae TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvae TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvae TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvae TO sig_edit;
 
ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canass
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canass TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canass TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canass TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canass TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvass
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvass TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvass TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvass TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvass TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canasseu
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canasseu TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canasseu TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canasseu TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canasseu TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvasseu
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvasseu TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvasseu TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvasseu TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvasseu TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassun
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canassun TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canassun TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canassun TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canassun TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassun
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvassun TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvassun TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvassun TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvassun TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassep
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canassep TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canassep TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canassep TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canassep TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassep
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvassep TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvassep TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvassep TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvassep TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_canassnr
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canassnr TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_canassnr TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_canassnr TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_canassnr TO sig_edit;

ALTER MATERIALIZED VIEW m_reseau_humide.geo_vm_resh_ouvassnr
  OWNER TO sig_create;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvassnr TO sig_create;
GRANT SELECT ON TABLE m_reseau_humide.geo_vm_resh_ouvassnr TO sig_read;
GRANT ALL ON TABLE m_reseau_humide.geo_vm_resh_ouvassnr TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_reseau_humide.geo_vm_resh_ouvassnr TO sig_edit;
