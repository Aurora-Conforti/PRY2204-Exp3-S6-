/* =========================================================================
   PRY2204 - Modelamiento de Bases de Datos - Semana 7
   Caso: Holding Carpenter SPA
   Actividad: "Realizando el poblamiento y consultas en la base de datos
   con sentencias SQL"
   =========================================================================
   Este script debe ejecutarse conectado con el usuario PRY2204_S7,
   creado previamente con el script PRY2204_Exp3_S7_Script_crea_usuario.SQL
   ejecutado como SYS/SYSTEM (o ADMIN en Oracle Cloud).
   ========================================================================= */


/* =========================================================================
   SECCIÓN 0: BORRADO DE OBJETOS (para permitir reejecutar el script)
   Se borran en orden inverso a sus dependencias (primero las tablas
   "hijas", al final las tablas "padre"). Cada DROP está protegido con
   manejo de excepción para que el script no falle si es la primera vez
   que se ejecuta y el objeto todavía no existe (ORA-00942 para tablas,
   ORA-02289 para secuencias).
   ========================================================================= */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE dominio CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE titulacion CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE personal CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE compania CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE comuna CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE idioma CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE titulo CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE genero CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE estado_civil CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE region CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_comuna';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_compania';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/


/* =========================================================================
   CASO 1: CREACIÓN DE TABLAS (MODELO RELACIONAL NORMALIZADO)
   Orden de creación: desde las tablas fuertes (sin dependencias) hacia
   las más débiles (con mayor cantidad de dependencias).
   ========================================================================= */

-- -------------------------------------------------------------------------
-- Tabla REGION: catálogo de regiones de Chile.
-- El identificador se autoincrementa iniciando en 7 y sumando de a 2
-- (IDENTITY), tal como lo pide el enunciado.
-- -------------------------------------------------------------------------
CREATE TABLE region (
    id_region      NUMBER(2)         GENERATED ALWAYS AS IDENTITY
                                      (START WITH 7 INCREMENT BY 2) NOT NULL,
    nombre_region  VARCHAR2(25 CHAR) NOT NULL
);

ALTER TABLE region
    ADD CONSTRAINT region_pk PRIMARY KEY (id_region);


-- -------------------------------------------------------------------------
-- Tabla ESTADO_CIVIL: catálogo de estados civiles del personal.
-- -------------------------------------------------------------------------
CREATE TABLE estado_civil (
    id_estado_civil        VARCHAR2(2 CHAR)  NOT NULL,
    descripcion_est_civil  VARCHAR2(25 CHAR) NOT NULL
);

ALTER TABLE estado_civil
    ADD CONSTRAINT estado_civil_pk PRIMARY KEY (id_estado_civil);


-- -------------------------------------------------------------------------
-- Tabla GENERO: catálogo de géneros del personal.
-- -------------------------------------------------------------------------
CREATE TABLE genero (
    id_genero          VARCHAR2(3 CHAR)  NOT NULL,
    descripcion_genero VARCHAR2(25 CHAR) NOT NULL
);

ALTER TABLE genero
    ADD CONSTRAINT genero_pk PRIMARY KEY (id_genero);


-- -------------------------------------------------------------------------
-- Tabla TITULO: catálogo de títulos profesionales/técnicos.
-- -------------------------------------------------------------------------
CREATE TABLE titulo (
    id_titulo          VARCHAR2(3 CHAR)  NOT NULL,
    descripcion_titulo VARCHAR2(60 CHAR) NOT NULL
);

ALTER TABLE titulo
    ADD CONSTRAINT titulo_pk PRIMARY KEY (id_titulo);


-- -------------------------------------------------------------------------
-- Tabla IDIOMA: catálogo de idiomas.
-- El identificador se autoincrementa iniciando en 25 y sumando de a 3
-- (IDENTITY), tal como lo pide el enunciado.
-- -------------------------------------------------------------------------
CREATE TABLE idioma (
    id_idioma      NUMBER(3)         GENERATED ALWAYS AS IDENTITY
                                      (START WITH 25 INCREMENT BY 3) NOT NULL,
    nombre_idioma  VARCHAR2(30 CHAR) NOT NULL
);

ALTER TABLE idioma
    ADD CONSTRAINT idioma_pk PRIMARY KEY (id_idioma);


-- -------------------------------------------------------------------------
-- Tabla COMUNA: cada comuna pertenece a una región. La clave primaria es
-- compuesta (id_comuna, cod_region) según el modelo relacional. El
-- id_comuna se poblará con un objeto SECUENCIA (Caso 3), no con IDENTITY.
-- -------------------------------------------------------------------------
CREATE TABLE comuna (
    id_comuna      NUMBER(5)         NOT NULL,
    comuna_nombre  VARCHAR2(25 CHAR) NOT NULL,
    cod_region     NUMBER(2)         NOT NULL
);

ALTER TABLE comuna
    ADD CONSTRAINT comuna_pk PRIMARY KEY (id_comuna, cod_region);

ALTER TABLE comuna
    ADD CONSTRAINT comuna_fk_region FOREIGN KEY (cod_region)
    REFERENCES region (id_region);


-- -------------------------------------------------------------------------
-- Tabla COMPANIA: compañías que forman parte del Holding Carpenter SPA.
-- El nombre de la empresa no se debe repetir (UNIQUE). El id_empresa se
-- poblará con un objeto SECUENCIA (Caso 3), no con IDENTITY.
-- -------------------------------------------------------------------------
CREATE TABLE compania (
    id_empresa       NUMBER(2)         NOT NULL,
    nombre_empresa   VARCHAR2(25 CHAR) NOT NULL,
    calle            VARCHAR2(50 CHAR) NOT NULL,
    numeracion       NUMBER(5)         NOT NULL,
    renta_promedio   NUMBER(10)        NOT NULL,
    pct_aumento      NUMBER(4,3),
    cod_comuna       NUMBER(5)         NOT NULL,
    cod_region       NUMBER(2)         NOT NULL
);

ALTER TABLE compania
    ADD CONSTRAINT compania_pk PRIMARY KEY (id_empresa);

ALTER TABLE compania
    ADD CONSTRAINT compania_un_nombre UNIQUE (nombre_empresa);

ALTER TABLE compania
    ADD CONSTRAINT compania_fk_comuna FOREIGN KEY (cod_comuna, cod_region)
    REFERENCES comuna (id_comuna, cod_region);


-- -------------------------------------------------------------------------
-- Tabla PERSONAL: trabajadores de las compañías del holding.
-- El RUT se separa en número + dígito verificador (DV). El sueldo mínimo
-- y la restricción del DV se agregan en el Caso 2 mediante ALTER TABLE.
-- Nota: el diagrama entregado define "sueldo" como NUMBER(5), pero esa
-- precisión (máximo 99.999) es incompatible con la regla de negocio del
-- Caso 2 que exige un sueldo mínimo de $450.000. Se amplía a NUMBER(8)
-- para poder cumplir ambas condiciones sin conflicto.
-- cod_genero, cod_estado_civil y encargado_rut son opcionales (NULL),
-- de acuerdo a las líneas punteadas del diagrama relacional (Figura 1).
-- -------------------------------------------------------------------------
CREATE TABLE personal (
    rut_persona          NUMBER(8)          NOT NULL,
    dv_persona           CHAR(1 CHAR)       NOT NULL,
    primer_nombre        VARCHAR2(25 CHAR)  NOT NULL,
    segundo_nombre       VARCHAR2(25 CHAR),
    primer_apellido      VARCHAR2(25 CHAR)  NOT NULL,
    segundo_apellido     VARCHAR2(25 CHAR)  NOT NULL,
    fecha_contratacion   DATE               NOT NULL,
    fecha_nacimiento     DATE               NOT NULL,
    email                VARCHAR2(100 CHAR),
    calle                VARCHAR2(50 CHAR)  NOT NULL,
    numeracion           NUMBER(5)          NOT NULL,
    sueldo               NUMBER(8)          NOT NULL,
    cod_comuna            NUMBER(5)         NOT NULL,
    cod_region            NUMBER(2)         NOT NULL,
    cod_genero             VARCHAR2(3 CHAR),
    cod_estado_civil        VARCHAR2(2 CHAR),
    cod_empresa           NUMBER(2)         NOT NULL,
    encargado_rut        NUMBER(8)
);

ALTER TABLE personal
    ADD CONSTRAINT personal_pk PRIMARY KEY (rut_persona);

ALTER TABLE personal
    ADD CONSTRAINT personal_fk_compania FOREIGN KEY (cod_empresa)
    REFERENCES compania (id_empresa);

ALTER TABLE personal
    ADD CONSTRAINT personal_fk_comuna FOREIGN KEY (cod_comuna, cod_region)
    REFERENCES comuna (id_comuna, cod_region);

ALTER TABLE personal
    ADD CONSTRAINT personal_fk_estado_civil FOREIGN KEY (cod_estado_civil)
    REFERENCES estado_civil (id_estado_civil);

ALTER TABLE personal
    ADD CONSTRAINT personal_fk_genero FOREIGN KEY (cod_genero)
    REFERENCES genero (id_genero);

ALTER TABLE personal
    ADD CONSTRAINT personal_personal_fk FOREIGN KEY (encargado_rut)
    REFERENCES personal (rut_persona);


-- -------------------------------------------------------------------------
-- Tabla TITULACION: títulos obtenidos por cada persona (entidad
-- asociativa entre PERSONAL y TITULO).
-- -------------------------------------------------------------------------
CREATE TABLE titulacion (
    cod_titulo         VARCHAR2(3 CHAR) NOT NULL,
    persona_rut        NUMBER(8)        NOT NULL,
    fecha_titulacion   DATE             NOT NULL
);

ALTER TABLE titulacion
    ADD CONSTRAINT titulacion_pk PRIMARY KEY (cod_titulo, persona_rut);

ALTER TABLE titulacion
    ADD CONSTRAINT titulacion_fk_personal FOREIGN KEY (persona_rut)
    REFERENCES personal (rut_persona);

ALTER TABLE titulacion
    ADD CONSTRAINT titulacion_fk_titulo FOREIGN KEY (cod_titulo)
    REFERENCES titulo (id_titulo);


-- -------------------------------------------------------------------------
-- Tabla DOMINIO: nivel de manejo de idiomas por cada persona (entidad
-- asociativa entre PERSONAL e IDIOMA).
-- -------------------------------------------------------------------------
CREATE TABLE dominio (
    id_idioma     NUMBER(3)         NOT NULL,
    persona_rut   NUMBER(8)         NOT NULL,
    nivel         VARCHAR2(25 CHAR) NOT NULL
);

ALTER TABLE dominio
    ADD CONSTRAINT dominio_pk PRIMARY KEY (id_idioma, persona_rut);

ALTER TABLE dominio
    ADD CONSTRAINT dominio_fk_idioma FOREIGN KEY (id_idioma)
    REFERENCES idioma (id_idioma);

ALTER TABLE dominio
    ADD CONSTRAINT dominio_fk_personal FOREIGN KEY (persona_rut)
    REFERENCES personal (rut_persona);


/* =========================================================================
   CASO 2: MODIFICACIÓN DEL MODELO (ALTER TABLE)
   ========================================================================= */

-- -------------------------------------------------------------------------
-- 1) El email es opcional, pero si se ingresa, no se debe repetir.
--    UNIQUE en Oracle permite múltiples NULL, por lo que no exigir email
--    no entra en conflicto con la restricción de unicidad.
-- -------------------------------------------------------------------------
ALTER TABLE personal
    ADD CONSTRAINT personal_un_email UNIQUE (email);


-- -------------------------------------------------------------------------
-- 2) El dígito verificador del RUN debe estar entre 0-9 o ser 'K'.
-- -------------------------------------------------------------------------
ALTER TABLE personal
    ADD CONSTRAINT personal_dv_ck
    CHECK (dv_persona IN ('0','1','2','3','4','5','6','7','8','9','K'));


-- -------------------------------------------------------------------------
-- 3) El sueldo mínimo del personal es de $450.000.
-- -------------------------------------------------------------------------
ALTER TABLE personal
    ADD CONSTRAINT personal_sueldo_ck
    CHECK (sueldo >= 450000);


/* =========================================================================
   CASO 3: POBLAMIENTO DEL MODELO
   Solo se pueblan 4 tablas: IDIOMA, REGION, COMUNA y COMPANIA. Se
   insertan en orden de dependencia (fuerte a débil): primero IDIOMA y
   REGION (independientes), luego COMUNA (depende de REGION) y
   finalmente COMPANIA (depende de COMUNA).
   ========================================================================= */

-- -------------------------------------------------------------------------
-- Objetos SECUENCIA requeridos por el enunciado.
-- -------------------------------------------------------------------------
CREATE SEQUENCE seq_comuna
    START WITH 1101
    INCREMENT BY 6;

CREATE SEQUENCE seq_compania
    START WITH 10
    INCREMENT BY 5;


-- -------------------------------------------------------------------------
-- IDIOMA (usa IDENTITY: genera 25, 28, 31, 34, 37 en este orden).
-- -------------------------------------------------------------------------
INSERT INTO idioma (nombre_idioma) VALUES ('Ingles');
INSERT INTO idioma (nombre_idioma) VALUES ('Chino');
INSERT INTO idioma (nombre_idioma) VALUES ('Aleman');
INSERT INTO idioma (nombre_idioma) VALUES ('Español');
INSERT INTO idioma (nombre_idioma) VALUES ('Frances');


-- -------------------------------------------------------------------------
-- REGION (usa IDENTITY: genera 7, 9, 11 en este orden).
-- -------------------------------------------------------------------------
INSERT INTO region (nombre_region) VALUES ('ARICA Y PARINACOTA');
INSERT INTO region (nombre_region) VALUES ('METROPOLITANA');
INSERT INTO region (nombre_region) VALUES ('LA ARAUCANIA');


-- -------------------------------------------------------------------------
-- COMUNA (usa SEQ_COMUNA: genera 1101, 1107, 1113 en este orden).
-- -------------------------------------------------------------------------
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region)
VALUES (seq_comuna.NEXTVAL, 'Arica', 7);

INSERT INTO comuna (id_comuna, comuna_nombre, cod_region)
VALUES (seq_comuna.NEXTVAL, 'Santiago', 9);

INSERT INTO comuna (id_comuna, comuna_nombre, cod_region)
VALUES (seq_comuna.NEXTVAL, 'Temuco', 11);


-- -------------------------------------------------------------------------
-- COMPANIA (usa SEQ_COMPANIA: genera 10, 15, 20 ... 55 en este orden).
-- El cod_region de cada fila corresponde a la región de su cod_comuna
-- (Arica=7, Santiago=9, Temuco=11), según la relación definida en la
-- tabla COMUNA de la Figura 2.
-- -------------------------------------------------------------------------
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'CCyRojas', 'Amapolas', 506, 1857000, 0.5, 1101, 7);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'SenTTy', 'Los Alamos', 3490, 897000, 0.025, 1101, 7);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'Praxia LTDA', 'Las Camelias', 11098, 2157000, 0.035, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'TIC spa', 'FLORES S.A.', 4357, 857000, NULL, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'SANTANA LTDA', 'AVDA VIC. MACKENA', 106, 757000, 0.015, 1101, 7);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'FLORES Y ASOCIADOS', 'PEDRO LATORRE', 557, 589000, 0.015, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'J.A. HOFFMAN', 'LATINA D.32', 509, 1857000, 0.025, 1113, 11);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'CAGLIARI D.', 'ALAMEDA', 206, 1857000, NULL, 1107, 9);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'Rojas HNOS LTDA', 'SUCRE', 106, 957000, 0.005, 1113, 11);

INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion, renta_promedio, pct_aumento, cod_comuna, cod_region)
VALUES (seq_compania.NEXTVAL, 'FRIENDS P. S.A', 'SUECIA', 506, 857000, 0.015, 1113, 11);

COMMIT;


/* =========================================================================
   CASO 4: RECUPERACIÓN DE DATOS
   ========================================================================= */

-- -------------------------------------------------------------------------
-- INFORME 1: Simulación de Renta Promedio de todas las empresas del
-- Holding Carpenter SPA. Simulación = renta_promedio * (1 + pct_aumento).
-- Orden: Renta Promedio descendente; en caso de empate, alfabético por
-- Nombre Empresa.
-- -------------------------------------------------------------------------
SELECT
    nombre_empresa               AS "Nombre Empresa",
    calle || ' ' || numeracion   AS "Dirección",
    renta_promedio               AS "Renta Promedio",
    renta_promedio * (1 + pct_aumento) AS "Simulación de Renta"
FROM compania
ORDER BY renta_promedio DESC, nombre_empresa ASC;


-- -------------------------------------------------------------------------
-- INFORME 2: Nueva simulación de Renta Promedio, sumando un 15%
-- adicional al porcentaje de aumento actualmente registrado.
-- Orden: Renta Promedio Actual ascendente y, luego, Nombre Empresa
-- descendente.
-- -------------------------------------------------------------------------
SELECT
    id_empresa                              AS "CODIGO",
    nombre_empresa                          AS "EMPRESA",
    renta_promedio                          AS "PROM RENTA ACTUAL",
    pct_aumento + 0.15                      AS "PCT AUMENTADO EN 15%",
    renta_promedio * (pct_aumento + 0.15)   AS "RENTA AUMENTADA"
FROM compania
ORDER BY renta_promedio ASC, nombre_empresa DESC;
