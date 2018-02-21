-- ====================================================================
-- Standard Grants to Roles
-- ====================================================================
GRANT All                            ON &xTable. to &RADMIN;
GRANT Select,Delete,Insert,Update    ON &xTable. to &RUSER;
GRANT Select                         ON &xTable. to &RPUBLIC;
