-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_User
DEFINE xTrigger=AppUser

-- Drop Table &xTable.;

Create Table &xTable.
 (
  User_ID                   Varchar2(50),
  Title_Name                Varchar2(15),
  First_Name                Varchar2(50),
  Last_Name                 Varchar2(50),
  Organisation              Varchar2(250),
  Department                Varchar2(250),
  Phone                     Varchar2(20),
  EMail                     Varchar2(50),
  User_Permission           Varchar2(250),
  Session_ID                Varchar2(250),
  Status                  	Number(5,0),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(User_ID)
) TABLESPACE &TBLSPACE_SYS;
;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
