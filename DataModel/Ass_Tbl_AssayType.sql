-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=AssayType
DEFINE xTrigger=AssayType
DEFINE xID=AssayType_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  AssayType_ID              Varchar2(10),
  AssayType_Code            Varchar2(20),
  AssayType_Class           Varchar2(20),
  AssayType_Version         Varchar2(8),
  Summary_Type              Varchar2(10),
  Organism                  Varchar2(50),
  Organism_ID			          Varchar2(15),
  Strain   			            Varchar2(30),
  Media_ID                  Varchar2(25),
  Readout_ID                Varchar2(25),
  Control_ID                Varchar2(25),
  Labware_ID                Varchar2(25),
  Test_Dye                  Varchar2(25),
  Test_Dye_Conc             Number,
  Test_Dye_Conc_Unit        Varchar2(10),
  Addition_ID               Varchar2(25),
  Addition_Conc             Number,
  Addition_Conc_Unit        Varchar2(10),
  Innoculation              Varchar2(250),
  Description               Varchar2(250),
  Status                    Number(3),
  aCreatedBy		            Varchar2(20),
  aCreatedDate              Date,
  aModifiedBy		            Varchar2(20),
  aModifiedDate             Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;

-- Create Index &xTrigger._OG_IDX on &xTable.(Organism_ID) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql
