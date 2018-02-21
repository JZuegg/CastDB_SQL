-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=vCompound
DEFINE xTrigger=vCompound
DEFINE xID=Compound_ID

Create or Replace View &xTable.
 As
 Select c.Compound_ID, c.Structure_ID, c.Compound_Name, c.CpOz_Sn, c.CpOz_ID,
         c.Project_ID, p.Project_Type, g.Group_Name,
         sc.HC_Rank, sc.HC_nHit, sc.TX_nHit, sc.HC_Active_Org,
         sc.TX_nAct, sc.HC_nAct_GN, sc.HC_nAct_GP, sc.HC_nAct_FG, sc.HC_nAssays, sc.HC_pScore,
         sc.PS_Rank, sc.PS_nAct, sc.PS_Active_Org,
         sc.PS_nAct_GN, sc.PS_nAct_GP, sc.PS_nAct_FG, sc.PS_nAssays,
         sc.PS_nAct_GN_MEM, sc.PS_nAssays_MEM
 From castdb.Compound c
  Left Join castdb.sum_Compound sc on c.Compound_ID = sc.Compound_ID
--   Left Join castdb.ChemProperty cp on c.Structure_ID = cp.Structure_ID
--    Left Join castdb.ChemNovelty cn on c.Structure_ID = cn.Structure_ID
    Left Join castdb.Project p on c.Project_ID = p.Project_ID
     Left Join castdb.Collaborator_Group g on p.Group_ID = g.Group_ID
 Order By Compound_ID;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
