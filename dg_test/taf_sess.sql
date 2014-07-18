set linesize 120
set pagesize 100
col username format a10
col machine  format a20
col program  format a30
col service_name format a15
col failover_type format a10
col failover_method format a10
col failed_over format a9
select username, machine, program, service_name,failover_type, failover_method, failed_over from v$session
where username is not null order by 1,4;
