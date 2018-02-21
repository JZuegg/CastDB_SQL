-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Collaborator_Group
DEFINE xTrigger=CollaboratorGrp
DEFINE xID=Group_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Group_ID                  Varchar2(10),
  PI_User_ID                Varchar2(10),
  Group_Name                Varchar2(250),
  Group_Description         Varchar2(250),
  Organisation              Varchar2(250),
  Department                Varchar2(250),
  Address_Full              Varchar2(512),
  Street_Address            Varchar2(250),
  City                      Varchar2(120),
  ZipCode                   Varchar2(25),
  Country                   Varchar2(120),
  MTA_Document              Varchar2(25),
  MTA_Status                Varchar2(120),
  Status                  	Number(5,0),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;

 Create Index &xTrigger._PI_IDX on &xTable.(PI_User_ID) TABLESPACE &TBLSPACE_IDX ;
 Create Index &xTrigger._GN_IDX on &xTable.(Group_Name) TABLESPACE &TBLSPACE_IDX ;

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
       Values ('&xTable.','&xID.',NULL,'CG:5','&xTrigger._SEQ');
