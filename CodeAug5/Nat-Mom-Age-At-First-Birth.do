*HH_grid
*Find CM's natural mother person number
*Find all natural children of that mother
*Arrange them according to birth order
*Keep only the eldest child
*Extrapolate mother's first birth by

*=================================================================================
* Section 0: Directories and Setup
*=================================================================================
vers 10.1 
clear all
set more off
global directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/

*=================================================================================
* Section 1: Loop over Waves 1 and 2
* Prevents missing values - some cohort members first enter at Wave2
*=================================================================================

foreach num in 1 2 3 4 {
	if `num' == 1{
		local HHGrid "${directory}Raw/MCS-Survey-1/stata9/mcs1_hhgrid.dta"
		local prefix AH
		local loopend K
	}
	
	if `num' == 2{
		local HHGrid "${directory}Raw/MCS-Survey-2/stata9_se/mcs2_hhgrid.dta"
		local prefix BH
		local loopend R
		* gives results for 11,503 families
	}
	
	if `num' == 3{
		local HHGrid "${directory}Raw/MCS-Survey-3/stata9_se/mcs3_hhgrid.dta"
		local prefix CH
		local loopend Y
	}
	
	if `num' == 4{
		local HHGrid "${directory}Raw/MCS-Survey-4/stata9_se/mcs4_hhgrid.dta"
		local prefix DH
		local loopend Y
	}
	*=================================================================================
	* Section 2: Find CM's natural mother person number
	*=================================================================================
	use `HHGrid', clear
	sort MCSID
	save `HHGrid', replace

	* __CREL00: Relationship to Cohort Member
	* __PNUM00: Person number
	* __PSEX00: Person Sex
	* __PDBY00: Person's DOB (year)
	* __PDBM00: Person's DOB (month)
	rename `prefix'CREL00 Relation_to_CM
	rename `prefix'PNUM00 Person_Number
	rename `prefix'PSEX00 Person_Sex
	rename `prefix'PDBY00 P_DOB_Y
	rename `prefix'PDBM00 P_DOB_M

	keep if Relation_to_CM == 7 & Person_Sex == 2

/*
		We now have natural mothers
		Now we must create a new variable for all members of the HH that equals the
		natural mothers number
		Can do so by merging again using HH_grid on MCSID
*/

	keep MCSID Person_Number P_DOB_Y P_DOB_M Relation_to_CM
	rename Person_Number Nat_Mom_No
	rename P_DOB_Y Mother_DOB_Y
	rename P_DOB_M Mother_DOB_M

/*
		Might wish to check if there is more than one nat mom per HH
		duplicates report MCSID
*/

	save ${directory}Intermediate/temp.dta, replace

	sort MCSID
	merge MCSID using `HHGrid'
	sort MCSID
	* Wave1: 81 observation (26 HH) don't have a natural mother
	* Wave2: 440 observations don't have a natural mother
	keep if _merge != 2
	drop _merge

	*=================================================================================
	* Section 3: Find all natural children of that mother
	*=================================================================================

	sort Nat_Mom_No MCSID

	save ${directory}Intermediate/temp1.dta, replace

	*Erasing all values from relationship to person 1-11 (A-K)
	local counter = 1
	foreach var of varlist `prefix'PREL0A-`prefix'PREL0`loopend' {
		replace `var' = . if Nat_Mom_No != `counter'
		local ++counter
	}

/*
		Getting for each member of HH its relation to the natural mother
		of CM from that HH
*/
	egen relation_to_family_mom = rowfirst(`prefix'PREL0*)

	*Keeping only natural children of the natural mother of CM
	keep if relation_to_family_mom == 3

	rename `prefix'PDBY00 P_DOB_Y
	rename `prefix'PDBM00 P_DOB_M

	sort MCSID P_DOB_Y P_DOB_M

	*Save now, to use again for finding birth order of CM and birth order of later twins
	*But, use HHGrid 5
	save ${directory}Intermediate/natural_children_of_CM_mom_wave`num'.dta, replace

	* Drop "Dont know" observations
	drop if P_DOB_Y < 0 | P_DOB_M < 0

	*Unite person's DOB and CM's DOB in same variable
	*`prefix'CDBY00: CM DOB (year)
	*`prefix'CDBM00: CM DOB (month)
	replace P_DOB_Y = `prefix'CDBY00 if  P_DOB_Y == -1
	replace P_DOB_M = `prefix'CDBM00 if  P_DOB_M == -1

	*Drop obs where DOB is unknown or simply missing
	drop if P_DOB_Y == . | P_DOB_Y == -2

	duplicates report MCSID P_DOB_Y P_DOB_M
	*Arrange them according to birth order
	sort MCSID P_DOB_Y P_DOB_M

	*=================================================================================
	* Section 4: Getting person's age and mom's age
	*=================================================================================

	rename P_DOB_Y Child_DOB_Y
	rename P_DOB_M Child_DOB_M

	*Drop observation with mother's unknown year of birth (9 obs)
	drop if Mother_DOB_Y < 0
	*Drop observation with mother's unknown month of birth (9 obs)
	drop if Mother_DOB_M < 0
	*Drop observation with child's unknown year of birth (0 obs)
	drop if Child_DOB_Y < 0
	*Drop observation with child's unknown month of birth (11 obs)
	drop if Child_DOB_M < 0

	gen Mom_Age = 2014 - Mother_DOB_Y + (8 - Mother_DOB_M) / 12
	gen Child_Age = 2014 - Child_DOB_Y + (8 - Child_DOB_M) / 12

	*=================================================================================
	* Section 5: Extrapolating mom's age at birth and thus at first birth
	*=================================================================================

	gen Mom_Age_At_Birth = Mom_Age - Child_Age
	egen agefirstbirth = min(Mom_Age_At_Birth), by(MCSID)
	label var agefirstbirth "Mother Age at First Birth, calculated by Natural Children of Nat Mom"
	*histogram agefirstbirth

	keep MCSID agefirstbirth
	duplicates drop
	save ${directory}Intermediate/agefirstbirth_wave`num'.dta, replace
}

*=================================================================================
* Section 6: Combine agefirstbirth from waves 1 - 4
*=================================================================================
use ${directory}Intermediate/agefirstbirth_wave1.dta, clear
gen wave = 1
append using ${directory}Intermediate/agefirstbirth_wave2.dta
replace wave = 2 if wave == .

* Perhaps I should merge together the list of natural children, remove duplicates and any without DOB
* That will prevent the different age calculations I'm finding

*append using ${directory}Intermediate/agefirstbirth_wave3.dta
*replace wave = 3 if wave == .
*append using ${directory}Intermediate/agefirstbirth_wave4.dta
*replace wave = 4 if wave == .

/*
Test for different age calculations
duplicates tag, gen(sameage)
duplicates tag MCSID, gen(samemcsid)
edit if sameage != 1 & samemcsid == 1
*/

duplicates drop MCSID, force
sort MCSID
tab wave
drop wave
save ${directory}Intermediate/agefirstbirth.dta, replace
