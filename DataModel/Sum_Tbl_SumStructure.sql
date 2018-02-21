-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Sum_Structure
DEFINE xTrigger=SumStruct
DEFINE xID=Structure_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
   Structure_ID   Varchar2(15),
   Screen_Status	Varchar2(50),
   PS_RANK	      Number(5,2),
   PS_nSelHC	    Number(3,0),
   PS_nAct	      Number(3,0),
   PS_nAct_GN	    Number(3,0),
   PS_nAct_GN_MEM	Number(3,0),
   PS_nAct_GP	    Number(3,0),
   PS_nAct_FG	    Number(3,0),
   PS_nAssays	    Number(3,0),
   PS_nAssays_MEM	Number(3,0),
   PS_nAssays_STD	Number(3,0),
   PS_Active_Org	Varchar2(50),
   PS_RunID_Lst 	Varchar2(512),
   PS_pScore	    Number(9,2),
   PS_Status	    Varchar2(50),
   HC_Rank	      Number(5,2),
   HC_nAct	      Number(3,0),
   HC_nAct_GN	    Number(3,0),
   HC_nAct_GN_MEM	Number(3,0),
   HC_nAct_GP	    Number(3,0),
   HC_nAct_FG	    Number(3,0),
   HC_nHit	      Number(3,0),
   HC_nHit_GN	    Number(3,0),
   HC_nHit_GP	    Number(3,0),
   HC_nHit_FG	    Number(3,0),
   HC_nAssays	    Number(3,0),
   HC_nAssays_STD	Number(3,0),
   HC_nAssays_MEM	Number(3,0),
   HC_nAssays_SER	Number(3,0),
   HC_nAssays_EXT	Number(3,0),
   HC_Active_Org	Varchar2(50),
   HC_RunID_Lst	  Varchar2(512),
   HC_pScore	    Number(9,2),
   HC_Status	    Varchar2(50),
   HC_SelHV  	    Number(3,0),
   TX_nHit	      Number(3,0),
   TX_nAct	      Number(3,0),
   TX_nAssays	    Number(3,0),
   TX_pScore	    Number(5,2),
   TX_Status	    Varchar2(50),
   QC_Pass	      Number(3,0),
   QC_Status	    Varchar2(120),
   QC_nAssays	    Number(3,0),
   QC_LastDate	  Date,
   QC_RunID_Lst	  Varchar2(150),
   Status         Number(5,0),
   aCreatedBy		  Varchar2(20),
   aCreatedDate   Date,
   aModifiedBy		Varchar2(20),
   aModifiedDate  Date,
   CONSTRAINT &xTrigger._PKEY PRIMARY KEY(&xID.)
) TABLESPACE &TBLSPACE_DAT;


-- Create Index PrimaryScreening_PI_IDX on PrimaryScreening(Project_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PA_IDX on &xTable.(PS_nAct) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._HA_IDX on &xTable.(HC_nAct) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._HH_IDX on &xTable.(HC_nHit) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._TA_IDX on &xTable.(TX_nAct) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._TH_IDX on &xTable.(TX_nHit) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
