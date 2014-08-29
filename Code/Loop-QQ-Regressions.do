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
	Same
/IV-EffectSizes
	Same
/OLS-EffectSizes
	...
/Summary
	DataV1-All-IncludeMissing
	DataV1-OLSsample-IncludeMissing
	DataV1-IVTwoPlus-IncludeMissing
	...

*/

pause on

* SWITCHES (1 if run, else not run)
global zscores        0
global OLS            0
global IV             0
global subsamples     0
global fullcontrols   1
global fixmissing1    1
global evalmissing    0
global sumstats       0
global graphs         0

do "QQ-Regressions.do"
pause

* SWITCHES (1 if run, else not run)
global zscores        0
global OLS            0
global IV             0
global subsamples     0
global fullcontrols   0
global fixmissing1    0
global evalmissing    0
global sumstats       0
global graphs         0

do "QQ-Regressions.do"
pause

di "Complete"


