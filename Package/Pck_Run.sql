create or replace Package CastDB_Run
-------------------------------------------------------------
IS

 PROCEDURE Rename_RunID(oldRunID Varchar2, newRunID Varchar2);
 PROCEDURE Update_Run;

-- ===================================================================== --
END CastDB_Run;
-- ===================================================================== --
/
