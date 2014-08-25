*=================================================================================* Section 0: Directories and Setup*=================================================================================vers 10.1 clear allset more offglobal directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/*======================================================================================* Section 1: Prep HH Grid*=====================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_hhgrid.dta", clearsort MCSID* Keep CM onlykeep if EHCREL00 == 96rename EHCNUM00 CMNUMkeep MCSID CMNUM EHCSEX00rename EHCSEX00 CM_Sexpreserveuse "${directory}Raw/MCS-Survey-5/stata11/longitudinal_family_file.dta", clearsort MCSID* Can keep different weight factors for wave 3, wave 4keep MCSID NOCMHH SENTRY COUNTRY PTTYPE2 NH2 EISSUED DAOUTC00 EAOUTC00 EOVWT1 EOVWT2 ENRESPWTrename EOVWT2 sweightsave "${directory}Intermediate/longitudinal_family_file.dta", replacerestoresort MCSIDmerge MCSID using "${directory}Intermediate/longitudinal_family_file.dta"drop if _merge == 2drop _merge*======================================================================================* Section 2: CM quality outcomes*=====================================================================================* TODO: Get age of CM heresort MCSID CMNUMmerge MCSID CMNUM using "${directory}Intermediate/CM_quality_outcomes.dta" "${directory}Intermediate/CM_quality_outcomes4.dta"drop _merge**======================================================================================* Section 3: Birth Order of CM; Mother edu + health stocks; later born twins*=====================================================================================sort MCSIDmerge MCSID using "${directory}Intermediate/CM_birth_order_and_sibling_count.dta" "${directory}Intermediate/mother_derived_variables.dta" "${directory}Intermediate/CM_with_later_born_twins.dta" "${directory}Intermediate/mcs2_parent.dta" "${directory}Intermediate/agefirstbirth.dta"* Should I use agefirstbirth_composite.dta or agefirstbirth.dta? Doesn't seem to matter. Results robust to both measures* agefirstbirth_composite results: NumberSkills significance increases with S and H controls added (fixmissing == 0)* agefirstbirth_composite results: NumberSkills significant (fixmissing == 1)* agefirstbirth results: NumberSkills significance increases with S and H controls added (fixmissing == 0)* agefirstbirth results: NumberSkills significant (fixmissing == 1)drop if _merge1 == 0drop _merge** Note: If CM are twins, they'll have same birth order* tab CM_birth_order CM_has_later_twin_siblings*======================================================================================* Section 6: Mother fertility (looking at natural mother)*=====================================================================================sort MCSIDmerge MCSID using "${directory}Intermediate/fertility-by-MCSID.dta"drop _merge* Computer mother fertility using siblings + CMsgen mother_fertility = Number_CMs_in_HH + siblings_from_natural_motherlabel var mother_fertility "Fertility: CMs + children for CM's mother. Includes half sibs"* tab mother_fertility fertility_count_by_nat_siblings* We expect Fertility(nat children of mom) = Fert(nat sibs) + Fert(half sibs from CMs mom)* This generally holds: we see mother_fertility > fertility_count_by_nat_siblings for almost all observations* A few exceptions: we see Fert(nat children of mom) = 1 sometimes when Fert(nat sibs) = 2.* In conclusion: mother_fertility is a better measure than fertility_count_by_nat_siblings.* Why? Because it includes half siblings from the same mother* TODO: CHECK: fertility is a count of all children from the same natural mother. Check I don't include half siblings from the father.* TODO: Damian, when the cohort member are twins, should they get the same birth order?*======================================================================================* Section 7: Merge in mother pre birth info (weight/alcohol/smoking/complications)*=====================================================================================sort MCSIDmerge MCSID using "${directory}Intermediate/mcs1_mother_pregnancy"* _merge == 1: CMs first included in wave 2. Unfortunately wave 2 does not obtain the same information on pre pregnancy health* _merge == 2: CMs included in wave 1 but missing in later wavesdrop if _merge == 2drop _merge*======================================================================================* Section 8: Give similar varnames as previous QQ regressions*=====================================================================================rename mother_age_CM_birth motherage rename mother_fertility fertgen motheragesq = motherage^2gen motheragecub = motherage^3gen malec = 0replace malec = 1 if CM_Sex == 1drop CM_Sexlab var malec "CM is a boy"rename CM_birth_order bord*======================================================================================* Section 9: Finish it up*=====================================================================================save "${directory}Final/QQ-Ready-for-Regressions.dta", replace