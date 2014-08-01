********************************************************************************** (0) Globals and Locals*******************************************************************************clear allvers 10.1 cap log closeforeach ado in ivreg2 outreg2 estout ranktest mat2txt plausexog {	cap which `ado'	if _rc!=0 ssc install `ado'}* DIRECTORIESglobal Directory /Users/pedm/Documents/jobs/Damian-Clarkeglobal Data    "${Directory}/Data"global Source  "${Directory}/Code"global Log     "${Directory}/Log"global Graphs  "${Directory}/Results/Graphs"global Tables  "${Directory}/Results/Outreg"foreach dirname in Summary Twin OLS RF IV Conley {	cap mkdir "$Tables/`dirname'"}* VARIABLES* We cannot obtain a measure of educf - Mother's years of education * Instead we use natural_mother_education_NVQ - mothers edu level* TODO: _contracep* - contraceptive use and intention* TODO: search for a mothers year of education, or similar* Original:* global base malec _country* _yb* _contracep** global S educf educfyrs_sqglobal outcomes Quality_EVSTSCOglobal base malec _country* _yb* _dob*global age motherage motheragesq motheragecub agefirstbirthglobal S _mother_edu*global H height bmi* ECONOMETRIC SPECIFICATIONS* Only include CM that are available in Wave 5local cond if Quality_EVSTSCO != .local se cluster(MCSID)local wt [pw=sweight]local conditions ALL==1 income_quint==1 income_quint>1&income_quint<5 malec==0 malec==1local fnames All LowIncome MidIncome Girls Boys********************************************************************************** (1) Setup (+ discretionary choices)*******************************************************************************use "${Data}/Final/QQ-Ready-for-Regressions.dta"gen ALL = 1replace bmi=. if bmi>50replace height=. if height>2.4replace height=. if height<0.8* Generate dummy varsqui tab country, gen(_country)qui tab year_birth, gen(_yb)qui tab natural_mother_education_NVQ, gen(_mother_edu)qui tab bord, gen(_bord)* All CM are born between 200-2002, thus this is a better measure than agetostring CM_DOB_Month CM_DOB_Year, replacegen CM_dob = CM_DOB_Year + "." + CM_DOB_Monthqui tab CM_dob, gen(_dob)/*tab contracep_intent, gen(_contracep)drop if twinfamily>2gen cat="Low Inc, Singleton" if twind==0 & inc_status=="L"replace cat="Low Inc, Twin" if twind==1 & inc_status=="L"replace cat="Mid Inc, Single" if twind==0 & inc_status!="L"replace cat="Mid Inc, Twin" if twind==1 & inc_status!="L"encode cat, gen(catnum)egen category=concat(income twindfamily)egen nonmiss = rowmiss(educf height bmi motherage malec)*/* Generate Z scores of outcome variablesforeach var of varlist $outcomes {	egen `var'_sd=sd(`var')	egen `var'_mean=mean(`var')		gen Z`var'=(`var'-`var'_mean)/`var'_sd	drop `var'_sd `var'_mean	global outcomes $outcomes Z`var'}************************************************************************************ (1b) Investigate missing values - how can I increase sample size?********************************************************************************		preserve	keep `cond'	qui reg Qual fert $base $age $S $H, `se'	generate sample = e(sample)	tab sample	egen base_miss = rowmiss($base)	egen age_miss = rowmiss($age)	egen S_miss = rowmiss($S)	egen H_miss = rowmiss($H)	egen miss = rowmiss($base $age $S $H)		* edit Qual fert $base $age $S $H if sample == 0	restore	* Fixed: Sample size has increased by 50% after adding bmi and height from wave1* TODO: 1554 missing values for fert* TODO: 3543 missing values for agefirstbirth* TODO: currently only 8,937 obs have age_miss == 0************************************************************************************ (2) Simple OLS of Q-Q (can then apply Altonji)********************************************************************************	* Note: i.bord does not work in stata 10.1. 	* Instead we use _bord* as a dummy for each		local out "${Tables}/OLS/QQ_ols.xls"	cap rm "`out'"	cap rm "${Tables}/OLS/QQ_ols.txt"	foreach inc in ALL==1 income_quint==1 income_quint>1&income_quint<5 {		preserve		di "`cond' & `inc'"		keep `cond' & `inc'		foreach y of varlist $outcomes {									qui reg `y' fert $base $age $S $H, `se'						qui reg `y' fert $base $age `wt' if e(sample), `se'			outreg2 fert $age using "`out'", excel append						qui reg `y' fert $base $age $H `wt' if e(sample), `se'			outreg2 fert $age $H using "`out'", excel append						qui reg `y' fert $base $age $S $H `wt', `se'			outreg2 fert $age $S $H using "`out'", excel append			qui reg `y' fert $base $age $S $H _bord* `wt', `se'			outreg2 fert $age $S $H using "`out'", excel append			}		restore	}************************************************************************************ (3) IV (using twin at order n), subsequent inclusion of twin predictors********************************************************************************* Estimation samples for the IV regression - look only at those that had local max 1local fert 2foreach num in two three four {	* two_plus = 1 for the family that had 2+ births    gen `num'_plus=bord<=`max'&fert>=`fert'    replace `num'_plus=0 if NOCMHH != 1    	* twin_two_fam = 1 if a family has a twin at the second birth and 0 otherwise	* TODO: this does not account for families that have multiple twin births  	gen twin_`num'_fam = (LaterTwin_birth_order == `fert')    local ++max    local ++fert}* I do not include cluster(MCSID) because our sample does not include non-singleton CMstokenize `fnames'local i 1foreach condition of local conditions {	local condition_name = "``i''"		local out "${Tables}/IV/`condition_name'.xls"	cap rm "`out'"	cap rm "${Tables}/IV/`condition_name'.txt"		foreach n in two three {		preserve				keep `cond'&`condition'&`n'_plus==1		* TODO: What was this line meant to do??		* keep .... &(twinfamily==2|twinfamily==0)				foreach y of varlist $outcomes {			qui ivregress 2sls `y' `base' $age $S $H (fert=twin_`n'_fam) `wt'			outreg2 fert $age $S $H using "`out'", excel append			qui ivregress 2sls `y' `base' $age $S (fert=twin_`n'_fam) `wt' if e(sample)			outreg2 fert $age $S using "`out'", excel append			qui ivregress 2sls `y' `base' (fert=twin_`n'_fam) `wt' if e(sample)					outreg2 fert $age using "`out'", excel append		}		restore	}		local ++i}