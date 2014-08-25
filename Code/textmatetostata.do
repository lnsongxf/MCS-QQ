
local cells "count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))"
local sumstats All OLSsample IV_two_plus IV_three_plus
foreach cond of local sumstats{
	
	*Compute five types of sum stats:
	* 1. all observations
	* 2. observations with no twins in family
	* 3. obs with at least one twin in family
	* 4. obs with no later twins (the IV)
	* 5. obs with at least one later twin
	
	eststo clear
	qui eststo: qui estpost sum $sumstatsC if `cond'
	sort twinfamily
	qui by twinfamily: eststo: qui estpost sum $sumstatsC if `cond'
	sort CM_has_later_twin_siblings
	qui by CM_has_later_twin_siblings: eststo: qui estpost sum $sumstatsC if `cond'
	esttab using "${Tables}/Summary/`cond'.rtf", cells("`cells'") mtitle("All" "No twins fam" "Twin in fam" "No later twins" "Later Twins") nonumber replace
	local cells "mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))"
	
}

