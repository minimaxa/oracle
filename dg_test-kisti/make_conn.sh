#!/bin/ksh
#
#Make n number of connections to db
#
#
echo "Enter the number of connections to make :\c"
read NOF;
i=0
while [[ $i -lt $NOF ]];
do
 sqlplus -s userid/passwd @conn.sql >/dev/null &
 i=$i+1
done
exit;

