/*

This file produces one folder containing regression estimates for each sample

Global switches control the output of QQ-Regressions.do
QQ-Regressions.do can still be run indepedently, with switches defined internally
When using this file, make sure to comment out the switches within QQ-Regressions.do
The outreg folder should look as follows:

Readme
/IV
	DataV1-All-IncludeMissing
	DataV1-All-OmitMissing
	DataV1-All-IncludeMissing
	DataV2-All-OmitMissing
	DataV1-Girls-IncludeMissing
	DataV1-Girls-OmitMissing
	DataV1-Girls-IncludeMissing
	DataV2-Girls-OmitMissing
/IV-DHSControlsOnly
	DataV1-All-IncludeMissing
	DataV1-All-OmitMissing
	DataV1-All-IncludeMissing
	DataV2-All-OmitMissing
	DataV1-Girls-IncludeMissing
	DataV1-Girls-OmitMissing
	DataV1-Girls-IncludeMissing
	DataV2-Girls-OmitMissing
/OLS
	...
/IV-EffectSizes
	...
/OLS-EffectSizes
	...
/Summary
	DataV1-All-IncludeMissing
	DataV1-OLSsample-IncludeMissing
	DataV1-IVTwoPlus-IncludeMissing
	...

*/
clear
set memory 100000
pause on



* We only estimate effectsizes for fullcontrols==1
* EffectSizes, OLS and IV, OmitMissing
global fullcontrols   1
global zscores        1
global fixmissing1    0
do "QQ-Regressions.do"

* EffectSizes, OLS and IV, IncludeMissing
global zscores        1
global fixmissing1    1
do "QQ-Regressions.do"




* Repeat for data versions
*foreach v in V1 V2{
foreach v in V2{
	* SWITCHES (1 if run, else not run)
	* Create DataV1, create sumstats
	* OLS and IV, OmitMissing
	global zscores        0
	global OLS            1
	global IV             1
	global subsamples     0
	global fullcontrols   1
	global fixmissing1    0
	global evalmissing    0
	global sumstats       1
	global graphs         0
	global fastTesting    0
	global recreateData   1
	global dataV          `v'
	do "QQ-Regressions.do"
	
	* Repeat sumstats for IncludeMissing
	global recreateData   0
	global sumstats       1
	global fixmissing1    1
	do "QQ-Regressions.do"
	global sumstats       0

	* Repeat for DHSControlsOnly
	foreach fullcontrols in 0 1 {
		*OLS and IV, OmitMissing
		global fullcontrols   `fullcontrols'
		global OLS            1
		global IV             1
		do "QQ-Regressions.do"

		* OLS and IV, IncludeMissing
		global sumstats       0
		global fixmissing1    1
		global recreateData   0
		do "QQ-Regressions.do"
	}
	
	* We only estimate effectsizes for fullcontrols==1
	* EffectSizes, OLS and IV, OmitMissing
	global fullcontrols   1
	global zscores        1
	global fixmissing1    0
	do "QQ-Regressions.do"

	* EffectSizes, OLS and IV, IncludeMissing
	global zscores        1
	global fixmissing1    1
	do "QQ-Regressions.do"
}

di "Complete"

