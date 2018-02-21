-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_Message
DEFINE xTrigger=AppMsg
DEFINE xID=Msg_Code

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Msg_Code                  Varchar2(15),
  Msg_Type             	    Varchar2(15),
  Msg_Description           Varchar2(1024),
  Msg_Cause                 Varchar2(1024),
  Msg_Fix                   Varchar2(1024),
  Msg_Object                Varchar2(15),
  Msg_Status                Number(5,0),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
) TABLESPACE &TBLSPACE_SYS.;

Create Index &xTrigger._EC_IDX on &xTable.(Msg_Code) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._TY_IDX on &xTable.(Msg_Type) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
