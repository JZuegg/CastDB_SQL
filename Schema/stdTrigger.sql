-- ====================================================================
-- Standard CastDB Trigger
-- ====================================================================
Create Trigger &xTrigger._BIU
  Before Insert Or Update On &xTable.
  For Each Row
 Begin
  If Inserting Then
   :new.aCreatedDate := SYSDATE;
   If (:new.aCreatedBy is NULL) Then
      :new.aCreatedBy := User;
   End If;

  End If;
  If Updating Then
   :new.aModifiedDate := SYSDATE;
   If (:new.aModifiedBy is NULL) Then
      :new.aModifiedBy := User;
   End If;
  End If;
 Exception
    When Others Then
     Raise_Application_Error(-20000, 'Error in &OWNER..&xTrigger._BIU : ' || SQLERRM);
End;
/
