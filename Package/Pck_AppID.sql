create or replace Package APP_ID
-------------------------------------------------------------
IS
 FUNCTION genID(xTabl Varchar2, xField Varchar2) Return Varchar2;
 FUNCTION genID(xTabl Varchar2, xField Varchar2, xType Varchar2) Return Varchar2;
 PROCEDURE resetSEQ(xTabl Varchar2, xField Varchar2);
 PROCEDURE resetSEQ(xTabl Varchar2, xField Varchar2, xType Varchar2);
-- ===================================================================== --
END APP_ID;
-- ===================================================================== --
/
