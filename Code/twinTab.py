# twinTabs.py v 2.0.0      damiancclarke, pedm             yyyy-mm-dd:2014-09-03
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#

import re
import os
import locale
from pprint import pprint
locale.setlocale(locale.LC_ALL, 'en_US')
from HTMLParser import HTMLParser

class MLStripper(HTMLParser):
    def __init__(self):
        self.reset()
        self.fed = []
    def handle_data(self, d):
        self.fed.append(d)
    def get_data(self):
        return ''.join(self.fed)

def strip_tags(html):
    s = MLStripper()
    s.feed(html)
    return s.get_data()

ftype = 'tex'
print('\n\nHey. The script is making %s files \n' %(ftype))

#==============================================================================
#== (1a) File names (comes from QQ-Regressions.do)
#==============================================================================
Results  = "/Users/pedm/Documents/jobs/Damian-Clarke/Results/Outreg/"
Tables   = "/Users/pedm/Documents/jobs/Damian-Clarke/Tables/"

QDataVs = ["DataV2", "DataV1"]
QVars = ["Verbal Similarities", "Number Skills", "Word Reading", "Pattern Construction", "Help Reading Freq", "Help Writing Freq", "Proactive School Selection"]
QRows = ["All IncludeMissing", "All OmitMissing", "Girls IncludeMissing", "Girls OmitMissing", "Boys IncludeMissing", "Boys OmitMissing"]

base = 'All.xls'
lowi = 'LowIncome.xls'
midi = 'MidIncome.xls'
thre = 'Desire_IV_reg_all.xls'
twIV = 'Base_IV_twins.xls'
adjf = 'ADJAll.xls'

gend = ['Girls.xls','Boys.xls']
genl = ['gendFLow.xls','gendMLow.xls']
genm = ['gendFMid.xls','gendMMid.xls']
gent = ['gendFWithTwin.xls','gendMWithTwin.xls']
gena = ['ADJGirls.xls','ADJBoys.xls']
fgen = ['Girls_first.xls','Boys_first.xls']
fgna = ['ADJGirls_first.xls','ADJBoys_first.xls']

firs = 'All_first.xls'
flow = 'LowIncome_first.xls'
fmid = 'MidIncome_first.xls'
ftwi = 'Base_IV_twins_firststage.xls'
fadj = 'ADJAll_first.xls'
fdes = 'Desire_IV_firststage_reg_all.xls'

ols  = "QQ_ols.txt"
bala = "Balance_mother.tex"
twin = "Twin_Predict.xls"
samp = "Samples.txt"
summ = "Summary.txt"
sumc = "SummaryChild.txt"
sumf = "SummaryMortality.txt"
coun = "Count.txt"
dhss = "Countries.txt"

conl = "ConleyResults.txt"
imrt = "PreTwinTest.xls"

os.chdir(Results+'IV/')

#==============================================================================
#== (1b) Options (tex or csv out)
#==============================================================================
if ftype=='tex':
    dd   = "&"
    dd1  = "&\\begin{footnotesize}"
    dd2  = "\\end{footnotesize}&\\begin{footnotesize}"
    dd3  = "\\end{footnotesize}"
    end  = "tex"
    foot = "$^{*}$p$<$0.1; $^{**}$p$<$0.05; $^{***}$p$<$0.01"
    ls   = "\\\\"
    mr   = '\\midrule'
    hr   = '\\hline'
    tr   = '\\toprule'
    br   = '\\bottomrule'
    mc1  = '\\multicolumn{'
    mcsc = '}{l}{\\textsc{'
    mcbf = '}{l}{\\textbf{'    
    mc2  = '}}'
    twid = ['5','8','4','5','9','9','4','6','10','7','12','6']
    tcm  = ['}{p{10.0cm}}','}{p{17.8cm}}','}{p{10.4cm}}','}{p{11.6cm}}',
            '}{p{13.8cm}}','}{p{14.2cm}}','}{p{12.1cm}}','}{p{13.8cm}}',
            '}{p{18.0cm}}','}{p{12.8cm}}','}{p{19.2cm}}','}{p{10.0cm}}']
    mc3  = '{\\begin{footnotesize}\\textsc{Notes:} '
    lname = "Fertility$\\times$desire"
    tname = "Twin$\\times$desire"
    tsc  = '\\textsc{' 
    ebr  = '}'
    R2   = 'R$^2$'
    mi   = '$\\'
    mo   = '$'
    lineadd = '\\begin{footnotesize}\\end{footnotesize}&'*6+ls
    lA   = '\\begin{footnotesize}\\end{footnotesize}&'*9+'\\begin{footnotesize}\\end{footnotesize}'+ls
    lA2  = '\\begin{footnotesize}\\end{footnotesize}&'*11+'\\begin{footnotesize}\\end{footnotesize}'+ls

    hs   = '\\hspace{5mm}'

    rIVa = '\\ref{TWINtab:IVAll}'
    rIV2 = '\\ref{TWINtab:IVTwoplus}'
    rIV3 = '\\ref{TWINtab:IVThreeplus}'
    rIV4 = '\\ref{TWINtab:IVFourplus}'
    rIV5 = '\\ref{TWINtab:IVFiveplus}'
    rTwi = '\\label{TWINtab:twinreg1}'
    rSuS = '\\ref{TWINtab:sumstats}'
    rFSt = '\\ref{TWINtab:FS}'
    rCou = '\\ref{TWINtab:countries}'
    rGen = '\\ref{TWINtab:IVgend}'

elif ftype=='csv':
    dd   = ";"
    dd1  = ";"
    dd2  = ";"
    dd3  = ";"
    end  = "csv"
    foot = "* p<0.1, ** p<0.05, *** p<0.01"
    ls   = ""
    mr   = ""
    hr   = ""
    br   = ""
    tr   = ""
    mc1  = ''
    mcsc = ''
    mcbf = ''   
    mc2  = ''
    twid = ['','','','','','','','','','','','']
    tcm  = ['','','','','','','','','','','','']
    mc3  = 'NOTES: '
    lname = "Fertility*desire"
    tname = "Twin*desire"
    tsc  = '' 
    ebr  = ''
    R2   = 'R-squared'
    mi   = ''
    mo   = ''
    lineadd = ''
    lA   = '\n'
    lA2  = '\n'
    hs   = ''

    rIVa = '5'
    rIV2 = '5'
    rIV3 = '6'
    rIV4 = '12'
    rIV5 = '13'
    rTwi = '11'
    rSuS = '1'
    rFSt = '15'
    rCou = '10'
    rGen = '14'

#==============================================================================
#== (2) Function to return fertilility beta and SE for IV tables
#==============================================================================
def plustable(ffile,n1,n2,searchterm,depvar,alt,n3):
    # I no longer use n1 n2 or n3, but keep them in case later needed
    beta = []
    se   = []
    N    = []
    v    = []
    cols = []

    # Excel files produced by stata v10.1 only have one line
    f = open(ffile, 'r').readlines()[0].split('</Row><Row>')

    for i, line in enumerate(f):
        if re.search("VARIABLES", line):
            v.append(i)
        if re.search(searchterm, line):
            beta.append(i)
            se.append(i+1)
        if re.search("Observations", line):
            N.append(i)

    colTitles = f[v[0]].split('</Cell>')
    for i, col in enumerate(colTitles):
		if re.search(depvar, col):
			cols.append(i)

    TB = []
    TS = []
    TN = []
    OU = []

    for n in cols:
		TB.append(strip_tags(f[beta[0]].split('</Cell>')[n]))
		TS.append(strip_tags(f[se[0]].split('</Cell>')[n]))
		TN.append(strip_tags(f[N[0]].split('</Cell>')[n]))

    return TB, TS, TN

os.chdir(Results+'IV')
base = "DataV2-Girls-IncludeMissing.xls"
TB1, TS1, TN1 = plustable(base, 1, 4,"fert","Q_Verbal_Similarities", 'alt',1000)

print " "
print "results"
pprint(TB1)
pprint(TS1)
pprint(TN1)

#==============================================================================
#== (3) Call functions, print table for plus groups
#==============================================================================
# Removed: write 2+ 3+ and 4+ tables here. For original, see Damian's github

#==============================================================================
#== (3b) Alternate table Full IVResults
#==============================================================================
os.chdir(Results+'IV-EffectSizes')

IV2 = open(Tables+"IV-Together."+end, 'w')
for QDataV in QDataVs:
	for QVar in QVars:
		if ftype=='tex':
		    IV2.write("\\begin{landscape}\\begin{table}[htpb!]"
		    "\\caption{" + QVar + " IV Results (" + QDataV + ")}\n"
		    "\\label{TWINtab:IVAll}\n\\begin{center}"
		    "\\begin{tabular}{lcccp{2mm}cccp{2mm}ccc}\n\\toprule \\toprule \n"
		    "&\\multicolumn{3}{c}{2+}&&\\multicolumn{3}{c}{3+}&&\\multicolumn{3}{c}{4+}"
		    "\\\\ \\cmidrule(r){2-4} \\cmidrule(r){6-8} \\cmidrule(r){10-12} \n"
		    "\\textsc{" + QVar + " Z-Score}&Base&+H&+S\&H&&Base&+H&+S\&H&&Base&+H&+S\&H"
		    "\\\\ \\midrule \n"
		    +"\\begin{footnotesize}\\end{footnotesize}& \n"*11+
		    "\\begin{footnotesize}\\end{footnotesize}\\\\ \n")
		elif ftype=='csv':
		    IV2.write(";2+;;;;3+;;;;4+;;;\n"
		    "FERTILITY;Base;+H;+H&S;;Base;+H;+H&S;;Base;+H;+H&S \n")

		for QRow in QRows:
			AllB = []
			AllS = []
			AllN = []
			Out  = []

			file = QDataV + "-" + QRow.replace(" ", "-") + ".xls"
			pprint(file)
			subtitle = QRow
			varname = "ZQ_" + QVar.replace(" ", "_")
			BB, BS, BN    = plustable(file, 0, 3,'fert',varname,'normal',1000)

			AllB = dd.join(BB[0:3]) + dd + dd + dd.join(BB[3:6]) + dd + dd + dd.join(BB[6:9])
			AllS = dd.join(BS[0:3]) + dd + dd + dd.join(BS[3:6]) + dd + dd + dd.join(BS[6:9])
			AllN = dd.join(BN[0:3]) + dd + dd + dd.join(BN[3:6]) + dd + dd + dd.join(BN[6:9])

			Out.append(mc1+twid[10]+mcbf+subtitle+mc2+ls+" \n"
			"Fertility"+dd+AllB+ls+'\n'
			+dd+AllS+ls+'\n'+lA2+"Observations"+dd+AllN+ls+'\n')

			IV2.write("".join(Out))

		IV2.write('\n'+mr+mc1+twid[10]+tcm[10]+mc3+
		"The two plus subsample refers to all first born children in families with "
		"at least two births.  Three plus refers to first- and second-borns in families "
		"with at least three births, etc")
		if ftype=='tex':
		    IV2.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
		    "\\end{tabular}\\end{center}\\end{table}\\end{landscape}")

print "Complted IV Output"

#==============================================================================
#== (4) Function to return fertilility beta and SE for OLS tables
#==============================================================================
# maybe useful later - opens OLS files

#==============================================================================
#== (5) Write OLS table
#==============================================================================

#==============================================================================
#== (6) Read in balance table, fix formatting
#==============================================================================
# bali = open(Results+bala, 'r').readlines()

#==============================================================================
#== (7) Read in twin predict table, LaTeX format
#==============================================================================
# twini = open(Results+"Twin/"+twin, 'r')
# twino = open(Tables+"TwinReg."+end, 'w')

#==============================================================================
#== (8) Read in summary stats, LaTeX format
#==============================================================================
# counti = open(Results+"Summary/"+coun, 'r')

#==============================================================================
#== (9) Create Conley et al. table
#==============================================================================
# conli = open(Results+"Conley/"+conl, 'r').readlines()
# conlo = open(Tables+"Conley."+end, 'w')

#==============================================================================
#== (10) Create country list table
#==============================================================================
# dhssi = open(Results+"Summary/"+dhss, 'r').readlines()
# dhsso = open(Tables+"Countries."+end, 'w')

#==============================================================================
#== (11) Gender table
#==============================================================================
genfi = open(Results+'IV/'+gend[0],'r').readlines
genmi = open(Results+'IV/'+gend[1],'r').readlines

gendo = open(Tables+'Gender.'+end, 'w')


FB, FS, FN = plustable(Results+'IV/'+gend[0],1,13,"fert",'normal',1000)
MB, MS, MN = plustable(Results+'IV/'+gend[1],1,13,"fert",'normal',1000)


Ns = format(float(FN[0][0]), "n")+', '+format(float(MN[0][0]), "n")+', '
Ns = Ns + format(float(FN[0][3]),"n")+', '+format(float(MN[0][3]),"n")+', '
Ns = Ns + format(float(FN[0][8]),"n")+', '+format(float(MN[0][8]),"n")

if ftype=='tex':
    gendo.write("\\begin{table}[htpb!]\\caption{Q-Q IV Estimates by Gender} \n"
    "\\label{TWINtab:gend}\\begin{center}\\begin{tabular}{lcccccccc}\n"
    "\\toprule \\toprule \n"
    "&\\multicolumn{4}{c}{Females}""&\\multicolumn{4}{c}{Males}\\\\ \n" 
    "\\cmidrule(r){2-5} \\cmidrule(r){6-9} \n" 
    "&Base&Socioec&Health&Obs.&Base&Socioec&Health&Obs. \\\\ \\midrule \n"+lineadd)
elif ftype=='csv':
    gendo.write(";Females;;;Males;; \n"  
    ";Base;Socioec;Health;Obs.;Base;Socioec;Health;Obs. \n")


gendo.write(
"Two Plus "+dd+FB[0][0]+dd+FB[0][1]+dd+FB[0][2]+dd+format(float(FN[0][0]), "n")+dd
+MB[0][0]+dd+MB[0][1]+dd+MB[0][2]+dd+format(float(MN[0][0]), "n")+ls+'\n'
+dd+FS[0][0]+dd+FS[0][1]+dd+FS[0][2]+dd+dd
+MS[0][0]+dd+MS[0][1]+dd+MS[0][2]+dd+ls+'\n' + lineadd +
"Three Plus "+dd+FB[0][3]+dd+FB[0][4]+dd+FB[0][5]+dd+format(float(FN[0][3]), "n")+dd
+MB[0][3]+dd+MB[0][4]+dd+MB[0][5]+dd+format(float(MN[0][3]), "n")+ls+'\n'
+dd+FS[0][3]+dd+FS[0][4]+dd+FS[0][5]+dd+dd
+MS[0][3]+dd+MS[0][4]+dd+MS[0][5]+dd+ls+'\n'+ lineadd +
"Four Plus "+dd+FB[0][6]+dd+FB[0][7]+dd+FB[0][8]+dd+format(float(FN[0][8]), "n")+dd
+MB[0][6]+dd+MB[0][7]+dd+MB[0][8]+dd+format(float(MN[0][8]), "n")+ls+'\n'
+dd+FS[0][6]+dd+FS[0][7]+dd+FS[0][8]+dd+dd
+MS[0][6]+dd+MS[0][7]+dd+MS[0][8]+dd+ls+'\n'
#+ lineadd +
#"Five Plus &"+FB[0][9]+'&'+FB[0][10]+'&'+FB[0][11]+'&'
#+MB[0][9]+'&'+MB[0][10]+'&'+MB[0][11]+'\\\\ \n'
#"&"+FS[0][9]+'&'+FS[0][10]+'&'+FS[0][11]+'&'
#+MS[0][9]+'&'+MS[0][10]+'&'+MS[0][11]+'\\\\ \n' 
+mr+mc1+twid[5]+tcm[5]+mc3+
"Female or male refers to the gender of the index child of the regression. \n"
"All regressions include full controls including socioeconomic and maternal "
"health variables.  The full lis of controls are available in \n"
"the notes to table "+rIVa+".  Full IV results for male and "
"female children are presented in table "+rGen+". Standard errors " 
"are clustered \n by mother."+foot+"\n")
if ftype=='tex':
    gendo.write("\\end{footnotesize}} \\\\ \\bottomrule \n"
    "\\end{tabular}\\end{center}\\end{table}")

gendo.close()


#==============================================================================
#== (12) IMR Test table
#==============================================================================
# imrti = open(Results+"New/"+imrt, 'r').readlines()
# imrto = open(Tables+"IMRtest."+end, 'w')

#==============================================================================
#== (14) First stage table
#==============================================================================
# fstao = open(Tables+"firstStage."+end, 'w')
# os.chdir(Results+'IV')

#==============================================================================
#== (14) Gender full IV
#==============================================================================
genio = open(Tables+'GenderIV.'+end, 'w')

AllB = []
AllS = []
AllN = []
LowB = []
LowS = []
LowN = []
MidB = []
MidS = []
MidN = []
TwiB = []
TwiS = []
TwiN = []
AdjB = []
AdjS = []
AdjN = []

FirB = []
FirS = []
AFiB = []
AFiS = []

for gg in [0,1]:
    BB, BS, BN    = plustable(gend[gg], 1, 10,'fert','normal',1000)
    LB, LS, LN    = plustable(genl[gg], 1, 10,'fert','normal',1000)
    MB, MS, MN    = plustable(genm[gg], 1, 10,'fert','normal',1000)
    TB, TS, TN    = plustable(gent[gg], 1, 10,'fert','normal',1000)
    AB, AS, AN    = plustable(gena[gg], 1, 10,'ADJfert','normal',1000)
    
    AllB.append(dd + BB[0][2] + dd + BB[0][5] + dd + BB[0][8])
    AllS.append(dd + BS[0][2] + dd + BS[0][5] + dd + BS[0][8])
    AllN.append(dd + BN[0][2] + dd + BN[0][5] + dd + BN[0][8])
    LowB.append(dd + LB[0][2] + dd + LB[0][5] + dd + LB[0][8])
    LowS.append(dd + LS[0][2] + dd + LS[0][5] + dd + LS[0][8])
    LowN.append(dd + LN[0][2] + dd + LN[0][5] + dd + LN[0][8])
    MidB.append(dd + MB[0][2] + dd + MB[0][5] + dd + MB[0][8])
    MidS.append(dd + MS[0][2] + dd + MS[0][5] + dd + MS[0][8])
    MidN.append(dd + MN[0][2] + dd + MN[0][5] + dd + MN[0][8])
    TwiB.append(dd + TB[0][2] + dd + TB[0][5] + dd + TB[0][8])
    TwiS.append(dd + TS[0][2] + dd + TS[0][5] + dd + TS[0][8])
    TwiN.append(dd + TN[0][2] + dd + TN[0][5] + dd + TN[0][8])
    AdjB.append(dd + AB[0][2] + dd + AB[0][5] + dd + AB[0][8])
    AdjS.append(dd + AS[0][2] + dd + AS[0][5] + dd + AS[0][8])
    AdjN.append(dd + AN[0][2] + dd + AN[0][5] + dd + AN[0][8])

    for num in ['two','three','four']:
        searcher='twin\_'+num+'\_fam'
        Asearcher='ADJtwin\_'+num+'\_fam'

        FSB, FSS, FSN    = plustable(fgen[gg], 1, 4,searcher,'normal',1000)
        FAB, FAS, FAN    = plustable(fgna[gg], 1, 4,searcher,'normal',1000)


        FirB.append(dd + FSB[0][2])
        FirS.append(dd + FSS[0][2])
        AFiB.append(dd + FAB[0][2])
        AFiS.append(dd + FAS[0][2])


if ftype=='tex':
    genio.write("\\begin{table}[!htbp] \\centering \n"
    "\\caption{Instrumental Variables Estimates: Female and Male Children} \n"
    "\\label{TWINtab:IVgend} \n"
    "\\begin{tabular}{lcccccc} \\toprule \\toprule \n"
    "&\\multicolumn{3}{c}{Females}""&\\multicolumn{3}{c}{Males}\\\\ \n" 
    "\\cmidrule(r){2-4} \\cmidrule(r){5-7} \n" 
    "&2+&3+&4+&2+&3+&4+ \\\\ \\midrule \n")
elif ftype=='csv':
    genio.write(";Females;;;Males;; \n"  
    ";2+;3+;4+;2+;3+;4+ \n")
genio.write(dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All"+mc2+ls+" \n"
"Fertility"+AllB[0]+AllB[1]+ls+"\n"
""         +AllS[0]+AllS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Low-Income Countries"+mc2+ls+" \n"
"Fertility"+LowB[0]+LowB[1]+ls+"\n"
""         +LowS[0]+LowS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Middle-Income Countries"+mc2+ls+" \n"
"Fertility"+MidB[0]+MidB[1]+ls+"\n"
""         +MidS[0]+MidS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Adjusted Fertility"+mc2+ls+" \n"
"Fertility"+AdjB[0]+AdjB[1]+ls+"\n"
""         +AdjS[0]+AdjS[1]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Twins and Pre-Twins"+mc2+ls+" \n"
"Fertility"+TwiB[0]+TwiB[1]+ls+"\n"
""         +TwiS[0]+TwiS[1]+ls+ "\n"+mr

+mc1+twid[0]+mcsc+"First Stage"+mc2+ls+" \n"
+dd+dd+dd+dd+ls+"\n"
+mc1+twid[9]+mcbf+"All"+mc2+ls+" \n"
"Twin"+FirB[0]+FirB[1]+FirB[2]+FirB[3]+FirB[4]+FirB[5]+ls+"\n"
""         +FirS[0]+FirS[1]+FirS[2]+FirS[3]+FirS[4]+FirS[5]+ls+ "\n"
+dd+dd+dd+dd+ls+"\n" 

+mc1+twid[9]+mcbf+"Adjusted Fertility"+mc2+ls+" \n"
"Twin"+AFiB[0]+AFiB[1]+AFiB[2]+AFiB[3]+AFiB[4]+AFiB[5]+ls+"\n"
""         +AFiS[0]+AFiS[1]+AFiS[2]+AFiS[3]+AFiS[4]+AFiS[5]+ls+ "\n"

+'\n'+mr+mc1+twid[9]+tcm[9]+mc3+
"Each cell presents the coefficient from a 2SLS regression of standardised "
"educational attainment on fertility.  2+, 3+ and 4+ refer to the birth "
"orders of children included in the regression.  For a full description of "
"these groups see table "+rIVa+".  Each regression includes full controls "
"including maternal health and socioeconomic variables.  The sample is made "
"up of all children aged between 6-18 years from families in the DHS who "
"fulfill birth order and gender requirements indicated in the header.  "
"Standard errors are clustered by mother."
+foot+" \n")

if ftype=='tex':
    genio.write("\\end{footnotesize}}\n"+ls+br+
    "\\normalsize\\end{tabular}\\end{table} \n")
genio.close()

#==============================================================================
#== (15) Sample table
#==============================================================================

print "Terminated Correctly."