col name format a50
select * from (
select sequence#, name, applied from v$archived_log
      where resetlogs_change# = (select resetlogs_change# from v$database)
      order by sequence# desc
)
where rownum <=10;
