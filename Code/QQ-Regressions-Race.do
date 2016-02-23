
* IV Interacted with Race
* Quality = a + b*fertilty + c*race + d*(race*fertility) + ... + u


cap drop race
cap drop fert_race
cap drop twin_two_fam_race
cap drop twin_three_fam_race

gen race = (ethnic_group == 3) | (ethnic_group == 4) | (ethnic_group == 5) |  (ethnic_group == 6) | (ethnic_group == 10)
gen fert_race = fert*race
gen twin_three_fam_race = twin_three_fam * race

keep if three_plus==1 & malec==0

tab ethnic_group race
tab twin_three_fam_race
tab race

* twin_two_fam_race will not work as an instrument because there's only one observation

global base malec _country* _yb* _dob* _eth1-_eth10

foreach y of varlist $outcomes {
	defineweight `y'
	ivregress 2sls `y' fert*race $base $age $S $H (fert =twin_three_fam ) $wt
* 	ivregress 2sls `y' $base $age $S $H(fert fert_race=twin_three_fam twin_three_fam_race) $wt
* 	ivregress 2sls `y' $base $age $S $H(fert fert_race=twin_three_fam race) $wt

}

