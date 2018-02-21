-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Compound
DEFINE xTrigger=Compound
DEFINE xID=Compound_ID

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Compound_ID             Varchar2(15),
  Project_ID              Varchar2(10),
  Parent_ID               Varchar2(15),
  Compound_Code           Varchar2(100),
  Compound_Name           Varchar2(100),
  Compound_Type           Varchar2(120),
  Compound_Description    Varchar2(512),
  CpOz_SN                 Varchar2(25),
  CpOz_ID                 Varchar2(20),
  Reg_Amount              Number(8,3),
  Reg_Amount_Unit         Varchar2(10),
  Reg_Volume              Number(8,3),
  Reg_Volume_Unit         Varchar2(10),
  Reg_Conc				        Number(8,3),
  Reg_Conc_Unit           Varchar2(10),
  Reg_Solubility          Varchar2(40),
  Reg_MW                  Number(12,2),
  Reg_MF                  Varchar2(100),
  Reg_Smiles              Varchar2(1025),
  Reg_Structure           Varchar2(250),
  Structure_ID            Varchar2(15),
  Salt_Code               Varchar2(120),
  Structure_Type          Varchar2(50),
  Structure_Status        Number(2,0),
  Full_MW                 Number(12,2),
  Full_MF                 Varchar2(100),
  Screening_Status        Varchar2(25),
  Status                  Number(5),
  aCreatedBy		          Varchar2(20),
  aCreatedDate            Date,
  aModifiedBy		          Varchar2(20),
  aModifiedDate           Date,
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(&xID.)
) TABLESPACE &TBLSPACE_DAT;

Create Index &xTrigger._CPC_IDX on &xTable.(Compound_Code) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._CPN_IDX on &xTable.(Compound_Name) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PI_IDX on &xTable.(Project_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._SI_IDX on &xTable.(Structure_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._CzN_IDX on &xTable.(CpOz_SN) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._CzI_IDX on &xTable.(CpOz_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._CzP_IDX on &xTable.(CpOz_Project_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._Bc_IDX on &xTable.(Stock_Barcode) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._STK_IDX on &xTable.(Stock_Plate_ID,Stock_Well_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._ST_IDX on &xTable.(Status) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdTrigger.sql
@../Schema/stdGrant.sql

-- ====================================================================
-- Sequence
-- ====================================================================
Delete From &APPLICATION_ID. Where ID_Table = '&xTable.' And ID_Field = '&xID.';

DEFINE xSeq=&xTrigger._COADD_SEQ
Drop Sequence &xSeq.;
Create Sequence &xSeq. INCREMENT BY 1 START WITH 1
       MAXVALUE 1.0E28 MINVALUE 1 NOCYCLE NOCACHE;
Insert Into &APPLICATION_ID. (ID_Table,ID_Field,ID_Type,ID_Format,ID_SEQ)
       Values ('&xTable.','&xID.','CO-ADD','C:7','&xSeq.');

DEFINE xSeq=&xTrigger._Ext_SEQ
Drop Sequence &xSeq.;
Create Sequence &xSeq. INCREMENT BY 1 START WITH 1
      MAXVALUE 1.0E28 MINVALUE 1 NOCYCLE NOCACHE;
Insert Into &APPLICATION_ID. (ID_Table,ID_Field,ID_Type,ID_Format,ID_SEQ)
      Values ('&xTable.','&xID.','External','CX:6','&xSeq.');

DEFINE xSeq=&xTrigger._MCC_SEQ
Drop Sequence &xSeq.;
Create Sequence &xSeq. INCREMENT BY 1 START WITH 1
      MAXVALUE 1.0E28 MINVALUE 1 NOCYCLE NOCACHE;
Insert Into &APPLICATION_ID. (ID_Table,ID_Field,ID_Type,ID_Format,ID_SEQ)
      Values ('&xTable.','&xID.','CooperGrp','CM:6','&xSeq.');
Commit;
