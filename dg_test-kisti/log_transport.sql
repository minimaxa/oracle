set pagesize 100
set linesize 100
col dest_name format a19
col destination format a11
col error format a30
select dest_name, target, destination, status, error
from v$archive_dest where target='STANDBY';

