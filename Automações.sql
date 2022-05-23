set SERVEROUTPUT on
--* -------------------------------------------------------------------------- */
--*                                   Usuario                                  */
--* -------------------------------------------------------------------------- */
--? Sequence Usuario
create sequence SEQ_USUARIO
    start with 1
    increment by 1
    nocache
    nocycle;

--? Trigger Usuario
create or replace trigger TG_USUARIO
    before insert or update or delete on T_USUARIO
    for each row
    declare
        existeUsuario number;
    begin
        if(INSERTING or UPDATING) then
            select count(*) into existeUsuario from T_USUARIO where DS_EMAIL = :NEW.DS_EMAIL;

            if (existeUsuario > 0) then
                raise_application_error(-20901, 'Este email já existe!');
            end if;
        end if;
    end;
/

--* -------------------------------------------------------------------------- */
--*                                  Endereço                                  */
--* -------------------------------------------------------------------------- */
--? Sequencia Endereço
create sequence SEQ_ENDERECO
    start with 1
    increment by 1
    nocache
    nocycle;

--? Procedure CriarEndereco
create or replace procedure SP_CRIARENDERECO(P_PERFIL_ID number, P_TP_END smallint, P_DS_ESTADO varchar2,
                                   P_DS_CIDADE varchar2, P_DS_BAIRRO varchar2, P_CEP varchar2, P_DS_COMP varchar2 default '') as
    begin
        insert into T_ENDERECO(ID_END, T_PERFIL_ID_PERFIL, TP_END, DS_ESTADO, DS_CIDADE, DS_BAIRRO, CEP, DS_COMP)
               values (SEQ_ENDERECO.nextval, P_PERFIL_ID, P_TP_END, P_DS_ESTADO, P_DS_CIDADE, P_DS_BAIRRO, P_CEP, P_DS_COMP);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--* -------------------------------------------------------------------------- */
--*                                   Perfil                                   */
--* -------------------------------------------------------------------------- */
--? Sequencia Perfil
create sequence SEQ_PERFIL
    start with 1
    increment by 1
    nocache
    nocycle;

--* -------------------------------------------------------------------------- */
--*                                   Pessoa                                   */
--* -------------------------------------------------------------------------- */
--? Trigger Pessoa
create or replace trigger TG_PESSOA
    before insert or update or delete on T_PESSOA
    for each row
    declare
        existePessoa number;
    begin
        if(INSERTING or UPDATING) then
            select count(*) into existePessoa from T_PESSOA where CPF = :NEW.CPF;

            if (existePessoa > 0) then
                raise_application_error(-20901, 'Este cpf já existe!');
            end if;
        end if;
    end;
/

--? Procedure CriarPessoa
create or replace procedure SP_CRIARPESSOA(P_DS_EMAIL varchar2, P_DS_SENHA varchar2, P_NM_PERFIL varchar2, P_DT_ORIGEM date,
                                           P_CPF varchar2, P_DS_SEXO smallint, P_PERFIL_ID out number)
    as
        V_USUARIO_ID number;
    begin
        V_USUARIO_ID := SEQ_USUARIO.nextval;
        P_PERFIL_ID := SEQ_PERFIL.nextval;

        insert into T_USUARIO(ID_USER, DS_EMAIL, DS_SENHA) values (V_USUARIO_ID, P_DS_EMAIL, P_DS_SENHA);
        insert into T_PERFIL(ID_PERFIL, T_USUARIO_ID_USER, DISCRIMINACAO, NM_PERFIL, DT_ORIGEM)
                            values (P_PERFIL_ID, V_USUARIO_ID, 'PESSOA', P_NM_PERFIL, P_DT_ORIGEM);
        insert into T_PESSOA(T_PERFIL_ID_PERFIL, CPF, DS_SEXO) values (P_PERFIL_ID, P_CPF, P_DS_SEXO);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--? Procedure CriarPessoa_S_SAIDA
create or replace procedure SP_CRIARPESSOA_S_SAIDA(P_DS_EMAIL varchar2, P_DS_SENHA varchar2, P_NM_PERFIL varchar2, P_DT_ORIGEM date,
                                          P_CPF varchar2, P_DS_SEXO smallint)
    as
        V_PERFIL_ID number;
    begin
        SP_CRIARPESSOA(P_DS_EMAIL, P_DS_SENHA, P_NM_PERFIL, P_DT_ORIGEM, P_CPF, P_DS_SEXO, V_PERFIL_ID);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--? Procedure CriarPessoa_Endereco
create or replace procedure SP_CRIARPESSOA_ENDERECO(P_DS_EMAIL varchar2, P_DS_SENHA varchar2, P_NM_PERFIL varchar2, P_DT_ORIGEM date,
                                    P_CPF varchar2, P_DS_SEXO smallint, P_TP_END smallint, P_DS_ESTADO varchar2, P_DS_CIDADE varchar2,
                                    P_DS_BAIRRO varchar2, P_CEP varchar2, P_DS_COMP varchar2 default '')
    as
        V_PERFIL_ID number;
    begin
        SP_CRIARPESSOA(P_DS_EMAIL, P_DS_SENHA, P_NM_PERFIL, P_DT_ORIGEM, P_CPF, P_DS_SEXO, V_PERFIL_ID);
        SP_CRIARENDERECO(V_PERFIL_ID, P_TP_END, P_DS_ESTADO, P_DS_CIDADE, P_DS_BAIRRO, P_CEP, P_DS_COMP);

        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--* -------------------------------------------------------------------------- */
--*                                  Estrutura                                 */
--* -------------------------------------------------------------------------- */
--? Trigger Estrutura;
create or replace trigger TG_ESTRUTURA
    before insert or update or delete on T_ESTRUTURA
    for each row
    declare
        existeEstrutura number;
    begin
        if(INSERTING or UPDATING) then
            select count(*) into existeEstrutura from T_ESTRUTURA where CNPJ = :NEW.CNPJ;

            if (existeEstrutura > 0) then
                raise_application_error(-20901, 'Este cnpj já existe!');
            end if;
        end if;
    end;
/

--? Procedure CriarEstrutura
create or replace procedure SP_CRIARESTRUTURA(P_USUARIO_ID number, P_NM_PERFIL varchar2, P_DT_ORIGEM date, P_CNPJ varchar2,
                                              P_DS_CATEGORIA smallint, P_PERFIL_ID out number) is
    begin
        P_PERFIL_ID := SEQ_PERFIL.nextval;
        insert into T_PERFIL(ID_PERFIL, T_USUARIO_ID_USER, DISCRIMINACAO, NM_PERFIL, DT_ORIGEM)
            values (P_PERFIL_ID, P_USUARIO_ID, 'ESTRUTURA', P_NM_PERFIL, P_DT_ORIGEM);
        insert into T_ESTRUTURA(T_PERFIL_ID_PERFIL, CNPJ, DS_CATEGORIA) values (P_PERFIL_ID, P_CNPJ, P_DS_CATEGORIA);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--? Procedure CriarEstrutura_S_SAIDA
create or replace procedure SP_CRIARESTRUTURA_S_SAIDA(P_USUARIO_ID number, P_NM_PERFIL varchar2, P_DT_ORIGEM date, P_CNPJ varchar2,
                                              P_DS_CATEGORIA smallint)
    as
        V_PERFIL_ID number;
    begin
        SP_CRIARESTRUTURA(P_USUARIO_ID, P_NM_PERFIL, P_DT_ORIGEM, P_CNPJ, P_DS_CATEGORIA, V_PERFIL_ID);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--? Procedure CriarEstrutura_Endereco
create or replace procedure SP_CRIARESTRUTURA_ENDERECO(P_USUARIO_ID number, P_NM_PERFIL varchar2, P_DT_ORIGEM date, P_CNPJ varchar2,
                                    P_DS_CATEGORIA smallint, P_TP_END smallint, P_DS_ESTADO varchar2, P_DS_CIDADE varchar2,
                                    P_DS_BAIRRO varchar2, P_CEP varchar2, P_DS_COMP varchar2 default '')
    as
        V_PERFIL_ID number;
    begin
        SP_CRIARESTRUTURA(P_USUARIO_ID, P_NM_PERFIL, P_DT_ORIGEM, P_CNPJ, P_DS_CATEGORIA, V_PERFIL_ID);
        SP_CRIARENDERECO(V_PERFIL_ID, P_TP_END, P_DS_ESTADO, P_DS_CIDADE, P_DS_BAIRRO, P_CEP, P_DS_COMP);

        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--* -------------------------------------------------------------------------- */
--*                                   Animal                                   */
--* -------------------------------------------------------------------------- */
--? Função PegarEnderecoAnimal
-- create or replace function FN_PEGAR_ENDERECO_ANIMAL(P_PERFIL_ANIMAL_ID number) return record
--     as
--         V_PESSOA_ID number;
--         V_ESTRUTURA_ID number;
--         -- V_TIPO_PERFIL varchar2;
--         V_ENDERECO record;
--     begin
--         select T_PESSOA_T_PERFIL_ID_PERFIL, T_ESTRUTURA_T_PERFIL_ID_PERFIL into V_PESSOA_ID, V_ESTRUTURA_ID
--                                                 from T_ANIMAL where T_PERFIL_ID_PERFIL = P_PERFIL_ANIMAL_ID;
        
--         -- select discriminacao into V_TIPO_PERFIL from T_PERFIL where ID_PERFIL = V_PESSOA_ID or ID_PERFIL = V_ESTRUTURA_ID;

--         select TP_END, DS_ESTADO, DS_CIDADE, DS_BAIRRO, CEP, DS_COMP into V_ENDERECO
--                             from T_ENDERECO where T_PERFIL_ID_PERFIL = V_PESSOA_ID or T_PERFIL_ID_PERFIL = V_ESTRUTURA_ID;
--         RETURN V_ENDERECO;
--     exception
--         when others then
--             DBMS_OUTPUT.PUT_LINE(sqlerrm);
--             rollback;
--     end;

--? Procedure CriarAnimal
create or replace procedure SP_CRIARANIMAL(P_USUARIO_ID number, P_NM_PERFIL varchar, P_DT_ORIGEM date, P_DS_SEXO smallint,
                                           P_NR_TAM number, P_NR_PESO number, P_RACA_ID number,
                                           P_ESTRUTURA_ID number default -1) is
        V_PERFIL_ID number;
        V_PERFIL_PESSOA_ID number;
    begin
        V_PERFIL_ID := SEQ_PERFIL.nextval;
        insert into T_PERFIL(ID_PERFIL, T_USUARIO_ID_USER, DISCRIMINACAO, NM_PERFIL, DT_ORIGEM)
                            values (V_PERFIL_ID, P_USUARIO_ID, 'ANIMAL', P_NM_PERFIL, P_DT_ORIGEM);
        if (P_ESTRUTURA_ID = -1) then
            select perfil.ID_PERFIL into V_PERFIL_PESSOA_ID from T_PERFIL perfil, T_PESSOA pessoa
                                                            where perfil.T_USUARIO_ID_USER = P_USUARIO_ID
                                                            and perfil.DISCRIMINACAO = 'PESSOA';
            insert into T_ANIMAL(T_PERFIL_ID_PERFIL, T_PESSOA_T_PERFIL_ID_PERFIL, T_RACA_ID_RACA, DS_SEXO, NR_TAM, NR_PESO)
                                values (V_PERFIL_ID, V_PERFIL_PESSOA_ID, P_RACA_ID, P_DS_SEXO, P_NR_TAM, P_NR_PESO);
        else
            insert into T_ANIMAL(T_PERFIL_ID_PERFIL, T_ESTRUTURA_T_PERFIL_ID_PERFIL, T_RACA_ID_RACA, DS_SEXO, NR_TAM, NR_PESO)
                                values (V_PERFIL_ID, P_ESTRUTURA_ID, P_RACA_ID, P_DS_SEXO, P_NR_TAM, P_NR_PESO);
        end if;
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--* -------------------------------------------------------------------------- */
--*                                    RAÇA                                    */
--* -------------------------------------------------------------------------- */
--? Trigger Raça
create or replace trigger TG_RACA
    before insert or update or delete on T_RACA
    for each row
    declare
        p_existeRaca number;
    begin
        if(INSERTING or UPDATING) then
            select count(*) into p_existeRaca from T_RACA where DS_RACA = :NEW.DS_RACA and TP_ANIMAL = :NEW.TP_ANIMAL;

            if (p_existeRaca > 0) then
                raise_application_error(-20901, 'Esta raça já existe!');
            end if;
        end if;
    end;
/

--? Sequence Raça
create sequence SEQ_RACA
    start with 1
    increment by 1
    nocache
    nocycle;

--? Procedure CriarRaca
create or replace procedure SP_CRIARRACA(P_TP_ANIMAL varchar2, P_DS_RACA varchar2) as
    begin
        insert into T_RACA(ID_RACA, TP_ANIMAL, DS_RACA) values (SEQ_RACA.nextval, P_TP_ANIMAL, P_DS_RACA);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--* -------------------------------------------------------------------------- */
--*                                    CARGO                                   */
--* -------------------------------------------------------------------------- */
--? Sequence Cargo
create sequence SEQ_CARGO
    start with 1
    increment by 1
    nocache
    nocycle;

--? Procedure CriarAtribuirCargo
create or replace procedure SP_ATRIBUIRCARGO(PERFIL_PESSOA_ID number, TP_CARGO smallint) as
    begin
        insert into T_CARGO(ID_CARGO, T_PESSOA_T_PERFIL_ID_PERFIL, TP_CARGO) values (SEQ_CARGO.nextval, PERFIL_PESSOA_ID, TP_CARGO);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

--* -------------------------------------------------------------------------- */
--*                               MASSA DE TESTES                              */
--* -------------------------------------------------------------------------- */
create or replace procedure SP_POPULARTABELAS
    as
        PERFIL_ID number;
        USUARIO_ID number;
        ESTRUTURA_COUNT number;
        RACA_ID number;
        TP_ANIMAL T_RACA.TP_ANIMAL%TYPE;
    begin
        for i in 1..100 loop
            -- select * from t_endereco;
            SP_CRIARPESSOA('EMAIL' || i || '@EMAIL.COM',
                            i ||'ljkçljkmcfndjkbç',
                            'PERFIL ' || i,
                            sysdate,
                            to_char(DBMS_RANDOM.VALUE(11111111111, 99999999999), '99999999999'),
                            to_number(to_char(DBMS_RANDOM.VALUE(0, 1), '9')),
                            PERFIL_ID);
            if (DBMS_RANDOM.VALUE(0,1) > 0.2) then
                SP_ATRIBUIRCARGO(PERFIL_ID, DBMS_RANDOM.VALUE(1, 10));
            end if;
            SP_CRIARENDERECO(PERFIL_ID, 
                             0,
                             DBMS_RANDOM.STRING('U', 2),
                             DBMS_RANDOM.STRING('U', 20),
                             DBMS_RANDOM.STRING('U', 6),
                             to_char(DBMS_RANDOM.VALUE(11111111, 88888888), '999999999'),
                             '');
            
        end loop;
        PERFIL_ID := -1;
        for i in 1..150 loop
            select ID_USER into USUARIO_ID from T_USUARIO order by DBMS_RANDOM.RANDOM() fetch first 1 row only;
            SP_CRIARESTRUTURA(USUARIO_ID,
                                    'ESTRUTURA ' || i,
                                    sysdate,
                                    to_char(DBMS_RANDOM.VALUE(1111111111, 9999999999), '999999999999'),
                                    to_number(to_char(DBMS_RANDOM.VALUE(0, 99))), PERFIL_ID);
            SP_CRIARENDERECO(PERFIL_ID, 
                             1,
                             DBMS_RANDOM.STRING('U', 2),
                             DBMS_RANDOM.STRING('U', 20),
                             DBMS_RANDOM.STRING('U', 6),
                             to_char(DBMS_RANDOM.VALUE(11111111, 88888888), '999999999'),
                             '');
        end loop;
        PERFIL_ID := -1;
        for i in 1..100 loop
            if (DBMS_RANDOM.VALUE(0, 1) > 0.5) then
                TP_ANIMAL := 'CACHORRO';
            else
                TP_ANIMAL := 'GATO';
            end if;
            SP_CRIARRACA(TP_ANIMAL,
                        DBMS_RANDOM.STRING('U', 10));
        end loop;
        PERFIL_ID := -1;
        for i in 1..150 loop
            select ID_USER into USUARIO_ID from T_USUARIO
                                           inner join T_PERFIL on (T_USUARIO.ID_USER = T_PERFIL.T_USUARIO_ID_USER)
                                           where T_PERFIL.DISCRIMINACAO = 'ESTRUTURA'
                                           order by DBMS_RANDOM.RANDOM() fetch first 1 row only;
            select ID_RACA into RACA_ID from T_RACA order by DBMS_RANDOM.RANDOM() fetch first 1 row only;
            -- DBMS_OUTPUT.PUT_LINE('USUARIO: '|| USUARIO_ID || '\nRACA: ' || RACA_ID);

            -- if (DBMS_RANDOM.VALUE(0, 1) > 0.7) then
                -- select count(*) into ESTRUTURA_COUNT from T_ESTRUTURA
                --             inner join T_PERFIL on (T_PERFIL.ID_PERFIL = T_ESTRUTURA.T_PERFIL_ID_PERFIL)
                --             where T_PERFIL.T_USUARIO_ID_USER = USUARIO_ID;

                -- if (ESTRUTURA_COUNT > 0) then
                    select T_PERFIL_ID_PERFIL into PERFIL_ID from T_ESTRUTURA
                                inner join T_PERFIL on (T_PERFIL.ID_PERFIL = T_ESTRUTURA.T_PERFIL_ID_PERFIL)
                                where T_PERFIL.T_USUARIO_ID_USER = USUARIO_ID fetch first 1 row only;
                -- end if;
            -- end if;

            SP_CRIARANIMAL(USUARIO_ID,
                           'ANIMAL ' || i,
                           sysdate,
                           to_number(to_char(DBMS_RANDOM.VALUE(0, 1), '9')),
                           DBMS_RANDOM.VALUE(0.3, 10),
                           DBMS_RANDOM.VALUE(0.3, 100),
                           RACA_ID,
                           PERFIL_ID);
        end loop;
    end;

SELECT * FROM  DBA_ERRORS;


--* -------------------------------------------------------------------------- */
--*                                   TESTES                                   */
--* -------------------------------------------------------------------------- */

select * from t_estrutura;
select * from t_perfil where id_perfil = 1161;
select * from t_perfil where t_usuario_id_user = 648;
select * from t_perfil where id_perfil = 1161;
select * from t_animal;
select * from T_RACA;
select * from t_usuario;
select * from t_usuario inner join t_perfil on (t_usuario.ID_USER = t_perfil.T_USUARIO_ID_USER) where t_usuario.ID_USER = 1;
select * from T_ESTRUTURA;
select * from t_usuario inner join t_perfil on (t_usuario.ID_USER = t_perfil.T_USUARIO_ID_USER)
                        inner join t_animal on (t_perfil.ID_PERFIL = t_animal.T_PERFIL_ID_PERFIL)
                        inner join t_raca on (t_animal.T_RACA_ID_RACA = t_raca.ID_RACA);
                        
select * from t_usuario inner join t_perfil on (t_usuario.ID_USER = t_perfil.T_USUARIO_ID_USER)
                        inner join t_pessoa on (t_perfil.ID_PERFIL = t_pessoa.T_PERFIL_ID_PERFIL)
                        inner join t_endereco on (t_pessoa.T_PERFIL_ID_PERFIL = t_endereco.T_PERFIL_ID_PERFIL);

select * from t_estrutura
                        inner join t_endereco on (t_estrutura.T_PERFIL_ID_PERFIL = t_estrutura.T_PERFIL_ID_PERFIL);

select * from t_cargo;

set SERVEROUTPUT on
declare
    V_PERFIL_ID number;
begin
    SP_CRIARPESSOA('ALGO@ALGO.ALGO.BR', 'ALGUMACOISA', 'ALGUÉM', sysdate, '6546874', 1, V_PERFIL_ID);
    DBMS_OUTPUT.PUT_LINE('Perfil: ' || V_PERFIL_ID);
end;
    
execute SP_CRIARPESSOA_S_SAIDA('ALGO@ALGO.ALGO.BRs', 'ALGUMACOISA', 'ALGUÉM', sysdate, '65468741', 1);
execute SP_CRIARPESSOA_ENDERECO('ALGO@ALGO.ALGO.BRr', 'ALGUMACOISA', 'ALGUÉM', sysdate, '65468742', 1, 1, 'SP', 'GUAREI', 'CENTRO', '18250000');

execute SP_CRIARESTRUTURA_S_SAIDA(1, 'Um passo para o inferno', sysdate, '87942', 4);
execute SP_CRIARESTRUTURA_ENDERECO(1, 'Um passo para o inferno', sysdate, '879422', 4, 1, 'SP', 'GUAREI', 'CENTRO', '18250000');

execute SP_CRIARRACA('CACHORRO', 'VIRA LATA');
execute SP_CRIARRACA('GATO', 'VIRA LATA');

execute SP_CRIARANIMAL(1, 'Fifi', sysdate, 1, 0.8, 56, 1);
execute SP_CRIARANIMAL(2, 'Belinha', sysdate, 1, 0.8, 56, 1, 9);

execute SP_ATRIBUIRCARGO(4, 2);

execute SP_POPULARTABELAS();