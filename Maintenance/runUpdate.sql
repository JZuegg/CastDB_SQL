-- -------------------- --
-- Run Manual UPDATE
-- -------------------- --

-- sqlplus castdb/coaddAdmin@coadb @runUpdate

Set Timing on

-- Execute castdb_util.Update_DB();

Execute    castdb_old.Update_Compound_Castdb();
Execute    castdb_old.Update_Project_Castdb();
   
Execute    castdb_plate.Update_TestPlate_FailedQC();
Execute    castdb_run.Update_Run();

-- Execute    castdb_sum.Update_sumInhibition_Cmpd();   
-- Execute    castdb_sum.Update_sumDoseResponse_Cmpd();
-- Execute    castdb_cmpd.Update_sumCompound();

quit;
