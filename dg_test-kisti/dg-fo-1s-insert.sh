#!/bin/sh

###################################################################
#
# Check for Invalid Command Line Arguments
# $1 = TNS Alias
#
###################################################################
if [ $# -lt 1 ]
then
  echo "Usage: $0 <TNS Alias>"
  echo "Example: $0 ORCL"
  exit
fi
sqlplus -s "scott/tiger@$1" <<EOF1
drop table primary_tab purge;
create table primary_tab(id number, updated date);
insert into primary_tab values (1, sysdate);
commit;
EOF1

while true
do
sqlplus -s "scott/tiger@$1" <<EOF
set feedback off
col instance_name format a10
set head off
     select instance_name, to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') from v\$instance;
     update primary_tab set id=id+1, updated=sysdate;
     commit;
     select id, to_char(updated, 'YYYY-MM-DD HH24:MI:SS') from primary_tab;
     exit;
EOF
sleep 1
done

