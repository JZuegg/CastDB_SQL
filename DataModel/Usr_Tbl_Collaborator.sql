-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Collaborator
DEFINE xTrigger=Collaborator
DEFINE xID=User_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  User_ID                   Varchar2(10),
  Group_ID                  Varchar2(250),
  Prev_CastDB_ID            Varchar2(20),
  Group_Position            Varchar2(25),
  Title_Name                Varchar2(15),
  First_Name                Varchar2(50),
  Last_Name                 Varchar2(50),
  Position_Name             Varchar2(50),
  Organisation              Varchar2(250),
  Department                Varchar2(250),
  Address_Full              Varchar2(512),
  Street_Address            Varchar2(250),
  City                      Varchar2(120),
  ZipCode                   Varchar2(25),
  Country                   Varchar2(120),
  Phone                     Varchar2(50),
  EMail                     Varchar2(50),
  User_Permission           Varchar2(250),
  Session_ID                Varchar2(50),
  Status                  	Number(5,0),
  aCreatedBy		      	    Varchar2(20),
  aCreatedDate            	Date,
  aModifiedBy		      	    Varchar2(20),
  aModifiedDate            	Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
 ) TABLESPACE &TBLSPACE_DAT;

Create Index &xTrigger._GI_IDX on &xTable.(Group_ID) TABLESPACE &TBLSPACE_IDX ;

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
       Values ('&xTable.','&xID.',NULL,'CU:5','&xTrigger._SEQ');
