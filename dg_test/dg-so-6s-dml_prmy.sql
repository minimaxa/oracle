select count(*) from scott.redo_check;
insert into scott.redo_check select max(id)+1,sysdate from scott.redo_check;
commit;
select count(*) from scott.redo_check;

