-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=vStock
DEFINE xTrigger=vStock
DEFINE xID=Compound_ID

Create or Replace View &xTable.
 As
 Select w.Compound_ID, w.Plate_ID, w.Well_ID, w.Barcode,
        w.Amount,w.Amount_Unit, w.Volume,w.Volume_Unit,
        w.Conc,w.Conc_Unit, w.Solvent,w.Solvent_Conc,w.Solvent_Conc_Unit,
        mp.Labware_ID, mp.Plate_Type, mp.Well_Type,
        mp.Plate_Size, mp.Plating, mp.Storage_Location
 From
 (  Select mw.Compound_ID, mw.Plate_ID, mw.Well_ID, NULL Barcode,
         mw.Amount,mw.Amount_Unit,
           mw.Volume,mw.Volume_Unit,
           mw.Conc,mw.Conc_Unit,
           mw.Solvent,mw.Solvent_Conc,mw.Solvent_Conc_Unit
     From MasterWell mw
   Union
    Select mw.Compound_ID, mw.Plate_ID, mw.Well_ID, mw.Barcode,
           mw.Amount,mw.Amount_Unit,
           mw.Volume,mw.Volume_Unit,
           mw.Conc,mw.Conc_Unit,
           mw.Solvent,mw.Solvent_Conc,mw.Solvent_Conc_Unit
      From MasterTube mw) w
   Left Join MasterPlate mp on mp.Plate_ID = w.Plate_ID
 Where mp.Plate_Type = 'Stock' OR mp.Plate_Type = 'Master'
 Order By Compound_ID;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
