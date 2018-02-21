DEFINE OWNER=CASTDB
DEFINE PASSWD=coaddAdmin
--
DEFINE RADMIN=CASTDB_ADMIN
DEFINE RUSER=CASTDB_USER
DEFINE RPUBLIC=CASTDB_PUBLIC
--
DEFINE TBLSPACE_SYS=CASTDB
DEFINE TBLSPACE_DAT=CASTDB_DAT
DEFINE TBLSPACE_IDX=CASTDB_IDX
DEFINE TBLSPACE_TMP=CASTDB_TMP
--
DEFINE APPLICATION_ID=APPLICATION_IDGEN
DEFINE MDL=C$DIRECT2017
-- DEFINE CESH=C$MDLICHESH51
--

-- all : FRA,HYD,MAS,MET,RAD,SAL,STE,VAL,BON,ION,CHA,DAT,MIX,POL,TYP,MSU,END
-- DEFINE FMSETTING='MAS,STE,TAU,ION,FRA'
DEFINE FMSETTING='FRA,HYD,MAS,MET,RAD,SAL,STE,VAL,TAU,ION,CHA,DAT,MIX,POL,TYP,MSU,END'

-- MAS isotops
-- BOB bonds
-- STE Stereochemistry
-- TAU Tautomer Bonds
-- CHA Charge
-- ION Total Charge
-- FRA Fragments
-- HYD Hydrogen Count
-- SAL Salts
-- MET Metall bonds
-- RAD Radicals
-- VAL Valence
-- DAT Attached Data
-- END Polymer end group
-- MIX Mixture
-- MSU Monomer/SRU uniqueness
-- POL Polymers
-- TYP Polymer Type

-- Status:
-- -10	Deleted
-- -5	not Valid
--	0	Initial
--  1	Processing
--	5	Validated
--  10  Approved and Confirmed (no changes)
--
--
--
