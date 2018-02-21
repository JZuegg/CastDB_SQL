-- -------------------- --
-- Run Backup
-- -------------------- --

-- sqlplus castdb_old/sampleTracking@coadb @runBackupOld

Set Timing on

Execute castdbold_util.Export_CastDBOld('EXP_DIR');

quit;
