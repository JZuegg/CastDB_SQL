-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_Permission
DEFINE xTrigger=AppPermission

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Permission                Varchar2(50),
  Code                      Varchar2(5),
  Dependency                Varchar2(120),
  Status                  	Number(5,0),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(Permission)
) TABLESPACE &TBLSPACE_SYS;
;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
