select sysdate from dual;
exec dbms_lock.sleep(10);
exit;

