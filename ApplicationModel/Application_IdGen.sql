-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_IdGen
DEFINE xTrigger=AppIdGen

-- Drop Table &xTable.;

Create Table &xTable.
  (
  ID_Table                  Varchar2(20),
  ID_Field                  Varchar2(20),
  ID_Type             	    Varchar2(20),
  ID_Format                 Varchar2(25),
  ID_SEQ                    Varchar2(25),
  Status                    Number(3),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date
) TABLESPACE &TBLSPACE_SYS;

Create Index &xTrigger._TB_IDX on &xTable.(ID_Table) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._FD_IDX on &xTable.(ID_Field) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._TY_IDX on &xTable.(ID_Type) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
