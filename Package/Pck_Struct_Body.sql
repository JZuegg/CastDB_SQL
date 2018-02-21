create or replace Package Body CastDB_Struct
-------------------------------------------------------------
AS

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumStructure
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
   nP Number;
  Begin
   Update_sumStructure_SP();
   Update_sumStructure_DR();

   Update sum_Structure
     Set PS_Status = 'Completed'
   Where NVL(PS_nAssays,0) = 7;

  Update sum_Structure
     Set PS_Status = 'missingPS'
   Where NVL(PS_nAssays,0) < 7;

  Update sum_Structure
     Set Screen_Status = 'NotActive'
   Where PS_nAct = 0
     And NVL(HC_nHit,0) = 0 ;

  Update sum_Structure
     Set Screen_Status = 'Active',
         HC_Status  = 'toHC'
   Where NVL(PS_nAct,0) > 0 and HC_nAssays is Null;

  Update sum_Structure
     Set HC_Status = 'Completed'
   Where HC_nAssays_STD = 7;

  Update sum_Structure
     Set HC_Status = 'missingHC'
   Where HC_nAssays_STD < 7;

  Update sum_Structure
     Set TX_Status = 'Completed'
   Where TX_nAssays = 2;

  Update sum_Structure
     Set TX_Status = 'missingTox'
   Where TX_nAssays < 2;

  Update sum_Structure
     Set Screen_Status = 'Hit'
   Where HC_nHit > 0 and TX_nHit = 0;

  Update sum_Structure
     Set Screen_Status = 'Hit (missingTox)'
   Where HC_nHit > 0 and NVL(TX_nAssays,0) = 0;

  Update sum_Structure
     Set Screen_Status = 'HitTox'
   Where HC_nHit > 0 and TX_nHit > 0;

  Update sum_Structure
     Set Screen_Status = 'NotHit'
   Where HC_nHit = 0;

   Commit;

  Select count(*) into nP From sum_Structure;
  castdb_util.AddLog('Update_sumStructure','Update','Structures : ' || To_Char(nP),'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumStructure;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumStructure_DR
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
IS
  Cursor c_StructureDR Is
   Select Distinct Structure_ID
     From sumStruct_DoseResponse
     Where Structure_ID is not NULL;
  sid Compound.Structure_ID%Type;
  nP Number;
Begin
  nP := 0;
  Open c_StructureDR;
  Loop
    Fetch c_StructureDR into sid;
    Exit When c_StructureDR%notfound;
    sumDR_struct(sid);
    nP := nP + 1;
  End Loop;
  Close c_StructureDR;

 castdb_util.AddLog('Update_sumStructure_DR','Update','Structures : ' || To_Char(nP),'Done');
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumStructure_DR;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE sumDR_struct (lSID Varchar2)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
 IS
  --------------------------------------------------------
  -- Cursors
  --------------------------------------------------------
  Cursor c_DRAssays(xSID VARCHAR2) Is
   Select *
   From
   ( Select sc.Structure_ID, ass.Summary_Type, nAct
       From sumStruct_DoseResponse sc
        Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
      Where sc.Structure_ID = xSID  )
  Pivot
   ( Count(nAct)
       For Summary_Type
           IN ('GP' GP,'GP_SER' GP_SER,
               'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
               'FG' FG,'FG_SER' FG_SER,
               'TX' TX)
      );

  --------------------------------------------------------
  Cursor c_HVAssays(xSID VARCHAR2) Is
   Select *
   From
   ( Select sc.Structure_ID, ass.AssayType_Class, nAct
       From sumStruct_DoseResponse sc
        Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
      Where sc.Structure_ID = xSID  )
  Pivot
   ( Count(nAct)
       For AssayType_Class
           IN ('Standard' StandardA,'Serum_Reversal' SerumA,
               'Extended' ExtendedA,'Mutant_Membrane' MembraneA)
      );

  --------------------------------------------------------
  Cursor c_DRActs(xSID VARCHAR2) Is
   Select *
    From
    ( Select sc.Structure_ID, ass.Summary_Type, nAct
        From sumStruct_DoseResponse sc
         Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
       Where sc.Structure_ID = xSID  )
   Pivot
    ( Sum(nAct)
        For Summary_Type
            IN ('GP' GP,'GP_SER' GP_SER,
                'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                'FG' FG,'FG_SER' FG_SER,
                'TX' TX)
       );

   --------------------------------------------------------
   Cursor c_DRHits(xSID VARCHAR2) Is
    Select *
     From
      ( Select sc.Structure_ID, ass.Summary_Type, nHit
         From sumStruct_DoseResponse sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
        Where sc.Structure_ID = xSID  )
    Pivot
     ( Sum(nHit)
         For Summary_Type
             IN ('GP' GP,'GP_SER' GP_SER,
                 'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                 'FG' FG,'FG_SER' FG_SER,
                 'TX' TX)
        );

   --------------------------------------------------------
   Cursor c_DRScores(xSID VARCHAR2) Is
    Select *
     From
      ( Select sc.Structure_ID, ass.Summary_Type, pScore
         From sumStruct_DoseResponse sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
        Where sc.Structure_ID = xSID  )
    Pivot
     ( Max(pScore)
         For Summary_Type
             IN ('GP' GP,'GP_SER' GP_SER,
                 'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                 'FG' FG,'FG_SER' FG_SER,
                 'TX' TX)
        );

    --
    Cursor c_COADDHits(xSID VARCHAR2) Is
     Select *
     From
      ( Select Structure_ID, AssayType_ID, nHit
          From sumStruct_DoseResponse
        Where Structure_ID = xSID )
     Pivot
      ( Sum(nHit)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
               'FG_001' Ca, 'FG_002' Cn,
               'MA_007' Hk, 'HA_150' Hm));

    --------------------------------------------------------
    Cursor c_RunID (xSID VARCHAR2) Is
      Select Structure_ID,
                  ListAgg(Run_ID,'; ')
                    Within Group (Order by Structure_ID) as RunID_lst
            From
              (
               Select Distinct Structure_ID, Run_ID
                 From vDoseResponse
                Where Structure_ID = xSID
              )
            Group by Structure_ID;

    --------------------------------------------------------
    -- Variables
    --------------------------------------------------------
    r_DRAssays c_DRAssays%ROWTYPE;
    r_HVAssays c_HVAssays%ROWTYPE;
    r_DRHits c_DRHits%ROWTYPE;
    r_DRActs c_DRActs%ROWTYPE;
    r_DRScores c_DRScores%ROWTYPE;
    r_COADDHits c_COADDHits%ROWTYPE;
    r_RunID c_RunID%ROWTYPE;

    nRec         Number;
    nAssay_HC    Number;
    nAct_Tot     Number;
    nHit_Tot     Number;
    HC_Score     Number;
    HC_Rank      Number;
    Hit_Lst      sum_Structure.HC_Active_Org%Type;

 Begin
  -- Assays ------------------------------------------------------------------
  Open c_DRAssays(lSID);
   Loop
    Fetch c_DRAssays into r_DRAssays;
     Exit When c_DRAssays%notfound;

     -- Add missing Structure_ID to Sum_Structure ------------------------------
     Select count(Distinct Structure_ID) into nRec
       From Sum_Structure
      Where Structure_ID = lSID;
      If (nRec = 0) Then
       Insert into Sum_Structure (Structure_ID, Status) Values (lSID,0);
      End If;

   End Loop;
  Close c_DRAssays;

  Open c_HVAssays(lSID);
   Loop
    Fetch c_HVAssays into r_HVAssays;
     Exit When c_HVAssays%notfound;
   End Loop;
  Close c_HVAssays;

  nAssay_HC := r_DRAssays.GP + r_DRAssays.GP_SER;
  nAssay_HC := nAssay_HC + r_DRAssays.GN + r_DRAssays.GN_SER + r_DRAssays.GN_MEM;
  nAssay_HC := nAssay_HC + r_DRAssays.FG + r_DRAssays.FG_SER;

  -- Actives and Hits --------------------------------------------------------
  Open c_DRActs(lSID);
   Loop
    Fetch c_DRActs into r_DRActs;
     Exit When c_DRActs%notfound;
   End Loop;
  Close c_DRActs;

  Open c_DRHits(lSID);
  Loop
   Fetch c_DRHits into r_DRHits;
    Exit When c_DRHits%notfound;
  End Loop;
  Close c_DRHits;

  Open c_DRScores(lSID);
  Loop
   Fetch c_DRScores into r_DRScores;
    Exit When c_DRScores%notfound;
  End Loop;
  Close c_DRScores;

  -- CO-ADD Hits -------------------------------------------------------------
  Open c_COADDHits(lSID);
  Loop
   Fetch c_COADDHits into r_COADDHits;
    Exit When c_COADDHits%notfound;
  End Loop;
  Close c_COADDHits;

  Hit_Lst := coalesce(to_Char(r_COADDHits.Sa),'-') || ';' ;
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Ec),'-') || ';';
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Kp),'-') || ';';
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Pa),'-') || ';';
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Ab),'-') || ';';
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Ca),'-') || ';';
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Cn),'-') || ';';
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Hk),'-') || ';';
  Hit_Lst := Hit_Lst || coalesce(to_Char(r_COADDHits.Hm),'-') || ';';

  -- Total Actives/Hit -------------------------------------------------------
  nAct_Tot := NULL;
  nHit_Tot := NULL;
  If (nAssay_HC > 0) Then
     nAct_Tot := 0;
     If (r_DRActs.GP > 0) Then
         nAct_Tot := nAct_Tot + 1;
     End If;
     If (r_DRActs.GN > 0) Then
         nAct_Tot := nAct_Tot + 1;
     End If;
     If (r_DRActs.FG > 0) Then
         nAct_Tot := nAct_Tot + 1;
     End If;
     nHit_Tot := 0;
     If (r_DRHits.GP > 0) Then
         nHit_Tot := nHit_Tot + 1;
     End If;
     If (r_DRHits.GN > 0) Then
         nHit_Tot := nHit_Tot + 1;
     End If;
     If (r_DRHits.FG > 0) Then
         nHit_Tot := nHit_Tot + 1;
     End If;
  End If;

  -- Rank and pScore ----------------------------------------------------------
  HC_Rank := 0;
  HC_Score := 0;
  If ((r_DRHits.GN > 0) And (r_DRHits.GP = 0) And (r_DRHits.FG = 0)) Then
     HC_Rank  := 7;
     HC_Score := r_DRScores.GN;
  End If;
  If ((r_DRHits.GN > 0) And (r_DRHits.GP > 0) And (r_DRHits.FG = 0)) Then
     HC_Rank := 6;
     HC_Score := greatest(r_DRScores.GP,r_DRScores.GN);
  End If;
  If ((r_DRHits.GN > 0) And (r_DRHits.GP = 0) And (r_DRHits.FG > 0)) Then
     HC_Rank := 5;
     HC_Score := greatest(r_DRScores.GN,r_DRScores.FG);
  End If;
  If ((r_DRHits.GN = 0) And (r_DRHits.GP = 0) And (r_DRHits.FG > 0)) Then
     HC_Rank := 4;
     HC_Score := r_DRScores.FG;
  End If;
  If ((r_DRHits.GN = 0) And (r_DRHits.GP > 0) And (r_DRHits.FG = 0)) Then
     HC_Rank := 3;
     HC_Score := r_DRScores.GP;
  End If;
  If ((r_DRHits.GN = 0) And (r_DRHits.GP > 0) And (r_DRHits.FG > 0)) Then
     HC_Rank := 2;
     HC_Score := greatest(r_DRScores.GP,r_DRScores.FG);
  End If;
  If ((r_DRHits.GN > 0) And (r_DRHits.GP > 0) And (r_DRHits.FG > 0)) Then
     HC_Rank := 1;
     HC_Score := greatest(r_DRScores.GP,r_DRScores.GN,r_DRScores.FG);
  End If;

  If ((r_DRHits.TX = 0) And (r_DRScores.TX = 0) And (HC_Rank > 0 ))
         Then HC_Rank := HC_Rank + 0.50;
     ElsIf ((HC_Score - r_DRScores.TX) >= 1)
         Then HC_Rank := HC_Rank + 0.25;
  End If;

  If HC_Score >= 6.0 Then HC_Rank := HC_Rank + 0.15;
     ElsIf HC_Score >= 5.5 Then HC_Rank := HC_Rank + 0.10;
     ElsIf HC_Score >= 5.2 Then HC_Rank := HC_Rank + 0.05;
  End If;

  -- Screening Runs  ----------------------------------------------------------
  Open c_RunID(lSID);
   Loop
    Fetch c_RunID into r_RunID;
     Exit When c_RunID%notfound;
   End Loop;
  Close c_RunID;

  -- Update Sum_Structure  -----------------------------------------------------
  Update Sum_Structure
     Set HC_nAct = nAct_Tot,
         HC_nAct_GP = r_DRActs.GP,
         HC_nAct_GN = r_DRActs.GN,
         HC_nAct_GN_MEM = r_DRActs.GN_MEM,
         HC_nAct_FG = r_DRActs.FG,
         TX_nAct = r_DRActs.TX,
         HC_nAssays = nAssay_HC,
         TX_nAssays = r_DRAssays.TX,
         HC_nAssays_MEM = r_HVAssays.MembraneA,
         HC_nAssays_STD = r_HVAssays.StandardA,
         HC_nAssays_SER = r_HVAssays.SerumA,
         HC_nAssays_EXT = r_HVAssays.ExtendedA,
         HC_nHit = nHit_Tot,
         HC_nHit_GP = r_DRHits.GP,
         HC_nHit_GN = r_DRHits.GN,
         HC_nHit_FG = r_DRHits.FG,
         TX_nHit = r_DRHits.TX,
         HC_Rank = HC_Rank,
         HC_Active_Org = Hit_Lst,
         HC_pScore = HC_Score,
         TX_pScore = r_DRScores.TX,
         HC_RunID_Lst = r_RunID.RunID_lst,
         Status = 1
   Where Structure_ID = lSID ;
   Commit;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End sumDR_struct;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumStructure_SP
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
IS
  Cursor c_StructureSP Is
   Select Distinct Structure_ID
     From vInhibition
     Where Structure_ID is not NULL;
  sid Compound.Structure_ID%Type;
  nP Number;
Begin
  nP := 0;
  Open c_StructureSP;
  Loop
    Fetch c_StructureSP into sid;
    Exit When c_StructureSP%notfound;
    sumSP_struct(sid);
    nP := nP + 1;
  End Loop;
  Close c_StructureSP;

  castdb_util.AddLog('Update_sumStructure_SP','Update','Structures : ' || To_Char(nP),'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumStructure_SP;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE sumSP_struct (lSID Varchar2)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
 IS
  --------------------------------------------------------
  -- Cursors
  --------------------------------------------------------
   Cursor c_SPAssays(xSID VARCHAR2) Is
    Select *
     From
      ( Select sc.Structure_ID, ass.Summary_Type, nAct
          From sumCmpd_Inhibition sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
         Where sc.Structure_ID = xSID  )
     Pivot
      ( Count(nAct)
         For Summary_Type
           IN ('GP' GP,'GP_SER' GP_SER,
               'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
               'FG' FG,'FG_SER' FG_SER,
               'TX' TX)
      );
   --------------------------------------------------------
   Cursor c_SPActs(xSID VARCHAR2) Is
    Select *
     From
     ( Select sc.Structure_ID, ass.Summary_Type, nAct
         From sumCmpd_Inhibition sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
       Where Structure_ID = xSID )
    Pivot
     ( Sum(nAct)
         For Summary_Type
            IN ('GP' GP,'GP_SER' GP_SER,
                'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                'FG' FG,'FG_SER' FG_SER,
                'TX' TX)
       );

   --------------------------------------------------------
   Cursor c_SPSels(xSID VARCHAR2) Is
    Select *
     From
     ( Select sc.Structure_ID, ass.Summary_Type, nSelHC
         From sumCmpd_Inhibition sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
       Where Structure_ID = xSID )
    Pivot
     ( Sum(nSelHC)
         For Summary_Type
            IN ('GP' GP,'GP_SER' GP_SER,
                'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                'FG' FG,'FG_SER' FG_SER,
                'TX' TX)
       );

    --------------------------------------------------------
    Cursor c_COADDActs(xSID VARCHAR2) Is
     Select *
     From
      ( Select Structure_ID, AssayType_ID, nAct
          From sumCmpd_Inhibition
        Where Structure_ID = xSID )
     Pivot
      ( Sum(nAct)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
               'FG_001' Ca, 'FG_002' Cn,
               'MA_007' Hk, 'HA_150' Hm));
    --------------------------------------------------------
    Cursor c_RunID (xSID VARCHAR2) Is
      Select Structure_ID,
                  ListAgg(Run_ID,'; ')
                    Within Group (Order by Structure_ID) as RunID_lst
            From
              (
               Select Distinct Structure_ID, Run_ID
                 From vInhibition
                Where Structure_ID = xSID
              )
            Group by Structure_ID;

    --------------------------------------------------------
    -- Variables
    --------------------------------------------------------
    r_SPAssays c_SPAssays%ROWTYPE;
    r_SPActs c_SPActs%ROWTYPE;
    r_SPSels c_SPSels%ROWTYPE;
    r_COADDActs c_COADDActs%ROWTYPE;
    r_RunID c_RunID%ROWTYPE;

    nRec         Number;
    nAssay_SP    Number;
    nAct_Tot     Number;
    nSel_Tot     Number;
    Act_Rank     Number;
    Act_Lst      sum_Structure.PS_Active_Org%Type;

 Begin
  -- Assays ------------------------------------------------------------------
  Open c_SPAssays(lSID);
   Loop
    Fetch c_SPAssays into r_SPAssays;
     Exit When c_SPAssays%notfound;

     -- Add missing Structure_ID to Sum_Structure ------------------------------
     Select count(Distinct Structure_ID) into nRec
       From Sum_Structure
      Where Structure_ID = lSID;
      If (nRec = 0) Then
       Insert into Sum_Structure (Structure_ID, Status) Values (lSID,0);
      End If;

   End Loop;
  Close c_SPAssays;

  nAssay_SP := r_SPAssays.GP + r_SPAssays.GN + r_SPAssays.GN_MEM + r_SPAssays.FG;

  -- Actives -----------------------------------------------------------------
  Open c_SPActs(lSID);
   Loop
    Fetch c_SPActs into r_SPActs;
       Exit When c_SPActs%notfound;
   End Loop;
  Close c_SPActs;

  Open c_SPSels(lSID);
   Loop
    Fetch c_SPSels into r_SPSels;
       Exit When c_SPSels%notfound;
   End Loop;
  Close c_SPSels;

  -- Total Actives ------------------------------------------------------------
  nAct_Tot := NULL;
  nSel_Tot := NULL;
  If (nAssay_SP > 0) Then
     nAct_Tot := 0;
     If (r_SPActs.GP > 0) Then
         nAct_Tot := nAct_Tot + 1;
     End If;
     If (r_SPActs.GN > 0) Then
         nAct_Tot := nAct_Tot + 1;
     End If;
     If (r_SPActs.FG > 0) Then
         nAct_Tot := nAct_Tot + 1;
     End If;
     nSel_Tot := 0;
     If (r_SPSels.GP > 0) Then
         nSel_Tot := nSel_Tot + 1;
     End If;
     If (r_SPSels.GN > 0) Then
         nSel_Tot := nSel_Tot + 1;
     End If;
     If (r_SPSels.FG > 0) Then
         nSel_Tot := nSel_Tot + 1;
     End If;
  End If;

  -- Rank and pScore ----------------------------------------------------------
     Act_Rank := 0;
     If ((r_SPActs.GN > 0) And (r_SPActs.GP = 0) And (r_SPActs.FG = 0)) Then
        Act_Rank  := 7;
     End If;
     If ((r_SPActs.GN > 0) And (r_SPActs.GP > 0) And (r_SPActs.FG = 0)) Then
        Act_Rank := 6;
     End If;
     If ((r_SPActs.GN > 0) And (r_SPActs.GP = 0) And (r_SPActs.FG > 0)) Then
        Act_Rank := 5;
     End If;
     If ((r_SPActs.GN = 0) And (r_SPActs.GP = 0) And (r_SPActs.FG > 0)) Then
        Act_Rank := 4;
     End If;
     If ((r_SPActs.GN = 0) And (r_SPActs.GP > 0) And (r_SPActs.FG = 0)) Then
        Act_Rank := 3;
     End If;
     If ((r_SPActs.GN = 0) And (r_SPActs.GP > 0) And (r_SPActs.FG > 0)) Then
        Act_Rank := 2;
     End If;
     If ((r_SPActs.GN > 0) And (r_SPActs.GP > 0) And (r_SPActs.FG > 0)) Then
        Act_Rank := 1;
     End If;

  -- CO-ADD Hits -------------------------------------------------------------
  Open c_COADDActs(lSID);
  Loop
   Fetch c_COADDActs into r_COADDActs;
    Exit When c_COADDActs%notfound;
  End Loop;
  Close c_COADDActs;

  Act_Lst := coalesce(to_Char(r_COADDActs.Sa),'-') || ';' ;
  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Ec),'-') || ';';
  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Kp),'-') || ';';
  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Pa),'-') || ';';
  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Ab),'-') || ';';
  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Ca),'-') || ';';
  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Cn),'-') || ';';
--  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Hk),'-') || ';';
--  Act_Lst := Act_Lst || coalesce(to_Char(r_COADDActs.Hm),'-') || ';';

  -- Screening Runs  ----------------------------------------------------------
  Open c_RunID(lSID);
   Loop
    Fetch c_RunID into r_RunID;
     Exit When c_RunID%notfound;
   End Loop;
  Close c_RunID;

  -- Update Sum_Structure  -----------------------------------------------------
  Update Sum_Structure
    Set PS_nAssays = nAssay_SP,
        PS_nAssays_MEM = r_SPAssays.GN_MEM,
        PS_nAct    = nAct_Tot,
        PS_nSelHC = nSel_Tot,
        PS_nAct_GP = r_SPActs.GP,
        PS_nAct_GN = r_SPActs.GN,
        PS_nAct_GN_MEM = r_SPActs.GN_MEM,
        PS_nAct_FG = r_SPActs.FG,
        PS_Rank   = Act_Rank,
        PS_Active_Org = Act_Lst,
        PS_RunID_Lst = r_RunID.RunID_Lst,
        Status = 1
      Where Structure_ID = lSID ;
   Commit;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End sumSP_struct;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ===================================================================== --
END CastDB_Struct;
-- ===================================================================== --
