connect / as sysdba
alter user scott identified by tiger account unlock;
grant select on v_$instance to scott;
PROMPT Login SCOTT User and Create Demo Table : Please Enter Key
PAUSE
connect scott/tiger
drop table redo_check purge;
create table redo_check (id number, updated date);
insert into redo_check values(1,sysdate);
commit;
@qry-tab
