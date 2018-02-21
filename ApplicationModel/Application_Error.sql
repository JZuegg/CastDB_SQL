-- ====================================================================
-- Definition
-- ====================================================================
@../Schema/CastDB_Define.sql

--------------------------------------------------
-- Table Definition
--------------------------------------------------
DEFINE xTable=Application_Error
DEFINE xTrigger=AppErr
DEFINE xID=Name

-- Drop Table &xTable.;

Create Table &xTable.
 (
  Err_Code                  Varchar2(15),
  Err_Procedure             Varchar2(50),
  Err_Type             	    Varchar2(15),
  Err_Date                  Timestamp(6),
  Err_User  		      	    Varchar2(20),
  Err_Object                Varchar2(15),
  Err_Description           Varchar2(1024),
  Err_Status                Number(5,0)
) TABLESPACE &TBLSPACE_SYS.;

Create Index &xTrigger._TY_IDX on &xTable.(Err_Type) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._EC_IDX on &xTable.(Err_Code) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._US_IDX on &xTable.(Err_User) TABLESPACE &TBLSPACE_IDX ;
Create Index &xTrigger._PR_IDX on &xTable.(Err_Procedure) TABLESPACE &TBLSPACE_IDX ;

-- ====================================================================
-- Special Error Trigger
-- ====================================================================
Create Trigger &xTrigger._BI
  Before Insert On &xTable.
  For Each Row
 Begin
  If Inserting Then
   :new.Err_Date := SYSTIMESTAMP;
   If (:new.Err_User is NULL) Then
      :new.Err_User := User;
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
