shutdown immediate
startup mount
alter database flashback on;
alter database open;
select flashback_on from v$database;
