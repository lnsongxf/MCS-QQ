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
global directory C:\Users\7User\Documents\Work\Damian\

*=================================================================================
* Section 1: Find CM's natural mother person number
*=================================================================================

use "${directory}Data\Raw\MCS-Survey-1\stata9\mcs1_hhgrid.dta", clear

*AHCREL00: Relationship to Cohort Member
*AHPNUM00: Person number
*AHPSEX00: Person Sex
*AHPDBY00: Person's DOB (year)
*AHPDBM00: Person's DOB (month)
rename AHCREL00 Relation_to_CM
rename AHPNUM00 Person_Number
rename AHPSEX00 Person_Sex
rename AHPDBY00 P_DOB_Y
rename AHPDBM00 P_DOB_M

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

save ${directory}Intermediate\temp.dta, replace

sort MCSID
merge 1:m MCSID using "${directory}Data\Raw\MCS-Survey-1\stata9\mcs1_hhgrid.dta"
sort MCSID
*81 observation (26 HH) don't have a natural mother
keep if _merge != 2
drop _merge

*=================================================================================
* Section 2: Find all natural children of that mother
*=================================================================================

sort Nat_Mom_No MCSID

save ${directory}Intermediate\temp1.dta, replace

*Erasing all values from relationship to person 1-11 (A-K)
local counter = 1
foreach var of varlist AHPREL0A-AHPREL0K {
	replace `var' = . if Nat_Mom_No != `counter'
	local ++counter
}

/*
	Getting for each member of HH its relation to the natural mother
	of CM from that HH
*/
egen relation_to_family_mom = rowfirst(AHPREL0*)

*Keeping only natural children of the natural mother of CM
keep if relation_to_family_mom == 3

rename AHPDBY00 P_DOB_Y
rename AHPDBM00 P_DOB_M

sort MCSID P_DOB_Y P_DOB_M

*Save now, to use again for finding birth order of CM and birth order of later twins
*But, use HHGrid 5
save ${directory}Intermediate\natural_children_of_CM_mom.dta, replace


*Unite person's DOB and CM's DOB in same variable
*AHCDBY00: CM DOB (year)
*AHCDBM00: CM DOB (month)
replace P_DOB_Y = AHCDBY00 if  P_DOB_Y == -1
replace P_DOB_M = AHCDBM00 if  P_DOB_M == -1

*Drop obs where DOB is unknown or simply missing
drop if P_DOB_Y == . | P_DOB_Y == -2

duplicates report MCSID P_DOB_Y P_DOB_M
*Arrange them according to birth order
sort MCSID P_DOB_Y P_DOB_M

*=================================================================================
* Section 3: Getting person's age and mom's age
*=================================================================================

rename P_DOB_Y Child_DOB_Y
rename P_DOB_M Child_DOB_M

*Drop observation with mother's unknown year of birth (9 obs)
drop if Mother_DOB_Y == -2
*Drop observation with mother's unknown month of birth (9 obs)
drop if Mother_DOB_M == -2
*Drop observation with child's unknown year of birth (0 obs)
drop if Child_DOB_Y == -2
*Drop observation with child's unknown month of birth (11 obs)
drop if Child_DOB_M == -2

gen Mom_Age = 2014 - Mother_DOB_Y + (8 - Mother_DOB_M) / 12
gen Child_Age = 2014 - Child_DOB_Y + (8 - Child_DOB_M) / 12

*=================================================================================
* Section 4: Extrapolating mom's age at birth and thus at first birth
*=================================================================================

gen Mom_Age_At_Birth = Mom_Age - Child_Age
egen Mom_Age_At_First_Birth = min(Mom_Age_At_Birth), by(MCSID)
histogram Mom_Age_At_First_Birth

save ${directory}Intermediate\natural_children_of_CM_mom_with_age_at_first_birth.dta, replace

