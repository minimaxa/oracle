#!/bin/ksh
variable1=$( 
echo "set feed off
set pages 0
select count(*) from redo_check;
exit
"  | sqlplus -s scott/tiger@kis03
)
echo "found count = $variable1"
