create or replace Package Body CastDB_Plate
-------------------------------------------------------------
AS

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_TestPlate_FailedQC
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   Is
    nP Number;
   Begin

    Update Testplate
       Set Issues = NULL
     Where Issues = 'None';

    Update Testplate
       Set Status = 0
     Where Status is null;

    Update Testplate
       Set Status = -1
     Where Status >= 0
       And (Plate_QC < 0.2 OR Issues like '%FailedQC%');

    Update Testplate
       Set Status = 1
     Where Status >= 0
       And Plate_QC >= 0.2
       And (Issues is NULL OR not(Issues like '%FailedQC%') OR Issues like '%PassedQC%');

    Select count(*) into nP From TestPlate;

-- Inhibition

    Update TestWell tw
       Set Status = -1
     Where tw.Plate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = -1);

    Update TestWell tw
       Set Status = 1
     Where (tw.Status is NULL OR tw.Status = 0)
   And tw.Plate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = 1);

-- MIC
    Update ActData_MIC dd
       Set Status = -1
     Where dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = -1);

    Update ActData_MIC dd
       Set Status = 1
     Where (dd.Status is NULL OR dd.Status = 0)
   And dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = 1);

-- Cytotox
    Update ActData_Cytotox dd
       Set Status = -1
     Where dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = -1);

    Update ActData_Cytotox dd
       Set Status = 1
     Where (dd.Status is NULL OR dd.Status = 0)
   And dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = 1);

-- Haemolysis
    Update ActData_Haemolysis dd
       Set Status = -1
     Where dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = -1);

    Update ActData_Haemolysis dd
       Set Status = 1
     Where (dd.Status is NULL OR dd.Status = 0)
   And dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = 1);

-- CMC
    Update ActData_CMC dd
       Set Status = -1
     Where dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = -1);

    Update ActData_CMC dd
       Set Status = 1
     Where (dd.Status is NULL OR dd.Status = 0)
   And dd.TestPlate_ID in
           ( Select tp.Plate_ID
           From TestPlate tp
      Where tp.Status = 1);

 castdb_util.AddLog('Update_TestPlate_FailedQC','Update','TestPlate : ' || To_Char(nP),'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_TestPlate_FailedQC;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_MasterTube
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (nBarcode Varchar2, nPlateID Varchar2, nWellID Varchar2, nCompoundID Varchar2,
      nConc Varchar2, nConcUnit Varchar2, nSolvent Varchar2)
  Is
   oBarcode MasterTube.Barcode%Type;
   oPlateID MasterTube.Plate_ID%Type;
   oWellID MasterTube.Well_ID%Type;
   oConc MasterTube.Conc%Type;
   oConcUnit MasterTube.Conc_Unit%Type;
   oSolvent MasterTube.Solvent%Type;
   xCnt Number;
  Begin
 --
 -- Update Old MasterTube by Plate_ID/Well_ID
 --
   If (nBarcode is not NULL) Then

     xCnt := 0;
     Select count(1) Into xCnt
       From MasterTube
      Where Plate_ID = nPlateID AND Well_ID = nWellID;

     If (xCnt > 0) Then
       Select Barcode into oBarcode
         From MasterTube
        Where Plate_ID = nPlateID AND Well_ID = nWellID;

       If ((oBarcode is not NULL) And (oBarcode != nBarcode)) Then
         Update MasterTube
            Set Plate_ID = NULL, Well_ID = NULL,
                Prev_Plate_ID = nPlateID, Prev_Well_ID = nWellID
          Where Barcode = oBarcode;
       End If;
     End If;

 --
 -- Update New MasterTube by Barcode
 --
     xCnt := 0;
     Select count(1) Into xCnt
       From MasterTube
      Where Barcode = nBarcode;

     If (xCnt > 0) Then
        Select  Barcode, Plate_ID, Well_ID , Conc, Conc_Unit,  Solvent
          into oBarcode, oPlateID, oWellID ,oConc, oConcUnit, oSolvent
          From MasterTube
         Where Barcode = nBarcode;

        If ((oPlateID is NULL) And (oWellID is NULL)) Then
           Update MasterTube
              Set Plate_ID = nPlateID, Well_ID = nWellID
            Where Barcode = nBarcode;
        End If;
        If ((nPlateID != oPlateID) Or (nWellID != oWellID)) Then
           Update MasterTube
              Set Plate_ID = nPlateID, Well_ID = nWellID,
                  Prev_Plate_ID = oPlateID, Prev_Well_ID = oWellID
            Where Barcode = nBarcode;
        End If;
        If ((oConc is NULL) And (oConcUnit is NULL) And (oSolvent is NULL)) Then
           Update MasterTube
              Set Conc = nConc, Conc_Unit = nConcUnit, Solvent = nSolvent
            Where Barcode = nBarcode;
        End If;
        If ((nConc != oConc) Or (nConcUnit != oConcUnit) Or (nSolvent != oSolvent)) Then
           Update MasterTube
              Set Conc = nConc, Conc_Unit = nConcUnit, Solvent = nSolvent
            Where Barcode = nBarcode;
        End If;


     Else
        Insert Into MasterTube
          (Compound_ID, Barcode, Plate_ID, Well_ID, Conc,Conc_Unit,  Solvent)
        Values
         (nCompoundID, nBarcode, nPlateID, nWellID,nConc, nConcUnit, nSolvent);
     End If;

 --
 -- Update MasterPlate by Plate_ID
 --
     If (nPlateID is not NULL) Then
       xCnt := 0;
       Select count(1) Into xCnt From MasterPlate Where Plate_ID = nPlateID;

       If (xCnt = 0) Then
          Insert Into MasterPlate (Plate_ID, Plate_Type, Well_Type )
                           Values (nPlateID,'Stock',   'Tube');
       End If;
     End If;
   End If;

 -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_MasterTube;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

 -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_MasterWell
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (nPlateID Varchar2, nWellID Varchar2, nCompoundID Varchar2,
           nConc Varchar2, nConcUnit Varchar2, nSolvent Varchar2)

  Is
   oCompoundID MasterWell.Compound_ID%Type;
   oPlateID MasterWell.Plate_ID%Type;
   oWellID MasterWell.Well_ID%Type;
   oConc MasterWell.Conc%Type;
   oConcUnit MasterWell.Conc_Unit%Type;
   oSolvent MasterWell.Solvent%Type;
  xCnt Number;
  Begin
 --
 -- Update New MasterWell by PlateID/WellID
 --
   If ((nPlateID is not NULL) And (nWellID is not NULL)) Then
     xCnt := 0;
     Select count(1) Into xCnt
       From MasterWell
      Where Plate_ID = nPlateID And Well_ID = nWellID;

     If (xCnt > 0) Then
        Select Plate_ID, Well_ID , Conc, Conc_Unit,  Solvent
          into oPlateID, oWellID ,oConc, oConcUnit, oSolvent
          From MasterWell
         Where Plate_ID = nPlateID And Well_ID = nWellID;

        If ((oConc is NULL) And (oConcUnit is NULL) And (oSolvent is NULL)) Then
           Update MasterWell
              Set Conc = nConc, Conc_Unit = nConcUnit, Solvent = nSolvent
            Where Plate_ID = nPlateID And Well_ID = nWellID;
        End If;
        If ((nConc != oConc) Or (nConcUnit != oConcUnit) Or (nSolvent != oSolvent)) Then
           Update MasterWell
              Set Conc = nConc, Conc_Unit = nConcUnit, Solvent = nSolvent
            Where Plate_ID = nPlateID And Well_ID = nWellID;
        End If;

     Else
       Insert Into MasterWell
          (Compound_ID, Plate_ID, Well_ID, Conc, Conc_Unit,  Solvent)
        Values
          (nCompoundID, nPlateID, nWellID,nConc, nConcUnit, nSolvent);
     End If;
 --
 -- Update MasterPlate by Plate_ID
 --
     xCnt := 0;
     Select count(1) Into xCnt From MasterPlate Where Plate_ID = nPlateID;

     If (xCnt = 0) Then
        Insert Into MasterPlate (Plate_ID, Plate_Type, Well_Type )
                         Values (nPlateID, 'Stock',   'Well');
     End If;
  End If;

 -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_MasterWell;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Rename_TestPlateID
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (oldPlateID Varchar2, newPlateID Varchar2)
  Is
  Begin

  Update TestPlate
   Set Plate_ID = newPlateID Where  Plate_ID = oldPlateID;
  Update TestWell
   Set Plate_ID = newPlateID Where  Plate_ID = oldPlateID;

  Update ActData_MIC
   Set TestPlate_ID = newPlateID Where  TestPlate_ID = oldPlateID;
  Update ActData_CMC
   Set TestPlate_ID = newPlateID Where  TestPlate_ID = oldPlateID;
  Update ActData_Cytotox
   Set TestPlate_ID = newPlateID Where  TestPlate_ID = oldPlateID;
  Update ActData_Haemolysis
   Set TestPlate_ID = newPlateID Where  TestPlate_ID = oldPlateID;
  Update QCData
   Set TestPlate_ID = newPlateID Where  TestPlate_ID = oldPlateID;

 castdb_util.AddLog('Rename_TestPlateID','Rename','TestPlate : ' || oldPlateID || ' to ' || newPlateID,'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Rename_TestPlateID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Rename_MotherPlateID
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (oldPlateID Varchar2, newPlateID Varchar2)
  Is
  Begin

  Update MasterPlate
    Set Plate_ID = newPlateID Where  Plate_ID = oldPlateID;
  Update MasterWell
   Set Plate_ID = newPlateID Where  Plate_ID = oldPlateID;
  Update TestPlate
   Set MotherPlate_ID = newPlateID Where  MotherPlate_ID = oldPlateID;

  castdb_util.AddLog('Rename_MotherPlateID','Rename','MotherPlate : ' || oldPlateID || ' to ' || newPlateID,'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Rename_MotherPlateID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

 -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Reject_TestPlateID
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     (rPlateID Varchar2)
  Is
  Begin

  Update TestPlate
   Set Status = -1 Where  Plate_ID = rPlateID;

  Update TestPlate
   Set Status = -1, Plate_QC = -4 Where  Plate_ID = rPlateID;
  Update ActData_MIC
   Set Status = -1 Where  TestPlate_ID = rPlateID;
  Update ActData_Cytotox
   Set Status = -1 Where  TestPlate_ID = rPlateID;
  Update ActData_Haemolysis
   Set Status = -1 Where  TestPlate_ID = rPlateID;
  Update ActData_CMC
   Set Status = -1 Where  TestPlate_ID = rPlateID;
  Update QCData
   Set Status = -1 Where  TestPlate_ID = rPlateID;

 castdb_util.AddLog('Reject_TestPlateID','Rename','TestPlate : ' || rPlateID || ' Status -1 ','Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Reject_TestPlateID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ===================================================================== --
END CastDB_Plate;
-- ===================================================================== --
