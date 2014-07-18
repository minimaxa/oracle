PID=`ps -ef|grep dg-fo-1s-insert |grep -v grep |awk '{print $2}'`
echo ""
echo "=== 다음 프로세스를 kill합니다 ==="
ps -ef|grep $PID|grep -v grep
ps -ef|grep $PID|grep -v grep |awk '{print "kill -9 "$2}' |sh
echo ""

