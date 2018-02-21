 -- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=QCData
DEFINE xTrigger=QCData

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Compound_ID             Varchar2(25),
  TestPlate_ID            Varchar2(25),
  TestWell_ID             Varchar2(3),
  Vial_ID                 Number(3),
  AssayType_ID            Varchar2(25),
  Test_Date               Date,
  Run_ID                  Varchar2(25),
  Analysis                Varchar2(25),
  Hit                     Varchar2(4),
  Active                  Varchar2(4),
  QC                      Varchar2(20),
  QC_Issue                Varchar2(2),
  Purity                  Varchar2(25),
  Purity_By               Varchar2(25),
  Data_File               Varchar2(120),
  Status                  Number(5),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		      	  Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKEY PRIMARY KEY(TestPlate_ID,TestWell_ID,Analysis)
 ) TABLESPACE &TBLSPACE_DAT;
;

Create Index &xTrigger._CI_IDX on &xTable.(Compound_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._AT_IDX on &xTable.(AssayType_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._RI_IDX on &xTable.(Run_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._HA_IDX on &xTable.(Hit,Active) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
