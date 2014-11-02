*=================================================================================
* Section 0: Directories and Setup
*=================================================================================
vers 10.1 
clear all
set more off
global directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/

*======================================================================================
* Section 1: Prep HH Grid
*=====================================================================================

use "${directory}Raw/MCS-Survey-5/stata11/mcs5_hhgrid.dta", clear
sort MCSID
* Keep CM only
keep if EHCREL00 == 96
rename EHCNUM00 CMNUM
keep MCSID CMNUM EHCSEX00
rename EHCSEX00 CM_Sex

preserve
use "${directory}Raw/MCS-Survey-5/stata11/longitudinal_family_file.dta", clear
sort MCSID
* Can keep different weight factors for wave 3, wave 4
keep MCSID NOCMHH SENTRY COUNTRY PTTYPE2 NH2 EISSUED DAOUTC00 EAOUTC00 EOVWT1 EOVWT2 ENRESPWT
rename EOVWT2 sweight
save "${directory}Intermediate/longitudinal_family_file.dta", replace
restore

sort MCSID
merge MCSID using "${directory}Intermediate/longitudinal_family_file.dta"
drop if _merge == 2
drop _merge

*======================================================================================
* Section 2: CM quality outcomes
*=====================================================================================

* TODO: Get age of CM here

sort MCSID CMNUM
merge MCSID CMNUM using "${directory}Intermediate/CM_quality_outcomes.dta" "${directory}Intermediate/CM_quality_outcomes4.dta"
drop _merge*

sort MCSID
merge MCSID using "${directory}Intermediate/CM_quality_outcomes4_parent.dta"
