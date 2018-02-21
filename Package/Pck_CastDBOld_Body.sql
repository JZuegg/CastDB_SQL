create or replace Package Body CastDB_Old
-------------------------------------------------------------
AS

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
PROCEDURE Update_Compound_Castdb
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
IS
Cursor oldCompound is
    Select c.id, c.compound_name, c.description,
           c.project_id, c.cpoz_sn, c.cpoz_id,
           c.nom_fullmw, c.nom_mf,
           c.master_plate_id, c.master_well_id, c.master_barcode,
           c.master_solvent, c.master_conc, c.master_conc_unit,
           c.smiles,
           c.supplied_Amount, c.supplied_Amount_Unit,
           c.supplied_Conc, c.supplied_Conc_Unit,
     nc.Compound_ID
    From castdb_old.compound c
   Left Outer Join castdb.compound nc on (castdb_util.fmtCID(c.ID) = nc.Compound_ID);

  rec oldCompound%ROWTYPE;
  plid masterplate.Plate_ID%Type;
  cid  compound.compound_ID%Type;
Begin

Open oldCompound;
Loop
Fetch oldCompound into rec;
 Exit When oldCompound%notfound;

 CID := castdb_util.fmtCID(rec.ID);
 If rec.Compound_ID is NULL THEN
  Insert into castdb.Compound
 (Compound_ID,Status) Values (CID,0);
 End If;

-- Compound
 Update Compound
  Set Compound_Code = rec.compound_name,
    Compound_Description = rec.description,
      CPOZ_SN = rec.cpoz_sn,
  CPOZ_ID = rec.cpoz_id,
  Project_ID = castdb_util.fmtPID(rec.project_id),
  Reg_MW = Trunc(rec.nom_fullmw,2),
  Reg_MF = rec.nom_mf,
      Reg_Smiles = rec.smiles,
      Reg_Conc = rec.supplied_Conc,
      Reg_Conc_Unit = rec.supplied_Conc_Unit
Where Compound_ID = CID;

-- Amount
If rec.supplied_Amount_Unit = 'mg' Then
   Update Compound
   Set Reg_Amount = rec.supplied_Amount,
     Reg_Amount_Unit = rec.supplied_Amount_Unit
 Where Compound_ID = CID;
End If;

If (rec.supplied_Amount_Unit = 'uL' OR rec.supplied_Amount_Unit = 'mL')Then
   Update Compound
   Set Reg_Volume = rec.supplied_Amount,
     Reg_Volume_Unit = rec.supplied_Amount_Unit
 Where Compound_ID = CID;
End If;

-- Stock Plate
If (rec.master_plate_id is not NULL) Then
  Select Plate_ID into plid
   From MasterPlate
   Where Plate_ID = rec.master_plate_id;

  If (plid is null) Then
   Insert Into MasterPlate (Plate_ID,Plate_Type,Has_Compound,Status)
    Values (rec.master_plate_id,'Stock','1',0);
  End If;

  Select Plate_ID into plid
   From MasterWell
   Where Plate_ID = rec.master_plate_id AND Well_ID = rec.master_well_id;

  If (plid is null) Then
   Insert Into MasterWell (Plate_ID,Well_ID, Compound_ID,Barcode,
                           Conc,Conc_Unit,Solvent,Status)
    Values (rec.master_plate_id, rec.master_well_id,
            CID,rec.master_barcode,
            rec.master_conc, rec.master_conc_unit,
            rec.master_solvent,0);
  Else
   Update MasterWell Set
    Compound_ID = CID ,Barcode = rec.master_barcode,
    Conc = rec.master_conc, Conc_Unit = rec.master_conc_unit,
    Solvent = rec.master_solvent, Status = 1
    Where Plate_ID = rec.master_plate_id
      And Well_ID = rec.master_well_id;
  End If;

End If;


End Loop;
Close oldCompound;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
End Update_Compound_Castdb;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

 -- Grant all on castdb_old.project to castdb;
 -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_Project_Castdb
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  IS
	Cursor oldProject is
      Select op.id, op.project_name, op.project_type,
	         op.date_samples_received, op.project_status,
             op.cp_oz_id,
             op.organisation, op.department, op.country,
			 np.Project_ID
	    From castdb_old.Project op
		 Left Outer Join castdb.project np on (castdb_util.fmtPID(op.ID) = np.Project_ID);

    rec oldProject%ROWTYPE;

  Begin
  Open oldProject;
  Loop
  Fetch oldProject into rec;
   Exit When oldProject%notfound;

   If rec.Project_ID is NULL THEN
    Insert into castdb.Project
	 (Project_ID,Status) Values (castdb_util.fmtPID(rec.ID),0);
   End If;

   Update castdb.Project
    Set Project_Name = rec.project_name,
	    Project_Type = rec.project_type,
		Project_Status = rec.project_status,
		Received = rec.date_samples_received,
		Organisation = rec.organisation,
	    Country = rec.country,
		CPOZ_ID = rec.cp_oz_id
	Where Project_ID = castdb_util.fmtPID(rec.ID)	;

  End Loop;
  Close oldProject;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_Project_Castdb;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE Update_Run_CastDB
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   Is
   Begin

  Insert Into Run (Run_ID)
     ( Select Distinct dd.Raw_Data
         From castdb.primary_screening dd
           Left Join Run r on r.Run_ID = dd.Raw_Data
        Where r.Run_ID is NULL);

    Insert Into Run (Run_ID)
     ( Select Distinct dd.Raw_Data
         From castdb.MIC dd
           Left Join Run r on r.Run_ID = dd.Raw_Data
        Where r.Run_ID is NULL);

	Insert Into Run (Run_ID)
     ( Select Distinct dd.Raw_Data
         From castdb.Cytotox dd
           Left Join Run r on r.Run_ID = dd.Raw_Data
        Where r.Run_ID is NULL);

-- Update Numbers

	Update Run r
       Set CastDB_Inhibition =
       ( Select Sum(NVL2(dd.Result_Value1,1,0) + NVL2(dd.Result_Value2,1,0))
           From castdb.Primary_Screening dd
          Where dd.Raw_Data = r.Run_ID);

	Update Run r
       Set CastDB_Cytotox =
       ( Select Sum(NVL2(d.Active1,1,0) + NVL2(d.Active2,1,0))
           From castdb.Cytotox d
          Where d.Raw_Data = r.Run_ID);

	Update Run r
       Set CastDB_MIC =
       ( Select Sum(NVL2(d.Result_Value1,1,0) + NVL2(d.Result_Value2,1,0))
           From castdb.MIC d
          Where d.Raw_Data = r.Run_ID);
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  End Update_Run_CastDB;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --


-- ===================================================================== --
END CastDB_Old;
-- ===================================================================== --
