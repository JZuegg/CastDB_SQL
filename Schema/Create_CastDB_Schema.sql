-- ====================================================================
-- Definition
-- ====================================================================
@./CastDB_Define.sql

-- Drop User &OWNER cascade;

CREATE User &OWNER Identified by &PASSWD
Default Tablespace &TBLSPACE_SYS
Temporary Tablespace &TBLSPACE_TMP;

-- Roles
-- CREATE Role &RADMIN;
-- CREATE Role &RUSER;
-- CREATE Role &RPUBLIC;


GRANT CONNECT TO &OWNER;
GRANT CREATE TABLE TO &OWNER;
GRANT CREATE TRIGGER TO &OWNER;
GRANT CREATE PROCEDURE TO &OWNER;
GRANT CREATE SEQUENCE TO &OWNER;
GRANT CREATE TYPE TO &OWNER;
GRANT CREATE VIEW TO &OWNER;
GRANT CREATE MATERIALIZED VIEW to &OWNER;
GRANT ALTER ANY MATERIALIZED VIEW to &OWNER;
GRANT CREATE SYNONYM TO &OWNER;

GRANT RESOURCE TO &OWNER;
GRANT UNLIMITED TABLESPACE TO &OWNER;
GRANT CREATE SESSION TO &OWNER;

-- To create scheduled jobs
GRANT CREATE JOB to &OWNER;
GRANT READ, WRITE on DIRECTORY EXP_DIR to &OWNER;

GRANT SELECT ON sys.dba_pending_transactions TO &OWNER;
GRANT SELECT ON sys.pending_trans$ TO &OWNER;
GRANT SELECT ON sys.dba_2pc_pending TO &OWNER;
GRANT EXECUTE ON sys.dbms_xa TO &OWNER;
GRANT FORCE ANY TRANSACTION TO &OWNER;

-- To get access to data in CASTDB via SQL
-- GRANT CASTDB_ADMIN to &OWNER;

-- To get access to data in CASTDB via PL/SQL
-- GRANT SELECT on castdb.primary_screening to &OWNER;
-- GRANT SELECT on castdb.MIC to &OWNER;
-- GRANT SELECT on castdb.Cytotox to &OWNER;
-- GRANT SELECT on castdb.Compound to &OWNER;
-- GRANT SELECT on castdb.Project to &OWNER;
-- GRANT SELECT on castdb.Client to &OWNER;
