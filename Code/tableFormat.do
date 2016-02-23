********************************************************************************
*** (1) Setup
********************************************************************************
global OUT "~/investigacion/2015/birthQuarter/results/ipums/regressions"
global LOG "~/investigacion/2015/birthQuarter/log"

log using "$LOG/labourRegs.txt", text replace

#delimit ;
local estopt cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par([ ]) )) stats
             (N, fmt(%9.0g) label(Observations))
             starlevel ("*" 0.10 "**" 0.05 "***" 0.01) collabels(none) label;
local enote  "Heteroscedasticity robust standard errors are reported in
           parentheses. ***p-value$<$0.01, **p-value$<$0.05, *p-value$<$0.01.";
#delimit cr



********************************************************************************
*** (4) Regressions
********************************************************************************
local ctl motherAge motherAge2 highEduc uhrswork i.year
local cnd if motherAge>34
local abs absorb(state)
local se  robust

eststo: areg logWage mother teacher teacherXmother `ctl' `wt'      , `abs' `se'
eststo: areg wages   mother teacher teacherXmother `ctl' `wt'      , `abs' `se'
eststo: areg logWage mother teacher teacherXmother `ctl' `wt' `cnd', `abs' `se'
eststo: areg wages   mother teacher teacherXmother `ctl' `wt' `cnd', `abs' `se'

#delimit ;
esttab est1 est2 est3 est4 using "$OUT/ValueGoodSeason_all.tex", replace
`estopt' booktabs keep(mother teacher teacherXmother) mlabels(, depvar)
mgroups("All" "$\geq$ 35 Years", pattern(1 0 1 0)
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
title("Wages, Job Types, and Mothers"\label{tab:IPUMSWages}) 
postfoot("\bottomrule\multicolumn{5}{p{14.6cm}}{\begin{footnotesize}        "
"Add in note here about sample, etc. `enote'                                "
"\end{footnotesize}}\end{tabular}\end{table}") style(tex);
#delimit cr
estimates clear

