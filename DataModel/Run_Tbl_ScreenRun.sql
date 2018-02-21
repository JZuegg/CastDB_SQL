-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=ScreenRun
DEFINE xTrigger=ScrRun
DEFINE xID=Run_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Run_ID                  Varchar2(55),
  Run_Name                Varchar2(100),
  Run_Type                Varchar2(5),
  Project_Lst             Varchar2(512),
  CpOz_ID                 Varchar2(50),
  Stock_Format            Varchar2(50),
  wf_nStock_Plates        Number(7,0),
  wf_nMother_Plates       Number(7,0),
  wf_nTest_Plates         Number(7,0),
  wf_Plating              Varchar2(50),
  wf_Plating_Date         Date,
  wf_Plating_Ready        Date,
  wf_Screens              Varchar2(150),
  Run_Issues              Varchar2(250),
  Run_Status              Varchar2(150),
  Next_Selection          Varchar2(50),
  Screen_Date             Date,
  nCompound               Number(7,0),
  nAssay                  Number(7,0),
  nMotherPlate            Number(7,0),
  nTestPlate              Number(7,0),
  nInhibition             Number(7,0),
  nMIC                    Number(7,0),
  nCytotox                Number(7,0),
  nHaemolysis             Number(7,0),
  nCMC                    Number(7,0),
  nQC                     Number(7,0),
  Status                  Number(3),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		      	  Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;


-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql

-- ====================================================================
-- Sequence
-- ====================================================================
Drop Sequence &xTrigger._PS_SEQ;
Drop Sequence &xTrigger._HC_SEQ;
Drop Sequence &xTrigger._HV_SEQ;
Delete From &APPLICATION_ID. Where ID_Table = '&xTable.' And ID_Field = '&xID.';

Create Sequence &xTrigger._PS_SEQ INCREMENT BY 1 START WITH 1
       MAXVALUE 1.0E28 MINVALUE 1 NOCYCLE NOCACHE;
Insert Into &APPLICATION_ID. (ID_Table,ID_Field,ID_Type,ID_Format,ID_SEQ)
       Values ('&xTable.','&xID.',NULL,'PSR:5','&xTrigger._PS_SEQ');

Create Sequence &xTrigger._HC_SEQ INCREMENT BY 1 START WITH 1
      MAXVALUE 1.0E28 MINVALUE 1 NOCYCLE NOCACHE;
Insert Into &APPLICATION_ID. (ID_Table,ID_Field,ID_Type,ID_Format,ID_SEQ)
      Values ('&xTable.','&xID.',NULL,'HCR:5','&xTrigger._HC_SEQ');

Create Sequence &xTrigger._HV_SEQ INCREMENT BY 1 START WITH 1
      MAXVALUE 1.0E28 MINVALUE 1 NOCYCLE NOCACHE;
Insert Into &APPLICATION_ID. (ID_Table,ID_Field,ID_Type,ID_Format,ID_SEQ)
      Values ('&xTable.','&xID.',NULL,'HVR:5','&xTrigger._HV_SEQ');
