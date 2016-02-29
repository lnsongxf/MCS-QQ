*=================================================================================* Section 0: Directories and Setup*=================================================================================vers 10.1 clear allset more offglobal directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/* TODO: Wherever I use natural siblings of the CM, it will be useful to change it to natural children of the CM's mother* This is because half siblings of the CM may be natural children of the mother or the father. Will impact measure of mother's fertility*======================================================================================* Section 1: Identify non-CM twin-siblings*=====================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_hhgrid.dta", clear* Look for duplicates of MCSID, DOB Month, and DOB Year* Do this for natural siblings first, since some half siblings might have similar DOB but not be twins* Notice that some step siblings are born on the same year and month as natural siblings. Thus we should first find twin siblings, then twin half siblingskeep if EHCREL00 == 11 * EHCREL00 == 12 <<<< to keep half siblings* EHCREL00 == 96 <<<< to keep CMduplicates report MCSID EHPDBM00 EHPDBY00duplicates tag MCSID EHPDBM00 EHPDBY00, generate(multiple_births)tab EHCREL00 multiple_birthskeep if multiple_births == 1 | multiple_births == 2gen Twin_DOB_Month = EHPDBM00gen Twin_DOB_Year = EHPDBY00keep MCSID Twin_DOB_Month Twin_DOB_Year multiple_birthsduplicates drop* Potential issue: some families have multiple twinsduplicates report MCSID* Temporary fix: only look at the earlier twins (since we have two IVs: shock at 3 or shock at 4th)* TODO: look at the later twins, since that's more of a shock to fertility gsort Twin_DOB_Year Twin_DOB_Month sort MCSIDsave "${directory}Intermediate/mcs5_nonsingleton_natural_siblings.dta", replace*======================================================================================* Section 2: Identify cohort members with later-born twin siblings*======================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_hhgrid.dta", clear* Keep CM onlykeep if EHCREL00 == 96* Drop non-cohort varsdrop EHPNUM00 drop EHCHK000 EHBWHP00 EHPDCY00 EHPDCM00 EHPSPY00 EHPSPM00 EHPDBM00 EHPDBY00 EHPAGE00 EHCREL00 EHPJOB00 EHPSTY00 EHPSTM00 EHPFUL00 EHELIG00 EHRESP00 EHELIG00 EHRESP00drop EHPREL0** Merge in non-CM twin-births (natural siblings... for now)sort MCSIDmerge MCSID using "${directory}Intermediate/mcs5_nonsingleton_natural_siblings.dta"replace multiple_births = 0 if multiple_births == .* Count later twinsgen CM_has_later_twin_siblings = 0replace CM_has_later_twin_siblings = 1 if Twin_DOB_Year > EHCDBY00 & multiple_births > 0replace CM_has_later_twin_siblings = 1 if Twin_DOB_Year == EHCDBY00 & Twin_DOB_Month > EHCDBM00 & multiple_births > 0tab CM_has_later_twin_siblings multiple_birthslab var CM_has_later_twin_siblings "HHG S5 Later twins. Problem: uses natural siblings, skips half sibs"gen CM_has_twin_siblings = 0replace CM_has_twin_siblings = 1 if multiple_births > 0lab var CM_has_twin_siblings "HHG S5 Twins. Problem: uses natural siblings, skips half sibs"* Save Twin DOBs, used to compute twin birth order* TODO: Damian, we only want to instrument for later born twins, correct?preservekeep MCSID CM_has_later_twin_siblings Twin_DOB_Year Twin_DOB_Month CM_has_later_twin_siblingsdrop if Twin_DOB_Year == .drop if CM_has_later_twin_siblings != 1drop CM_has_later_twin_siblingsduplicates dropsort MCSIDsave "${directory}Intermediate/Later_twin_DOB_by_Family.dta", replacerestore* Save for importkeep MCSID CM_has_later_twin_siblings CM_has_twin_siblingsduplicates dropsort MCSIDsave "${directory}Intermediate/CM_with_later_born_twins.dta", replace* In dta file, each row corresponds to one MCSID*======================================================================================* Section 3: Find the birth order of cohort members* Section 3a: Prep datafile with CM DOB*=====================================================================================* Create dataset CM_DOB_by_Familyuse "${directory}Raw/MCS-Survey-5/stata11/mcs5_hhgrid.dta", cleargen CM_DOB_Month = EHCDBM00gen CM_DOB_Year = EHCDBY00keep MCSID CM_DOB_Month CM_DOB_Yearduplicates drop MCSID, forcesort MCSIDsave "${directory}Intermediate/CM_DOB_by_Family.dta", replace*======================================================================================* Section 3b: List all siblings and CM, with CM and LaterTwin DOBs for comparison*=====================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_hhgrid.dta", clearrename EHPDBM00 P_DOB_Monthrename EHPDBY00 P_DOB_Yearkeep MCSID P_DOB_Month P_DOB_Year EHCREL00* Keep only natural siblings and CMrename EHCREL00 Person_relation_to_CMdrop if Person_relation_to_CM != 11 & Person_relation_to_CM != 96drop Person_relation_to_CM* Could include with natural siblings, adopted siblings, and foster siblings* Could also check if the siblings still live in same household* Merge in CM and LaterTwin DOB, matching each MCSIDsort MCSIDmerge MCSID using "${directory}Intermediate/CM_DOB_by_Family.dta" "${directory}Intermediate/Later_twin_DOB_by_Family.dta"*======================================================================================* Section 3c: Find the birth order of CM*=====================================================================================gen sibling_older_than_CM = 0replace sibling_older_than_CM = 1 if P_DOB_Year < CM_DOB_Year & P_DOB_Year != .replace sibling_older_than_CM = 1 if P_DOB_Year == CM_DOB_Year & P_DOB_Month < CM_DOB_Month & P_DOB_Year != .* TODO: There are some cases where this is impossible (ie, not 9 mo in between)* edit if P_DOB_Year == CM_DOB_Year & P_DOB_Month < CM_DOB_Month & P_DOB_Year != .* Sum over all older siblingsegen CM_older_siblings = sum( sibling_older_than_CM), by( MCSID )gen CM_birth_order = CM_older_siblings + 1label var CM_birth_order "HHG S5 CM Birth order. Prob: does not include half sibs from mother"*======================================================================================* Section 3d: Find the birth order of non-CM LaterTwins*=====================================================================================gen sibling_older_than_LaterTwin = 0replace sibling_older_than_LaterTwin = 1 if P_DOB_Year < Twin_DOB_Year & P_DOB_Year != . & Twin_DOB_Year != .replace sibling_older_than_LaterTwin = 1 if P_DOB_Year == Twin_DOB_Year & P_DOB_Month < Twin_DOB_Month & P_DOB_Year != . & Twin_DOB_Year != .* Sum over all older siblingsegen LaterTwin_older_siblings = sum( sibling_older_than_LaterTwin), by( MCSID )gen LaterTwin_birth_order = .replace LaterTwin_birth_order = LaterTwin_older_siblings + 1 if Twin_DOB_Year != .label var LaterTwin_birth_order "HHG S5 Later Tiwns birth order. Prob: does not include half sibs from mother"* Test it out:drop _merge*sort MCSID P_DOB_Year* edit if LaterTwin_birth_order != .*======================================================================================* Section 3e: Count number of natural children in each family*======================================================================================egen fertility_count_by_nat_siblings = count(P_DOB_Year), by( MCSID )label var fertility_count_by_nat_siblings "Fertility: Nat sibs + CMs. HHG S5. Does not include half sibs from mother"keep MCSID CM_birth_order LaterTwin_birth_order fertility_count_by_nat_siblings CM_DOB_Month CM_DOB_Yearduplicates dropsort MCSIDsave "${directory}Intermediate/CM_birth_order_and_sibling_count.dta", replace* Data notes: Each row corresponds to one MCSID* In the event on non-singleton births, this dataset will give the birth order of the first