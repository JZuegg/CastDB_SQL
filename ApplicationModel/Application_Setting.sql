-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_Setting
DEFINE xTrigger=AppSetting
DEFINE xID=Name

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Name             	        Varchar2(50),
  Setting                   Varchar2(256),
  Setting_Type              Varchar2(20),
  Description               Varchar2(512),
  Status                    Number(3),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
) TABLESPACE &TBLSPACE_SYS.;

Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
