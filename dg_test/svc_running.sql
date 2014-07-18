set linesize 100
set pagesize 100
col name format a15
col network_name   format a15
col goal           format a10
col "AQ_HA_NOTIFY" format a8
col clb_goal       format a8
select name, network_name, goal, AQ_HA_NOTIFICATION "AQ_HA_NOTIFY", CLB_GOAL from v$services
order by 1;
