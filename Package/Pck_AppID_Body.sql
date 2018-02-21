create or replace Package Body APP_ID
-------------------------------------------------------------
AS

 Cursor c_genID(xTbl Varchar2, xField Varchar2) Is
  Select ID_Format, ID_Seq
    From Application_IDGen
   Where Upper(ID_Table) = Upper(xTbl)
     And Upper(ID_Field) = Upper(xField);

 Cursor c_genID_Type(xTbl Varchar2, xField Varchar2, xType Varchar2) Is
  Select ID_Format, ID_Seq
    From Application_IDGen
   Where Upper(ID_Table) = Upper(xTbl)
     And Upper(ID_Field) = Upper(xField)
     And Upper(ID_Type)  = Upper(xType);

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION genID (xTabl Varchar2, xField Varchar2) Return Varchar2
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   Is
    v_quote  varchar2(1) := chr(39);
  	rid  Varchar2(50);
    rec_id c_genID%ROWTYPE;
  	lprf Varchar2(12);
  	ndig Number(2,0);
  	nextid  Number(10,0);
  	vsel Varchar2(100);
    nexist Number(2);
   Begin
     rid := NULL;

     Open c_genID(xTabl,xField);
      Loop
       Fetch c_genID into rec_id;
        Exit When c_genID%notfound;
      End Loop;
     Close c_genID;

     If (rec_id.ID_Format is not NULL) Then
      lprf := SubStr(rec_id.ID_Format,1,InStr(rec_id.ID_Format,':')-1);
      ndig := SubStr(rec_id.ID_Format,-(Length(rec_id.ID_Format)-InStr(rec_id.ID_Format,':')));
     End If;

     nExist := 0;
     Loop
       If (rec_id.ID_Seq is not NULL) Then
        vsel := 'Select ' || rec_id.ID_Seq || '.nextval from dual';
  	  Execute Immediate vsel into nextid;
       End If;

       If (lprf is not NULL) And (nextid is not NULL) And (ndig is not NULL) Then
        rid := lprf || LPad(nextid,ndig,'0');
       End If;

       vsel := 'Select count(*) From ' || xTabl || ' Where ' || xField || ' = ' || v_quote || rid || v_quote;
       Execute Immediate vsel into nExist;

       Exit When nExist = 0;
     End Loop;

    Return rid;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   End genID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  FUNCTION genID (xTabl Varchar2, xField Varchar2, xType Varchar2) Return Varchar2
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   Is
    v_quote  varchar2(1) := chr(39);
  	rid  Varchar2(50);
    rec_id c_genID_Type%ROWTYPE;
  	lprf Varchar2(12);
  	ndig Number(2,0);
  	nextid  Number(10,0);
  	vsel Varchar2(100);
    nexist Number(2);
   Begin
     rid := NULL;

     Open c_genID_Type(xTabl,xField,xType);
      Loop
       Fetch c_genID_Type into rec_id;
        Exit When c_genID_Type%notfound;
      End Loop;
     Close c_genID_Type;

     If (rec_id.ID_Format is not NULL) Then
      lprf := SubStr(rec_id.ID_Format,1,InStr(rec_id.ID_Format,':')-1);
      ndig := SubStr(rec_id.ID_Format,-(Length(rec_id.ID_Format)-InStr(rec_id.ID_Format,':')));
     End If;

     nExist := 0;
     Loop
       If (rec_id.ID_Seq is not NULL) Then
         vsel := 'Select ' || rec_id.ID_Seq || '.nextval from dual';
  	     Execute Immediate vsel into nextid;
       End If;

       If (lprf is not NULL) And (nextid is not NULL) And (ndig is not NULL) Then
        rid := lprf || LPad(nextid,ndig,'0');
       End If;

       vsel := 'Select count(*) From ' || xTabl || ' Where ' || xField || ' = ' || v_quote || rid || v_quote;
       Execute Immediate vsel into nExist;

       Exit When nExist = 0;
     End Loop;

    Return rid;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   End genID;
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE resetSEQ (xTabl Varchar2, xField Varchar2)
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     Is
     rec_id c_genID%ROWTYPE;
     nextid Number;
   Begin

    Open c_genID(xTabl,xField);
     Loop
      Fetch c_genID into rec_id;
       Exit When c_genID%notfound;
     End Loop;
    Close c_genID;

    If (rec_id.ID_Seq is not NULL) Then
       Execute Immediate 'Select ' || rec_id.ID_Seq ||
       '.nextval from dual' into nextid;

       Execute Immediate 'Alter Sequence ' || rec_id.ID_Seq ||
       ' Increment By -' || nextid || ' Minvalue 0';

       Execute Immediate 'Select ' || rec_id.ID_Seq ||
       '.nextval from dual' into nextid;

       Execute Immediate 'Alter Sequence ' || rec_id.ID_Seq ||
       ' Increment By 1 Minvalue 0';
    End If;

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   End resetSEQ;
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

 -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
  PROCEDURE resetSEQ (xTabl Varchar2, xField Varchar2, xType Varchar2)
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
     Is
     rec_id c_genID_Type%ROWTYPE;
     nextid Number;
   Begin

    Open c_genID_Type(xTabl,xField,xType);
     Loop
      Fetch c_genID_Type into rec_id;
       Exit When c_genID_Type%notfound;
     End Loop;
    Close c_genID_Type;

    If (rec_id.ID_Seq is not NULL) Then
       Execute Immediate 'Select ' || rec_id.ID_Seq ||
       '.nextval from dual' into nextid;

       Execute Immediate 'Alter Sequence ' || rec_id.ID_Seq ||
       ' Increment By -' || nextid || ' Minvalue 0';

       Execute Immediate 'Select ' || rec_id.ID_Seq ||
       '.nextval from dual' into nextid;

       Execute Immediate 'Alter Sequence ' || rec_id.ID_Seq ||
       ' Increment By 1 Minvalue 0';
    End If;

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   End resetSEQ;
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

-- ===================================================================== --
END APP_ID;
-- ===================================================================== --
/
