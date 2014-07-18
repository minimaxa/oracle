#!/bin/ksh

if [ "$#" -ne "3" ]; then
  # conn.sh dbm 10  1
  echo "usage: `basename $0` tns-alias count interval"
  exit
fi 

inst1="$1"1
inst2="$1"2

#inst1="$(echo ${inst1} | tr 'a-z' 'A-Z')"
#inst2="$(echo ${inst2} | tr 'a-z' 'A-Z')"

log="conn.log"

function dblogin
{
let i=1

tee << _eosql_
set pages 0 feed off
spool $log
_eosql_

while(( $i <= $2 ))
do
tee << _eosql_
connect system/oracle@$1
select
  $i,
  to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
  instance_name
from
  v\$instance;
disconnect
_eosql_
sleep $3
let i=i+1
done
}

dblogin $1 $2 $3 | sqlplus -s /nolog

echo total logins to $inst1: `grep $inst1 $log | wc -l`
echo total logins to $inst2: `grep $inst2 $log | wc -l`


