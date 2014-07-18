col "UPDATED" format a20
select id, to_char(updated, 'YYYY-MM-DD HH24:MI:SS') "UPDATED" from scott.redo_check;
