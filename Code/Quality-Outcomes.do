*=================================================================================* Section 0: Directories and Setup*=================================================================================vers 10.1 clear allset more offglobal directory /Users/pedm/Documents/jobs/Damian-Clarke/Data/*======================================================================================* Section 1: EVSTSCO Verbal Score (from child survey S5)*=====================================================================================use "${directory}Raw/MCS-Survey-5/stata11/mcs5_cm_asssessment.dta", clearkeep MCSID ECCNUM00 EVSTSCOrename ECCNUM00 CMNUMrename EVSTSCO Quality_EVSTSCOreplace Quality_EVSTSCO =. if Quality_EVSTSCO <=0sort MCSID CMNUMsave "${directory}Intermediate/CM_quality_outcomes.dta", replace*======================================================================================* Section 2: NFER Number Skills, BAS Word Reading, BAS Pattern Construction (Survey 4)*=====================================================================================use "${directory}Raw/MCS-Survey-4/stata9_se/mcs4_assessment_final.dta"rename mcsid MCSIDrename dccnum00 CMNUMrename dcagem00 CM_age_interview4rename dcnsco00 Quality_Number_Skillsrename dcwrab00 Quality_Word_Readingrename dcwrsd00 Quality_Word_Reading_Standardrename dcpcab00 Quality_Pattern_Constructionrename dcpcts00 Quality_Pattern_Constr_Treplace Quality_Number_Skills = . if Quality_Number_Skills < 0replace Quality_Word_Reading = . if Quality_Word_Reading < 0replace Quality_Word_Reading_Standard = . if Quality_Word_Reading_Standard < 0replace Quality_Pattern_Construction = . if Quality_Pattern_Construction < 0replace Quality_Pattern_Constr_T = . if Quality_Pattern_Constr_T < 0keep MCSID CMNUM CM_age_interview4 Quality_Number_Skills Quality_Word_Reading Quality_Word_Reading_Standard Quality_Pattern_Construction Quality_Pattern_Constr_Tsort MCSID CMNUMsave "${directory}Intermediate/CM_quality_outcomes4.dta", replace*======================================================================================* Section 3: Quality outcomes (from parent survey)*=====================================================================================* SDQ Behavioural Development - Measure of Total Difficulties for each CM* S4 DV SDQ Total Difficulties	C1,C2,C3* ddebdta0,ddebdtb0, ddebdtc0