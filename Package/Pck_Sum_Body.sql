create or replace Package Body CastDB_Sum
-------------------------------------------------------------
AS

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_sumInhibition_Cmpd
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
    Cursor c_Compound Is
     Select Distinct Compound_ID From vInhibition;
   cid Compound.Compound_ID%Type;
   nP Number;
  Begin
   nP := 0;
   Open c_Compound;
   Loop
    Fetch c_Compound into cid;
     Exit When c_Compound%notfound;
     sumInhibition_cmpd(cid);
     nP := nP + 1;
   End Loop;
   Close c_Compound;

  castdb_util.AddLog('Update_sumInhibition_Cmpd','Update','Compounds : ' || To_Char(nP),'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_sumInhibition_Cmpd;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_sumDoseResponse_Cmpd
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
    Cursor c_Compound Is
     Select Distinct Compound_ID From vDoseResponse;
    cid Compound.Compound_ID%Type;
   nP Number;
 Begin
  Open c_Compound;
   nP := 0;
   Loop
    Fetch c_Compound into cid;
     Exit When c_Compound%notfound;
     sumDoseResponse_Cmpd(cid);
    nP := nP + 1;
    End Loop;
   Close c_Compound;

  castdb_util.AddLog('Update_sumDoseResponse_Cmpd','Update','Compounds : ' || To_Char(nP),'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_sumDoseResponse_Cmpd;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_sumInhibition_Struct
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
    Cursor c_Structure Is
     Select Distinct Structure_ID From vInhibition
      Where Structure_ID is not NULL;
   sid Compound.Structure_ID%Type;
   nP Number;
  Begin
   nP := 0;
   Open c_Structure;
   Loop
    Fetch c_Structure into sid;
     Exit When c_Structure%notfound;
     sumInhibition_struct(sid);
     nP := nP + 1;
   End Loop;
   Close c_Structure;

  castdb_util.AddLog('Update_sumInhibition_Struct','Update','Structures : ' || To_Char(nP),'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_sumInhibition_Struct;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_sumDoseResponse_Struct
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
    Cursor c_Structure Is
     Select Distinct Structure_ID From vDoseResponse
      Where Structure_ID is not NULL;
    sid Compound.Structure_ID%Type;
   nP Number;
 Begin
  Open c_Structure;
   nP := 0;
   Loop
    Fetch c_Structure into sid;
     Exit When c_Structure%notfound;
     sumDoseResponse_Struct(sid);
    nP := nP + 1;
    End Loop;
   Close c_Structure;

  castdb_util.AddLog('Update_sumDoseResponse_Struct','Update','Structures : ' || To_Char(nP),'Done');

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_sumDoseResponse_Struct;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE sumInhibition_Cmpd (lCID Varchar2)
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
  -- Summary Inhition Cursor
    Cursor c_Inhibition (xCID VARCHAR2) Is
     Select Compound_ID, AssayType_ID, AssayType_Class, nAssays,
            Inhibition_ave, Inhibition_std,
            Inhibition_max, Inhibition_min,
            Inhibition_lst,
            MScore_lst, Active_lst, pScore,
            RunDate,
            Case When (Active_lst like '%A%') Then 1
                 Else 0
                 End nAct,
            Case When (Active_lst like '%A%' Or Active_lst like '%S%') Then 1
                 When (AssayType_ID like 'GN%' And Active_lst like '%P%') Then 1
                 Else 0
                 End nSel
       From
      ( Select Compound_ID, AssayType_ID, AssayType_Class, count(*) nAssays,
               Trunc(avg(Inhibition),2) Inhibition_ave,
               Trunc(stddev(Inhibition),2) Inhibition_std,
               Trunc(max(Inhibition),2) Inhibition_max,
               Trunc(min(Inhibition),2) Inhibition_min,
               median(pScore) pScore,
               ListAgg(To_Char(Inhibition, 'FM990D0'),'; ')
                 Within Group (Order by Compound_ID) as Inhibition_lst,
               ListAgg(To_Char(MScore, 'FM990D0'),'; ')
                Within Group (Order by Compound_ID) as MScore_lst,
               ListAgg(Active,'; ')
                 Within Group (Order by Compound_ID) as Active_lst,
               Max(Test_Date) RunDate
          From vInhibition
         Where Compound_ID = xCID
         Group by Compound_ID, AssayType_ID, AssayType_Class );

  -- Summary RunID Cursor
    Cursor c_RunID (xCID VARCHAR2) Is
     Select Compound_ID, AssayType_ID,
            ListAgg(Run_ID,'; ')
              Within Group (Order by Compound_ID) as RunID_lst,
            ListAgg(tConc,'; ')
              Within Group (Order by Compound_ID) as Conc_lst
      From
       ( Select Distinct Compound_ID, Run_ID, AssayType_ID,
                         Conc || ' ' || Conc_Unit tConc
           From vInhibition
          Where Compound_ID = xCID )
      Group by Compound_ID, AssayType_ID;

   r_inhib c_Inhibition%ROWTYPE;
   r_runid c_RunID%ROWTYPE;
   xLst SumCmpd_Inhibition.Inhib_Lst%Type;
   xRec  Number;

  Begin
   Delete From SumCmpd_Inhibition Where Compound_ID = lCID;

   Open c_Inhibition(lCID);
     Loop
      Fetch c_Inhibition into r_inhib;
       Exit When c_Inhibition%notfound;

       Select count(Distinct Compound_ID) into xRec
         From SumCmpd_Inhibition
        Where Compound_ID = lCID And AssayType_ID = r_inhib.Assaytype_ID;

        If (xRec = 0) Then
         Insert into SumCmpd_Inhibition
           (Compound_ID, AssayType_ID, Status)
          Values
           (lCID,r_inhib.Assaytype_ID,0);
        End If;

        If (r_inhib.Inhibition_Lst is NULL) Then
            xLst := NULL;
        Else
            xLst := r_inhib.Inhibition_Lst || '; PCT;';
        End If;

        Update SumCmpd_Inhibition
         Set nAssays    = r_inhib.nAssays,
             Inhib_Lst  = xLst,
             Inhib_Ave  = Trunc(r_inhib.Inhibition_Ave,2),
             Inhib_Std  = Trunc(r_inhib.Inhibition_Std,2),
             Inhib_Max  = Trunc(r_inhib.Inhibition_Max,2),
             Inhib_Min  = Trunc(r_inhib.Inhibition_Min,2),
             MScore_Lst = r_inhib.MScore_Lst,
             Active_Lst = r_inhib.Active_Lst,
             pScore     = Trunc(r_inhib.pScore,2),
             nAct       = r_inhib.nAct,
             nSelHC     = r_inhib.nSel,
             RunID_Date = r_inhib.RunDate
         Where Compound_ID  = lCID
           And AssayType_ID = r_inhib.Assaytype_ID;
     End Loop;
     Close c_Inhibition;

     Open c_RunID(lCID);
     Loop
      Fetch c_RunID into r_runid;
       Exit When c_RunID%notfound;

      Update SumCmpd_Inhibition
         Set RunID_Lst = r_runid.RunID_Lst,
             Conc_Lst  = r_runid.Conc_Lst
       Where Compound_ID  = lCID
         And AssayType_ID = r_runid.Assaytype_ID;
     End Loop;
     Close c_RunID;
     Commit;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End sumInhibition_Cmpd;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE sumDoseResponse_Cmpd (lCID Varchar2)
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
     Cursor c_DoseResponse (xCID VARCHAR2) Is
     Select Compound_ID, AssayType_ID, nAssays,
            DR_med, DR_low, DR_high,
            DR_lst,
            DMax_lst,
            Dmax_ave, Dmax_med, Dmax_std,
            Active_lst, Hit_lst, pScore,
            RunDate,
            Case When (Active_lst like '%A%') Then 1
                 Else 0
                 End Act,
-- CO-ADD Hit rule
            Case When (Hit_lst like '%A%') Then 1
                 When (AssayType_ID like 'GN%' And Hit_lst like '%P%') Then 1
                 When (AssayType_ID like 'MA%' And Hit_lst like '%P%') Then 1
                 When (AssayType_ID like 'HA%' And Hit_lst like '%P%') Then 1
                 Else 0
                 End Hit
       From
      (
        Select Compound_ID, AssayType_ID, count(*) nAssays,
               castdb_util.fmtSort_DRX(Percentile_Disc(0.5)
                       Within Group (Order by DRX_Sort)) as DR_med,
               castdb_util.fmtSort_DRX(Min(DRX_Sort)) DR_low,
               castdb_util.fmtSort_DRX(Max(DRX_Sort)) DR_high,
               Trunc(avg(DMax),2) DMax_ave,
               Trunc(median(DMax),2) DMax_med,
               Trunc(stddev(DMax),2) DMax_std,
               Trunc(median(pScore),2) pScore,
               ListAgg(DR,'; ')
                 Within Group (Order by Compound_ID) as DR_lst,
               ListAgg(To_Char(DMax, 'FM990D0'),'; ')
                 Within Group (Order by Compound_ID) as DMax_lst,
               ListAgg(Active,'; ')
                 Within Group (Order by Compound_ID) as Active_lst,
               ListAgg(Hit,'; ')
                 Within Group (Order by Compound_ID) as Hit_lst,
               Max(Test_Date) RunDate
          From vDoseResponse
         Where Compound_ID = xCID
         Group by Compound_ID, AssayType_ID
       );


   Cursor c_RunID (xCID VARCHAR2) Is
     Select Compound_ID, AssayType_ID, Result_Type,
            ListAgg(Run_ID,'; ')
              Within Group (Order by Compound_ID) as RunID_lst
      From
        (
         Select Distinct Compound_ID, AssayType_ID,
                         Run_ID, Result_Type
           From vDoseResponse
          Where Compound_ID = xCID
        )
      Group by Compound_ID, AssayType_ID, Result_Type ;

   Cursor c_Unit (xCID VARCHAR2) Is
     Select Compound_ID, AssayType_ID,
            ListAgg(DR_Unit,'; ')
              Within Group (Order by Compound_ID) as DRVal_Unit
      From
        (
         Select Distinct Compound_ID, AssayType_ID, DR_Unit
           From vDoseResponse
          Where Compound_ID = xCID
        )
      Group by Compound_ID, AssayType_ID, DR_Unit ;

   rec_d c_DoseResponse%ROWTYPE;
   rec_r c_RunID%ROWTYPE;
   rec_u c_Unit%ROWTYPE;
   nRec  Number;

  Begin
   Delete From SumCmpd_DoseResponse Where Compound_ID = lCID;
   Commit;

     Open c_DoseResponse(lCID);
     Loop
      Fetch c_DoseResponse into rec_d;
       Exit When c_DoseResponse%notfound;

       Select count(Distinct Compound_ID) into nRec
         From SumCmpd_DoseResponse
        Where Compound_ID = lCID And AssayType_ID = rec_d.Assaytype_ID;

        If (nRec = 0) Then
         Insert into SumCmpd_DoseResponse
           (Compound_ID, AssayType_ID, Status)
          Values
           (lCID,rec_d.Assaytype_ID,0);
        End If;

        Update SumCmpd_DoseResponse
         Set nAssays = rec_d.nAssays,
             DRVal_Median = rec_d.DR_med,
             DRVal_Low  = rec_d.DR_low,
             DRVal_High = rec_d.DR_high,
             DRVal_Lst = rec_d.DR_lst,
             DMax_Ave = rec_d.DMax_ave,
             DMax_Lst = rec_d.DMax_lst || '; PCT;',
             Active_Lst = rec_d.Active_lst,
             Hit_Lst = rec_d.Hit_lst,
             pScore = rec_d.pScore,
             nAct = rec_d.Act,
             nHit = rec_d.Hit,
             RunID_Date = rec_d.RunDate
         Where Compound_ID = lCID And AssayType_ID = rec_d.Assaytype_ID;

     End Loop;
     Close c_DoseResponse;

     Open c_RunID(lCID);
     Loop
      Fetch c_RunID into rec_r;
       Exit When c_RunID%notfound;

        Update SumCmpd_DoseResponse
         Set RunID_Lst = rec_r.RunID_Lst,
             DRVal_Type = rec_r.Result_Type
         Where Compound_ID = lCID And AssayType_ID = rec_r.Assaytype_ID;

     End Loop;
     Close c_RunID;

     Open c_Unit(lCID);
     Loop
      Fetch c_Unit into rec_u;
       Exit When c_Unit%notfound;

        Update SumCmpd_DoseResponse
         Set DRVal_Unit = rec_u.DRVal_Unit
         Where Compound_ID = lCID And AssayType_ID = rec_u.Assaytype_ID;

     End Loop;
     Close c_Unit;
     Commit;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End sumDoseResponse_Cmpd;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE sumInhibition_Struct (lSID Varchar2)
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
  -- Summary Inhition Cursor
    Cursor c_Inhibition (xSID VARCHAR2) Is
     Select Structure_ID, AssayType_ID, AssayType_Class, nAssays,
            Inhibition_ave, Inhibition_std,
            Inhibition_max, Inhibition_min,
            Inhibition_lst,
            MScore_lst, Active_lst, pScore,
            RunDate,
            Case When (Active_lst like '%A%') Then 1
                 Else 0
                 End nAct,
            Case When (Active_lst like '%A%' Or Active_lst like '%S%') Then 1
                 When (AssayType_ID like 'GN%' And Active_lst like '%P%') Then 1
                 Else 0
                 End nSel
       From
      ( Select Structure_ID, AssayType_ID, AssayType_Class, count(*) nAssays,
               Trunc(avg(Inhibition),2) Inhibition_ave,
               Trunc(stddev(Inhibition),2) Inhibition_std,
               Trunc(max(Inhibition),2) Inhibition_max,
               Trunc(min(Inhibition),2) Inhibition_min,
               median(pScore) pScore,
               ListAgg(To_Char(Inhibition, 'FM990D0'),'; ')
                 Within Group (Order by Structure_ID) as Inhibition_lst,
               ListAgg(To_Char(MScore, 'FM990D0'),'; ')
                Within Group (Order by Structure_ID) as MScore_lst,
               ListAgg(Active,'; ')
                 Within Group (Order by Structure_ID) as Active_lst,
               Max(Test_Date) RunDate
          From vInhibition
         Where Structure_ID = xSID
         Group by Structure_ID, AssayType_ID, AssayType_Class );

  -- Summary RunID Cursor
    Cursor c_RunID (xSID VARCHAR2) Is
     Select Structure_ID, AssayType_ID,
            ListAgg(Run_ID,'; ')
              Within Group (Order by Structure_ID) as RunID_lst,
            ListAgg(tConc,'; ')
              Within Group (Order by Structure_ID) as Conc_lst
      From
       ( Select Distinct Structure_ID, Run_ID, AssayType_ID,
                         Conc || ' ' || Conc_Unit tConc
           From vInhibition
          Where Structure_ID = xSID )
      Group by Structure_ID, AssayType_ID;

   r_inhib c_Inhibition%ROWTYPE;
   r_runid c_RunID%ROWTYPE;
   xLst SumStruct_Inhibition.Inhib_Lst%Type;
   xRec  Number;

  Begin
   Delete From SumStruct_Inhibition Where Structure_ID = lSID;

   Open c_Inhibition(lSID);
     Loop
      Fetch c_Inhibition into r_inhib;
       Exit When c_Inhibition%notfound;

       Select count(Distinct Structure_ID) into xRec
         From SumStruct_Inhibition
        Where Structure_ID = lSID And AssayType_ID = r_inhib.Assaytype_ID;

        If (xRec = 0) Then
         Insert into SumStruct_Inhibition
           (Structure_ID, AssayType_ID, Status)
          Values
           (lSID,r_inhib.Assaytype_ID,0);
        End If;

        If (r_inhib.Inhibition_Lst is NULL) Then
            xLst := NULL;
        Else
            xLst := r_inhib.Inhibition_Lst || '; PCT;';
        End If;

        Update SumStruct_Inhibition
         Set nAssays    = r_inhib.nAssays,
             Inhib_Lst  = xLst,
             Inhib_Ave  = Trunc(r_inhib.Inhibition_Ave,2),
             Inhib_Std  = Trunc(r_inhib.Inhibition_Std,2),
             Inhib_Max  = Trunc(r_inhib.Inhibition_Max,2),
             Inhib_Min  = Trunc(r_inhib.Inhibition_Min,2),
             MScore_Lst = r_inhib.MScore_Lst,
             Active_Lst = r_inhib.Active_Lst,
             pScore     = Trunc(r_inhib.pScore,2),
             nAct       = r_inhib.nAct,
             nSelHC     = r_inhib.nSel,
             RunID_Date = r_inhib.RunDate
         Where Structure_ID  = lSID
           And AssayType_ID = r_inhib.Assaytype_ID;
     End Loop;
     Close c_Inhibition;

     Open c_RunID(lSID);
     Loop
      Fetch c_RunID into r_runid;
       Exit When c_RunID%notfound;

      Update SumStruct_Inhibition
         Set RunID_Lst = r_runid.RunID_Lst,
             Conc_Lst  = r_runid.Conc_Lst
       Where Structure_ID  = lSID
         And AssayType_ID = r_runid.Assaytype_ID;
     End Loop;
     Close c_RunID;
     Commit;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End sumInhibition_Struct;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE sumDoseResponse_Struct (lSID Varchar2)
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
     Cursor c_DoseResponse (xSID VARCHAR2) Is
     Select Structure_ID, AssayType_ID, nAssays,
            DR_med, DR_low, DR_high,
            DR_lst,
            DMax_lst,
            Dmax_ave, Dmax_med, Dmax_std,
            Active_lst, Hit_lst, pScore,
            RunDate,
            Case When (Active_lst like '%A%') Then 1
                 Else 0
                 End Act,
-- CO-ADD Hit rule
            Case When (Hit_lst like '%A%') Then 1
                 When (AssayType_ID like 'GN%' And Hit_lst like '%P%') Then 1
                 When (AssayType_ID like 'MA%' And Hit_lst like '%P%') Then 1
                 When (AssayType_ID like 'HA%' And Hit_lst like '%P%') Then 1
                 Else 0
                 End Hit
       From
      (
        Select Structure_ID, AssayType_ID, count(*) nAssays,
               castdb_util.fmtSort_DRX(Percentile_Disc(0.5)
                       Within Group (Order by DRX_Sort)) as DR_med,
               castdb_util.fmtSort_DRX(Min(DRX_Sort)) DR_low,
               castdb_util.fmtSort_DRX(Max(DRX_Sort)) DR_high,
               Trunc(avg(DMax),2) DMax_ave,
               Trunc(median(DMax),2) DMax_med,
               Trunc(stddev(DMax),2) DMax_std,
               Trunc(median(pScore),2) pScore,
               ListAgg(DR,'; ')
                 Within Group (Order by Structure_ID) as DR_lst,
               ListAgg(To_Char(DMax, 'FM990D0'),'; ')
                 Within Group (Order by Structure_ID) as DMax_lst,
               ListAgg(Active,'; ')
                 Within Group (Order by Structure_ID) as Active_lst,
               ListAgg(Hit,'; ')
                 Within Group (Order by Structure_ID) as Hit_lst,
               Max(Test_Date) RunDate
          From vDoseResponse
         Where Structure_ID = xSID
         Group by Structure_ID, AssayType_ID
       );


   Cursor c_RunID (xSID VARCHAR2) Is
     Select Structure_ID, AssayType_ID, Result_Type,
            ListAgg(Run_ID,'; ')
              Within Group (Order by Structure_ID) as RunID_lst
      From
        (
         Select Distinct Structure_ID, AssayType_ID,
                         Run_ID, Result_Type
           From vDoseResponse
          Where Structure_ID = xSID
        )
      Group by Structure_ID, AssayType_ID, Result_Type ;

   Cursor c_Unit (xSID VARCHAR2) Is
     Select Structure_ID, AssayType_ID,
            ListAgg(DR_Unit,'; ')
              Within Group (Order by Structure_ID) as DRVal_Unit
      From
        (
         Select Distinct Structure_ID, AssayType_ID, DR_Unit
           From vDoseResponse
          Where Structure_ID = xSID
        )
      Group by Structure_ID, AssayType_ID, DR_Unit ;

   rec_d c_DoseResponse%ROWTYPE;
   rec_r c_RunID%ROWTYPE;
   rec_u c_Unit%ROWTYPE;
   nRec  Number;

  Begin
   Delete From SumStruct_DoseResponse Where Structure_ID = lSID;
   Commit;

     Open c_DoseResponse(lSID);
     Loop
      Fetch c_DoseResponse into rec_d;
       Exit When c_DoseResponse%notfound;

       Select count(Distinct Structure_ID) into nRec
         From SumStruct_DoseResponse
        Where Structure_ID = lSID And AssayType_ID = rec_d.Assaytype_ID;

        If (nRec = 0) Then
         Insert into SumStruct_DoseResponse
           (Structure_ID, AssayType_ID, Status)
          Values
           (lSID,rec_d.Assaytype_ID,0);
        End If;

        Update SumStruct_DoseResponse
         Set nAssays = rec_d.nAssays,
             DRVal_Median = rec_d.DR_med,
             DRVal_Low  = rec_d.DR_low,
             DRVal_High = rec_d.DR_high,
             DRVal_Lst = rec_d.DR_lst,
             DMax_Ave = rec_d.DMax_ave,
             DMax_Lst = rec_d.DMax_lst || '; PCT;',
             Active_Lst = rec_d.Active_lst,
             Hit_Lst = rec_d.Hit_lst,
             pScore = rec_d.pScore,
             nAct = rec_d.Act,
             nHit = rec_d.Hit,
             RunID_Date = rec_d.RunDate
         Where Structure_ID = lSID And AssayType_ID = rec_d.Assaytype_ID;

     End Loop;
     Close c_DoseResponse;

     Open c_RunID(lSID);
     Loop
      Fetch c_RunID into rec_r;
       Exit When c_RunID%notfound;

        Update SumStruct_DoseResponse
         Set RunID_Lst = rec_r.RunID_Lst,
             DRVal_Type = rec_r.Result_Type
         Where Structure_ID = lSID And AssayType_ID = rec_r.Assaytype_ID;

     End Loop;
     Close c_RunID;

     Open c_Unit(lSID);
     Loop
      Fetch c_Unit into rec_u;
       Exit When c_Unit%notfound;

        Update SumStruct_DoseResponse
         Set DRVal_Unit = rec_u.DRVal_Unit
         Where Structure_ID = lSID And AssayType_ID = rec_u.Assaytype_ID;

     End Loop;
     Close c_Unit;
     Commit;

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End sumDoseResponse_Struct;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ===================================================================== --
END CastDB_Sum;
-- ===================================================================== --
