create or replace Package Body CastDB_Util
-------------------------------------------------------------
AS

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_DB
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
  Begin
   castdb_old.Update_Compound_Castdb();
   castdb_old.Update_Project_Castdb();

   castdb_plate.Update_TestPlate_FailedQC();
   castdb_run.Update_Run();

   castdb_sum.Update_sumInhibition_Cmpd();
   castdb_sum.Update_sumDoseResponse_Cmpd();
   castdb_cmpd.Update_sumCompound();

--   castdb_sum.Update_sumInhibition_Struct();
--   castdb_sum.Update_sumDoseResponse_Struct();
--  coadd_struct.Update_sumStructure();

--   coadd_project.Update_Project();

--   coadd_struct.Update_Structure_Index();

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_DB;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Export_CastDB (xExpDir Varchar2 Default 'EXP_DIR')
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  Is
    H1 Number := NULL;
    FName Varchar2(120);
  Begin
   FName := 'COADB_CastDB_expdp_' || TO_CHAR(SYSDATE, 'yyyy_mm_dd');

   H1 := DBMS_DATAPUMP.open(
      operation => 'EXPORT',
	  job_mode => 'SCHEMA',
	  job_name => 'CastDB_EXPDP',
	  version => 'COMPATIBLE');

   DBMS_DATAPUMP.add_file(
      handle => H1,
      filename => FName || '.log',
      directory => xExpDir,
      filetype => 3);

   DBMS_DATAPUMP.add_file(
      handle => H1,
      filename => FName || '.dmp',
      directory => xExpDir,
      filetype => 1);

   DBMS_DATAPUMP.START_JOB(
      handle => H1,
      skip_current => 0);

   DBMS_DATAPUMP.DETACH(
      handle => H1);

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Export_CastDB;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE AddLog
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (lProcedure Varchar2,lType Varchar2,lDescription Varchar2,lStatus Varchar2)
  Is
  Begin
   Insert Into Application_Log
    (Log_Procedure,Log_Type,Log_Date,Log_Description,Log_Status)
   Values
   (lProcedure,lType,SYSDATE,lDescription,lStatus);
   Commit;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End AddLog;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

 -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION fmtDR_Sort
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (xPrefix Varchar2, xValue Number) Return Number
  Is
    lret Varchar2(25);
  Begin
   If (xPrefix = '>') Then
        lret := (9 + xValue/1000);
   ElsIf (xPrefix = '<=') Then
        lret := -(0 + xValue/1000);
   Else
        lret := (0 + xValue/1000);
   End If;

   Return lret;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End fmtDR_Sort;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION fmtSort_DR
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (xValue Number) Return Varchar2
  Is
    lret Varchar2(25);
  Begin
   If (xValue > 9) Then
        lret := fmtDR('>',1000*(xValue-9));
   ElsIf (xValue < 0) Then
        lret := fmtDR('<=',-1000*(xValue));
   Else
        lret := fmtDR('=',1000*(xValue));
   End If;

   Return lret;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End fmtSort_DR;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION fmtDRX_Sort
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (xPrefix Varchar2, xValue Number) Return Varchar2
  Is
    lfmt Varchar2(15);
    lprf Varchar2(25);
    lret Varchar2(25);
    xpad Number;
  Begin
   lfmt := 'FM990D9999';
   If (xValue < 10 And xValue >= 1) Then
    lfmt := 'FM990D999';
   End If;
   If (xValue < 100 And xValue >= 10) Then
    lfmt := 'FM990D99';
   End If;
   If (xValue < 1000 And xValue >= 100) Then
    lfmt := 'FM990D9';
   End If;
   If (xValue >= 1000) Then
    lfmt := 'FM990';
   End If;


   lprf := RTrim(To_Char(xValue, lfmt), To_Char(0, 'D'));
   If (xPrefix = '>') Then
        lret := Concat(lprf,'Z');
   ElsIf (xPrefix = '<=') Then
        lret := Concat(lprf,'M');
   Else
        lret := Concat(lprf,'A');
   End If;

   xpad := 5;
   If (InStr(lret,'.') > 0) Then
        xpad := Length(lret) - InStr(lret,'.') + 5;
   End If;
   lret := LPad(lret,xpad,'0');

   Return lret;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End fmtDRX_Sort;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION fmtSort_DRX
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (xValue Varchar2) Return Varchar2
  Is
    lret Varchar2(25);
    lval Varchar2(25);
    lprf Varchar2(2);
  Begin

   lprf := SubStr(xValue,-1,1);
   lval := SubStr(xValue,1,Length(xValue)-1);

   lret := Trim(Leading '0' from lval);
   If (SubStr(lret,1,1) = '.') Then
        lret := Concat('0',lret);
   End If;

   If (lprf = 'Z') Then
        lprf := '>';
   ElsIf (lprf = 'M') Then
        lprf := '<=';
   Else
        lprf := '';
   End If;

   lret := Concat(lprf,lret);
   Return lret;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End fmtSort_DRX;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION fmtDR
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (xPrefix Varchar2, xValue Number) Return Varchar2
  Is
    lfmt Varchar2(15);
    lprf Varchar2(25);
    lret Varchar2(25);
  Begin

   lfmt := 'FM990D9999';
   If (xValue < 10 And xValue >= 1) Then
    lfmt := 'FM990D999';
   End If;
   If (xValue < 100 And xValue >= 10) Then
    lfmt := 'FM990D99';
   End If;
   If (xValue < 1000 And xValue >= 100) Then
    lfmt := 'FM990D9';
   End If;
   If (xValue >= 1000) Then
    lfmt := 'FM990';
   End If;

   lprf := RTrim(To_Char(xValue, lfmt), To_Char(0, 'D'));
   lret := lprf;
   If ((xPrefix = '<=') Or (xPrefix = '>')) Then
	  lret := Concat(xPrefix,lprf);
   End If;

   Return lret;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End fmtDR;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION fmtPID
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (xPID Number) Return Varchar2
  Is
   cPID Project.Project_ID%Type;
  Begin
   cPID := Concat('P',LPAD(xPID,4,'0'));
   Return cPID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End fmtPID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION fmtCID
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (xCID Number) Return Varchar2
  Is
   cCID Compound.Compound_ID%Type;
  Begin
   cCID := Concat('C', LPAD(xCID,7,'0'));
   Return cCID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End fmtCID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


-- ===================================================================== --
END CastDB_Util;
-- ===================================================================== --
