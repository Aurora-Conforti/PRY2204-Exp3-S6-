/* =========================================================================
   PRY2204 - Modelamiento de Bases de Datos - Semana 6
   Caso: Consultorio Médico Municipalidad Santa Gema
   Actividad: "Implementando un Modelo Relacional con sentencias SQL"
   =========================================================================
   Este script debe ejecutarse conectado con el usuario PRY2204_S6,
   creado previamente con el script PRY2204_Exp3_S6_Script_crea_usuario.SQL
   ejecutado como SYS/SYSTEM (o ADMIN en Oracle Cloud).
   ========================================================================= */


/* =========================================================================
   SECCIÓN 0: BORRADO DE OBJETOS (para permitir reejecutar el script)
   Se borran en orden inverso a sus dependencias (primero las tablas
   "hijas", al final las tablas "padre"). Cada DROP está protegido con
   manejo de excepción para que el script no falle si es la primera vez
   que se ejecuta y la tabla todavía no existe (error ORA-00942).
   ========================================================================= */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE dosis CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE pago CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE receta CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE medicamento CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE diagnostico CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE paciente CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE medico CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE digitador CASCADE CONSTRAINTS PURGE';
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
    EXECUTE IMMEDIATE 'DROP TABLE ciudad CASCADE CONSTRAINTS PURGE';
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
    EXECUTE IMMEDIATE 'DROP TABLE especialidad CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE banco CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/


/* =========================================================================
   CASO 1: CREACIÓN DE TABLAS (MODELO RELACIONAL NORMALIZADO)
   ========================================================================= */

-- -------------------------------------------------------------------------
-- Tabla REGION: catálogo de regiones de Chile.
-- -------------------------------------------------------------------------
CREATE TABLE region (
    id_region      NUMBER(2)       NOT NULL,
    nombre_region  VARCHAR2(50 CHAR) NOT NULL
);

ALTER TABLE region
    ADD CONSTRAINT region_pk PRIMARY KEY (id_region);


-- -------------------------------------------------------------------------
-- Tabla CIUDAD: cada ciudad pertenece a una región.
-- -------------------------------------------------------------------------
CREATE TABLE ciudad (
    id_ciudad      NUMBER(4)       NOT NULL,
    nombre_ciudad  VARCHAR2(50 CHAR) NOT NULL,
    id_region      NUMBER(2)       NOT NULL
);

ALTER TABLE ciudad
    ADD CONSTRAINT ciudad_pk PRIMARY KEY (id_ciudad);

ALTER TABLE ciudad
    ADD CONSTRAINT ciudad_region_fk FOREIGN KEY (id_region)
    REFERENCES region (id_region);


-- -------------------------------------------------------------------------
-- Tabla COMUNA: cada comuna pertenece a una ciudad.
-- El identificador comienza en 1101 y se incrementa en 1 (IDENTITY).
-- -------------------------------------------------------------------------
CREATE TABLE comuna (
    id_comuna      NUMBER          GENERATED ALWAYS AS IDENTITY
                                    (START WITH 1101 INCREMENT BY 1) NOT NULL,
    nombre_comuna  VARCHAR2(50 CHAR) NOT NULL,
    id_ciudad      NUMBER(4)       NOT NULL
);

ALTER TABLE comuna
    ADD CONSTRAINT comuna_pk PRIMARY KEY (id_comuna);

ALTER TABLE comuna
    ADD CONSTRAINT comuna_ciudad_fk FOREIGN KEY (id_ciudad)
    REFERENCES ciudad (id_ciudad);


-- -------------------------------------------------------------------------
-- Tabla ESPECIALIDAD: catálogo de especialidades médicas.
-- El identificador se autoincrementa (IDENTITY).
-- -------------------------------------------------------------------------
CREATE TABLE especialidad (
    id_especialidad     NUMBER      GENERATED ALWAYS AS IDENTITY NOT NULL,
    nombre_especialidad VARCHAR2(80 CHAR) NOT NULL
);

ALTER TABLE especialidad
    ADD CONSTRAINT especialidad_pk PRIMARY KEY (id_especialidad);


-- -------------------------------------------------------------------------
-- Tabla BANCO: catálogo de bancos utilizados en los pagos.
-- -------------------------------------------------------------------------
CREATE TABLE banco (
    id_banco     NUMBER(3)       NOT NULL,
    nombre_banco VARCHAR2(80 CHAR) NOT NULL
);

ALTER TABLE banco
    ADD CONSTRAINT banco_pk PRIMARY KEY (id_banco);


-- -------------------------------------------------------------------------
-- Tabla MEDICO: profesionales del consultorio.
-- El RUT se separa en número + dígito verificador (DV). El DV solo
-- admite los valores 0-9 y K. El teléfono debe ser único (dos médicos
-- no pueden compartir el mismo número).
-- -------------------------------------------------------------------------
CREATE TABLE medico (
    rut_medico       NUMBER(9)       NOT NULL,
    dv_medico        CHAR(1 CHAR)    NOT NULL,
    nombre_medico    VARCHAR2(100 CHAR) NOT NULL,
    telefono_medico  VARCHAR2(20 CHAR) NOT NULL,
    id_especialidad  NUMBER          NOT NULL
);

ALTER TABLE medico
    ADD CONSTRAINT medico_pk PRIMARY KEY (rut_medico);

ALTER TABLE medico
    ADD CONSTRAINT medico_especialidad_fk FOREIGN KEY (id_especialidad)
    REFERENCES especialidad (id_especialidad);

ALTER TABLE medico
    ADD CONSTRAINT medico_telefono_un UNIQUE (telefono_medico);

ALTER TABLE medico
    ADD CONSTRAINT medico_dv_ck
    CHECK (dv_medico IN ('0','1','2','3','4','5','6','7','8','9','K'));


-- -------------------------------------------------------------------------
-- Tabla DIGITADOR: usuarios del consultorio que ingresan las recetas.
-- -------------------------------------------------------------------------
CREATE TABLE digitador (
    rut_digitador    NUMBER(9)       NOT NULL,
    dv_digitador     CHAR(1 CHAR)    NOT NULL,
    nombre_digitador VARCHAR2(100 CHAR) NOT NULL
);

ALTER TABLE digitador
    ADD CONSTRAINT digitador_pk PRIMARY KEY (rut_digitador);

ALTER TABLE digitador
    ADD CONSTRAINT digitador_dv_ck
    CHECK (dv_digitador IN ('0','1','2','3','4','5','6','7','8','9','K'));


-- -------------------------------------------------------------------------
-- Tabla PACIENTE: pacientes atendidos en el consultorio.
-- (edad se agrega aquí en el Caso 1; se reemplaza por fecha_nacimiento
-- en el Caso 2, mediante ALTER TABLE, tal como pide el enunciado).
-- -------------------------------------------------------------------------
CREATE TABLE paciente (
    rut_paciente     NUMBER(9)       NOT NULL,
    dv_paciente      CHAR(1 CHAR)    NOT NULL,
    nombre_paciente  VARCHAR2(100 CHAR) NOT NULL,
    edad             NUMBER(3)       NOT NULL,
    direccion        VARCHAR2(150 CHAR) NOT NULL,
    telefono_paciente VARCHAR2(20 CHAR) NOT NULL,
    id_comuna        NUMBER          NOT NULL
);

ALTER TABLE paciente
    ADD CONSTRAINT paciente_pk PRIMARY KEY (rut_paciente);

ALTER TABLE paciente
    ADD CONSTRAINT paciente_comuna_fk FOREIGN KEY (id_comuna)
    REFERENCES comuna (id_comuna);

ALTER TABLE paciente
    ADD CONSTRAINT paciente_dv_ck
    CHECK (dv_paciente IN ('0','1','2','3','4','5','6','7','8','9','K'));


-- -------------------------------------------------------------------------
-- Tabla DIAGNOSTICO: catálogo de diagnósticos clínicos.
-- -------------------------------------------------------------------------
CREATE TABLE diagnostico (
    id_diagnostico          NUMBER(6)       NOT NULL,
    descripcion_diagnostico VARCHAR2(200 CHAR) NOT NULL
);

ALTER TABLE diagnostico
    ADD CONSTRAINT diagnostico_pk PRIMARY KEY (id_diagnostico);


-- -------------------------------------------------------------------------
-- Tabla MEDICAMENTO: catálogo de medicamentos disponibles.
-- (precio_unitario se agrega en el Caso 2 mediante ALTER TABLE).
-- -------------------------------------------------------------------------
CREATE TABLE medicamento (
    id_medicamento      NUMBER(8)       NOT NULL,
    nombre_medicamento  VARCHAR2(150 CHAR) NOT NULL,
    dosis_recomendada   VARCHAR2(100 CHAR) NOT NULL,
    stock               NUMBER(6)       NOT NULL,
    tipo_medicamento    VARCHAR2(20 CHAR) NOT NULL,
    tipo_presentacion   VARCHAR2(50 CHAR) NOT NULL
);

ALTER TABLE medicamento
    ADD CONSTRAINT medicamento_pk PRIMARY KEY (id_medicamento);

ALTER TABLE medicamento
    ADD CONSTRAINT medicamento_tipo_ck
    CHECK (tipo_medicamento IN ('GENERICO','MARCA'));


-- -------------------------------------------------------------------------
-- Tabla RECETA: receta médica emitida por un médico, ingresada por un
-- digitador, entregada a un paciente, con un único diagnóstico asociado.
-- -------------------------------------------------------------------------
CREATE TABLE receta (
    id_receta            NUMBER(10)      NOT NULL,
    fecha_emision         DATE            NOT NULL,
    observaciones         VARCHAR2(300 CHAR),
    fecha_expiracion      DATE,
    tipo_receta           VARCHAR2(15 CHAR) NOT NULL,
    rut_paciente          NUMBER(9)       NOT NULL,
    rut_medico            NUMBER(9)       NOT NULL,
    rut_digitador         NUMBER(9)       NOT NULL,
    id_diagnostico        NUMBER(6)       NOT NULL
);

ALTER TABLE receta
    ADD CONSTRAINT receta_pk PRIMARY KEY (id_receta);

ALTER TABLE receta
    ADD CONSTRAINT receta_paciente_fk FOREIGN KEY (rut_paciente)
    REFERENCES paciente (rut_paciente);

ALTER TABLE receta
    ADD CONSTRAINT receta_medico_fk FOREIGN KEY (rut_medico)
    REFERENCES medico (rut_medico);

ALTER TABLE receta
    ADD CONSTRAINT receta_digitador_fk FOREIGN KEY (rut_digitador)
    REFERENCES digitador (rut_digitador);

ALTER TABLE receta
    ADD CONSTRAINT receta_diagnostico_fk FOREIGN KEY (id_diagnostico)
    REFERENCES diagnostico (id_diagnostico);

ALTER TABLE receta
    ADD CONSTRAINT receta_tipo_ck
    CHECK (tipo_receta IN ('DIGITAL','MAGISTRAL','RETENIDA','GENERAL','VETERINARIA'));


-- -------------------------------------------------------------------------
-- Tabla DOSIS: detalle de los medicamentos indicados en una receta
-- (entidad asociativa entre RECETA y MEDICAMENTO, ya que una receta
-- puede tener uno o más medicamentos, cada uno con su propia dosis).
-- -------------------------------------------------------------------------
CREATE TABLE dosis (
    id_receta            NUMBER(10)      NOT NULL,
    id_medicamento        NUMBER(8)       NOT NULL,
    via_administracion    VARCHAR2(50 CHAR) NOT NULL,
    cantidad_unidades     NUMBER(5)       NOT NULL,
    dosis_indicada        VARCHAR2(100 CHAR) NOT NULL,
    duracion_tratamiento  VARCHAR2(50 CHAR) NOT NULL
);

ALTER TABLE dosis
    ADD CONSTRAINT dosis_pk PRIMARY KEY (id_receta, id_medicamento);

ALTER TABLE dosis
    ADD CONSTRAINT dosis_receta_fk FOREIGN KEY (id_receta)
    REFERENCES receta (id_receta);

ALTER TABLE dosis
    ADD CONSTRAINT dosis_medicamento_fk FOREIGN KEY (id_medicamento)
    REFERENCES medicamento (id_medicamento);


-- -------------------------------------------------------------------------
-- Tabla PAGO: pagos asociados a una receta (una receta puede tener uno
-- o más pagos). Se relaciona con BANCO para identificar la entidad
-- financiera utilizada.
-- (metodo_pago se restringe en el Caso 2 mediante ALTER TABLE).
-- -------------------------------------------------------------------------
CREATE TABLE pago (
    id_pago         NUMBER(10)      NOT NULL,
    monto_pagado    NUMBER(10)      NOT NULL,
    fecha_pago      DATE            NOT NULL,
    metodo_pago     VARCHAR2(15 CHAR) NOT NULL,
    id_banco        NUMBER(3)       NOT NULL,
    id_receta       NUMBER(10)      NOT NULL
);

ALTER TABLE pago
    ADD CONSTRAINT pago_pk PRIMARY KEY (id_pago);

ALTER TABLE pago
    ADD CONSTRAINT pago_banco_fk FOREIGN KEY (id_banco)
    REFERENCES banco (id_banco);

ALTER TABLE pago
    ADD CONSTRAINT pago_receta_fk FOREIGN KEY (id_receta)
    REFERENCES receta (id_receta);


/* =========================================================================
   CASO 2: MODIFICACIONES SOBRE EL MODELO YA CREADO (ALTER TABLE)
   ========================================================================= */

-- -------------------------------------------------------------------------
-- 1) Agregar el precio unitario de cada medicamento, entre $1.000 y
--    $2.000.000.
-- -------------------------------------------------------------------------
ALTER TABLE medicamento
    ADD precio_unitario NUMBER(9);

ALTER TABLE medicamento
    ADD CONSTRAINT medicamento_precio_ck
    CHECK (precio_unitario BETWEEN 1000 AND 2000000);


-- -------------------------------------------------------------------------
-- 2) Restringir los métodos de pago a: EFECTIVO, TARJETA, TRANSFERENCIA.
-- -------------------------------------------------------------------------
ALTER TABLE pago
    ADD CONSTRAINT pago_metodo_ck
    CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA'));


-- -------------------------------------------------------------------------
-- 3) Eliminar la columna edad del paciente y agregar fecha_nacimiento.
-- -------------------------------------------------------------------------
ALTER TABLE paciente
    DROP COLUMN edad;

ALTER TABLE paciente
    ADD fecha_nacimiento DATE;
