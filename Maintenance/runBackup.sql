-- -------------------- --
-- Run Backup
-- -------------------- --

-- sqlplus castdb/coaddAdmin@coadb @runBackup

Set Timing on

Execute castdb_util.Export_CastDB('EXP_DIR');

quit;
