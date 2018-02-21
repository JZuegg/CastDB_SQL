-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=vCompound

-- Drop Table &xTable.;

Create or Replace View &xTable.
 As
  Select c.Compound_ID, c.Structure_ID, c.Compound_Name, c.CpOz_Sn, c.CpOz_ID,
         c.Project_ID, p.Project_Type, g.Group_Name,
--         cp.MW, cp.alogD_7, cp.logS,
--		     cn.Nov_Score, cn.ChemCluster_ID,
--		     cn.Nov_Bact, cn.Nov_BactAct, cn.Nov_Fung, cn.Nov_FungAct,
--		     cn.Nov_ChEMBL, cn.Nov_DrugBank,
--		     c.Stock_Conc, c.Stock_Conc_Unit, c.Stock_Solvent,
--		     c.Stock_Barcode, c.Stock_Plate_ID, c.Stock_Well_ID,
         sc.HC_Rank, sc.HC_nHit, sc.TX_nHit, sc.HC_Active_Org,
		     sc.TX_nAct, sc.HC_nAct_GN, sc.HC_nAct_GP, sc.HC_nAct_FG, sc.HC_nAssays, sc.HC_pScore,
         sc.PS_Rank, sc.PS_nAct, sc.PS_Active_Org,
		     sc.PS_nAct_GN, sc.PS_nAct_GP, sc.PS_nAct_FG, sc.PS_nAssays,
		     sc.PS_nAct_GN_MM, sc.PS_nAssays_MM
 From castdb.Compound c
  Left Join castdb.sum_Compound sc on c.Compound_ID = sc.Compound_ID
   Left Join castdb.MasterBarcode mb on c.Compound_ID = mb.Compound_ID
--   Left Join castdb.ChemProperty cp on c.Structure_ID = cp.Structure_ID
--    Left Join castdb.ChemNovelty cn on c.Structure_ID = cn.Structure_ID
  Left Join castdb.Project p on c.Project_ID = p.Project_ID
   Left Join castdb.Collaborator_Group g on p.Group_ID = g.Group_ID;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
