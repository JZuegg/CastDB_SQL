-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=tmpWork
DEFINE xTrigger=tmpWork
DEFINE xID=Run_ID

Drop Table &xTable.;

Create Table &xTable.
 (
   Barcode                 Varchar2(15),
   Compound_ID             Varchar2(25),
   Work                    Varchar2(5),
   CpOz_SN                 Varchar2(25),
   Plate_ID                Varchar2(25),
   Well_ID                 Varchar2(3),
   Status                  Number(3),
   aCreatedBy		           Varchar2(20),
   aCreatedDate            Date,
   aModifiedBy		      	 Varchar2(20),
   aModifiedDate           Date
--   CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
  ) TABLESPACE &TBLSPACE_DAT;

  -- ====================================================================
  -- Standard Trigger and Grants
  -- ====================================================================
  @../Schema/stdTrigger.sql
  @../Schema/stdGrant.sql
