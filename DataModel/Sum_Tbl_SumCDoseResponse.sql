-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=SumCmpd_DoseResponse
DEFINE xTrigger=SumCDosRes

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Compound_ID            Varchar2(15),
  AssayType_ID				   Varchar2(25),
  RunID_Lst      		     Varchar2(512),
  RunID_Date             Date,
  DRVal_Type             Varchar2(15),
  DRVal_Lst					     Varchar2(250),
  DRVal_Unit    			   Varchar2(25),
  DMax_Lst					     Varchar2(250),
  Active_Lst					   Varchar2(120),
  Hit_Lst					       Varchar2(120),
  DRVal_median				   Varchar2(20),
  DRVal_high    			   Varchar2(20),
  DRVal_low     			   Varchar2(20),
  DMax_ave    				   Number(5,2),
  pScore					       Number(5,2),
  nHit						       Number(2,0),
  nAct						       Number(2,0),
  nAssays					       Number(3,0),
  Status                 Number(5,0),
  aCreatedBy		      	 Varchar2(20),
  aCreatedDate           Date,
  aModifiedBy		      	 Varchar2(20),
  aModifiedDate          Date,
  CONSTRAINT &xTrigger._PKEY PRIMARY KEY(Compound_ID,AssayType_ID)
 ) TABLESPACE &TBLSPACE_DAT;
;

-- Create Index PrimaryScreening_PI_IDX on PrimaryScreening(Project_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._HT_IDX on &xTable.(nHit) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._AT_IDX on &xTable.(nAct) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
