create or replace Package Body CastDB_Cmpd
-------------------------------------------------------------
AS

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Rename_CompoundID
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
    (oldCompoundID Varchar2, newCompoundID Varchar2)
  Is
  Begin

  Update ActData_MIC
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update ActData_Cytotox
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update ActData_Haemolysis
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update ActData_CMC
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update QCData
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update MasterWell
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update TestWell
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update TestWell
    Set Compound2_ID = newCompoundID Where  Compound2_ID = oldCompoundID;

  Update SumCmpd_Inhibition
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Update SumCmpd_DoseResponse
    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;

--  Update ChEMBLActivity
--    Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;

  Update Compound
   Set Compound_ID = newCompoundID Where  Compound_ID = oldCompoundID;
  Commit;
  castdb_util.AddLog('Rename_CompoundID','Rename','Compounds : ' || oldCompoundID || ' to ' || newCompoundID,'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Rename_CompoundID;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumCompound
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
   nP Number;
  Begin
   Update_sumCompound_SP();
   Update_sumCompound_DR();

   Update sum_Compound
     Set PS_Status = 'Completed'
   Where NVL(PS_nAssays,0) = 7;

  Update sum_Compound
     Set PS_Status = 'missingPS'
   Where NVL(PS_nAssays,0) < 7;

  Update sum_Compound
     Set Screen_Status = 'NotActive'
   Where PS_nAct = 0
     And NVL(HC_nHit,0) = 0 ;

  Update sum_Compound
     Set Screen_Status = 'Active',
         HC_Status  = 'toHC'
   Where NVL(PS_nAct,0) > 0 and HC_nAssays is Null;

  Update sum_Compound
     Set HC_Status = 'Completed'
   Where (HC_nAssays - HV_nAssays) = 7;

  Update sum_Compound
     Set HC_Status = 'missingHC'
   Where (HC_nAssays - HV_nAssays) < 7;

  Update sum_Compound
     Set TX_Status = 'Completed'
   Where TX_nAssays = 2;

  Update sum_Compound
     Set TX_Status = 'missingTox'
   Where TX_nAssays < 2;

  Update sum_Compound
     Set Screen_Status = 'Hit'
   Where HC_nHit > 0 and TX_nHit = 0;

  Update sum_Compound
     Set Screen_Status = 'Hit (missingTox)'
   Where HC_nHit > 0 and NVL(TX_nAssays,0) = 0;

  Update sum_Compound
     Set Screen_Status = 'HitTox'
   Where HC_nHit > 0 and TX_nHit > 0;

  Update sum_Compound
     Set Screen_Status = 'NotHit'
   Where HC_nHit = 0;

   Commit;

  Select count(*) into nP From sum_Compound;
  castdb_util.AddLog('Update_sumCompound','Update','Compounds : ' || To_Char(nP),'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumCompound;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumCompound_DR
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
IS
  Cursor c_CompoundDR Is
   Select Distinct Compound_ID
     From sumCmpd_DoseResponse;
  cid Compound.Compound_ID%Type;
  nP Number;
Begin
  nP := 0;
  Open c_CompoundDR;
  Loop
    Fetch c_CompoundDR into cid;
    Exit When c_CompoundDR%notfound;
    sumDR_cmpd(cid);
    nP := nP + 1;
  End Loop;
  Close c_CompoundDR;

 castdb_util.AddLog('Update_sumCompound_DR','Update','Compounds : ' || To_Char(nP),'Done');
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumCompound_DR;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE sumDR_cmpd (lCID Varchar2)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
 IS
  --------------------------------------------------------
  -- Cursors
  --------------------------------------------------------
  Cursor c_DRAssays(xCID VARCHAR2) Is
   Select *
   From
   ( Select sc.Compound_ID, ass.Summary_Type, nAct
       From sumCmpd_DoseResponse sc
        Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
      Where sc.Compound_ID = xCID  )
  Pivot
   ( Count(nAct)
       For Summary_Type
           IN ('GP' GP,'GP_SER' GP_SER,
               'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
               'FG' FG,'FG_SER' FG_SER,
               'TX' TX)
      );

  --------------------------------------------------------
  Cursor c_HVAssays(xCID VARCHAR2) Is
   Select *
   From
   ( Select sc.Compound_ID, ass.AssayType_Class, nAct
       From sumCmpd_DoseResponse sc
        Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
      Where sc.Compound_ID = xCID  )
  Pivot
   ( Count(nAct)
       For AssayType_Class
           IN ('Standard' StandardA,'Serum_Reversal' SerumA,
               'Extended' ExtendedA,'Mutant_Membrane' MembraneA)
      );

  --------------------------------------------------------
  Cursor c_DRActs(xCID VARCHAR2) Is
   Select *
    From
    ( Select sc.Compound_ID, ass.Summary_Type, nAct
        From sumCmpd_DoseResponse sc
         Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
       Where sc.Compound_ID = xCID  )
   Pivot
    ( Sum(nAct)
        For Summary_Type
            IN ('GP' GP,'GP_SER' GP_SER,
                'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                'FG' FG,'FG_SER' FG_SER,
                'TX' TX)
       );

   --------------------------------------------------------
   Cursor c_DRHits(xCID VARCHAR2) Is
    Select *
     From
      ( Select sc.Compound_ID, ass.Summary_Type, nHit
         From sumCmpd_DoseResponse sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
        Where sc.Compound_ID = xCID  )
    Pivot
     ( Sum(nHit)
         For Summary_Type
             IN ('GP' GP,'GP_SER' GP_SER,
                 'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                 'FG' FG,'FG_SER' FG_SER,
                 'TX' TX)
        );

   --------------------------------------------------------
   Cursor c_DRScores(xCID VARCHAR2) Is
    Select *
     From
      ( Select sc.Compound_ID, ass.Summary_Type, pScore
         From sumCmpd_DoseResponse sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
        Where sc.Compound_ID = xCID  )
    Pivot
     ( Max(pScore)
         For Summary_Type
             IN ('GP' GP,'GP_SER' GP_SER,
                 'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                 'FG' FG,'FG_SER' FG_SER,
                 'TX' TX)
        );

    --
    Cursor c_COADDHits(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nHit
          From sumCmpd_DoseResponse
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nHit)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
               'FG_001' Ca, 'FG_002' Cn,
               'MA_007' Hk, 'HA_150' Hm));

    --------------------------------------------------------
    Cursor c_RunID (xCID VARCHAR2) Is
      Select Compound_ID,
                  ListAgg(Run_ID,'; ')
                    Within Group (Order by Compound_ID) as RunID_lst
            From
              (
               Select Distinct Compound_ID, Run_ID
                 From vDoseResponse
                Where Compound_ID = xCID
              )
            Group by Compound_ID;

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
    nAssay_HV    Number;
    nAct_Tot     Number;
    nHit_Tot     Number;
    HC_Score     Number;
    HC_Rank      Number;
    Hit_Lst      sum_Compound.HC_Active_Org%Type;

 Begin
  -- Assays ------------------------------------------------------------------
  Open c_DRAssays(lCID);
   Loop
    Fetch c_DRAssays into r_DRAssays;
     Exit When c_DRAssays%notfound;

     -- Add missing Compound_ID to Sum_Compound ------------------------------
     Select count(Distinct Compound_ID) into nRec
       From Sum_Compound
      Where Compound_ID = lCID;
      If (nRec = 0) Then
       Insert into Sum_Compound (Compound_ID, Status) Values (lCID,0);
      End If;

   End Loop;
  Close c_DRAssays;

  Open c_HVAssays(lCID);
   Loop
    Fetch c_HVAssays into r_HVAssays;
     Exit When c_HVAssays%notfound;
   End Loop;
  Close c_HVAssays;

  nAssay_HC := r_DRAssays.GP + r_DRAssays.GP_SER;
  nAssay_HC := nAssay_HC + r_DRAssays.GN + r_DRAssays.GN_SER + r_DRAssays.GN_MEM;
  nAssay_HC := nAssay_HC + r_DRAssays.FG + r_DRAssays.FG_SER;

  nAssay_HV := r_HVAssays.SerumA + r_HVAssays.ExtendedA + r_HVAssays.MembraneA;

  -- Actives and Hits --------------------------------------------------------
  Open c_DRActs(lCID);
   Loop
    Fetch c_DRActs into r_DRActs;
     Exit When c_DRActs%notfound;
   End Loop;
  Close c_DRActs;

  Open c_DRHits(lCID);
  Loop
   Fetch c_DRHits into r_DRHits;
    Exit When c_DRHits%notfound;
  End Loop;
  Close c_DRHits;

  Open c_DRScores(lCID);
  Loop
   Fetch c_DRScores into r_DRScores;
    Exit When c_DRScores%notfound;
  End Loop;
  Close c_DRScores;

  -- CO-ADD Hits -------------------------------------------------------------
  Open c_COADDHits(lCID);
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
  Open c_RunID(lCID);
   Loop
    Fetch c_RunID into r_RunID;
     Exit When c_RunID%notfound;
   End Loop;
  Close c_RunID;

  -- Update Sum_Compound  -----------------------------------------------------
  Update Sum_Compound
     Set HC_nAct = nAct_Tot,
         HC_nAct_GP = r_DRActs.GP,
         HC_nAct_GN = r_DRActs.GN,
         HC_nAct_GN_MM = r_DRActs.GN_MEM,
         HC_nAct_FG = r_DRActs.FG,
         TX_nAct = r_DRActs.TX,
         HC_nAssays = nAssay_HC,
         TX_nAssays = r_DRAssays.TX,
         HV_nAssays = nAssay_HV,
         HC_nAssays_MM = r_DRAssays.GN_MEM,
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
--         HV_nAct = nAct_HV,
--         HV_nAct_GP = r_HVActs.GP,
--         HV_nAct_GN = r_HVActs.GN,
--         HV_nAct_FG = r_HVActs.FG,
         Status = 1
   Where Compound_ID = lCID ;
   Commit;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End sumDR_cmpd;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumCompound_SP
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
IS
  Cursor c_CompoundSP Is
   Select Distinct Compound_ID
     From vInhibition;

  cid Compound.Compound_ID%Type;
  nP Number;
Begin
  nP := 0;
  Open c_CompoundSP;
  Loop
    Fetch c_CompoundSP into cid;
    Exit When c_CompoundSP%notfound;
    sumSP_cmpd(cid);
    nP := nP + 1;
  End Loop;
  Close c_CompoundSP;

  castdb_util.AddLog('Update_sumCompound_SP','Update','Compounds : ' || To_Char(nP),'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumCompound_SP;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE sumSP_cmpd (lCID Varchar2)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
 IS
  --------------------------------------------------------
  -- Cursors
  --------------------------------------------------------
   Cursor c_SPAssays(xCID VARCHAR2) Is
    Select *
     From
      ( Select sc.Compound_ID, ass.Summary_Type, nAct
          From sumCmpd_Inhibition sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
         Where sc.Compound_ID = xCID  )
     Pivot
      ( Count(nAct)
         For Summary_Type
           IN ('GP' GP,'GP_SER' GP_SER,
               'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
               'FG' FG,'FG_SER' FG_SER,
               'TX' TX)
      );
   --------------------------------------------------------
   Cursor c_SPActs(xCID VARCHAR2) Is
    Select *
     From
     ( Select sc.Compound_ID, ass.Summary_Type, nAct
         From sumCmpd_Inhibition sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
       Where Compound_ID = xCID )
    Pivot
     ( Sum(nAct)
         For Summary_Type
            IN ('GP' GP,'GP_SER' GP_SER,
                'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                'FG' FG,'FG_SER' FG_SER,
                'TX' TX)
       );

   --------------------------------------------------------
   Cursor c_SPSels(xCID VARCHAR2) Is
    Select *
     From
     ( Select sc.Compound_ID, ass.Summary_Type, nSelHC
         From sumCmpd_Inhibition sc
          Left Join AssayType ass on ass.AssayType_ID = sc.AssayType_ID
       Where Compound_ID = xCID )
    Pivot
     ( Sum(nSelHC)
         For Summary_Type
            IN ('GP' GP,'GP_SER' GP_SER,
                'GN' GN,'GN_SER' GN_SER,'GN_MEM' GN_MEM,
                'FG' FG,'FG_SER' FG_SER,
                'TX' TX)
       );

    --------------------------------------------------------
    Cursor c_COADDActs(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nAct
          From sumCmpd_Inhibition
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nAct)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
               'FG_001' Ca, 'FG_002' Cn,
               'MA_007' Hk, 'HA_150' Hm));
    --------------------------------------------------------
    Cursor c_RunID (xCID VARCHAR2) Is
      Select Compound_ID,
                  ListAgg(Run_ID,'; ')
                    Within Group (Order by Compound_ID) as RunID_lst
            From
              (
               Select Distinct Compound_ID, Run_ID
                 From vInhibition
                Where Compound_ID = xCID
              )
            Group by Compound_ID;

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
    Act_Lst      sum_Compound.PS_Active_Org%Type;

 Begin
  -- Assays ------------------------------------------------------------------
  Open c_SPAssays(lCID);
   Loop
    Fetch c_SPAssays into r_SPAssays;
     Exit When c_SPAssays%notfound;

     -- Add missing Compound_ID to Sum_Compound ------------------------------
     Select count(Distinct Compound_ID) into nRec
       From Sum_Compound
      Where Compound_ID = lCID;
      If (nRec = 0) Then
       Insert into Sum_Compound (Compound_ID, Status) Values (lCID,0);
      End If;

   End Loop;
  Close c_SPAssays;

  nAssay_SP := r_SPAssays.GP + r_SPAssays.GN + r_SPAssays.GN_MEM + r_SPAssays.FG;

  -- Actives -----------------------------------------------------------------
  Open c_SPActs(lCID);
   Loop
    Fetch c_SPActs into r_SPActs;
       Exit When c_SPActs%notfound;
   End Loop;
  Close c_SPActs;

  Open c_SPSels(lCID);
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
  Open c_COADDActs(lCID);
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
  Open c_RunID(lCID);
   Loop
    Fetch c_RunID into r_RunID;
     Exit When c_RunID%notfound;
   End Loop;
  Close c_RunID;

  -- Update Sum_Compound  -----------------------------------------------------
  Update Sum_Compound
    Set PS_nAssays = nAssay_SP,
        PS_nAssays_MM = r_SPAssays.GN_MEM,
        PS_nAct    = nAct_Tot,
        PS_nSelHC = nSel_Tot,
        PS_nAct_GP = r_SPActs.GP,
        PS_nAct_GN = r_SPActs.GN,
        PS_nAct_GN_MM = r_SPActs.GN_MEM,
        PS_nAct_FG = r_SPActs.FG,
        PS_Rank   = Act_Rank,
        PS_Active_Org = Act_Lst,
        PS_RunID_Lst = r_RunID.RunID_Lst,
        Status = 1
      Where Compound_ID = lCID ;
   Commit;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End sumSP_cmpd;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumCompound_HC
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
    Cursor c_CompoundDR Is
     Select Distinct Compound_ID
       From sumCmpd_DoseResponse;

    Cursor c_HCHits(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nHit
          From sumCmpd_DoseResponse
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nHit)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
		       'FG_001' Ca, 'FG_002' Cn,
               'MA_007' Hk, 'HA_150' Hm));

    Cursor c_HCActs(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nAct
          From sumCmpd_DoseResponse
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nAct)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
		       'FG_001' Ca, 'FG_002' Cn,
               'MA_007' Hk, 'HA_150' Hm));

    Cursor c_HCMuts(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nAct
          From sumCmpd_DoseResponse
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nAct)
         For AssayType_ID
          IN ( 'GN_211' PaMex5,
               'GN_046' EcLpxC, 'GN_049' EcTolC, 'GN_048' EcTolCLpxC ));

    Cursor c_HVActs(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, Substr(AssayType_ID,1,2) AssType, nAct
          From sumCmpd_DoseResponse
        Where Compound_ID = xCID
          And AssayType_ID not in ('GP_020',
                        'GN_001','GN_003','GN_042','GN_034',
                        'GN_211','GN_046','GN_049','GN_048',
		                'FG_001', 'FG_002','MA_007','HA_150')
      )
     Pivot
      ( Sum(nAct)
         For AssType
          IN ( 'GP' GP,
               'GN' GN,
		       'FG' FG));

    Cursor c_HVHits(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, Substr(AssayType_ID,1,2) AssType, nHit
          From sumCmpd_DoseResponse
        Where Compound_ID = xCID
          And AssayType_ID not in ('GP_020',
                        'GN_001','GN_003','GN_042','GN_034',
                        'GN_211','GN_046','GN_049','GN_048',
		                'FG_001', 'FG_002','MA_007','HA_150')
      )
     Pivot
      ( Sum(nHit)
         For AssType
          IN ( 'GP' GP,
               'GN' GN,
		       'FG' FG));

   Cursor c_HCScores(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, pScore
          From sumCmpd_DoseResponse
        Where Compound_ID = xCID )
     Pivot
      ( Max(pScore)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
		       'FG_001' Ca, 'FG_002' Cn,
               'MA_007' Hk, 'HA_150' Hm));

	Cursor c_RunID (xCID VARCHAR2) Is
     Select Compound_ID,
            ListAgg(Run_ID,'; ')
              Within Group (Order by Compound_ID) as RunID_lst
      From
        (
         Select Distinct Compound_ID, Run_ID
           From vDoseResponse
          Where Compound_ID = xCID
        )
      Group by Compound_ID;


   r_CmpdID  Compound.Compound_ID%Type;
   r_HCHits c_HCHits%ROWTYPE;
   r_HCActs c_HCActs%ROWTYPE;
   r_HCMuts c_HCMuts%ROWTYPE;
   r_HVHits c_HVHits%ROWTYPE;
   r_HVActs c_HVActs%ROWTYPE;
   r_HCScores c_HCScores%ROWTYPE;
   r_RunID c_RunID%ROWTYPE;
   nRec         Number;
   nAct_Tot     Number;
   nAct_GN      Number;
   nAct_GN_dMem Number;
   nAct_GP      Number;
   nAct_FG      Number;
   nAct_TX      Number;
   nHit_HV      Number;
   nAct_HV      Number;
   nHit_Tot     Number;
   nHit_GN      Number;
   nHit_GP      Number;
   nHit_FG      Number;
   nHit_TX      Number;
   Hit_Rank     Number;
   Hit_Score    Number;
   TX_Score     Number;
   nAssay_HC    Number;
   nAssay_TX    Number;
   nAssay_GN_dMem  Number;
   nAssay_HV    Number;
   Active_Lst   sum_Compound.HC_Active_Org%Type;
   nP Number;

  Begin
   nP := 0;
   Open c_CompoundDR;
   Loop
    Fetch c_CompoundDR into r_CmpdID;
     Exit When c_CompoundDR%notfound;

     -- ---------------- --
     -- sum_DoseResponse --
     -- ---------------- --
     Open c_HCHits(r_CmpdID);
     Loop
      Fetch c_HCHits into r_HCHits;
       Exit When c_HCHits%notfound;

       Select count(Distinct Compound_ID) into nRec
         From Sum_Compound
        Where Compound_ID = r_CmpdID;

        If (nRec = 0) Then
         Insert into Sum_Compound
           (Compound_ID, Status)
          Values
           (r_CmpdID,0);
        End If;

     End Loop;
     Close c_HCHits;

     Open c_HCActs(r_CmpdID);
     Loop
      Fetch c_HCActs into r_HCActs;
       Exit When c_HCActs%notfound;
     End Loop;
     Close c_HCActs;

     Open c_HCMuts(r_CmpdID);
     Loop
      Fetch c_HCMuts into r_HCMuts;
       Exit When c_HCMuts%notfound;
     End Loop;
     Close c_HCMuts;

     Open c_HVHits(r_CmpdID);
     Loop
      Fetch c_HVHits into r_HVHits;
       Exit When c_HVHits%notfound;
     End Loop;
     Close c_HVHits;

     Open c_HCScores(r_CmpdID);
     Loop
      Fetch c_HCScores into r_HCScores;
       Exit When c_HCScores%notfound;
     End Loop;
     Close c_HCScores;

	Open c_RunID(r_CmpdID);
     Loop
      Fetch c_RunID into r_RunID;
       Exit When c_RunID%notfound;
     End Loop;
     Close c_RunID;

    nAssay_HC := 0;
     Select sum(xAssays) into nAssay_HC
       From (Select Compound_ID,
                    Case When nAssays > 0 Then 1
                         Else 0
                    End xAssays
               From sumCmpd_DoseResponse
              Where Compound_ID = r_CmpdID
                    And AssayType_ID in ('GP_020',
                        'GN_001','GN_003','GN_042','GN_034',
		                'FG_001','FG_002'));

    nAssay_TX := 0;
     Select sum(xAssays) into nAssay_TX
       From (Select Compound_ID,
                    Case When nAssays > 0 Then 1
                         Else 0
                    End xAssays
               From sumCmpd_DoseResponse
              Where Compound_ID = r_CmpdID
                    And AssayType_ID in ('MA_007','HA_150'));

    nAssay_GN_dMem := 0;
     Select sum(xAssays) into nAssay_GN_dMem
       From (Select Compound_ID,
                    Case When nAssays > 0 Then 1
                         Else 0
                    End xAssays
               From sumCmpd_DoseResponse
              Where Compound_ID = r_CmpdID
                    And AssayType_ID in ('GN_211','GN_046','GN_049','GN_048'));

     nAssay_HV := 0;
     Select sum(xAssays) into nAssay_HV
       From (Select Compound_ID,
                    Case When nAssays > 0 Then 1
                         Else 0
                    End xAssays
               From sumCmpd_DoseResponse
              Where Compound_ID = r_CmpdID
                    And AssayType_ID not in ('GP_020',
                        'GN_001','GN_003','GN_042','GN_034',
		                'GN_211','GN_046','GN_049','GN_048',
                        'FG_001','FG_002','MA_007','HA_150'));


     Active_Lst := coalesce(to_Char(r_HCHits.Sa),'-') || ';' ;
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Ec),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Kp),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Pa),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Ab),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Ca),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Cn),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Hk),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_HCHits.Hm),'-') || ';';

-- Acts
     nAct_GP := r_HCActs.Sa;
     If ((r_HCActs.Ec is NULL) And (r_HCActs.Kp is NULL)
       And (r_HCActs.Pa is NULL) And (r_HCActs.Ab is NULL)) Then
        nAct_GN := NULL;
     Else
        nAct_GN := nvl(r_HCActs.Ec,0) + nvl(r_HCActs.Kp,0) + nvl(r_HCActs.Pa,0) + nvl(r_HCActs.Ab,0);
     End If;

     If ((r_HCActs.Ca is NULL) And (r_HCActs.Cn is NULL)) Then
        nAct_FG := NULL;
     Else
        nAct_FG := nvl(r_HCActs.Ca,0) + nvl(r_HCActs.Cn,0);
     End If;

     If ((r_HCActs.Hk is NULL) And (r_HCActs.Hm is NULL)) Then
        nAct_TX := NULL;
     Else
        nAct_TX := nvl(r_HCActs.Hk,0) + nvl(r_HCActs.Hm,0);
     End If;

     If ((r_HCMuts.PaMex5 is NULL) And (r_HCMuts.EcTolC is NULL)
       And (r_HCMuts.EcLpxC is NULL) And (r_HCMuts.EcTolCLpxC is NULL)) Then
        nAct_GN_dMem := NULL;
     Else
        nAct_GN_dMem := nvl(r_HCMuts.PaMex5,0) + nvl(r_HCMuts.EcTolC,0) + nvl(r_HCMuts.EcLpxC,0) + nvl(r_HCMuts.EcTolCLpxC,0);
     End If;

     nAct_Tot := NULL;
     If (nAssay_HC > 0) Then
        nAct_Tot := 0;
        If (nAct_GP > 0) Then
            nAct_Tot := nAct_Tot + 1;
        End If;
        If (nAct_GN > 0) Then
            nAct_Tot := nAct_Tot + 1;
        End If;
        If (nAct_FG > 0) Then
            nAct_Tot := nAct_Tot + 1;
        End If;
     End If;

     nAct_HV := NULL;
     If (nAssay_HV > 0) Then
        nAct_HV := 0;
        If (r_HVActs.GP > 0) Then
            nAct_HV := nAct_HV + 1;
        End If;
        If (r_HVActs.GN > 0) Then
            nAct_HV := nAct_HV + 1;
        End If;
        If (r_HVActs.FG > 0) Then
            nAct_HV := nAct_HV + 1;
        End If;
     End If;


-- Hits
     nHit_GP := r_HCHits.Sa;
     If ((r_HCHits.Ec is NULL) And (r_HCHits.Kp is NULL)
       And (r_HCHits.Pa is NULL) And (r_HCHits.Ab is NULL)) Then
        nHit_GN := NULL;
     Else
        nHit_GN := nvl(r_HCHits.Ec,0) + nvl(r_HCHits.Kp,0) + nvl(r_HCHits.Pa,0) + nvl(r_HCHits.Ab,0);
     End If;

     If ((r_HCHits.Ca is NULL) And (r_HCHits.Cn is NULL)) Then
        nHit_FG := NULL;
     Else
        nHit_FG := nvl(r_HCHits.Ca,0) + nvl(r_HCHits.Cn,0);
     End If;

     If ((r_HCHits.Hk is NULL) And (r_HCHits.Hm is NULL)) Then
        nHit_TX := NULL;
     Else
        nHit_TX := nvl(r_HCHits.Hk,0) + nvl(r_HCHits.Hm,0);
     End If;

     nHit_Tot := 0;
     If (nHit_GP > 0) Then
        nHit_Tot := nHit_Tot + 1;
     End If;
     If (nHit_GN > 0) Then
       nHit_Tot := nHit_Tot + 1;
     End If;
     If (nHit_FG > 0) Then
       nHit_Tot := nHit_Tot + 1;
     End If;

     nHit_HV := NULL;
     If (nAssay_HV > 0) Then
        nHit_HV := 0;
        If (r_HVHits.GP > 0) Then
            nHit_HV := nHit_HV + 1;
        End If;
        If (r_HVHits.GN > 0) Then
            nHit_HV := nHit_HV + 1;
        End If;
        If (r_HVHits.FG > 0) Then
            nHit_HV := nHit_HV + 1;
        End If;
     End If;


     TX_Score := 0;
     TX_Score := greatest(r_HCScores.Hk,r_HCScores.Hm);

     Hit_Rank := 0;
     Hit_Score := 0;
     If ((nHit_GN > 0) And (nHit_GP = 0) And (nHit_FG = 0)) Then
        Hit_Rank  := 7;
        Hit_Score := greatest(r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab);
     End If;
     If ((nHit_GN > 0) And (nHit_GP > 0) And (nHit_FG = 0)) Then
        Hit_Rank := 6;
        Hit_Score := greatest(r_HCScores.Sa,r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab);
     End If;
     If ((nHit_GN > 0) And (nHit_GP = 0) And (nHit_FG > 0)) Then
        Hit_Rank := 5;
        Hit_Score := greatest(r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab,r_HCScores.Ca,r_HCScores.Cn);
     End If;
     If ((nHit_GN = 0) And (nHit_GP = 0) And (nHit_FG > 0)) Then
        Hit_Rank := 4;
        Hit_Score := greatest(r_HCScores.Ca,r_HCScores.Cn);
     End If;
     If ((nHit_GN = 0) And (nHit_GP > 0) And (nHit_FG = 0)) Then
        Hit_Rank := 3;
        Hit_Score := greatest(r_HCScores.Sa);
     End If;
     If ((nHit_GN = 0) And (nHit_GP > 0) And (nHit_FG > 0)) Then
        Hit_Rank := 2;
        Hit_Score := greatest(r_HCScores.Sa,r_HCScores.Ca,r_HCScores.Cn);
     End If;
     If ((nHit_GN > 0) And (nHit_GP > 0) And (nHit_FG > 0)) Then
        Hit_Rank := 1;
        Hit_Score := greatest(r_HCScores.Sa,r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab,r_HCScores.Ca,r_HCScores.Cn);
     End If;

     If ((nHit_TX = 0) And (TX_Score = 0) And (Hit_Rank > 0 ))
            Then Hit_Rank := Hit_Rank + 0.50;
        ElsIf ((Hit_Score - TX_Score) >= 1)
            Then Hit_Rank := Hit_Rank + 0.25;
     End If;

     If Hit_Score >= 6.0 Then Hit_Rank := Hit_Rank + 0.15;
        ElsIf Hit_Score >= 5.5 Then Hit_Rank := Hit_Rank + 0.10;
        ElsIf Hit_Score >= 5.2 Then Hit_Rank := Hit_Rank + 0.05;
     End If;

     Update Sum_Compound
        Set HC_Rank = Hit_Rank,
            HC_Active_Org = Active_Lst,
            HC_nHit = nHit_Tot,
            HC_nHit_GP = nHit_GP,
            HC_nHit_GN = nHit_GN,
            HC_nHit_FG = nHit_FG,
            TX_nHit = nHit_TX,
            HC_nAct = nAct_Tot,
            HC_nAct_GP = nAct_GP,
            HC_nAct_GN = nAct_GN,
            HC_nAct_GN_MM = nAct_GN_dMem,
            HC_nAct_FG = nAct_FG,
            TX_nAct = nAct_TX,
            HC_nAssays = nAssay_HC,
            TX_nAssays = nAssay_TX,
            HC_nAssays_MM = nAssay_GN_dMem,
            HC_pScore = Hit_Score,
            TX_pScore = TX_Score,
            HC_RunID_Lst = r_RunID.RunID_lst,
            HV_nAct = nAct_HV,
            HV_nAssays = nAssay_HV,
            HV_nAct_GP = r_HVActs.GP,
            HV_nAct_GN = r_HVActs.GN,
            HV_nAct_FG = r_HVActs.FG
      Where Compound_ID = r_CmpdID ;

     Commit;
     nP := nP + 1;
   End Loop;
   Close c_CompoundDR;

  castdb_util.AddLog('Update_sumCompound_HC','Update','Compounds : ' || To_Char(nP),'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumCompound_HC;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_sumCompound_PS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
    Cursor c_CompoundSP Is
     Select Distinct Compound_ID
       From vInhibition;

    Cursor c_PSActs(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nAct
          From sumCmpd_Inhibition
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nAct)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
		       'FG_001' Ca, 'FG_002' Cn));

    Cursor c_PSMut(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nAct
          From sumCmpd_Inhibition
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nAct)
         For AssayType_ID
          IN ( 'GN_211' PaMex5,
               'GN_046' EcLpxC, 'GN_049' EcTolC, 'GN_048' EcTolCLpxC ));

    Cursor c_PSSels(xCID VARCHAR2) Is
     Select *
     From
      ( Select Compound_ID, AssayType_ID, nSelHC
          From sumCmpd_Inhibition
        Where Compound_ID = xCID )
     Pivot
      ( Sum(nSelHC)
         For AssayType_ID
          IN ( 'GP_020' Sa,
               'GN_001' Ec, 'GN_003' Kp, 'GN_042' Pa, 'GN_034' Ab,
		       'FG_001' Ca, 'FG_002' Cn));

    Cursor c_RunID (xCID VARCHAR2) Is
     Select Compound_ID,
            ListAgg(Run_ID,'; ')
              Within Group (Order by Compound_ID) as RunID_lst
      From
        (
         Select Distinct Compound_ID, Run_ID
           From vInhibition
          Where Compound_ID = xCID
        )
      Group by Compound_ID;

   r_CmpdID Compound.Compound_ID%Type;
   r_PSActs c_PSActs%ROWTYPE;
   r_PSSels c_PSSels%ROWTYPE;
   r_RunID c_RunID%ROWTYPE;
   r_PSMuts c_PSMut%ROWTYPE;
   nSel_Tot    Number;
   nHit_Tot    Number;
   nHit_GN    Number;
   nHit_GNM   Number;
   nHit_GP    Number;
   nHit_FG    Number;
   Hit_Rank  Number;
   Hit_Score Number;
   nAssay_HC   Number;
   nAssay_GN_dMem  Number;
   nRec   Number;
   Active_Lst   sum_Compound.PS_Active_Org%Type;
   nP Number;

  Begin
   nP := 0;
   Open c_CompoundSP;
   Loop
    Fetch c_CompoundSP into r_CmpdID;
     Exit When c_CompoundSP%notfound;
     -- ---------------- --
     -- sum_Inhibition --
     -- ---------------- --
     Open c_PSActs(r_CmpdID);
     Loop
      Fetch c_PSActs into r_PSActs;
       Exit When c_PSActs%notfound;

       Select count(Distinct Compound_ID) into nRec
         From Sum_Compound
        Where Compound_ID = r_CmpdID;

        If (nRec = 0) Then
         Insert into Sum_Compound
           (Compound_ID, Status)
          Values
           (r_CmpdID,0);
        End If;

     End Loop;
     Close c_PSActs;

	Open c_PSSels(r_CmpdID);
     Loop
      Fetch c_PSSels into r_PSSels;
       Exit When c_PSSels%notfound;
     End Loop;
     Close c_PSSels;

	Open c_PSMut(r_CmpdID);
     Loop
      Fetch c_PSMut into r_PSMuts;
       Exit When c_PSMut%notfound;
     End Loop;
     Close c_PSMut;

	Open c_RunID(r_CmpdID);
     Loop
      Fetch c_RunID into r_RunID;
       Exit When c_RunID%notfound;
     End Loop;
     Close c_RunID;

     nAssay_HC := 0;
     Select sum(xAssays) into nAssay_HC
       From (Select Compound_ID,
                    Case When nAssays > 0 Then 1
                         Else 0
                    End xAssays
               From sumCmpd_Inhibition
              Where Compound_ID = r_CmpdID
                    And AssayType_ID in ('GP_020',
                        'GN_001','GN_003','GN_042','GN_034',
		                'FG_001', 'FG_002'));

     nAssay_GN_dMem := 0;
     Select sum(xAssays) into nAssay_GN_dMem
       From (Select Compound_ID,
                    Case When nAssays > 0 Then 1
                         Else 0
                    End xAssays
               From sumCmpd_Inhibition
              Where Compound_ID = r_CmpdID
                    And AssayType_ID in ('GN_211','GN_046','GN_049','GN_048'));

     Active_Lst := coalesce(to_Char(r_PSActs.Sa),'-') || ';' ;
     Active_Lst := Active_Lst || coalesce(to_Char(r_PSActs.Ec),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_PSActs.Kp),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_PSActs.Pa),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_PSActs.Ab),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_PSActs.Ca),'-') || ';';
     Active_Lst := Active_Lst || coalesce(to_Char(r_PSActs.Cn),'-') || ';';

     nHit_GP := r_PSActs.Sa;
     If ((r_PSActs.Ec is NULL) And (r_PSActs.Kp is NULL)
       And (r_PSActs.Pa is NULL) And (r_PSActs.Ab is NULL)) Then
        nHit_GN := NULL;
     Else
        nHit_GN := nvl(r_PSActs.Ec,0) + nvl(r_PSActs.Kp,0) + nvl(r_PSActs.Pa,0) + nvl(r_PSActs.Ab,0);
     End If;

     If ((r_PSActs.Ca is NULL) And (r_PSActs.Cn is NULL)) Then
        nHit_FG := NULL;
     Else
        nHit_FG := nvl(r_PSActs.Ca,0) + nvl(r_PSActs.Cn,0);
     End If;


     If ((r_PSMuts.PaMex5 is NULL) And (r_PSMuts.EcTolC is NULL)
       And (r_PSMuts.EcLpxC is NULL) And (r_PSMuts.EcTolCLpxC is NULL)) Then
        nHit_GNM := NULL;
     Else
        nHit_GNM := nvl(r_PSMuts.PaMex5,0) + nvl(r_PSMuts.EcTolC,0) + nvl(r_PSMuts.EcLpxC,0) + nvl(r_PSMuts.EcTolCLpxC,0);
     End If;


     nHit_Tot := 0;
     If (nHit_GP > 0) Then
        nHit_Tot := nHit_Tot + 1;
     End If;
     If (nHit_GN > 0) Then
       nHit_Tot := nHit_Tot + 1;
     End If;
     If (nHit_FG > 0) Then
       nHit_Tot := nHit_Tot + 1;
     End If;

     nSel_Tot := nvl(r_PSSels.Sa,0);
     nSel_Tot := nSel_Tot + nvl(r_PSSels.Ec,0) + nvl(r_PSSels.Kp,0) + nvl(r_PSSels.Pa,0) + nvl(r_PSSels.Ab,0);
     nSel_Tot := nSel_Tot + nvl(r_PSSels.Ca,0) + nvl(r_PSSels.Cn,0);
     If (nSel_Tot > 0) Then
        nSel_Tot := 1;
     End If;

     Hit_Rank := 0;
     Hit_Score := 0;
     If ((nHit_GN > 0) And (nHit_GP = 0) And (nHit_FG = 0)) Then
        Hit_Rank  := 7;
--        Hit_Score := greatest(r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab);
     End If;
     If ((nHit_GN > 0) And (nHit_GP > 0) And (nHit_FG = 0)) Then
        Hit_Rank := 6;
--        Hit_Score := greatest(r_HCScores.Sa,r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab);
     End If;
     If ((nHit_GN > 0) And (nHit_GP = 0) And (nHit_FG > 0)) Then
        Hit_Rank := 5;
--        Hit_Score := greatest(r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab,r_HCScores.Ca,r_HCScores.Cn);
     End If;
     If ((nHit_GN = 0) And (nHit_GP = 0) And (nHit_FG > 0)) Then
        Hit_Rank := 4;
--        Hit_Score := greatest(r_HCScores.Ca,r_HCScores.Cn);
     End If;
     If ((nHit_GN = 0) And (nHit_GP > 0) And (nHit_FG = 0)) Then
        Hit_Rank := 3;
--        Hit_Score := greatest(r_HCScores.Sa);
     End If;
     If ((nHit_GN = 0) And (nHit_GP > 0) And (nHit_FG > 0)) Then
        Hit_Rank := 2;
--        Hit_Score := greatest(r_HCScores.Sa,r_HCScores.Ca,r_HCScores.Cn);
     End If;
     If ((nHit_GN > 0) And (nHit_GP > 0) And (nHit_FG > 0)) Then
        Hit_Rank := 1;
--        Hit_Score := greatest(r_HCScores.Sa,r_HCScores.Ec,r_HCScores.Kp,r_HCScores.Pa,r_HCScores.Ab,r_HCScores.Ca,r_HCScores.Cn);
     End If;

     Update Sum_Compound
        Set PS_Rank   = Hit_Rank,
            PS_Active_Org = Active_Lst,
            PS_nAct    = nHit_Tot,
            PS_nAct_GP = nHit_GP,
            PS_nAct_GN = nHit_GN,
            PS_nAct_GN_MM = nHit_GNM,
            PS_nAct_FG = nHit_FG,
--           HC_pScore = Hit_Score,
            PS_nSelHC = nSel_Tot,
            PS_nAssays = nAssay_HC,
            PS_nAssays_MM = nAssay_GN_dMem,
            PS_RunID_Lst = r_RunID.RunID_Lst
      Where Compound_ID = r_CmpdID ;

     Commit;
     nP := nP + 1;
     End Loop;
    Close c_CompoundSP;

  castdb_util.AddLog('Update_sumCompound_PS','Update','Compounds : ' || To_Char(nP),'Done');

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_sumCompound_PS;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ===================================================================== --
END CastDB_Cmpd;
-- ===================================================================== --
