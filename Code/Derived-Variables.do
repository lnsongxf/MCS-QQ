* Derivied Variables


*=================================================================================
* Section 0: Directories and Setup
*=================================================================================
vers 10.1 
clear all
set more off
* global directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/
global directory "C:\Users\pedm\Documents\My Research\MCS\MCS-QQ\Data\"

*======================================================================================
* Section 1: MCS2 Derived Variables
*=====================================================================================
/* 
Originally, mother_bmi was the control variable with the most missing observations.
Here we combine Wave 1 and Wave 2 to reduce the incidence of missing data.
We use Wave 2 because not all CMs are included in Wave 1. Similarly, many
mothers who gave their bmi in Wave 1 are not asked this question again.
*/



local prefix "A"
local wave_number 1
use "C:\Users\pedm\Documents\My Research\MCS\MCS-QQ\Data\Raw\MCS-Survey-1\stata9\mcs1_derived_variables.dta", clear
* use "${directory}Raw/MCS-Survey-`wave_number'/stata9_se/mcs`wave_number'_derived_variables.dta", clear
keep MCSID `prefix'DTOTS00 `prefix'DOTHS00 `prefix'DNSIB00 `prefix'DHSIB00 
sort MCSID
save "${directory}Intermediate/derived_variables_wave`wave_number'.dta", replace

local prefix "B"
local wave_number 2
use "${directory}Raw/MCS-Survey-`wave_number'/stata9_se/mcs`wave_number'_derived_variables.dta", clear
keep MCSID `prefix'DTOTS00 `prefix'DOTHS00 `prefix'DNSIB00 `prefix'DHSIB00 
sort MCSID
save "${directory}Intermediate/derived_variables_wave`wave_number'.dta", replace

local prefix "C"
local wave_number 3
use "${directory}Raw/MCS-Survey-`wave_number'/stata9_se/mcs`wave_number'_derived_variables.dta", clear
keep MCSID `prefix'DTOTS00 `prefix'DOTHS00 `prefix'DNSIB00 `prefix'DHSIB00 
sort MCSID
save "${directory}Intermediate/derived_variables_wave`wave_number'.dta", replace

local prefix "D"
local wave_number 4
use "${directory}Raw/MCS-Survey-`wave_number'/stata9_se/mcs`wave_number'_derived_variables.dta", clear
keep MCSID `prefix'DTOTS00 `prefix'DOTHS00 `prefix'DNSIB00 `prefix'DHSIB00 
sort MCSID
save "${directory}Intermediate/derived_variables_wave`wave_number'.dta", replace

* Note: no derived_variables.dta for MCS5
