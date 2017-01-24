*=================================================================================
* Time Reading and Births
*=================================================================================

* I'd be interested to see if (a) simply looking at the reading question measured at 
* various points in time, how does it change following a birth?  Do we see that the
* time spent reading with the index child falls once another has been born (ignoring 
* any endogeneity problems)?  I wonder if we can plot something similar to an event
* study where we have change in time reading at different lags and leads before and 
* after a birth.  And (b) see how this reacts to twins rather than singletons, which 
* is more plausibly a causal effect. 

*=================================================================================
* Section 0: Directories and Setup
*=================================================================================
clear all
set more off
* global directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/
global directory "C:\Users\pedm\Documents\My Research\MCS\MCS-QQ\Data\"
use "${directory}Final/QQ-Ready-for-Regressions.dta", clear

tab BDTOTS00

* Look only at families with 1 CM and 0 siblings at wave 2
* keep if BDTOTS00 == 1 


* KEY QUESTION:
* How often do you.. ..read with or to [^Cohort child's name]?
* 1 Every day or almost every day
* 2 Several times a week
* 3 Once or twice a week
* 4 Once or twice a month
* 5 Less often than once a month
* 6 Not at all

* Compute the number of new siblings each wave
gen new_sibs_pre_wave4 = DDTOTS00 - CDTOTS00
lab var new_sibs_pre_wave4 "Number of new siblings btwn waves 3 and 4"
gen new_sibs_pre_wave3 = CDTOTS00 - BDTOTS00
lab var new_sibs_pre_wave3 "Number of new siblings btwn waves 2 and 3"

* Drop the observations that don't make sense (negative change in siblings)
drop if new_sibs_pre_wave4 < 0 
drop if new_sibs_pre_wave3 < 0 

* Drop the observations that dont make sense (N/A result on reading question)
replace read_cm1_wave2 = . if read_cm1_wave2 <= 0
replace read_cm1_wave3 = . if read_cm1_wave3 <= 0
replace read_cm1_wave4 = . if read_cm1_wave4 <= 0

* Generate categories based on new siblings
* tab new_sibs_pre_wave4 new_sibs_pre_wave3
gen category = "No new sibs" if new_sibs_pre_wave3 == 0 & new_sibs_pre_wave4 == 0
replace category = "New sibs (btwn 2 & 3)" if new_sibs_pre_wave3 > 0 & new_sibs_pre_wave4 == 0
replace category = "New sibs (btwn 3 & 4)" if new_sibs_pre_wave3 == 0 & new_sibs_pre_wave4 > 0
replace category = "New sibs (btwn both)" if new_sibs_pre_wave3 > 0 & new_sibs_pre_wave4 > 0
tab category

* drop category
* gen category = "all"

* replace read_cm1_wave2 = 0 if read_cm1_wave2 > 1
* replace read_cm1_wave3 = 0 if read_cm1_wave3 > 1
* replace read_cm1_wave4 = 0 if read_cm1_wave4 > 1


* replace read_cm1_wave2 = 1 if read_cm1_wave2 == 2
* replace read_cm1_wave3 = 1 if read_cm1_wave3 == 2
* replace read_cm1_wave4 = 1 if read_cm1_wave4 == 2
* replace read_cm1_wave2 = 0 if read_cm1_wave2 > 2
* replace read_cm1_wave3 = 0 if read_cm1_wave3 > 2
* replace read_cm1_wave4 = 0 if read_cm1_wave4 > 2

collapse (mean) read_cm1_wave*, by(category)

edit 
sdfsdf

reshape long read_cm1_wave, i(category) j(wave)
encode category, gen(c)
xtset c wave
lab var read_cm1_wave "Avg Reading to Child"
* lab var read_cm1_wave "Percent of Mothers Reading Everyday to CM"

xtline read_cm1_wave, overlay title("Reading to CM Measure (1=everyday; 6=never)") 
* subtitle("Sample: No previous children")
