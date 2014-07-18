col name format a10
col flashback_on heading "FLASHBACK" format a10
select name, open_mode, database_role, switchover_status from v$database;
