-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=MasterTube
DEFINE xTrigger=MasterTube
DEFINE xID=Barcode

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Barcode                 Varchar2(15),
  Compound_ID             Varchar2(25),
  Batch_ID                Varchar2(5),
  CpOz_SN                 Varchar2(25),
  Plate_ID                Varchar2(25),
  Well_ID                 Varchar2(3),
  Amount                  Number,
  Amount_Unit             Varchar2(5),
  Volume                  Number,
  Volume_Unit             Varchar2(5),
  Conc                    Number,
  Conc_Unit               Varchar2(10),
  Solvent                 Varchar2(40),
  Solvent_Conc            Number,
  Solvent_Conc_Unit       Varchar2(10),
  Test_Conc               Number,
  Test_Conc_Unit          Varchar2(10),
  Test_Solvent_Conc       Number,
  Prev_Plate_ID           Varchar2(25),
  Prev_Well_ID            Varchar2(3),
  Status                  Number(3),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		      	  Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;

 Create Index &xTrigger._CI_IDX on &xTable.(Compound_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._SN_IDX on &xTable.(CpOz_SN) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._PC_IDX on &xTable.(Plate_ID,Well_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._PPC_IDX on &xTable.(Prev_Plate_ID,Prev_Well_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;


 -- ====================================================================
 -- Standard Trigger and Grants
 -- ====================================================================
 @../Schema/stdTrigger.sql
 @../Schema/stdGrant.sql
