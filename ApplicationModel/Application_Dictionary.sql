-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_Dictionary
DEFINE xTrigger=AppDict

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Dict_Type             	  Varchar2(15),
  Dict_Table                Varchar2(20),
  Dict_Value                Varchar2(50),
  Dict_Value_Type           Varchar2(20),
  Dict_Description          Varchar2(120),
  Status                    Number(3),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKEY PRIMARY KEY(Dict_Type,Dict_Value)
) TABLESPACE &TBLSPACE_SYS;
;

 Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

 -- ====================================================================
 -- Standard Trigger and Grants
 -- ====================================================================
 @../Schema/stdTrigger.sql
 @../Schema/stdGrant.sql
