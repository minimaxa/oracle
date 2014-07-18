connect / as sysdba
@@db-status
@@qry-tab
PROMPT CURRENT MOUNT Mode  : Manager Recovery Standby DB Cancel : Please Enter Key
PAUSE
@@mrp_cancel;
PROMPT ALTER DATABASE OPEN : Please Enter Key
PAUSE
alter database open;
@@db-status
PROMPT CURRENT READ ONLY Mode : SELECT Table : Please Enter Key
PAUSE
@@qry-tab
