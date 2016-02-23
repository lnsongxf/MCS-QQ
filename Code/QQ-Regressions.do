*******************************************************************************
*** (0) Globals and Locals
*******************************************************************************
clear all
vers 10.1 
cap log close
pause on
set more off

foreach ado in ivreg2 outreg2 estout ranktest mat2txt plausexog {
	cap which `ado'
	if _rc!=0 ssc install `ado'
}

* DIRECTORIES
* global Directory /Users/pedm/Documents/jobs/Damian-Clarke
* global Directory C:\Users\pedm\Documents\WindowsUbuntuDocs\MCS\MCS-QQ
global Directory F:\MCS\MCS-QQ

global Data          "${Directory}/Data"
global Source        "${Directory}/Code"
global Log           "${Directory}/Log"
global Graphs        "${Directory}/Results/Graphs"
global Tables        "${Directory}/Results/Outreg"
global ESTOUT 	     "${Directory}/Results/Presentation"

* SWITCHES (1 if run, else not run)
* But dataV must be V1, V2, or Aug7

global zscores        1
global OLS            0
global IV             0
global IVrace         0
global subsamples     0
global fullcontrols   1
global fixmissing1    1
global evalmissing    0
global twin           0
global sumstats       0
global graphs         0
global fastTesting    0
global recreateData   0
global dataV          V2
global IV_2016        1

* Note: If fullcontrols==0, we produce estimates using the same controls available in DHS
* These estimates are stored in the folder Outreg-DHScontrols

* VARIABLES
global outcomes Q_Verbal_Similarities Q_Number_Skills Q_Word_Reading Q_Pattern_Construction Q_Help_Reading_Freq Q_Help_Writing_Freq Q_Proactive_School_Selection
global base malec _country* _yb* _dob*
global age motherage motheragesq motheragecub agefirstbirth
global S _mother_edu*
global H height
global sumstatsC malec _country* year_birth CM_DOB_Year CM_DOB_Month motherage agefirstbirth natural_mother_education_NVQ height
global dataset data-v2
* options for dataset is data-v1 or data-v2

* ECONOMETRIC SPECIFICATIONS
* Only include CM that are available in Wave 5
local cond if ALL==1 
local se cluster(MCSID)
global wt [pw=sweight]

* FIGURES
local famsize   famsize
local famsize_n famsize_natsibs
local twinbord  twinbybord
local idealfam  idealfamsize

* REPEATED OPTIONS
local estopt cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par)) stats (r2 N, fmt(%9.2f %9.0g)) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)
local varlab varlabels(motherage "Mother's age" motheragesq "Mother's Age Squared" agefirstbirth "Age First Birth" height "Height" bmi "BMI")


* FILE NAMES
local fSuffix        ""
local Suffix         ""
local Prefix         "Data${dataV}"

* WEIGHT DIFFERENTLY FOR WAVES 4 AND 5
cap program drop defineweight
program defineweight
	args qvar
	if `qvar'== Q_Verbal_Similarities | `qvar'== ZQ_Verbal_Similarities {
		global wt [pw=sweight]
	}
	else{
		global wt [pw=sweight4]
	}	
end

/* Testing:
defineweight Q_Pattern_Construction
di $wt
defineweight ZQ_Verbal_Similarities
di $wt
*/


* TODO
* (N r2, fmt(%9.0g %9.2f) label(Observations R2)) 
#delimit ;
local estopt nonum cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par([ ]) )) stats
             (N, fmt(%9.0g) label(Observations)) 
             starlevel ("*" 0.10 "**" 0.05 "***" 0.01) collabels(none) label;
local enote  "Standard errors are reported in parentheses. ***p-value$<$0.01, **p-value$<$0.05, *p-value$<$0.01.";
#delimit cr


*******************************************************************************
*** (1) Generate full dataset QQ-Ready-for-Regressions.dta (SLOW)
*******************************************************************************
* Here there are two versions, differentiated based on 
* Version1 (Aug7): counts siblings using a mix of "natural siblings only" and "natural sibs + half siblings from same mother" 
* Version2: attempts to count siblings using entirely "natural sibs + half siblings from same mother"

if $recreateData==1{
	* Both versions use:
	do "${Directory}/Code/Fertility-Count-Using-Half-Siblings.do"
	do "${Directory}/Code/Mother-Health-Education.do"
	do "${Directory}/Code/Quality-Outcomes.do"
	
	if "${dataV}"=="V1"{
		* v1 : Aug 5
		do "${Directory}/CodeAug5/Nat-Mom-Age-At-First-Birth.do"
		do "${Directory}/CodeAug5/HH-Grid-Birth-Order.do"
	}
	
	if "${dataV}"=="V2"{
		* v2: Aug 25
		* Order of these files matters
		do "${Directory}/Code/Nat-Mom-Age-At-First-Birth.do"
		* Dependent upon natural_children_of_CM_mom_wave5.dta
		do "${Directory}/Code/testing.do"
		* Must run last, because dependent upon natural_children_of_natural_mother.dta
		do "${Directory}/Code/HH-Grid-Birth-Order-Using-Natural-Children.do"
	}

	* Both versions use the same file to merge Intermediate dta files
	* For version 1, should always use agefirstbirth.dta. Not meant to be used with agefirstbirth_composite
	* For version 2, should I use agefirstbirth_composite.dta or agefirstbirth.dta? Doesn't seem to matter. Results robust to both measures
	do "${Directory}/Code/Merge-Intermediate-Data.do"
	save "${Data}/Final/QQ-Ready-for-Regressions-${dataV}.dta", replace
}


*******************************************************************************
*** (2) Discretionary choices
*******************************************************************************
if $fullcontrols==1{
	global base $base _eth*
	global S $S _inc*
	global H $H daily_cig_before_preg weekly_alcohol_b_preg complications_during_preg
	global sumstatsC $sumstatsC _eth1-_eth4 _inc* daily_cig_before_preg weekly_alcohol_b_preg complications_during_preg
}

*Modify directories
if $fullcontrols==0{
	local fSuffix "`fSuffix'-DHSControlsOnly"
}
if $fixmissing1==1{
	local Suffix "`Suffix'IncludeMissing"
}
if $fixmissing1==0{
	local Suffix "`Suffix'OmitMissing"
}

if $subsamples==1{
	local conditions ALL==1 income_quint==1 income_quint>1&income_quint<5 malec==0 malec==1
	local fnames All LowIncome MidIncome Girls Boys
}
else{
	local conditions ALL==1 malec==0 malec==1
	local fnames All Girls Boys
}

* Never used in production runs, as it overrides other switches
if $fastTesting==1{
	global outcomes Q_Verbal_Similarities Q_Number_Skills
	local conditions ALL==1
	local fnames All	
}

* PRODUCE DIRECTORIES
cap mkdir "$Tables"
cap mkdir "$Graphs"
foreach dirname in Summary OLS OLS-DHSControlsOnly OLS-EffectSizes IV IV-DHSControlsOnly IV-EffectSizes Twins {
	cap mkdir "$Tables/`dirname'"
}

*******************************************************************************
*** (3) Data Setup
*******************************************************************************
use "${Data}/Final/QQ-Ready-for-Regressions-${dataV}.dta", clear

if "${dataV}"=="Aug7"{
	* Use "legacy" data to compare two different measures of birth order
	* if using Aug7 dta, rename outcome vars
	use "${Data}/Final/QQ-Ready-for-Regressions-Aug7.dta", clear
	rename Quality_EVSTSCO Q_Verbal_Similarities
	rename Quality_Number_Skills Q_Number_Skills
	rename Quality_Word_Reading Q_Word_Reading 
	rename Quality_Pattern_Construction Q_Pattern_Construction
}

gen ALL = 1
replace bmi=. if bmi>50
replace height=. if height>2.4
replace height=. if height<0.8
replace motherage=. if motherage<=0

* Incorporate into the regression all observations with missing controls
if $fixmissing1==1{
	* We need only add a zero, as these variables are categorical
	foreach var of varlist country year_birth ethnic_group income_quint natural_mother_education_NVQ{
		replace `var' = 0 if `var'==.
	}
	
	* Continuous variables: replace with zero and add a dummy to the regression
	gen miss_motherage= motherage==.
	replace motheragecub=0 if motherage==.
	replace motheragesq=0 if motherage==.
	replace motherage=0 if motherage==.
	gen miss_agefirstbirth= agefirstbirth==.
	replace agefirstbirth=0 if agefirstbirth==.
	global age $age miss_motherage miss_agefirstbirth
	
	foreach var of varlist $H{
		gen miss_`var'= `var'==.
		replace `var'=0 if `var'==.
		global H $H miss_`var'
	}
}

* Generate dummy vars
qui tab country, gen(_country)
qui tab year_birth, gen(_yb)
gen _yb_pre1955 = _yb1|_yb2|_yb3|_yb4|_yb5|_yb6|_yb7
cap drop _yb1-_yb7 _yb38
qui tab ethnic_group, gen(_eth)
qui tab income_quint, gen(_inc)
qui tab natural_mother_education_NVQ, gen(_mother_edu)
drop _mother_edu6 _inc5
qui tab bord, gen(_bord)
qui tab CM_DOB_Month, gen(_dob_m)
qui tab CM_DOB_Year, gen(_dob_y)

* Generate Z scores of outcome variables
* Z = (y - mean(y | age)) / sd(y | age)
global ZScores
foreach var of varlist $outcomes {
	if `var'== Q_Verbal_Similarities {
		sort CM_age_interview5
		qui gen decile=group(10)
	}
	else{
		sort CM_age_interview4
		qui gen decile=group(10)
	}
	
	sort decile
	by decile: egen `var'_sd=sd(`var')
	by decile: egen `var'_m=mean(`var')
	qui gen Z`var'=(`var'-`var'_m)/`var'_sd
	qui drop `var'_sd `var'_m decile
	global ZScores $ZScores Z`var'
}	
	
if $zscores==1{
	* Rewrite outcomes, add folder suffix
	global outcomes $ZScores
	local fSuffix "`fSuffix'-EffectSizes"
}

*******************************************************************************
*** () Look at sex of first born
*******************************************************************************
* This variable comes from agefirstbirth.dta which comes from Nat-Mom-Age-At-First-Birth.do 
* May later make sense to create agefirstbirth_composite.dta to increase sample size
* Notice missing first_child_sex for very many families
* tab fert first_child_sex

* pause

********************************************************************************
**** (4) Estimation samples for IV regression
********************************************************************************
local max 1
local fert 2
foreach num in two three four {

	* two_plus = 1 for the family that had 2+ births
    qui gen `num'_plus=bord<=`max'&fert>=`fert'
	qui replace `num'_plus=0 if NOCMHH != 1
	
	* twin_two_fam = 1 if a family has a twin at the second birth and 0 otherwise
	* TODO: this does not account for families that have multiple twin births  
	qui gen twin_`num'_fam = (LaterTwin_birth_order == `fert')

    local ++max
    local ++fert
}


********************************************************************************
**** (5a) Investigate missing values - how can I increase sample size?
********************************************************************************
	
if $evalmissing==1{
	keep `cond'
	qui reg Q_Verbal_Similarities fert $base $age $S $H, `se'
	generate sample = e(sample)
	tab sample
	egen base_miss = rowmiss($base)
	egen age_miss = rowmiss($age)
	egen S_miss = rowmiss($S)
	egen H_miss = rowmiss($H)
	egen Q_miss = rowmiss($outcomes)
	egen miss = rowmiss($base $age $S $H $outcomes)
	* edit Qual fert $base $age $S $H if sample == 0
}

* Fixed: Sample size has increased by 50% after adding bmi and height from wave1

********************************************************************************
**** (5b) Sum Stats
********************************************************************************
* twinfamily = At least one twin in family
* CM_has_twin_siblings - if at least one twin birth counted in siblings	
* NOCMHH - number of CM
gen twinfamily = (NOCMHH>1)|(CM_has_twin_siblings==1)

if c(os)=="Unix" local format eps
else if c(os)!="Unix" local format png

* SUM STATS - Generate samples
gen All=1

qui reg `y' fert $base $age $S $H, `se'
gen OLSsample=e(sample)

qui ivregress 2sls `y' $base $age $S $H (fert=twin_two_fam) $wt if two_plus==1
gen IVTwoPlus = e(sample)

qui ivregress 2sls `y' $base $age $S $H (fert=twin_three_fam) $wt if three_plus==1
gen IVThreePlus = e(sample)

qui ivregress 2sls `y' $base $age $S $H (fert=twin_three_fam) $wt if four_plus==1
gen IVFourPlus = e(sample)

local sumstatsSamples All OLSsample IVTwoPlus IVThreePlus IVFourPlus

if $sumstats==1 {

	local cells "count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))"
	foreach subSample of local sumstatsSamples {
	
		*Compute five types of sum stats:
		* 1. all observations
		* 2. observations with no twins in family
		* 3. obs with at least one twin in family
		* 4. obs with no later twins (the IV)
		* 5. obs with at least one later twin
	
		eststo clear
		qui eststo: qui estpost sum $outcomes $sumstatsC if `subSample'
		sort twinfamily
		qui by twinfamily: eststo: qui estpost sum $outcomes $sumstatsC if `subSample'
		sort CM_has_later_twin_siblings
		qui by CM_has_later_twin_siblings: eststo: qui estpost sum $outcomes $sumstatsC if `subSample'
		esttab using "${Tables}/Summary/`Prefix'-`subSample'-`Suffix'.rtf", cells("`cells'") mtitle("All" "No twins fam" "Twin in fam" "No later twins" "Later Twins") nonumber replace
		local cells "mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))"
	}
}

***************************************************************************
*** (5c) Graphical
*** graph 1: total births by family type (twins vs non-twins)
*** graph 2: total births by family type - fertility excluding half siblings
*** graph 3: Proportion of twins by birth order (line)
*** graph 4: Proportion of twins by birth order (histogram)
*** graph 5: Proportion of twins by mothers age
***************************************************************************

if $graphs==1 {
	
	twoway kdensity fert if twinfamily>0&twinfamily!=., lpattern(dash) bw(2) $wt || ///
	  kdensity fert if twinfamily==0, bw(2) scheme(s1color) ytitle("Density") $wt ///
	  legend(label(1 "Twin Family") label(2 "Singleton Family")) ///
	  title("Total births by Family Type") xtitle("total children ever born (includes half sibs)") 
	graph save "$Graphs/`famsize'", replace
	graph export "$Graphs/`famsize'.`format'", as(`format') replace
	
	twoway kdensity fertility_count_by_nat_siblings if twinfamily>0&twinfamily!=., lpattern(dash) bw(2) $wt || ///
	  kdensity fertility_count_by_nat_siblings if twinfamily==0, bw(2) scheme(s1color) ytitle("Density") $wt ///
	  legend(label(1 "Twin Family") label(2 "Singleton Family")) ///
	  title("Total births by Family Type") xtitle("total children ever born (natural siblings only)") 
	graph save "$Graphs/`famsize_n'", replace
	*graph export "$Graphs/`famsize_natsibs'.`format'", as(`format') replace
	
	* TODO: repeat this using different sample sizes (as in, the one with all, then the one just with those with no missings, etc etc)

	* twind  Child is a twin (binary)
	* Am I defining this right? I ask because this is about CM twins, not later born twins
	* TODO: make graphs for "later born twins" ie the IV
	gen twind = NOCMHH>1
	
	local note1 "Single births are 1-frac(twins). "
	local note2 "Total fraction of twins is represented by the solid line."
	local gnote "`note1' `note2'"
	sum twind
	local twinave=r(mean)	
	preserve
	* Compute mean by birth order
	collapse twind $wt, by(bord)
	
	* collapse (count) twind $wt, by(bord)
	* collapse (sum) twind $wt, by(bord)
	
	gen twinave=`twinave'	
	line twind bord if bord<11, lpattern(dash) title("Twinning by birth order") ///
	  ytitle("Fraction twins") xtitle("Birth Order") yline(0.0189) ///
	  note(`gnote') scheme(s1color)
	graph save "$Graphs/`twinbord'", replace
	graph export "$Graphs/`twinbord'.`format'", as(`format') replace

	twoway bar twind bord if bord<11 || ///
	line twinave bord if bord<11, title("Twinning by birth order") ///
	  ytitle("Fraction twins") xtitle("Birth Order")  ///
	  note(`gnote') scheme(s1color)
	graph save "$Graphs/`twinbord'_hist", replace
	graph export "$Graphs/`twinbord'_hist.`format'", as(`format') replace
	restore

	preserve
	collapse twind $wt, by( motherage )
	edit
	twoway connected twind motherage if motherage<=45, lpattern(dash) title("Twinning by mother's age") ///
	  ytitle("Fraction twins (CM)") xtitle("Mother's Age at birth of CM") yline(0.0189) ///
	  note(`gnote') scheme(s1color)
	* save
	restore
}

********************************************************************************
**** (6) Twin predict regressions
********************************************************************************
if $twin==1 {
	*This sets weight as in MCS4
	defineweight(a)
	gen twin = NOCMHH>1
	tokenize `fnames'
	local i 1
	foreach condition of local conditions {
		local condition_name = "``i''"
		preserve
			* Since we use MCS4 weighting, we should only look at entries present in MCS4
			qui keep if `condition' & Q_Help_Reading_Freq != .

			quietly reg twin $base $wt, `se' robust
			estimates store est1

			quietly reg twin $base $age $wt, `se' robust
			estimates store est2

			quietly reg twin $base $age $S $wt, `se' robust
			estimates store est3

			quietly reg twin $base $age $S $H $wt, `se' robust
			estimates store est4

			quietly reg twin $age $S $H $wt, `se' robust
			estimates store est5

			quietly reg twin $base $age _mother_edu* $H $wt, `se' robust
			estimates store est6

			quietly reg twin malec _country* _yb* _dob_m* $age _mother_edu* $H $wt, `se' robust
			estimates store est7

			quietly reg twin malec _country* _yb* _dob_m* $age $S $H $wt, `se' robust
			estimates store est8

			quietly reg twin malec _country* $age $S $H $wt, `se' robust
			estimates store est9

			* esttab est1 est2 est3 est4 est5 est6 est7 est8 est9, star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins)
			qui esttab est1 est2 est3 est4 est5 est6 est7 est8 est9 using "${Tables}/Twins/`Prefix'-TwinTables-`condition_name'-`Suffix'.tex", replace star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data)
			qui esttab est1 est2 est3 est4 est5 est6 est7 est8 est9 using "${Tables}/TWins/`Prefix'-TwinTables-`condition_name'-`Suffix'.csv", replace star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data)
			local ++i
		restore
	}
}

********************************************************************************
**** (6) Simple OLS of Q-Q (can then apply Altonji)
********************************************************************************
if $OLS==1{
	tokenize `fnames'
	local i 1
	foreach condition of local conditions {
		local condition_name = "``i''"
		local out "${Tables}/OLS`fSuffix'/`Prefix'-`condition_name'-`Suffix'.xls"
		cap rm "`out'"
		cap rm "${Tables}/OLS`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"

		foreach n in two three {
			preserve
			keep `cond'&`condition'&`n'_plus==1
			foreach y of varlist $outcomes {
				defineweight `y'
				
				qui reg `y' fert $base $age $S $H, `se'
		
				qui reg `y' fert $base $age $wt if e(sample), `se'
				qui outreg2 fert $age using "`out'", excel append
		
				qui reg `y' fert $base $age $H $wt if e(sample), `se'
				qui outreg2 fert $age $H using "`out'", excel append
		
				qui reg `y' fert $base $age $S $H $wt, `se'
				qui outreg2 fert $age $S $H using "`out'", excel append

				qui reg `y' fert $base $age $S $H _bord* $wt, `se'
				outreg2 fert $age $S $H using "`out'", excel append

				}
			restore
		}
		local ++i
	}
}

********************************************************************************
**** (7) IV (using twin at order n), subsequent inclusion of twin predictors
********************************************************************************

* There are two measures of fertility: 
* fert = natural + half siblings from mothers side
* fertility_count_by_nat_siblings = fertility count excluding half siblings
/*
drop fert
rename fertility_count_by_nat_siblings fert
*/

* I do not include cluster(MCSID) because our sample does not include non-singleton CMs
if $IV==1{
	tokenize `fnames'
	local i 1
	local n1=1
	local n2=2
	local n3=3
	local estimates ""
	local fstage ""
	local OUT "$Tables/IV/`1'"
		
	foreach condition of local conditions {

		local condition_name = "``i''"	
		local out "${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.xls"
		cap rm "`out'"
		cap rm "${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"

		foreach n in two three four {	
			preserve
			keep `cond'&`condition'&`n'_plus==1
						
			foreach y of varlist $outcomes {
				defineweight `y'
				
				qui ivregress 2sls `y' $base $age $S $H (fert=twin_`n'_fam) $wt

				qui ivregress 2sls `y' $base $age (fert=twin_`n'_fam) $wt if e(sample)		
				qui outreg2 fert $age using "`out'", excel append
			
				qui ivregress 2sls `y' $base $age $H (fert=twin_`n'_fam) $wt if e(sample)
				qui outreg2 fert $age $H using "`out'", excel append
			
				qui ivregress 2sls `y' $base $age $H $S (fert=twin_`n'_fam) $wt
				qui outreg2 fert $age $H $S using "`out'", excel append
				
				
				/*
				* While computationally inefficient, I continue to use ivregress above, as we have already written code to format the output into tex tables
				qui ivreg2 `y' $base $age $S $H (fert=twin_two_fam) $wt
				qui eststo: ivreg2 `y' $base $age (fert=twin_`n'_fam) $wt if e(sample), savefirst savefp(f`n1')	
				qui eststo: ivreg2 `y' $base $age $H (fert=twin_`n'_fam) $wt if e(sample), savefirst savefp(f`n2')
				qui eststo: ivreg2 `y' $base $age $H $S (fert=twin_`n'_fam) $wt, savefirst savefp(f`n3')
				
				di "`fstage'"
				di "`estimates'"
				
				local estimates `estimates'  est`n3' est`n2' est`n1' 
				local fstage `fstage' f`n1'fert f`n2'fert f`n3'fert
				local n1=`n1'+3
				local n2=`n2'+3
				local n3=`n3'+3
				*/

			}
			restore
		}
		local ++i
	}
	di "seeout using ${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"
	* seeout using "${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"
	
	* estout f1fert f2fert f3fert f4fert f5fert f6fert f7fert f8fert f9fert f10fert f11fert f12fert using "`OUT'_first.xls", replace `estopt' `varlab' keep(twin_* )
	* estout `fstage' using "`OUT'_first.xls", replace `estopt' `varlab' keep(twin_* $age $S $H)	
	* estout `estimates' using "`OUT'.xls", replace `estopt' `varlab' keep(fert $age $S $H)

		estimates clear
		macro shift
}

********************************************************************************
**** (8) IV (using twin at order n) - tables for IoE presentation
********************************************************************************

* I do not include cluster(MCSID) because our sample does not include non-singleton CMs
if $IV_2016==1{
	tokenize `fnames'
	local i 1
	local n1=1
	local n2=2
	local n3=3
	local estimates ""
	local fstage ""
	local OUT "$Tables/IV2016/`1'"
	
	* Loop over all / female / male
	foreach condition of local conditions {
		local condition_name = "``i''"	
		
		foreach n in three {
			local record = "`n'"
			
			preserve
			
			keep `cond'&`condition'&`n'_plus==1
			
			
			local reg_count = 1
			foreach y of varlist $outcomes {
				defineweight `y'
				
				* TODO: partial out the controls. might need to use ivreg2
				* this will help with reporting R squareds
				
				di "`n'"
				eststo: ivregress 2sls `y' $base $age $H $S (fert=twin_`n'_fam) $wt

			}
			
			
			restore
		}
		
		
		local ++i
	}
	
	* We store est1 - est21
	
	* Both genders: est1 - est7
	* Female: est8 - est14
	* Male: est15 - est21
	
	lab var fert "Fertility"

	lab var ZQ_Verbal_Sim "Verbal"
	lab var ZQ_Number_Skills "Mathematical"
	lab var ZQ_Word_Reading "Reading"
	lab var ZQ_Pattern_Construction "Patterns"
	lab var ZQ_Help_Reading_Freq "Reading Help"
	lab var ZQ_Help_Writing_Freq "Writing Help"
	lab var ZQ_Proactive_School_Selection "Selects School"
	
	* Output estimates
	#delimit ;
	esttab est8 est9 est10 est11 est15 est16 est17 est18 using "$ESTOUT/Table_outcomes_`record'.tex", replace
	`estopt' booktabs keep(fert) mlabels(, depvar)
	mgroups("Girls" "Boys", pattern(1 0 0 0 1 0 0 0)
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
	title("Standardised Test Outcomes and Q-Q Trade-off") 
	postfoot("\bottomrule\multicolumn{5}{p{14.6cm}}{\begin{footnotesize}        "
	"Notes: Verbal score is from the British Ability Scales, Second Edition, measured in Wave 5 of the MCS. Mathematical ability comes from NFER Number Skills, measured in Wave 4 of the MCS. Word Reading and Pattern Construction both come from the British Ability Scales in Wave 4 of the MCS. `enote'                                "
	"\end{footnotesize}}\end{tabular}\end{table}") style(tex);
	#delimit cr
	
	* Investments 
	#delimit ;
	esttab est12 est13 est19 est20 using "$ESTOUT/Table_investments_`record'.tex", replace
	`estopt' booktabs keep(fert) mlabels(, depvar)
	mgroups("Girls" "Boys", pattern(1 0 1 0 )
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
	title("Parental Investments and Q-Q Trade-off") 
	postfoot("\bottomrule\multicolumn{5}{p{14.6cm}}{\begin{footnotesize}        "
	"Notes: Reading Help measures the frequency with which a parent helps their child read during a five day week. Writing Help is measured similarly. Both are recorded in Wave 4 of the MCS. `enote'                                "
	"\end{footnotesize}}\end{tabular}\end{table}") style(tex);
	#delimit cr
	estimates clear
		
	* di "seeout using ${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"
	* seeout using "${Tables}/IV`fSuffix'/`Prefix'-`condition_name'-`Suffix'.txt"
	
	* estout f1fert f2fert f3fert f4fert f5fert f6fert f7fert f8fert f9fert f10fert f11fert f12fert using "`OUT'_first.xls", replace `estopt' `varlab' keep(twin_* )
	* estout `fstage' using "`OUT'_first.xls", replace `estopt' `varlab' keep(twin_* $age $S $H)	
	* estout `estimates' using "`OUT'.xls", replace `estopt' `varlab' keep(fert $age $S $H)

		macro shift
}


