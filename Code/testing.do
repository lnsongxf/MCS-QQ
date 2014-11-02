clear all
set memory 100000
use ${directory}Intermediate/natural_children_of_CM_mom_wave1.dta, clear
gen wave = 1
foreach num in 2 3 4 5 {
	append using ${directory}Intermediate/natural_children_of_CM_mom_wave`num'.dta
	replace wave = `num' if wave == .
}

gen problem2 = 0
replace problem2 = 1 if P_DOB_Y < 0 | P_DOB_M < 0
tab problem2

* This order is key!
drop if P_DOB_Y < 0 | P_DOB_M < 0
duplicates drop MCSID PNUM, force

* Result:  27,997 observations for which P DOB is good! 
* But, maybe most of this increase just comes from including those two dropped out before wave 4


preserve
use "${directory}Raw/MCS-Survey-5/stata11/longitudinal_family_file.dta", clear
sort MCSID
* Can keep different weight factors for wave 3, wave 4
keep MCSID NOCMHH SENTRY COUNTRY PTTYPE2 NH2 EISSUED DAOUTC00 EAOUTC00 EOVWT1 EOVWT2 ENRESPWT
rename EOVWT2 sweight
save "${directory}Intermediate/longitudinal_family_file_test.dta", replace
restore

sort MCSID
merge MCSID using "${directory}Intermediate/longitudinal_family_file_test.dta"
tab _merge
* TODO: What's up with 3,424 obs with only data in the longitudinal family file??
* And even if we only look at those "productive in sample 5" we have 1,796 MCSID not represented in master, but showing up in longitudinal_family_file....

drop if EAOUTC00 != 1
* We have 22,127 observations (if including surveys 1-4)

* DONE - Next steps: include survey 5
* DONE - Make P_DOB consistent across surveys
keep MCSID PNUM P_DOB_M P_DOB_Y Mother_DOB_M Mother_DOB_Y PSEX
* ^^^ note. those without PNUM are CM
* now only 110 or 111 people without DOB

* TODO NEXT: Repeat thing about agefirstbirth using this new dta on nat children of nat mom

gen Mom_Age = 2014 - Mother_DOB_Y + (8 - Mother_DOB_M) / 12
gen P_Age = 2014 - P_DOB_Y + (8 - P_DOB_M) / 12
*=================================================================================
* Section 5: Extrapolating mom's age at birth and thus at first birth
*=================================================================================

gen Mom_Age_At_Birth = Mom_Age - P_Age
drop if Mom_Age_At_Birth < 0
* TODO: Is this a sign of something wrong????? Look for these MCSIDs in HHGrid to see if this makes sense
egen agefirstbirth = min(Mom_Age_At_Birth), by(MCSID)
label var agefirstbirth "Mother Age at First Birth (composite) Uses Natural Children of Nat Mom"
* TODO: can I find "relation to CM" too

preserve
keep MCSID PNUM P_DOB_M P_DOB_Y Mother_DOB_M Mother_DOB_Y
save ${directory}Intermediate/natural_children_of_natural_mother_composite.dta, replace
restore

keep MCSID agefirstbirth
duplicates drop
sort MCSID
save ${directory}Intermediate/agefirstbirth_composite.dta, replace


/*
    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
agefirstbi~h |     13177    25.89432    5.639536   9.583334      52.75

*/


***** CURRENT GOAL: confirm results that I sent damian. Impact of turning on/off switches? and computing birth order just as I was doing before?









* Compare to agefirstbirth previously
* Consider doing similar to find twins AND twins birth order!



* In HHGrid Wave 3, look at outcomes for height, weight, sally anne, pattern, naming, etc. But only exists for CM

