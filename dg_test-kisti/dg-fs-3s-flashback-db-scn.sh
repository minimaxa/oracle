#!/bin/sh

###################################################################
#
# Check for Invalid Command Line Arguments
# $1 = flashback_scn
#
###################################################################
if [ $# -lt 1 ]
then
  echo "Usage: $0 <flashback-scn>"
  echo "Example: $0 1234567"
  exit
fi

sqlplus -s "/as sysdba" <<EOF1
shutdown abort
startup mount
@flashback-db-scn.sql $1;
EOF1

