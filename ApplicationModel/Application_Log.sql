-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_Log
DEFINE xTrigger=AppLog
DEFINE xID=Name

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Log_Code                  Varchar2(15),
  Log_Procedure             Varchar2(50),
  Log_Type             	    Varchar2(15),
  Log_Date                  Timestamp(6),
  Log_User  		      	    Varchar2(20),
  Log_Object                Varchar2(15),
  Log_Description           Varchar2(1024),
  Log_Status                Varchar2(15)
) TABLESPACE &TBLSPACE_SYS.;

Create Index &xTrigger._TY_IDX on &xTable.(Log_Type) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._LC_IDX on &xTable.(Log_Code) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._US_IDX on &xTable.(Log_User) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PR_IDX on &xTable.(Log_Procedure) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Special Log Trigger
-- ====================================================================
Create Trigger &xTrigger._BI
  Before Insert On &xTable.
  For Each Row
 Begin
  If Inserting Then
   :new.Log_Date := SYSTIMESTAMP;
   If (:new.Log_User is NULL) Then
      :new.Log_User := User;
   End If;
  End If;
 Exception
    When Others Then
     Raise_Application_Error(-20000, 'Error in &OWNER..&xTrigger._BI : ' || SQLERRM);
End;
/

-- ====================================================================
-- Standard Trigger and Grants
-- ====================================================================
@../Schema/stdGrant.sql
