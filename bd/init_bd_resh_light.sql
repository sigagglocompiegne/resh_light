/*
Réseau d'eau pluviale
Creation du squelette de la structure (table, séquence, trigger,...) du bloc de données "métadonnée de production"
init_bd_resh_assep_0_metaprod.sql
PostGIS

GeoCompiegnois - http://geo.compiegnois.fr/
Auteur : Florent Vanhoutte
*/




-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        DROP                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- schema
DROP SCHEMA IF EXISTS m_resh_assep CASCADE;



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                       SCHEMA                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- Schema: m_resh_assep

-- DROP SCHEMA m_resh_assep;

CREATE SCHEMA m_resh_assep;

COMMENT ON SCHEMA m_resh_assep
  IS 'Réseaux d''eau pluviale';



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINES DE VALEURS                                                           ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- **************  Classe de precision  **************

-- ### domaine de valeur hérité du standard StaR-DT

-- Table: m_resh_assep.lt_assep_clprec

-- DROP TABLE m_resh_assep.lt_assep_clprec;

CREATE TABLE m_resh_assep.lt_assep_clprec
(
  code character varying(1) NOT NULL,
  valeur character varying(80) NOT NULL,
  definition character varying(255),
  CONSTRAINT lt_clprec_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_resh_assep.lt_assep_clprec
  IS 'Classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';
COMMENT ON COLUMN m_resh_assep.lt_assep_clprec.code IS 'Code de la liste énumérée relative à la classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';
COMMENT ON COLUMN m_resh_assep.lt_assep_clprec.valeur IS 'Valeur de la liste énumérée relative à la classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';
COMMENT ON COLUMN m_resh_assep.lt_assep_clprec.definition IS 'Définition de la liste énumérée relative à la classe de précision au sens de l''arrêté interministériel du 15 février 2012 modifié (DT-DICT)';

INSERT INTO m_resh_assep.lt_assep_clprec(
            code, valeur, definition)
    VALUES
('A','Classe A','Classe de précision inférieure 40 cm'),
('B','Classe B','Classe de précision supérieure à 40 cm et inférieure à 1,50 m'),
('C','Classe C','Classe de précision supérieure à 1,50 m ou inconnue');


-- **************  Nature du réseau  **************

-- ### domaine de valeur hérité du standard StaR-DT, préexistant au PCRS mais avec des variantes

-- Table: m_resh_assep.lt_assep_natres

-- DROP TABLE m_resh_assep.lt_assep_natres;

CREATE TABLE m_resh_assep.lt_assep_natres
(
  code character varying(7) NOT NULL,
  valeur character varying(80) NOT NULL,
  couleur character varying(7) NOT NULL,
  CONSTRAINT lt_natres_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_resh_assep.lt_assep_natres
  IS 'Type de réseau conformément à la liste des réseaux de la NF P98-332';
COMMENT ON COLUMN m_resh_assep.lt_assep_natres.code IS 'Code de la liste énumérée relative à la nature du réseau';
COMMENT ON COLUMN m_resh_assep.lt_assep_natres.valeur IS 'Valeur de la liste énumérée relative à la nature du réseau';
COMMENT ON COLUMN m_resh_assep.lt_assep_natres.couleur IS 'Code couleur (hexadecimal) des réseaux enterrés selon la norme NF P 98-332';

INSERT INTO m_resh_assep.lt_assep_natres(
            code, valeur, couleur)
    VALUES
('00','Non défini','#FFFFFF'),
('ELEC','Electricité','#FF0000'),
('ELECECL','Eclairage public','#FF0000'),
('ELECSLT','Signalisation lumineuse tricolore','#FF0000'),
('ELECTRD','Eléctricité transport/distribution','#FF0000'), -- PCRS décomposé en 2
-- PCRS : ('ELECBT','Eléctricité basse tension','#FF0000'),
-- PCRS : ('ELECHT','Eléctricité haute tension','#FF0000'),
('GAZ','Gaz','#FFFF00'),
('CHIM','Produits chimiques','#F99707'),
('AEP','Eau potable','#00B0F0'),
('ASS','Assainissement et pluvial','#663300'), -- PCRS : ('ASSA','Assainissement et pluvial','#663300'),
('ASSEP','Eaux pluviales','#663300'),
('ASSEU','Eaux usées','#663300'),
('ASSUN','Réseau unitaire','#663300'), -- PCRS : ('ASSRU','Réseau unitaire','#663300'), 
('CHAU','Chauffage et climatisation','#7030A0'),
('COM','Télécom','#00FF00'),
('DECH','Déchets','#663300'),
('INCE','Incendie','#00B0F0'),
('PINS','Protection Inondation-Submersion','#663300'), -- n'existe pas PCRS
('MULT','Multi réseaux','#FF00FF');


-- **************  Type d'opération  **************

-- Table: m_resh_assep.lt_assep_typope

-- DROP TABLE m_resh_assep.lt_assep_typope;

CREATE TABLE m_resh_assep.lt_assep_typope
(
  code character varying(2) NOT NULL,
  valeur character varying(80) NOT NULL,
  definition character varying(255),
  CONSTRAINT lt_typope_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_resh_assep.lt_assep_typope
  IS 'Type d''opération de détection des réseaux enterrés';
COMMENT ON COLUMN m_resh_assep.lt_assep_typope.code IS 'Code de la liste énumérée relative au type d''opération de détection des réseaux enterrés';
COMMENT ON COLUMN m_resh_assep.lt_assep_typope.valeur IS 'Valeur de la liste énumérée relative au type d''opération de détection des réseaux enterrés';
COMMENT ON COLUMN m_resh_assep.lt_assep_typope.definition IS 'Définition de la liste énumérée relative au type d''opération de détection des réseaux enterrés';

INSERT INTO m_resh_assep.lt_assep_typope(
            code, valeur, definition)
    VALUES
('00','Non renseigné','Non renseigné'),
('IC','Investigation complémentaire','Opération menée dans le cadre de travaux par le maitre d''ouvrage'),
('OL','Opération de localisation','Opération menée dans le cadre de démarches d''amélioration continue par l''exploitant du réseau'),
('99','Autre','Autre');



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                     SEQUENCE                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- Sequence: m_resh_assep.idopedetec_seq

-- DROP SEQUENCE m_resh_assep.idopedetec_seq;

CREATE SEQUENCE m_resh_assep.idopedetec_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;

-- Sequence: m_resh_assep.idexcdetec_seq

-- DROP SEQUENCE m_resh_assep.idexcdetec_seq;

CREATE SEQUENCE m_resh_assep.idexcdetec_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;

-- Sequence: m_resh_assep.idptleve_seq

-- DROP SEQUENCE m_resh_assep.idptleve_seq;

CREATE SEQUENCE m_resh_assep.idptleve_seq
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



-- #################################################################### CLASSE OPERATION DE DETECTION ###############################################

-- Table: m_resh_assep.geo_assep_operation

-- DROP TABLE m_resh_assep.geo_assep_operation;

CREATE TABLE m_resh_assep.geo_assep_operation
(
  idopedetec character varying(254) NOT NULL,
  refope character varying(80) NOT NULL, -- fkey vers classe opedetec
  typope character varying(2) NOT NULL, -- fkey vers domaine de valeur lt_typope
  natres character varying(7) NOT NULL, -- fkey vers domaine de valeur lt_natres
  mouvrage character varying(80) NOT NULL,
  presta character varying(80) NOT NULL,
  datefinope date NOT NULL,
  datedebope date NOT NULL,  
  observ character varying(254),
  sup_m2 integer,
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,
  geom geometry(MultiPolygon,2154) NOT NULL,
  CONSTRAINT geo_operation_pkey PRIMARY KEY (idopedetec),
  CONSTRAINT refope_ukey UNIQUE (refope) 
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_resh_assep.geo_assep_operation
  IS 'Opération de détection de réseaux';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.idopedetec IS 'Identifiant unique de l''opération de détection dans la base de données';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.typope IS 'Type d''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.natres IS 'Nature du réseau faisant l''objet de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.mouvrage IS 'Maitre d''ouvrage de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.presta IS 'Prestataire de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.datefinope IS 'Date de fin de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.datedebope IS 'Date de début de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.observ IS 'Commentaires divers';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.sup_m2 IS 'Superficie de l''opération de détection (en mètres carrés)';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_resh_assep.geo_assep_operation.geom IS 'Géométrie de l''objet';

ALTER TABLE m_resh_assep.geo_assep_operation ALTER COLUMN idopedetec SET DEFAULT nextval('m_resh_assep.idopedetec_seq'::regclass);


-- #################################################################### CLASSE ZONE D'EXCLUSION ###############################################

-- Table: m_resh_assep.geo_assep_exclusion

-- DROP TABLE m_resh_assep.geo_assep_exclusion;

CREATE TABLE m_resh_assep.geo_assep_exclusion
(
  idexcdetec character varying(254) NOT NULL,
  refexc character varying(254) NOT NULL,
  refope character varying(80) NOT NULL, -- fkey vers classe opedetec
  observ character varying(254),
  sup_m2 integer,
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,
  geom geometry(Polygon,2154) NOT NULL,
  CONSTRAINT geo_exclusion_pkey PRIMARY KEY (idexcdetec)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_resh_assep.geo_assep_exclusion
  IS 'Secteur d''exclusion de détection de réseaux';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.idexcdetec IS 'Identifiant unique du secteur d''exclusion de détection dans la base de données';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.refexc IS 'Référence du secteur d''exclusion de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.observ IS 'Commentaires divers';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.sup_m2 IS 'Superficie du secteur d''exclusion de détection (en mètres carrés)';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_resh_assep.geo_assep_exclusion.geom IS 'Géométrie de l''objet';

ALTER TABLE m_resh_assep.geo_assep_exclusion ALTER COLUMN idexcdetec SET DEFAULT nextval('m_resh_assep.idexcdetec_seq'::regclass);




-- #################################################################### CLASSE POINT DE LEVE ###############################################

-- ## revoir cette classe par rapport à celle du PCRS


-- Table: m_resh_assep.geo_assep_pointleve

-- DROP TABLE m_resh_assep.geo_assep_pointleve;

CREATE TABLE m_resh_assep.geo_assep_pointleve
(
  idptleve character varying(254) NOT NULL, -- pkey
  idptope character varying(254) NOT NULL, -- unique
  refope character varying(80) NOT NULL, -- fkey vers classe opedetec
  refptope character varying(30) NOT NULL,
  insee character varying(5) NOT NULL, 
  natres character varying(7) NOT NULL, -- fkey vers domaine de valeur lt_natres  
  x numeric(10,3) NOT NULL,
  y numeric(11,3) NOT NULL,
  z numeric(7,3) NOT NULL,
  precxy numeric (7,3) NOT NULL,
  precz numeric (7,3) NOT NULL,
  clprecxy character varying (1) NOT NULL DEFAULT 'C',  -- fkey vers domaine de valeur
  clprecz character varying (1) NOT NULL DEFAULT 'C', -- fkey vers domaine de valeur
  clprec character varying (1) NOT NULL, -- fkey vers domaine de valeur #resultat combinaison prec xy et z généré par trigger
  horodatage timestamp without time zone NOT NULL,
  observ character varying(254),
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,
  geom geometry(Point,2154) NOT NULL,
  CONSTRAINT idptleve_pkey PRIMARY KEY (idptleve),
  CONSTRAINT idptope_ukey UNIQUE (idptope)   
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_resh_assep.geo_assep_pointleve
  IS 'Point de détection/géoréférencement d''un réseau';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.idptleve IS 'Identifiant unique du point de détection dans la base de données';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.idptope IS 'Identifiant unique du point de détection de l''opération';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.refope IS 'Référence de l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.refptope IS 'Matricule/référence du point levé dans l''opération de détection';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.insee IS 'Code INSEE de la commmune';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.natres IS 'Nature du réseau levé';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.x IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.y IS 'Coordonnée X Lambert 93 (en mètres)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.z IS 'Altimétrie Z NGF de la génératrice (supérieure si enterrée, inférieure si aérienne) du réseau (en mètres)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.precxy IS 'Précision absolue en planimètre (en mètres)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.precz IS 'Précision absolue en altimétrie (en mètres)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.clprecxy IS 'Classe de précision planimétrique (XY)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.clprecz IS 'Classe de précision altimétrique (Z)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.clprec IS 'Classe de précision planimétrique et altimétrique (XYZ)';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.horodatage IS 'Horodatage détection/géoréfécement du point';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.observ IS 'Commentaires divers';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_resh_assep.geo_assep_pointleve.geom IS 'Géométrie 3D de l''objet';

ALTER TABLE m_resh_assep.geo_assep_pointleve ALTER COLUMN idptleve SET DEFAULT nextval('m_resh_assep.idptleve_seq'::regclass);



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                           FKEY (clé étrangère)                                                               ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ID

-- exclusion > operation
ALTER TABLE m_resh_assep.geo_assep_exclusion
  ADD CONSTRAINT refope_fkey FOREIGN KEY (refope)
      REFERENCES m_resh_assep.geo_assep_operation (refope) MATCH SIMPLE;

--pointleve > operation
ALTER TABLE m_resh_assep.geo_assep_pointleve
  ADD CONSTRAINT refope_fkey FOREIGN KEY (refope)
      REFERENCES m_resh_assep.geo_assep_operation (refope) MATCH SIMPLE;

-- DOMAINE DE VALEUR

-- ## NATURE DU RESEAU

-- operation
ALTER TABLE m_resh_assep.geo_assep_operation               
  ADD CONSTRAINT lt_natres_fkey FOREIGN KEY (natres)
      REFERENCES m_resh_assep.lt_assep_natres (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

-- pointleve
ALTER TABLE m_resh_assep.geo_assep_pointleve
  ADD CONSTRAINT lt_natres_fkey FOREIGN KEY (natres)
      REFERENCES m_resh_assep.lt_assep_natres (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

      
-- ## TYPE OPE

-- operation
ALTER TABLE m_resh_assep.geo_assep_operation              
  ADD CONSTRAINT lt_typope_fkey FOREIGN KEY (typope)
      REFERENCES m_resh_assep.lt_assep_typope (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION; 

-- ## CLASSE GEOLOC DT-DICT      

-- pointleve
ALTER TABLE m_resh_assep.geo_assep_pointleve
  ADD CONSTRAINT lt_clprecxy_fkey FOREIGN KEY (clprecxy)
      REFERENCES m_resh_assep.lt_assep_clprec (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,          
  ADD CONSTRAINT lt_clprecz_fkey FOREIGN KEY (clprecz)
      REFERENCES m_resh_assep.lt_assep_clprec (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,            
  ADD CONSTRAINT lt_clprec_fkey FOREIGN KEY (clprec)
      REFERENCES m_resh_assep.lt_assep_clprec (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

      
      
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        VUES                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- Pas de vue pour les classes de métadonnées de production





-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      TRIGGER                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #################################################################### FONCTION TRIGGER - GEO_POINTLEVE ###################################################

-- Function: m_resh_assep.ft_m_geo_assep_pointleve()

-- DROP FUNCTION m_resh_assep.ft_m_geo_assep_pointleve();

CREATE OR REPLACE FUNCTION m_resh_assep.ft_m_geo_assep_pointleve()
  RETURNS trigger AS
$BODY$

--déclaration variable pour stocker la séquence des id
DECLARE v_idptdetec character varying(254);

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

NEW.idptleve=nextval('m_resh_assep.idptleve_seq'::regclass);
NEW.idptope = CONCAT(NEW.refope,'-',NEW.refptope);
NEW.insee=(SELECT insee FROM r_osm.geo_vm_osm_commune_arc WHERE st_intersects(NEW.geom,geom));
NEW.x=st_x(NEW.geom);
NEW.y=st_y(NEW.geom);
-- simplification ici car si réseau souple la classe A est <0.5 et non 0.4 comme pour une canalisation rigide. De même, règles différentes pour les branchements
-- cas où le point levé ne précise pas la précision, alors par défaut = 0 donc classe C
NEW.clprecxy=CASE WHEN NEW.precxy > 0 AND NEW.precxy <= 0.4 THEN 'A' WHEN NEW.precxy > 0.4 AND NEW.precxy < 1.5 THEN 'B' ELSE 'C' END;
NEW.clprecz=CASE WHEN NEW.precxy > 0 AND NEW.precz <= 0.4 THEN 'A' WHEN NEW.precz > 0.4 AND NEW.precz < 1.5 THEN 'B' ELSE 'C' END;
NEW.clprec=CASE WHEN (NEW.clprecxy = 'A' AND NEW.clprecz = 'A') THEN 'A' WHEN ((NEW.clprecxy IN ('A','B')) AND (NEW.clprecz = 'B')) THEN 'B' WHEN (NEW.clprecxy = 'B' AND NEW.clprecz IN ('A','B')) THEN 'B' ELSE 'C' END;
NEW.dbinsert=now();
NEW.dbupdate=NULL;
NEW.geom=CASE WHEN (SELECT geom FROM m_resh_assep.geo_assep_operation WHERE (st_contains(st_buffer(geom,0.1),NEW.geom)) AND NEW.refope = refope) IS NOT NULL THEN NEW.geom ELSE NULL END;

RETURN NEW;


-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

NEW.idptleve=OLD.idptleve;
NEW.idptope = CONCAT(NEW.refope,'-',NEW.refptope);
NEW.insee=(SELECT insee FROM r_osm.geo_vm_osm_commune_arc WHERE st_intersects(NEW.geom,geom));
NEW.x=st_x(NEW.geom);
NEW.y=st_y(NEW.geom);
NEW.clprecxy=CASE WHEN NEW.precxy > 0 AND NEW.precxy <= 0.4 THEN 'A' WHEN NEW.precxy > 0.4 AND NEW.precxy < 1.5 THEN 'B' ELSE 'C' END;
NEW.clprecz=CASE WHEN NEW.precxy > 0 AND NEW.precz <= 0.4 THEN 'A' WHEN NEW.precz > 0.4 AND NEW.precz < 1.5 THEN 'B' ELSE 'C' END;
NEW.clprec=CASE WHEN (NEW.clprecxy = 'A' AND NEW.clprecz = 'A') THEN 'A' WHEN ((NEW.clprecxy IN ('A','B')) AND (NEW.clprecz = 'B')) THEN 'B' WHEN (NEW.clprecxy = 'B' AND NEW.clprecz IN ('A','B')) THEN 'B' ELSE 'C' END;
NEW.horodatage=OLD.horodatage;
NEW.dbinsert=OLD.dbinsert;
NEW.dbupdate=now();
NEW.geom=CASE WHEN (SELECT geom FROM m_resh_assep.geo_assep_operation WHERE (st_contains(st_buffer(geom,0.1),NEW.geom)) AND NEW.refope = refope) IS NOT NULL THEN NEW.geom ELSE NULL END;

RETURN NEW;
          
END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION m_resh_assep.ft_m_geo_assep_pointleve() IS 'Fonction trigger pour mise à jour des entités depuis la classe des points de réseau détectés';


-- Trigger: t_t1_geo_pointleve on m_resh_assep.geo_assep_pointleve

-- DROP TRIGGER t_t1_geo_pointleve ON m_resh_assep.geo_assep_pointleve;

CREATE TRIGGER t_t1_geo_pointleve
  BEFORE INSERT OR UPDATE
  ON m_resh_assep.geo_assep_pointleve
  FOR EACH ROW
  EXECUTE PROCEDURE m_resh_assep.ft_m_geo_assep_pointleve();
  
  

-- #################################################################### FONCTION TRIGGER - GEO_EXCLUSION ###################################################

-- Function: m_resh_assep.ft_m_geo_assep_exclusion()

-- DROP FUNCTION m_resh_assep.ft_m_geo_assep_exclusion();

CREATE OR REPLACE FUNCTION m_resh_assep.ft_m_geo_assep_exclusion()
  RETURNS trigger AS
$BODY$

--déclaration variable pour stocker la séquence des id
DECLARE v_idexcdetec character varying(254);

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

NEW.idexcdetec=nextval('m_resh_assep.idexcdetec_seq'::regclass);
NEW.sup_m2=round(st_area(NEW.geom));
NEW.dbinsert=now();
NEW.dbupdate=NULL;
NEW.geom=CASE WHEN (SELECT geom FROM m_resh_assep.geo_assep_operation WHERE (st_contains(st_buffer(geom,0.1),NEW.geom)) AND NEW.refope = refope) IS NOT NULL THEN NEW.geom ELSE NULL END;

RETURN NEW;


-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

NEW.idexcdetec=OLD.idexcdetec;
NEW.sup_m2=round(st_area(NEW.geom));
NEW.dbinsert=OLD.dbinsert;
NEW.dbupdate=now();
NEW.geom=CASE WHEN (SELECT geom FROM m_resh_assep.geo_assep_operation WHERE (st_contains(st_buffer(geom,0.1),NEW.geom)) AND NEW.refope = refope) IS NOT NULL THEN NEW.geom ELSE NULL END;

RETURN NEW;
          
END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION m_resh_assep.ft_m_geo_assep_exclusion() IS 'Fonction trigger pour mise à jour des entités depuis la classe des secteurs d''exclusion de détection des réseaux';

-- Trigger: t_t1_geo_exclusion on m_resh_assep.geo_assep_exclusion

-- DROP TRIGGER t_t1_geo_exclusion ON m_resh_assep.geo_assep_exclusion;

CREATE TRIGGER t_t1_geo_exclusion
  BEFORE INSERT OR UPDATE
  ON m_resh_assep.geo_assep_exclusion
  FOR EACH ROW
  EXECUTE PROCEDURE m_resh_assep.ft_m_geo_assep_exclusion();
  

  
-- #################################################################### FONCTION TRIGGER - GEO_OPERATION ###################################################

-- Function: m_resh_assep.ft_m_geo_assep_operation()

-- DROP FUNCTION m_resh_assep.ft_m_geo_assep_operation();

CREATE OR REPLACE FUNCTION m_resh_assep.ft_m_geo_assep_operation()
  RETURNS trigger AS
$BODY$

--déclaration variable pour stocker la séquence des id
DECLARE v_idopedetec character varying(254);

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

NEW.idopedetec=nextval('m_resh_assep.idopedetec_seq'::regclass);
NEW.datedebope=CASE WHEN NEW.datedebope > NEW.datefinope THEN NULL ELSE NEW.datedebope END;
NEW.sup_m2=round(st_area(NEW.geom));
NEW.dbinsert=now();
NEW.dbupdate=NULL;

RETURN NEW;


-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

NEW.idopedetec=OLD.idopedetec;
NEW.datedebope=CASE WHEN NEW.datedebope > NEW.datefinope THEN NULL ELSE NEW.datedebope END;
NEW.sup_m2=round(st_area(NEW.geom));
NEW.dbinsert=OLD.dbinsert;
NEW.dbupdate=now();

RETURN NEW;
          
END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION m_resh_assep.ft_m_geo_assep_operation() IS 'Fonction trigger pour mise à jour des entités depuis la classe des opérations de détection des réseaux';

-- Trigger: t_t1_geo_operation on m_resh_assep.geo_assep_operation

-- DROP TRIGGER t_t1_geo_operation ON m_resh_assep.geo_assep_operation;

CREATE TRIGGER t_t1_geo_operation
  BEFORE INSERT OR UPDATE
  ON m_resh_assep.geo_assep_operation
  FOR EACH ROW
  EXECUTE PROCEDURE m_resh_assep.ft_m_geo_assep_operation();
    
