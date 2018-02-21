set pagesize 2000

Select
       substr(a.spid,1,9) pid,
       substr(b.sid,1,5) sid,
       substr(b.serial#,1,5) ser#,
       substr(b.machine,1,6) box,
       substr(b.username,1,10) username,
--       b.server,
       substr(b.osuser,1,8) os_user,
       substr(b.program,1,30) program
from v$session b, v$process a
where
b.paddr = a.addr
and type='USER'
order by spid;


	select inst_id,sid,serial# from gv$session where username='SCOTT';
  alter system kill session 'sid,serial#,@1';

select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text
from v$sqltext_with_newlines t,V$SESSION s
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value
and s.status = 'ACTIVE'
and s.username <> 'SYSTEM'
order by s.sid,t.piece;
