-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=vDoseResponse

-- Drop Table &xTable.;

Create or Replace View &xTable.
 As
Select dr.Compound_ID, c.Structure_ID, dr.AssayType_ID, dr.Run_ID, dr.Test_Date,
       'MIC' Result_Type,
	     dr.MIC DR, dr.MIC_Unit DR_Unit, dr.MIC_Value DR_Value, dr.MIC_Prefix DR_Prefix,
	     castdb_util.fmtDR_Sort(dr.MIC_Prefix,dr.MIC_Value) DR_Sort,
       castdb_util.fmtDRX_Sort(dr.MIC_Prefix,dr.MIC_Value) DRX_Sort,
       dr.Dmax, dr.Active, dr.Hit, dr.pScore
  From ActData_MIC dr
   Left Join Compound c on dr.Compound_ID = c.Compound_ID
 Where dr.Status > 0
Union
Select dr.Compound_ID, c.Structure_ID, dr.AssayType_ID, dr.Run_ID, dr.Test_Date,
       'CC50' Result_Type,
	     dr.CC50 DR, dr.CC50_Unit DR_Unit, dr.CC50_Value DR_Value, dr.CC50_Prefix DR_Prefix,
       castdb_util.fmtDR_Sort(dr.CC50_Prefix,dr.CC50_Value) DR_Sort,
       castdb_util.fmtDRX_Sort(dr.CC50_Prefix,dr.CC50_Value) DRX_Sort,
       dr.Dmax, dr.Active, dr.Hit, dr.pScore
  From ActData_Cytotox dr
   Left Join Compound c on dr.Compound_ID = c.Compound_ID
 Where dr.Status > 0
Union
Select dr.Compound_ID, c.Structure_ID, dr.AssayType_ID, dr.Run_ID, dr.Test_Date,
       'HC10' Result_Type,
	     dr.HC10 DR, dr.HC10_Unit DR_Unit, dr.HC10_Value DR_Value, dr.HC10_Prefix DR_Prefix,
       castdb_util.fmtDR_Sort(dr.HC10_Prefix,dr.HC10_Value) DR_Sort,
       castdb_util.fmtDRX_Sort(dr.HC10_Prefix,dr.HC10_Value) DRX_Sort,
       dr.Dmax, dr.Active, dr.Hit, dr.pScore
  From ActData_Haemolysis dr
   Left Join Compound c on dr.Compound_ID = c.Compound_ID
 Where dr.Status > 0
;
-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
