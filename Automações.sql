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
                                        P_CPF number, P_DS_SEXO smallint) is
    V_USUARIO_ID number;
    V_PERFIL_ID number;
    begin
        V_USUARIO_ID := SEQ_USUARIO.nextval;
        V_PERFIL_ID := SEQ_PERFIL.nextval;

        insert into T_USUARIO(ID_USER, DS_EMAIL, DS_SENHA) values (V_USUARIO_ID, P_DS_EMAIL, P_DS_SENHA);
        insert into T_PERFIL(ID_PERFIL, T_USUARIO_ID_USER, DISCRIMINACAO, NM_PERFIL, DT_ORIGEM)
                            values (V_PERFIL_ID, V_USUARIO_ID, 'PESSOA', P_NM_PERFIL, P_DT_ORIGEM);
        insert into T_PESSOA(T_PERFIL_ID_PERFIL, CPF, DS_SEXO) values (V_PERFIL_ID, P_CPF, P_DS_SEXO);

        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;

--* -------------------------------------------------------------------------- */
--*                                  Estrutura                                 */
--* -------------------------------------------------------------------------- */
--? Procedure CriarEstrutura
create or replace procedure SP_CRIARESTRUTURA(P_USUARIO_ID number, P_NM_PERFIL varchar2, P_DT_ORIGEM date, P_CNPJ number,
                                              P_DS_CATEGORIA smallint) is
    V_PERFIL_ID number;
    begin
        V_PERFIL_ID := SEQ_PERFIL.nextval;
        insert into T_PERFIL(ID_PERFIL, T_USUARIO_ID_USER, DISCRIMINACAO, NM_PERFIL, DT_ORIGEM)
            values (V_PERFIL_ID, P_USUARIO_ID, 'ESTRUTURA', P_NM_PERFIL, P_DT_ORIGEM);
        insert into T_ESTRUTURA(T_PERFIL_ID_PERFIL, CNPJ, DS_CATEGORIA) values (V_PERFIL_ID, P_CNPJ, P_DS_CATEGORIA);
        commit;
    exception
        when others then
            DBMS_OUTPUT.PUT_LINE(sqlerrm);
            rollback;
    end;
/

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

--? Procedure GerarDadosEstrutura
SP_CRIARESTRUTURA(P_USUARIO_ID number, P_NM_PERFIL varchar2, P_DT_ORIGEM date, P_CNPJ number, P_DS_CATEGORIA smallint)
create procedure GerarDadosEstrutura() is
    begin
        for i in 1..100
        loop
            execute SP_CRIARESTRUTURA();
        end loop;
    end;

--* -------------------------------------------------------------------------- */
--*                                   Animal                                   */
--* -------------------------------------------------------------------------- */
--? Trigger Animal

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

--* -------------------------------------------------------------------------- */
--*                                    RAÇA                                    */
--* -------------------------------------------------------------------------- */
--? Trigger Raça
create or replace trigger TG_RACA
    before insert or update or delete on T_RACA
    for each row
    declare
        existeRaca number;
    begin
        if(INSERTING or UPDATING) then
            select count(*) into existeRaca from T_RACA where DS_RACA = :NEW.DS_RACA and TP_ANIMAL = :NEW.TP_ANIMAL;

            if (existeRaca > 0) then
                raise_application_error(-20901, 'Esta raça já existe!');
            end if;
        end if;
    end;

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

--* -------------------------------------------------------------------------- */
--*                                   TESTES                                   */
--* -------------------------------------------------------------------------- */

select * from t_animal;
select * from T_RACA;
select * from t_usuario;
select * from T_ESTRUTURA;

execute SP_CRIARPESSOA('ALGO@ALGO.ALGO.BR', 'ALGUMACOISA', 'ALGUÉM', sysdate, 6546874, 1);
execute SP_CRIARESTRUTURA(18, 'Um passo para o inferno', sysdate, 87942, 4);
execute SP_CRIARRACA('CACHORRO', 'VIRA LATA');
execute SP_CRIARRACA('GATO', 'VIRA LATA');
execute SP_CRIARANIMAL(18, 'Fifi', sysdate, 1, 0.8, 30, 1);
execute SP_CRIARANIMAL(18, 'Belinha', sysdate, 1, 0.8, 30, 1, 45);