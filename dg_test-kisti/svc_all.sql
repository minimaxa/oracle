set linesize 100
set pagesize 100
col name format a15
col network_name format a15
col failover_method format a10
col failover_type format a10
col "FO_RETIES"   format 999999
col "FO_DELAY"    format 999999
col goal          format a10
select name, network_name, failover_method, failover_type,failover_retries "FO_RETRIES", failover_delay "FO_DELAY", goal 
from all_services order by 1;
