-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_Token
DEFINE xTrigger=AppToken

-- Drop Table &xTable.;

Create Table &xTable.
 (
  ID                        Number(19,0),
  User_ID                   Varchar2(50),
  IP_Address				        Varchar2(255),
  Created                   TimeStamp(6),
  Expiration				        TimeStamp(6),
  Description               Varchar2(255),
  Token_Type				        Varchar2(255),
  Token_Hash				        Raw(1024),
  CONSTRAINT &xTrigger._PKey PRIMARY KEY(ID)
) TABLESPACE &TBLSPACE_SYS;

Create Index &xTrigger._UI_IDX on &xTable.(User_ID) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._IP_IDX on &xTable.(IP_Address) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
