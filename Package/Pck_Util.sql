create or replace Package CastDB_Util
-------------------------------------------------------------
IS

 PROCEDURE Update_DB;

 PROCEDURE Export_CastDB (xExpDir Varchar2 Default 'EXP_DIR');

 PROCEDURE AddLog
     (lProcedure Varchar2,lType Varchar2,lDescription Varchar2,lStatus Varchar2);

 FUNCTION fmtDR (xPrefix Varchar2, xValue Number) Return Varchar2;

 FUNCTION fmtDR_Sort(xPrefix Varchar2, xValue Number) Return Number;
 FUNCTION fmtSort_DR(xValue Number) Return Varchar2;

 FUNCTION fmtDRX_Sort(xPrefix Varchar2, xValue Number) Return Varchar2;
 FUNCTION fmtSort_DRX (xValue Varchar2) Return Varchar2;

 FUNCTION fmtPID (xPID Number) Return Varchar2;
 FUNCTION fmtCID (xCID Number) Return Varchar2;

-- ===================================================================== --
END CastDB_Util;
-- ===================================================================== --
/
