-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Labware
DEFINE xTrigger=Labware
DEFINE xID=Labware_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Labware_ID              Varchar2(25),
  Labware_Name            Varchar2(50),
  Labware_Type            Varchar2(12),
  Labware_AddOn           Varchar2(50),
  Plate_Size  			      Varchar2(10),
  Brand                   Varchar2(25),
  Model                   Varchar2(25),
  Material                Varchar2(15),
  Well_Type               Varchar2(10),
  Well_Size               Varchar2(15),
  Well_Shape              Varchar2(15),
  Well_Bottom             Varchar2(20),
  Work_Volume             Number(10,3),
  Work_Volume_Unit        Varchar2(5),
  Status                  Number(1),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		          Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;
;

-- Create Index Labware_TY_IDX on Labware(CSTYPE) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
