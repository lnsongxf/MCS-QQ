********************************************************************************
**NOTE, THE FIRST BLOCK OF CODE GENERATES VARIABLES FOR GENDER MIX
**THE IMPORTANT VARIABLES HERE ARE:
**  > id: family identifier
**  > bord: birth order within a family
**  > sex: 1 if boy, 2 if girl
**
** variables produced are:
**  > smix*: 1 if same sex in family
**  > boy*:  1 if all boy mix
**  > girl*: 1 if all girl mixes
********************************************************************************

foreach num of numlist 1(1)5 {
  gen sex`num'=sex if bord==`num'
  bys id: egen g`num'=min(sex`num')

  gen gend`num'="g" if g`num'==2
  replace gend`num'="b" if g`num'==1
  drop g`num' sex`num'
}
gen  mix1=gend1
egen mix2=concat(gend1 gend2)
egen mix3=concat(gend1 gend2 gend3)
egen mix4=concat(gend1 gend2 gend3 gend4)
egen mix5=concat(gend1 gend2 gend3 gend4 gend5)

gen boy1     = gend1=="b"
gen boy2     = gend2=="b"
gen boy3     = gend3=="b"
gen boy4     = gend4=="b"
gen boy12    = mix2=="bb"   if fert>1
gen girl12   = mix2=="gg"   if fert>1
gen boy123   = mix3=="bbb"  if fert>2
gen girl123  = mix3=="ggg"  if fert>2
gen boy1234  = mix4=="bbbb" if fert>3
gen girl1234 = mix4=="gggg" if fert>3
gen smix12   = mix2=="bb"  |mix2=="gg"   if fert>1
gen smix123  = mix3=="bbb" |mix3=="ggg"  if fert>2
gen smix1234 = mix4=="bbbb"|mix4=="gggg" if fert>3

********************************************************************************
**NOW, THE SECOND BLOCK RUNS INSTRUMENTAL VARIABLES ESTIMATES BASED ON THE ABOVE
**  The logic is described in Angrist et al (2010) from JOLE.  We want to
**  instrument with sex mix, but conditioning on the sex of all previous children
**  We thus make lists of instruments (smix*) and controls, where the controls
**  vary by the birth order, as when we are at higher birth orders we have to
**  control for additional previous sex mixes.  Angrist et al. list the precise
**  controls in each case.
**
**  We use partiy groups as in twins (2+, 3+, 4+)
********************************************************************************
mat SarganStat = J(3,1,.)
mat SarganP    = J(3,1,.)

gen int3  = (1-smix12)*boy3
gen int4a = (1-smix123)*boy3
gen int4b = (1-smix123)*boy4

local controls _country* _yb* _age* _contracep* mage mage2 agefirstbirth
local gplus two three four
local weight [pw=weight]
local se     cluster(id)

local twoSel     boy1
local threeSel   malec boy12 girl12 int3
local fourSel    malec boy12 girl12 boy123 girl123 int3 int4*
local twoInsts   boy12 girl12
local threeInsts boy123 girl123
local fourInsts  boy1234 girl1234


local jj=1
foreach n in `gplus' {
	eststo: ivreg29 quality `controls' ``n'Sel' (fert = ``n'Insts') `wt' /*
	*/ `n'_plus==1, `se' partial(`controls') savefirst savefp(f`jj')
   mat SarganStat[`jj',1] = `e(j)'
   mat SarganP[`jj',1]    = `e(jp)'

	local ++jj
}

mat list SarganStat
mat list SarganP

matrix rownames SarganStat = TwoPlus ThreePlus FourPlus
matrix rownames SarganP    = TwoPlus ThreePlus FourPlus
mat2txt, matrix(SarganStat) saving("$OUT/SarganStat.txt") format(%6.4f) replace
mat2txt, matrix(SarganP) saving("$OUT/SarganP.txt") format(%6.4f) replace

local estopt cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par))
   stats (r2 N, fmt(%9.2f %9.0g)) starlevel ("*" 0.10 "**" 0.05 "***" 0.01)

estout est1 est2 est3 using "$OUT/SexMix.xls", replace `estopt' keep(fert)
estout f1fert f2fert f3fert using "$OUT/SexMix_first.xls", replace `estopt' /*                                                                                                                                                             
*/ keep(boy1* girl1*)

estimates clear
