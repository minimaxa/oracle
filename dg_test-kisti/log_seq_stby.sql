select max(sequence#) from v$archived_log
    where applied != 'NO'
    and resetlogs_change# = (select resetlogs_change# from v$database);
