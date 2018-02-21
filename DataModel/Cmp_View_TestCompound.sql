-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=vTestCompound
DEFINE xTrigger=vTestCompound
DEFINE xID=Compound_ID

Create or Replace View &xTable.
 As
 Select tp.Plate_ID, tp.Run_ID, tw.Well_ID,
         c.Compound_ID, c.Structure_ID, c.Compound_Name, c.CpOz_Sn, c.CpOz_ID,
         c.Project_ID
  From testPlate tp
   Left Join Testwell tw on tw.Plate_ID = tp.Plate_ID
    Left Join Compound c on tw.Compound_ID = c.Compound_ID
  Where tw.isSample = 1
    And tw.Compound_ID is not NULL

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
