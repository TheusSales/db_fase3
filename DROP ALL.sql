--? DROP TABLES
drop table T_USUARIO cascade constraints PURGE;
drop table T_PERFIL cascade constraints PURGE;
drop table T_PESSOA cascade constraints PURGE;
drop table T_PESSOA_ESTRU cascade constraints PURGE;
drop table T_ANIMAL cascade constraints PURGE;
drop table T_RACA cascade constraints PURGE;
drop table T_CARGO cascade constraints PURGE;
drop table T_ENDERECO cascade constraints PURGE;
drop table T_ESTRUTURA cascade constraints PURGE;
drop table T_EVENTO cascade constraints PURGE;
drop table T_NECESSIDADE cascade constraints PURGE;
drop table T_PECULIARIDADE cascade constraints PURGE;

--? DROP SEQUENCES
drop sequence SEQ_USUARIO;
drop sequence SEQ_PERFIL;
drop sequence SEQ_PESSOA;
drop sequence SEQ_PESSOA_ESTRU;
drop sequence SEQ_ANIMAL;
drop sequence SEQ_RACA;
drop sequence SEQ_CARGO;
drop sequence SEQ_ENDERECO;
drop sequence SEQ_ESTRUTURA;
drop sequence SEQ_EVENTO;
drop sequence SEQ_NECESSIDADE;
drop sequence SEQ_PECULIARIDADE;

--? LIMPAR REGISTROS
truncate table T_ANIMAL cascade;
truncate table T_RACA cascade;
truncate table T_CARGO cascade;
truncate table T_ENDERECO cascade;
truncate table T_ESTRUTURA cascade;
truncate table T_EVENTO cascade;
truncate table T_NECESSIDADE cascade;
truncate table T_PECULIARIDADE cascade;
truncate table T_PESSOA cascade;
truncate table T_PESSOA_ESTRU cascade;
truncate table T_PERFIL cascade;
truncate table T_USUARIO cascade;