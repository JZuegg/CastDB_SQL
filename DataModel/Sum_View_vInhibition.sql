-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=vInhibition

-- Drop Table &xTable.;

Create or Replace View &xTable.
 As
 Select tw.Compound_ID, c.Structure_ID,
	      tp.AssayType_ID,
        ast.AssayType_Class, ast.AssayType_Code,
		    tp.Run_ID,
        tw.Plate_ID, tw.Well_ID, tp.Test_Date,
        tw.Conc, tw.Conc_Unit, tw.Inhibition, tw.MScore,
        tw.Active, tw.pScore
 From castdb.TestWell tw
  Left Join castdb.TestPlate tp on tw.Plate_ID = tp.Plate_ID
   Left Join castdb.AssayType ast on tp.AssayType_ID = ast.AssayType_ID
  Left Join castdb.Compound c on tw.Compound_ID = c.Compound_ID
  Where (tp.Status > 0  And tw.Status > 0)
    And (tw.isSample > 0 And tw.isControl = 0
	  And tw.isNegControl = 0 And tw.isPosControl = 0
		And (tw.isSkip is NULL OR tw.isSkip = 0))
	  And tw.Compound_ID <> 'DMSO'
    And tw.Compound_ID is not NULL
    And tp.Result_Type = 'Inhibition';

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
