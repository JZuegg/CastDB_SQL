-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Project
DEFINE xTrigger=Project
DEFINE xID=Project_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Project_ID                Varchar2(10),
  Project_Name              Varchar2(250),
  Project_Type              Varchar2(50),
  Project_Comment           Varchar2(50),
  Group_ID                  Varchar2(10),
  Contact_A_ID              Varchar2(10),
  Contact_B_ID              Varchar2(10),
  Organisation              Varchar2(250),
  Country                   Varchar2(120),
  Provided_Container        Varchar2(150),
  Stock_Container           Varchar2(120),
  CpOz_ID                   Varchar2(50),
  Project_Status            Varchar2(150),
  Received                  Date,
  N_Compounds               Number(9,0),
  N_Structures              Number(9,0),
  N_PS                      Number(9,0),
  N_PS_Act                  Number(9,0),
  N_HC                      Number(9,0),
  N_HC_Act                  Number(9,0),
  N_QC                      Number(9,0),
  Compound_Status           Varchar2(25),
  Compound_Comment          Varchar2(150),
  Screen_Status             Varchar2(25),
  Screen_Comment            Varchar2(150),
  Completed                 Date,
  Report_Status             Varchar2(25),
  Report_Comment            Varchar2(150),
  Status                  	Number(5,0),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;

Create Index &xTrigger._GI_IDX on &xTable.(Group_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

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
       Values ('&xTable.','&xID.',NULL,'P:5','&xTrigger._SEQ');

-- ====================================================================
-- Dictionary
-- ====================================================================
