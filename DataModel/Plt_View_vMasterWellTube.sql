-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=vMasterWellTube

-- Drop Table &xTable.;

Create or Replace View &xTable.
 As
Select mw.Plate_ID, mw.Well_ID, mw.Compound_ID, mw.Batch_ID, mw.CpOz_SN,
       NULL BARCODE,
       mp.Plate_Type, mp.Well_Type, mp.Plating, mp.Labware_ID,
       mp.CpOz_ID, mp.Project_ID, mp.Run_ID,
       mw.Amount, mw.Amount_Unit, mw.Volume, mw.Volume_Unit,
       mw.Conc, mw.Conc_Unit, mw.Solvent, mw.Solvent_Conc, mw.Solvent_Conc_Unit,
       mw.Test_Conc, mw.Test_Conc_Unit, mw.Test_Solvent_Conc,
       mw.Status
  From MasterWell mw
   Left Join MasterPlate mp on mp.Plate_ID = mw.Plate_ID
Union
Select mw.Plate_ID, mw.Well_ID, mw.Compound_ID, mw.Batch_ID, mw.CpOz_SN,
       mw.Barcode,
       mp.Plate_Type, NVL(mp.Well_Type,'Tube') Well_Type, mp.Plating, mp.Labware_ID,
       mp.CpOz_ID, mp.Project_ID, mp.Run_ID,
       mw.Amount, mw.Amount_Unit, mw.Volume, mw.Volume_Unit,
       mw.Conc, mw.Conc_Unit, mw.Solvent, mw.Solvent_Conc, mw.Solvent_Conc_Unit,
       mw.Test_Conc, mw.Test_Conc_Unit, mw.Test_Solvent_Conc,
       mw.Status
  From MasterTube mw
   Left Join MasterPlate mp on mp.Plate_ID = mw.Plate_ID
;
-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
