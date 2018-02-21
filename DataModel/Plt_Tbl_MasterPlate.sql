-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=MasterPlate
DEFINE xTrigger=MasterPlate
DEFINE xID=Plate_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Plate_ID                Varchar2(25),
  Plate_Type              Varchar2(15),
  Well_Type               Varchar2(15),
  Project_ID              Varchar2(10),
  Labware_ID              Varchar2(25),
  Plate_Size              Varchar2(10),
  N_Wells                 Number(5,0),
  N_TestPlates            Number(3,0),
  Prep_Date               Date,
  Plating                 Varchar2(10),
  Prep_Operator           Varchar2(100),
  CpOz_ID                 Varchar2(20),
  Project_ID              Varchar2(10),
  Run_ID                  Varchar2(25),
  Storage_Location        Varchar2(50),
  Has_Compound            Char(1),
  Has_Layout              Char(1),
  Is_Stored               Char(1),
  Layout_Control          Varchar2(25),
  Layout_Dilution         Varchar2(25),
  Process_Status          Number(3,0),
  Processing              Varchar2(25),
  Issues                  Varchar2(100),
  Volume                  Number,
  Volume_Unit             Varchar2(5),
  Conc                    Number,
  Conc_Unit               Varchar2(10),
  Solvent                 Varchar2(10),
  Status                  Number(3),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		      	  Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
) TABLESPACE &TBLSPACE_DAT;

Create Index &xTrigger._LW_IDX on &xTable.(Labware_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PT_IDX on &xTable.(Plate_Type) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._RI_IDX on &xTable.(Run_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PI_IDX on &xTable.(Project_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._CP_IDX on &xTable.(CpOz_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PS_IDX on &xTable.(Process_Status) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._HI_IDX on &xTable.(has_Compound,has_Layout,is_Stored) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql

-- ====================================================================
-- Sequence
-- ====================================================================
Drop Sequence &xTrigger._SEQ;
Delete From &APPLICATION_ID. Where ID_Table = '&xTable.' And ID_Field = '&xID.';

Create Sequence &xTrigger._SEQ INCREMENT BY 1 START WITH 1
       MAXVALUE 1.0E28 MINVALUE 1 NOCYCLE NOCACHE;
Insert Into &APPLICATION_ID. (ID_Table,ID_Field,ID_Type,ID_Format,ID_SEQ)
       Values ('&xTable.','&xID.',NULL,'MPM:6','&xTrigger._SEQ');
