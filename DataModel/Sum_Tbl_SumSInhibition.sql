-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=SumStruct_Inhibition
DEFINE xTrigger=SumSInhib
DEFINE xID=Structure_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Structure_ID        Varchar2(15),
  AssayType_ID				Varchar2(25),
  RunID_Lst      		  Varchar2(512),
  RunID_Date          Date,
  Inhib_Lst					  Varchar2(512),
  MScore_Lst				  Varchar2(512),
  Active_Lst					Varchar2(512),
  Conc_Lst					  Varchar2(50),
  pScore					    Number(9,2),
  nAct						    Number(3,0),
  nAssays					    Number(5,0),
  Inhib_Ave					  Number(9,2),
  Inhib_Std   				Number(9,2),
  Inhib_Max    			  Number(9,2),
  Inhib_Min     			Number(9,2),
  MScore_Ave  				Number(9,2),
  nSelHC						  Number(2,0),
  Status              Number(5,0),
  aCreatedBy		      Varchar2(20),
  aCreatedDate        Date,
  aModifiedBy		      Varchar2(20),
  aModifiedDate       Date,
  CONSTRAINT &xTrigger._PKEY PRIMARY KEY(Structure_ID,AssayType_ID)
 ) TABLESPACE &TBLSPACE_DAT;


-- Create Index PrimaryScreening_PI_IDX on PrimaryScreening(Project_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._HT_IDX on &xTable.(nAct) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
