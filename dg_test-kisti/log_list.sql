set pagesize 100
set linesize 120
col member format a50
select group#, type, member from v$logfile order by 1;
select group#, bytes/1048576 "SIZE(MB)" from v$log;
select group#, bytes/1048576 "SIZE(MB)" from v$standby_log;

