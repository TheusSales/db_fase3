-- Gerado por Oracle SQL Developer Data Modeler 21.2.0.183.1957
--   em:        2022-05-17 21:40:22 BRT
--   site:      Oracle Database 11g
--   tipo:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE t_animal (
    t_perfil_id_perfil             NUMBER(30) NOT NULL,
    t_pessoa_id_perfil             NUMBER(30),
    t_estrutura_t_perfil_id_perfil NUMBER(30),
    ds_sexo                        SMALLINT NOT NULL,
    nr_tam                         NUMBER(1, 2) NOT NULL,
    nr_peso                        NUMBER(3, 2) NOT NULL
);

ALTER TABLE t_animal ADD CONSTRAINT t_animal_pk PRIMARY KEY ( t_perfil_id_perfil );

CREATE TABLE t_cargo (
    id_cargo           NUMBER(30) NOT NULL,
    t_pessoa_id_perfil NUMBER(30) NOT NULL,
    tp_cargo           SMALLINT NOT NULL
);

ALTER TABLE t_cargo ADD CONSTRAINT t_cargo_pk PRIMARY KEY ( id_cargo );

CREATE TABLE t_endereco (
    id_end             NUMBER NOT NULL,
    t_perfil_id_perfil NUMBER(30) NOT NULL,
    tp_end             SMALLINT NOT NULL,
    ds_estado          VARCHAR2(30) NOT NULL,
    ds_cidade          VARCHAR2(30) NOT NULL,
    ds_bairro          VARCHAR2(30) NOT NULL,
    cep                NUMBER(8) NOT NULL,
    ds_comp            VARCHAR2(30)
);

CREATE UNIQUE INDEX t_endereco__idx ON
    t_endereco (
        t_perfil_id_perfil
    ASC );

ALTER TABLE t_endereco ADD CONSTRAINT t_endereco_pk PRIMARY KEY ( id_end );

CREATE TABLE t_estrutura (
    t_perfil_id_perfil NUMBER(30) NOT NULL,
    cnpj               NUMBER(14) NOT NULL,
    ds_categoria       SMALLINT NOT NULL
);

ALTER TABLE t_estrutura ADD CONSTRAINT t_estrutura_pk PRIMARY KEY ( t_perfil_id_perfil );

CREATE TABLE t_evento (
    id_evento              NUMBER(30) NOT NULL,
    t_necessidade_id_neces NUMBER(30) NOT NULL,
    tp_evento              SMALLINT NOT NULL,
    dt_inicio              DATE NOT NULL,
    dt_fim                 DATE,
    latitude               BINARY_DOUBLE NOT NULL,
    longitude              BINARY_DOUBLE NOT NULL
);

CREATE UNIQUE INDEX t_evento__idx ON
    t_evento (
        t_necessidade_id_neces
    ASC );

ALTER TABLE t_evento ADD CONSTRAINT t_evento_pk PRIMARY KEY ( id_evento );

CREATE TABLE t_necessidade (
    id_neces           NUMBER(30) NOT NULL,
    t_perfil_id_perfil NUMBER(30) NOT NULL,
    tp_neces           SMALLINT NOT NULL,
    ds_neces           VARCHAR2(50) NOT NULL
);

ALTER TABLE t_necessidade ADD CONSTRAINT t_necessidade_pk PRIMARY KEY ( id_neces );

CREATE TABLE t_peculiaridade (
    id_peculiaridade   NUMBER(30) NOT NULL,
    t_animal_id_perfil NUMBER(30) NOT NULL,
    tp_pecul           SMALLINT NOT NULL,
    ds_pecu            VARCHAR2(50) NOT NULL
);

ALTER TABLE t_peculiaridade ADD CONSTRAINT t_peculiaridade_pk PRIMARY KEY ( id_peculiaridade );

CREATE TABLE t_perfil (
    id_perfil         NUMBER(30) NOT NULL,
    t_usuario_id_user NUMBER(30) NOT NULL,
    nm_perfil         VARCHAR2(30) NOT NULL,
    dt_origem         DATE NOT NULL
);

ALTER TABLE t_perfil ADD CONSTRAINT t_perfil_pk PRIMARY KEY ( id_perfil );

CREATE TABLE t_pessoa (
    t_perfil_id_perfil NUMBER(30) NOT NULL,
    cpf                NUMBER(11) NOT NULL,
    ds_sexo            SMALLINT NOT NULL
);

ALTER TABLE t_pessoa ADD CONSTRAINT t_pessoa_pk PRIMARY KEY ( t_perfil_id_perfil );

CREATE TABLE t_pessoa_estru (
    t_estrutura_t_perfil_id_perfil NUMBER(30) NOT NULL,
    t_pessoa_id_perfil             NUMBER(30) NOT NULL
);

ALTER TABLE t_pessoa_estru ADD CONSTRAINT t_pessoa_estru_pk PRIMARY KEY ( t_estrutura_t_perfil_id_perfil,
                                                                          t_pessoa_id_perfil );

CREATE TABLE t_raca (
    id_raca            NUMBER(30) NOT NULL,
    t_animal_id_perfil NUMBER(30) NOT NULL,
    tp_animal          VARCHAR2(30) NOT NULL,
    ds_raca            VARCHAR2(30) NOT NULL
);

CREATE UNIQUE INDEX t_raca__idx ON
    t_raca (
        t_animal_id_perfil
    ASC );

ALTER TABLE t_raca ADD CONSTRAINT t_raca_pk PRIMARY KEY ( id_raca );

CREATE TABLE t_usuario (
    id_user  NUMBER(30) NOT NULL,
    ds_email VARCHAR2(50) NOT NULL,
    ds_senha VARCHAR2(30) NOT NULL
);

ALTER TABLE t_usuario ADD CONSTRAINT t_usuario_pk PRIMARY KEY ( id_user );

ALTER TABLE t_animal
    ADD CONSTRAINT t_animal_t_estrutura_fk FOREIGN KEY ( t_estrutura_t_perfil_id_perfil )
        REFERENCES t_estrutura ( t_perfil_id_perfil );

ALTER TABLE t_animal
    ADD CONSTRAINT t_animal_t_perfil_fk FOREIGN KEY ( t_perfil_id_perfil )
        REFERENCES t_perfil ( id_perfil );

ALTER TABLE t_animal
    ADD CONSTRAINT t_animal_t_pessoa_fk FOREIGN KEY ( t_pessoa_id_perfil )
        REFERENCES t_pessoa ( t_perfil_id_perfil );

ALTER TABLE t_cargo
    ADD CONSTRAINT t_cargo_t_pessoa_fk FOREIGN KEY ( t_pessoa_id_perfil )
        REFERENCES t_pessoa ( t_perfil_id_perfil );

ALTER TABLE t_endereco
    ADD CONSTRAINT t_endereco_t_perfil_fk FOREIGN KEY ( t_perfil_id_perfil )
        REFERENCES t_perfil ( id_perfil );

ALTER TABLE t_estrutura
    ADD CONSTRAINT t_estrutura_t_perfil_fk FOREIGN KEY ( t_perfil_id_perfil )
        REFERENCES t_perfil ( id_perfil );

ALTER TABLE t_evento
    ADD CONSTRAINT t_evento_t_necessidade_fk FOREIGN KEY ( t_necessidade_id_neces )
        REFERENCES t_necessidade ( id_neces );

ALTER TABLE t_necessidade
    ADD CONSTRAINT t_necessidade_t_perfil_fk FOREIGN KEY ( t_perfil_id_perfil )
        REFERENCES t_perfil ( id_perfil );

ALTER TABLE t_peculiaridade
    ADD CONSTRAINT t_peculiaridade_t_animal_fk FOREIGN KEY ( t_animal_id_perfil )
        REFERENCES t_animal ( t_perfil_id_perfil );

ALTER TABLE t_perfil
    ADD CONSTRAINT t_perfil_t_usuario_fk FOREIGN KEY ( t_usuario_id_user )
        REFERENCES t_usuario ( id_user );

ALTER TABLE t_pessoa_estru
    ADD CONSTRAINT t_pessoa_estru_t_estrutura_fk FOREIGN KEY ( t_estrutura_t_perfil_id_perfil )
        REFERENCES t_estrutura ( t_perfil_id_perfil );

ALTER TABLE t_pessoa_estru
    ADD CONSTRAINT t_pessoa_estru_t_pessoa_fk FOREIGN KEY ( t_pessoa_id_perfil )
        REFERENCES t_pessoa ( t_perfil_id_perfil );

ALTER TABLE t_pessoa
    ADD CONSTRAINT t_pessoa_t_perfil_fk FOREIGN KEY ( t_perfil_id_perfil )
        REFERENCES t_perfil ( id_perfil );

ALTER TABLE t_raca
    ADD CONSTRAINT t_raca_t_animal_fk FOREIGN KEY ( t_animal_id_perfil )
        REFERENCES t_animal ( t_perfil_id_perfil );



-- Relat?rio do Resumo do Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            12
-- CREATE INDEX                             3
-- ALTER TABLE                             26
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
