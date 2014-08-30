Millennium Cohort Study Quantity-Quality Tradeoff

********************************************************************************
**** How to Read Regression Results
********************************************************************************

Let's look at one example: Results/Outreg/IV/DataV2-Girls-IncludeMissing.xls

Columns 1-12 are the estimates for the two_plus subsample
Columns 13-24 are estimates for the three_plus subsample
Columns 25-36 are estimates for the four_plus subsample
(four_plus is probably unnecessary, but occasionally significant)

All IV results are saved in that manner. OLS estimates follow a similar format, but due to the addition of birth order dummies as controls, there is one extra columns for each outcome variable in each subsample. 

********************************************************************************
**** Definitions
********************************************************************************

OmitMissing: drop all observations with missing values in the controls

IncludeMissing: account for missing values by creating a zero, and a var_missing dummy for each missing control variable.

DataV1: [The dataset used for my original estimates.] The two datasets differ in how birth-order is calculated. In both cases, this must be calculated by looking at a grid of household members, called HHGrid in the MCS. In DataV1, birth-order is calculated based on natural-siblings, ignoring half-siblings. Meanwhile, fertility is computed using both natural-siblings and half-siblings from the mother of the index child.

DataV2: [In my opinion, more reliable.] In DataV2, both measures include half siblings, and multiple versions of HHGrid are merged together. It seemed important that I use the same method for computing birth order and fertility, as it this helps prevent error in instrument and the dependent variable.

DHSControlsOnly: Here we try to use only the controls available in the DHS. This excludes controls such as income, cigarette count before birth, weekly alcohol consumption before birth, and complications during pregnancy. In all cases where DHSControlsOnly is not specified, then these controls are used. In that situation, income enters the equation through dummy variables (as it is measured by bracket.) The remaining controls are included linearly. 

EffectSizes: All outcome variables are scaled and transformed, with a mean of zero and standard deviation of one.

********************************************************************************
**** Comments
********************************************************************************

I have more confidence in estimates from DataV2. The important change to observe is when we go from OmitMissing to IncludeMissing, as this is how we seemed to lose significance. However as Damian points out, there are cases where this significance holds for girls but not boys.

One other way that I would like to test the validity of DataV2 is by looking at the OLS estimates and checking if bias is in the direction we expect. If I understand correctly, that was one thing that seemed off about the estimates of dataset v1.

I created DataV2, due to concern about measurement error in birth order and fertility, caused by half children. The MCS dataset does not directly say whether half siblings are of the same mother as the index child. It does say how half siblings relate to the mother, but there is some measurement error there. To see how much this matters, I think I'll flag all families where fertility or birth order might be incorrect, then exclude them from the regression. I've also read a bit about using eivreg, but it seems not to work on the instrument (which is where we need it.)

********************************************************************************
**** Folder Structure
********************************************************************************

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
	...same...
/IV-EffectSizes
	...same...
/OLS-EffectSizes
	...same...
/Summary
	DataV1-All-IncludeMissing
	DataV1-OLSsample-IncludeMissing
	DataV1-IVTwoPlus-IncludeMissing
	...

********************************************************************************
**** To Replicate Results
********************************************************************************
These results can be replicated by downloading the code from:
https://github.com/pedm/MCS-QQ
The file Loop-QQ-Regressions.do will produce the final datasets from raw MCS files. 
It then runs all regressions contained here, producing the output in this folder. 
All questions can be sent to pedm [at] uchicago [dot] edu.

