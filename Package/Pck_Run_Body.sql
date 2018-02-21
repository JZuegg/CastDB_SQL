create or replace Package Body CastDB_Run
-------------------------------------------------------------
AS

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Rename_RunID
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  (oldRunID Varchar2, newRunID Varchar2)
 Is
 Begin

 Update ActData_MIC
  Set Run_ID = newRunID Where  Run_ID = oldRunID;
 Update ActData_Cytotox
  Set Run_ID = newRunID Where  Run_ID = oldRunID;
 Update ActData_Haemolysis
  Set Run_ID = newRunID Where  Run_ID = oldRunID;
 Update ActData_CMC
  Set Run_ID = newRunID Where  Run_ID = oldRunID;
 Update QCData
  Set Run_ID = newRunID Where  Run_ID = oldRunID;
 Update MasterPlate
  Set Run_ID = newRunID Where  Run_ID = oldRunID;
 Update TestPlate
  Set Run_ID = newRunID Where  Run_ID = oldRunID;

 Update ScreenRun
  Set Run_ID = newRunID Where  Run_ID = oldRunID;
 Commit;
  castdb_util.AddLog('Rename_RunID','Rename','Run : ' || oldRunID || ' to ' || newRunID,'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Rename_RunID;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_Run
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   Is
    nP Number;
   Begin

    Insert Into ScreenRun (Run_ID)
     ( Select Distinct tp.Run_ID
         From TestPlate tp
          Left Join ScreenRun r on r.Run_ID = tp.Run_ID
        Where r.Run_ID is NULL And tp.Run_ID is not NULL);

    Insert Into ScreenRun (Run_ID)
     ( Select Distinct mp.Run_ID
         From MasterPlate mp
          Left Join ScreenRun r on r.Run_ID = mp.Run_ID
        Where r.Run_ID is NULL And mp.Run_ID is not NULL);

    Insert Into ScreenRun (Run_ID)
     ( Select Distinct d.Run_ID
         From ActData_MIC d
          Left Join ScreenRun r on r.Run_ID = d.Run_ID
        Where r.Run_ID is NULL And d.Run_ID is not NULL);

    Insert Into ScreenRun (Run_ID)
     ( Select Distinct d.Run_ID
         From ActData_Cytotox d
          Left Join ScreenRun r on r.Run_ID = d.Run_ID
        Where r.Run_ID is NULL And d.Run_ID is not NULL);

    Insert Into ScreenRun (Run_ID)
     ( Select Distinct d.Run_ID
         From ActData_Haemolysis d
          Left Join ScreenRun r on r.Run_ID = d.Run_ID
        Where r.Run_ID is NULL And d.Run_ID is not NULL);

    Insert Into ScreenRun (Run_ID)
     ( Select Distinct d.Run_ID
         From ActData_CMC d
          Left Join ScreenRun r on r.Run_ID = d.Run_ID
        Where r.Run_ID is NULL And d.Run_ID is not NULL);

    Commit;

    -- Update Numbers

	Update ScreenRun r
       Set nInhibition =
        ( Select count(*)
            From TestPlate tp
             Left Join TestWell tw on tw.Plate_ID = tp.Plate_ID
           Where tp.Run_ID = r.Run_ID
             And tw.Compound_ID like 'C%'
             And tw.isSample = 1
             And Active is not NUll);

	Update ScreenRun r
       Set nMIC =
       ( Select count(*)
           From ActData_MIC d
          Where d.Run_ID = r.Run_ID);

    Update ScreenRun r
       Set nCytotox =
       ( Select count(*)
           From ActData_Cytotox d
          Where d.Run_ID = r.Run_ID);

    Update ScreenRun r
       Set nHaemolysis =
       ( Select count(*)
           From ActData_Haemolysis d
          Where d.Run_ID = r.Run_ID);

	Update ScreenRun r
	   Set nCMC =
       ( Select count(*)
           From ActData_CMC d
          Where d.Run_ID = r.Run_ID);

	Update ScreenRun r
	   Set nQC =
       ( Select count(*)
           From QCData d
          Where d.Run_ID = r.Run_ID);

	Update ScreenRun r
	   Set nTestPlate =
       ( Select count(*)
           From TestPlate d
          Where d.Run_ID = r.Run_ID);

	Update ScreenRun r
	   Set Screen_Date =
       ( Select max(Test_Date)
           From TestPlate d
          Where d.Run_ID = r.Run_ID);

	Update ScreenRun r
       Set nMotherPlate =
       ( Select count(*)
           From MasterPlate d
          Where d.Run_ID = r.Run_ID);

	Update ScreenRun r
	   Set nCompound =
       ( Select count(Distinct tw.Compound_ID)
           From TestPlate tp
	        Left Join TestWell tw on tw.Plate_ID = tp.Plate_ID
          Where tp.Run_ID = r.Run_ID
	        And tw.Compound_ID like 'C%'
	        And tw.isSample = 1);

	Update ScreenRun r
	   Set nStructure =
       ( Select count(Distinct c.Structure_ID)
           From TestPlate tp
	        Left Join TestWell tw on tw.Plate_ID = tp.Plate_ID
             Left join Compound c on tw.Compound_ID = c.Compound_ID
          Where tp.Run_ID = r.Run_ID
	        And tw.Compound_ID like 'C%'
	        And tw.isSample = 1
            And c.Structure_ID is not NULL);




	Update ScreenRun r
       Set nAssay =
       ( Select count(Distinct tp.AssayType_ID)
           From TestPlate tp
          Where tp.Run_ID = r.Run_ID);

    Commit;
  Select count(*) into nP From ScreenRun;
  castdb_util.AddLog('Update_Run','Update','Run : ' || To_Char(nP),'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_Run;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


-- ===================================================================== --
END CastDB_Run;
-- ===================================================================== --
