 -- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=ActData_MIC
DEFINE xTrigger=ActMIC

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Compound_ID             Varchar2(25),
  TestPlate_ID            Varchar2(25),
  TestWell_ID             Varchar2(3),
  AssayType_ID            Varchar2(25),
  Test_Date               Date,
  Run_ID                  Varchar2(25),
  Analysis                Varchar2(10),
  Hit                     Varchar2(4),
  Active                  Varchar2(4),
  pScore                  Number(8,2),
  MIC                     Varchar2(20),
  MIC_Value               Number,
  MIC_Prefix              Varchar2(2),
  MIC_Unit                Varchar2(10),
  MIC2                    Varchar2(20),
  MIC2_Value              Number,
  MIC2_Prefix             Varchar2(2),
  fMIC                    Varchar2(20),
  fMIC_Value              Number,
  fMIC_Prefix             Varchar2(2),
  IC50                    Varchar2(20),
  IC50_Value              Number,
  IC50_Prefix             Varchar2(2),
  DMax                    Number(6,1),
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
