

* output by R code in same folder
use "$sim\results_rev4.dta", replace

gen simid = _n

lab var covb_mean "CR in survey B"
lab var cova_mean "CR in survey A"
lab var respb_mean "RR in survey B"
lab var respa_mean "RR in survey A"
lab var y_mean "true ybar in this pop"
lab var yb_mean "ybar estiamted from survey B"
lab var ya_mean "ybar estiamted from survey A"
lab var corr_cpb_y "corr(CPb, Y)"
lab var corr_cpa_y "corr(CPa, Y)"
lab var corr_rpb_y "corr(RPb, Y)"
lab var corr_rpa_y "corr(RPa, Y)"
lab var corr_cpa_rpa "corr(CPa, RPa)"
lab var corr_cpa_cpb "corr(CPa, CPb)"
lab var corr_cpb_rpa "corr(CPb, RPa)"
lab var p1 "cov(X,Z)"
lab var p2 "cpincrease -- how much CPs increase in survey B compared to survey A"
lab var p3 "bx -- coeff on X in reg to create Y"
lab var p4 "bz -- coeff on Z in reg to create Y"
lab var p5 "gx -- coeff on X in reg to create CP"
lab var p6 "gz -- coeff on Z in reg to create RP"

gen crdiff = (covb_mean - cova_mean)*100
gen rrdiff = (respb_mean - respa_mean)*100
gen ratea = cova_mean * respa_mean
gen rateb = covb_mean * respb_mean
gen ratediff = (rateb - ratea)*100
gen rate_better = rateb > ratea
lab var crdiff "Change in Coverage Rate, in % points"
lab var rrdiff "Change in Response Rate, in % points"
lab var ratediff "Change in Overall Rate, in % points"

gen biasa = ya_mean - y_mean
gen biasb = yb_mean - y_mean
gen absbiasa = abs(ya_mean - y_mean)
gen absbiasb = abs(yb_mean - y_mean)
gen absrelbiasa = abs(ya_mean - y_mean)/y_mean*100
gen absrelbiasb = abs(yb_mean - y_mean)/y_mean*100
gen absbiasdiff = (absbiasb-absbiasa)/10*100
gen absrelbiasdiff = absrelbiasb - absrelbiasa
gen bias_better = absbiasb < absbiasa
lab var absrelbiasa "Absolute Relative Bias in Survey A, in %"
lab var absrelbiasb "Absolute Relative Bias in Survey B, in %"
lab var absbiasdiff "Change in Absolute Relative Bias, in % points"
lab var rate_better "overall rate in B > A"
lab var bias_better "bias in B < A (in abs value)"

gen tradeoff = (crdiff > 0 & rrdiff < 0)
lab var tradeoff "CR higher, RR lower"

gen crratio = covb_mean/cova_mean
gen rrratio = respb_mean/respa_mean
gen rateratio = rateb/ratea

xtile corr10 = corr_cpa_rpa, nq(10)
xtile corr5 = corr_cpa_rpa, nq(5)

bys p1: sum corr_cpa_rpa
bys p1 p5 p6: sum corr_cpa_rpa
* unique combos of p1 p5 p6 seem to determine corr_rpa_cpa (as expected)
cap drop cor
*egen cor = group2(p1 p5 p6), sort(mean(corr_cpa_rpa)) label
egen cor = group(p1 p5 p6), label
egen cor2 = mean(corr_cpa_rpa), by(cor)
*egen cor3 = axis(cor2), label(cor2)
* very small SE
mean corr_cpa_rpa, over(cor)

gen betaX = abs(p3)
gen betaXneg = p3<0
recode betaX (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab betaX p3, mis nol

gen betaZ = abs(p4)
gen betaZneg = p4<0
recode betaZ (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab betaZ p4, mis nol

gen gammaX = p5
recode gammaX (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab gammaX p5, mis

gen gammaZ = p6
recode gammaZ (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab gammaZ p6, mis


* trouble below w rounded values
replace p1 = round(p1,.1)

lab def p1pos 1 "p1 >=0" 0 "p1 < 0"
gen p1factor = abs(p1*100)
gen p1neg = p1<0
*lab val p1neg p1neg
gen p1pos = 1-p1neg
lab val p1pos p1pos

gen betas_samesign = (p3>0 & p4>0) | (p3<0 & p4<0)
lab def lowhigh 1 "low" 2 "med" 3 "high"
lab val betaX lowhigh
lab val betaZ lowhigh
lab val gammaX lowhigh
lab val gammaZ lowhigh

d
sum



* get rid of medium values
drop if inlist(2, betaX, betaZ, gammaX, gammaZ) | inlist(-2, betaX, betaZ, gammaX, gammaZ)

drop if p1 == 0

qui:compress
save sim_results, replace

exit



* when X,Z gleich sind
use "$sim\results5", replace

gen simid = _n

lab var covb_mean "CR in survey B"
lab var cova_mean "CR in survey A"
lab var respb_mean "RR in survey B"
lab var respa_mean "RR in survey A"
lab var y_mean "true ybar in this pop"
lab var yb_mean "ybar estiamted from survey B"
lab var ya_mean "ybar estiamted from survey A"
lab var corr_cpb_y "corr(CPb, Y)"
lab var corr_cpa_y "corr(CPa, Y)"
lab var corr_rpb_y "corr(RPb, Y)"
lab var corr_rpa_y "corr(RPa, Y)"
lab var corr_cpa_rpa "corr(CPa, RPa)"
lab var corr_cpa_cpb "corr(CPa, CPb)"
lab var corr_cpb_rpa "corr(CPb, RPa)"
lab var p1 "cov(X,Z)"
lab var p2 "cpincrease -- how much CPs increase in survey B compared to survey A"
lab var p3 "bx -- coeff on X in reg to create Y"
lab var p4 "bz -- coeff on Z in reg to create Y"
lab var p5 "gx -- coeff on X in reg to create CP"
lab var p6 "gz -- coeff on Z in reg to create RP"

gen crdiff = (covb_mean - cova_mean)*100
gen rrdiff = (respb_mean - respa_mean)*100
gen ratea = cova_mean * respa_mean
gen rateb = covb_mean * respb_mean
gen ratediff = (rateb - ratea)*100
gen rate_better = rateb > ratea
lab var crdiff "Change in Coverage Rate, in % points"
lab var rrdiff "Change in Response Rate, in % points"
lab var ratediff "Change in Overall Rate, in % points"

gen biasa = ya_mean - y_mean
gen biasb = yb_mean - y_mean
gen absbiasa = abs(ya_mean - y_mean)
gen absbiasb = abs(yb_mean - y_mean)
gen absrelbiasa = abs(ya_mean - y_mean)/y_mean*100
gen absrelbiasb = abs(yb_mean - y_mean)/y_mean*100
gen absbiasdiff = (absbiasb-absbiasa)/10*100
gen absrelbiasdiff = absrelbiasb - absrelbiasa
gen bias_better = absbiasb < absbiasa
lab var absrelbiasa "Absolute Relative Bias in Survey A, in %"
lab var absrelbiasb "Absolute Relative Bias in Survey B, in %"
lab var absbiasdiff "Change in Absolute Relative Bias, in % points"
lab var rate_better "overall rate in B > A"
lab var bias_better "bias in B < A (in abs value)"

gen tradeoff = (crdiff > 0 & rrdiff < 0)
lab var tradeoff "CR higher, RR lower"

gen crratio = covb_mean/cova_mean
gen rrratio = respb_mean/respa_mean
gen rateratio = rateb/ratea

xtile corr10 = corr_cpa_rpa, nq(10)
xtile corr5 = corr_cpa_rpa, nq(5)

bys p1: sum corr_cpa_rpa
bys p1 p5 p6: sum corr_cpa_rpa
* unique combos of p1 p5 p6 seem to determine corr_rpa_cpa (as expected)
cap drop cor
*egen cor = group2(p1 p5 p6), sort(mean(corr_cpa_rpa)) label
egen cor = group(p1 p5 p6), label
egen cor2 = mean(corr_cpa_rpa), by(cor)
*egen cor3 = axis(cor2), label(cor2)
* very small SE
mean corr_cpa_rpa, over(cor)

gen betaX = abs(p3)
gen betaXneg = p3<0
recode betaX (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab betaX p3, mis nol

gen betaZ = abs(p4)
gen betaZneg = p4<0
recode betaZ (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab betaZ p4, mis nol

gen gammaX = p5
recode gammaX (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab gammaX p5, mis

gen gammaZ = p6
recode gammaZ (.2=1) (-.2=-1) (1=2) (-1=-2) (2=3) (-2=-3)
tab gammaZ p6, mis


* trouble below w rounded values
replace p1 = round(p1,.1)

lab def p1pos 1 "p1 >=0" 0 "p1 < 0"
gen p1factor = abs(p1*100)
gen p1neg = p1<0
*lab val p1neg p1neg
gen p1pos = 1-p1neg
lab val p1pos p1pos

gen betas_samesign = (p3>0 & p4>0) | (p3<0 & p4<0)
lab def lowhigh 1 "low" 2 "med" 3 "high"
lab val betaX lowhigh
lab val betaZ lowhigh
lab val gammaX lowhigh
lab val gammaZ lowhigh

d
sum

save xz, replace
