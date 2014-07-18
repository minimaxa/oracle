#!/bin/sh
count=0
while [ $count -lt $1 ]                                               # Set up a loop control
do                                                                            # Begin the loop
    count=`expr $count + 1`                                      # Increment the counter 
    sqlplus -s scott/tiger@$2 @test_conn.sql 
    sleep 1
done
