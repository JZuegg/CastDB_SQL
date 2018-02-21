
-- Grant Create Job to <User>

EXEC DBMS_SCHEDULER.CREATE_SCHEDULE( -
 repeat_interval => 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SAT;BYHOUR=4;BYMINUTE=30;BYSECOND=0', -
 comments        => 'Sat at 04:30 to export CastDB data', -
 schedule_name   => 'ExpDP_CastDB_Sat_0430');

EXEC DBMS_SCHEDULER.CREATE_JOB( -
 job_name      => 'ExpDP_CastDB', -
 job_type      => 'STORED_PROCEDURE', -
 job_action    => 'castdb_util.Export_CastDB', -
 job_class     => 'DEFAULT_JOB_CLASS', -
 schedule_name => 'ExpDP_CastDB_Sat_0430', -
 comments      => 'ExpDP CastDB data', -
 auto_drop     => FALSE, -
 enabled       => TRUE);

--------------------------------------------------------------------------------------------

 EXEC DBMS_SCHEDULER.CREATE_SCHEDULE( -
  repeat_interval => 'FREQ=DAILY;BYHOUR=11,23', -
  comments        => 'Every 11:00 and 23:00 to update CastDB data', -
  schedule_name   => 'Update_CastDB_1100_2300');

 EXEC DBMS_SCHEDULER.CREATE_JOB( -
  job_name      => 'Update_CastDB', -
  job_type      => 'STORED_PROCEDURE', -
  job_action    => 'castdb_util.Update_DB', -
  job_class     => 'DEFAULT_JOB_CLASS', -
  schedule_name => 'Update_CastDB_1100_2300', -
  comments      => 'Update CastDB data', -
  auto_drop     => FALSE, -
  enabled       => TRUE);
