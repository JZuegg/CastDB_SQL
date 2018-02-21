-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=TestPlate
DEFINE xTrigger=TestPlate
DEFINE xID=Plate_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Plate_ID                Varchar2(25),
  Plate_Set               Varchar2(25),
  Labware_ID              Varchar2(25),
  MotherPlate_ID          Varchar2(25),
  MotherPlate2_ID         Varchar2(25),
  Plate_Size              Varchar2(10),
  N_Wells                 Number(5,0),
  Prep_Date               Date,
  Plating                 Varchar2(10),
  Run_ID                  Varchar2(25),
  Project_ID              Varchar2(10),
  AssayType_ID            Varchar2(25),
  Result_Type             Varchar2(15),
  Test_Date               Date,
  Test_Name               Varchar2(25),
  Media_ID                Varchar2(25),
  Process_Status          Number(5),
  Has_Readout             Number(1,0),
  Has_Compound            Number(1,0),
  Has_Layout              Number(1,0),
  Has_Analysis            Number(1,0),
  Has_DoseResponse        Number(1,0),
  Readout_ID              Varchar2(25),
  Reader                  Varchar2(50),
  nReads                  Number(2,0),
  Experiment              Varchar2(80),
  Protocol                Varchar2(80),
  InputFile               Varchar2(80),
  Test_Operator           Varchar2(100),
  Control_ID              Varchar2(25),
  Control_Count           Number(2,0),
  Layout_Control          Varchar2(35),
  Layout_Dilution         Varchar2(25),
  Processing              Varchar2(25),
  Issues                  Varchar2(100),
  Analysis_Parameter      Varchar2(100),
  Volume                  Number,
  Volume_Unit             Varchar2(5),
  Test_Dye                Varchar2(25),
  Test_Dye_Conc           Number,
  Test_Dye_Conc_Unit      Varchar2(10),
  Plate_QC                Number(7,2),
  ZFactor                 Number(7,2),
  Signal_Window           Number(7,2),
  NegControl_Median       Number,
  NegControl_MAD          Number,
  PosControl_Median       Number,
  PosControl_MAD          Number,
  Sample_Median           Number,
  Sample_MAD              Number,
  Edge_Median             Number(7,2),
  NonEdge_Median          Number(7,2),
  Status                  Number(3),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		      	  Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;

Create Index &xTrigger._LW_IDX on &xTable.(Labware_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._MP_IDX on &xTable.(MotherPlate_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._RT_IDX on &xTable.(Result_Type) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._RI_IDX on &xTable.(Run_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PI_IDX on &xTable.(Project_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PS_IDX on &xTable.(Process_Status) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._HI_IDX on &xTable.(has_Readout,has_Compound,has_Layout,has_Analysis,Has_DoseResponse) TABLESPACE &TBLSPACE_IDX ;

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
       Values ('&xTable.','&xID.',NULL,'TPL:6','&xTrigger._SEQ');
