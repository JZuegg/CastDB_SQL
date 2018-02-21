@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=TestWell
DEFINE xTrigger=TestWell

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Plate_ID                Varchar2(25),
  Well_ID                 Varchar2(3),
  Compound_ID             Varchar2(25),
  Batch_ID                Varchar2(5),
  CpOz_SN                 Varchar2(25),
  Compound2_ID            Varchar2(25),
  Batch2_ID               Varchar2(5),
  CpOz2_SN                Varchar2(25),
  Volume                  Number,
  Volume_Unit             Varchar2(5),
  Conc                    Number,
  Conc_Unit               Varchar2(10),
  Conc2                   Number,
  Conc2_Unit              Varchar2(10),
  Solvent                 Varchar2(25),
  Solvent_Conc            Number,
  Solvent_Conc_Unit       Varchar2(10),
  Readout                 Number,
  ReadoutA                Number,
  ReadoutB                Number,
  isSkip                  Number(1),
  isSample                Number(1),
  isMixture               Number(1),
  isControl               Number(1),
  isPosControl            Number(1),
  isNegControl            Number(1),
  isValid                 Number(1),
  ZScore                  Number(7,2),
  MScore                  Number(7,2),
  BScore                  Number(7,2),
  Inhibition              Number(7,2),
  Active                  Varchar2(4),
  pScore                  Number(7,2),
  Status                  Number(5),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		      	  Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKey  PRIMARY KEY(Plate_ID,Well_ID)
 ) TABLESPACE &TBLSPACE_DAT;

 Create Index &xTrigger._CI_IDX on &xTable.(Compound_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._BI_IDX on &xTable.(Batch_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._CO_IDX on &xTable.(CpOz_SN) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._CI2_IDX on &xTable.(Compound2_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._BI2_IDX on &xTable.(Batch2_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._CO2_IDX on &xTable.(CpOz2_SN) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._IS_IDX on &xTable.(isSkip,isSample,isMixture,isControl,isPosControl,isNegControl,isValid) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;


 -- ====================================================================
 -- Standard Trigger and Grants
 -- ====================================================================
 @../Schema/stdTrigger.sql
 @../Schema/stdGrant.sql
