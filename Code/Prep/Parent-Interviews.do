* Parent Interview

*=================================================================================
* Section 0: Directories and Setup
*=================================================================================
vers 10.1 
clear all
set more off
* global directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/
global directory "C:\Users\pedm\Documents\My Research\MCS\MCS-QQ\Data\"

set maxvar 6000

*======================================================================================
* Mother Reads to the Child
*======================================================================================

local prefix "b"
use "${directory}Raw/MCS-Survey-2/stata9_se/mcs2_parent_interview.dta", clear
rename mcsid MCSID
keep MCSID `prefix'mofrea0 `prefix'mofreb0  `prefix'mofrec0 
rename `prefix'mofrea0 read_cm1_wave2
desc
sort MCSID
save "${directory}Intermediate/parent_interview_wave2.dta", replace

* OFRE
* How often do you read to Jack?
* 1 Every day
* 2 Several times a week
* 3 Once or twice a week
* 4 Once or twice a month
* 5 Less often
* 6 Not at all

local prefix "c"
use "${directory}Raw/MCS-Survey-3/stata9_se/mcs3_parent_interview.dta", clear
rename mcsid MCSID
keep MCSID `prefix'mreofa0 `prefix'mreofb0 `prefix'mreofc0
rename `prefix'mreofa0 read_cm1_wave3
desc
sort MCSID
save "${directory}Intermediate/parent_interview_wave3.dta", replace


* REOF
* How often do you read to [^Cohort child's name]?
* 1 Every day
* 2 Several times a week
* 3 Once or twice a week
* 4 Once or twice a month
* 5 Less often
* 6 Not at all


local prefix "d"
use "${directory}Raw/MCS-Survey-4/stata9_se/mcs4_parent_interview.dta", clear
rename mcsid MCSID
keep MCSID `prefix'mreofa0 `prefix'mreofb0 `prefix'mreofc0
rename `prefix'mreofa0 read_cm1_wave4
desc
sort MCSID
save "${directory}Intermediate/parent_interview_wave4.dta", replace

* REOF
* How often do you.. ..read with or to [^Cohort child's name]?
* 1 Every day or almost every day
* 2 Several times a week
* 3 Once or twice a week
* 4 Once or twice a month
* 5 Less often than once a month
* 6 Not at all
