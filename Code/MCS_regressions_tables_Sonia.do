clear all
set more off
cap log close

use "D:\Home\jgomes\Happiness\MCS\MCS_data.dta",

log using MCS_regression_tables.log, replace

de twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol BirthOrder
sutex twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol BirthOrder, minmax



drop educ_not

quietly reg twin age_at_birth age_at_birth2, robust
estimates store est1

quietly reg twin age_at_birth age_at_birth2 BirthOrder, robust
estimates store est2

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_*, robust
estimates store est3

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss, robust
estimates store est4

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss smoke alcohol, robust
estimates store est5

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss if e(sample), robust
estimates store est6


quietly reg twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol, robust
estimates store est7

esttab est1 est2 est3 est4 est5 est6 est7, star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.tex, replace star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - No weights)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.csv, replace star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - No weights)







quietly reg twin age_at_birth age_at_birth2, robust
estimates store est1

quietly reg twin age_at_birth age_at_birth2 BirthOrder, robust
estimates store est2

quietly reg twin age_at_birth age_at_birth2 BirthOrder height_mother bmi_mother bmi_miss, robust
estimates store est3


quietly reg twin age_at_birth age_at_birth2 BirthOrder height_mother bmi_mother bmi_miss smoke alcohol, robust
estimates store est4

quietly reg twin age_at_birth age_at_birth2 BirthOrder height_mother bmi_mother  bmi_miss if e(sample), robust
estimates store est5

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss smoke alcohol, robust
estimates store est6

quietly reg twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol, robust
estimates store est7

esttab est1 est2 est3 est4 est5 est6 est7, star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.tex, append star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - No weights)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.csv, append star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - No weights)

**************************************
*Now with weights
**************************************

gen wt_var = aovwt2

quietly reg twin age_at_birth age_at_birth2 [pweight = wt_var], robust
estimates store est1

quietly reg twin age_at_birth age_at_birth2 BirthOrder [pweight = wt_var], robust
estimates store est2

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* [pweight = wt_var], robust
estimates store est3

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss [pweight = wt_var], robust
estimates store est4

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss smoke alcohol [pweight = wt_var], robust
estimates store est5

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss if e(sample) [pweight = wt_var], robust
estimates store est6


quietly reg twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol [pweight = wt_var], robust
estimates store est7

esttab est1 est2 est3 est4 est5 est6 est7, star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.tex, append star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - With weights)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.csv, append star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - With weights)





quietly reg twin age_at_birth age_at_birth2 [pweight = wt_var], robust
estimates store est1

quietly reg twin age_at_birth age_at_birth2 BirthOrder [pweight = wt_var], robust
estimates store est2

quietly reg twin age_at_birth age_at_birth2 BirthOrder height_mother bmi_mother bmi_miss [pweight = wt_var], robust
estimates store est3


quietly reg twin age_at_birth age_at_birth2 BirthOrder height_mother bmi_mother bmi_miss smoke alcohol [pweight = wt_var], robust
estimates store est4

quietly reg twin age_at_birth age_at_birth2 BirthOrder height_mother bmi_mother  bmi_miss if e(sample) [pweight = wt_var], robust
estimates store est5

quietly reg twin age_at_birth age_at_birth2 BirthOrder educ_* height_mother bmi_mother bmi_miss smoke alcohol [pweight = wt_var], robust
estimates store est6

quietly reg twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol [pweight = wt_var], robust
estimates store est7

esttab est1 est2 est3 est4 est5 est6 est7, star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.tex, append star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - With weights)
esttab est1 est2 est3 est4 est5 est6 est7 using MCS_tables.csv, append star(* 0.10 ** 0.05 *** 0.01) se r2 scalars(N) title(Twins regressions MCS data - With weights)


/***********************************
F - Test
***********************************/

reg twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol, robust

test age_at_birth age_at_birth2
test height_mother bmi_mother
test height_mother bmi_mother  educ_other educ_DCSE_DG educ_Olevel educ_Alevel educ_diploma educ_First educ_High alcohol
test educ_other educ_DCSE_DG educ_Olevel educ_Alevel educ_diploma educ_First educ_High


reg twin age_at_birth age_at_birth2 educ_* height_mother bmi_mother bmi_miss smoke alcohol [pweight = wt_var], robust

test age_at_birth age_at_birth2
test height_mother bmi_mother
test height_mother bmi_mother  educ_other educ_DCSE_DG educ_Olevel educ_Alevel educ_diploma educ_First educ_High alcohol
test educ_other educ_DCSE_DG educ_Olevel educ_Alevel educ_diploma educ_First educ_High


log close
