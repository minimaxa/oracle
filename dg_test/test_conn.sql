col "Time" format a17
col "Instance" format a10
col "Host" format a10
col "Service Name" format a20
select to_char(sysdate, 'yyyymmdd hh24:mi:ss') "Time", sys_context('userenv', 'instance_name') "Instance",
       sys_context('userenv', 'server_host') "Host",
       sys_context('userenv', 'service_name') "Service Name"
from dual;
exit;
