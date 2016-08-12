
use sim_results, replace

d
sum

tab rate_better, mis

* p1 (rho) relates very closely to corr(cpa, rpa)
scatter corr_cpa_rpa p1


* these params don't influence rates, so hold them constant
keep if p3==.2 & p4==.2

keep if gammaX == gammaZ
	
/* understand how input parameters work

* p1 < 0 -- curves slope up as p2 increases, no tradeoff
* p1 > 0 -- curves slop down as p2 increases, tradeoff 
* though there are some exceptions
tab p1 tradeoff, mis
tw scatter rrdiff crdiff, by(p1) mlab(p2)

* p5 controls how p2 translates into crdiff and rrdiff
* spread
tw scatter rrdiff crdiff, by(p2) mlab(p5)

* p5, p6 control how p2 translates into crdiff and rrdiff
* spread
tw scatter rrdiff crdiff, by(p5 p6)
*/

egen gX = axis(gammaX), rev label(gammaX)
egen gZ = axis(gammaZ), rev label(gammaZ)
egen byvar = axis(p1neg gX gZ)
lab def byvar 1 "{&rho} > 0, {&gamma}X {&gamma}Z high" ///
	2 "{&rho} > 0, {&gamma}X {&gamma}Z low" ///
	3 "{&rho} < 0, {&gamma}X {&gamma}Z high" ///
	4 "{&rho} < 0, {&gamma}X {&gamma}Z low", replace
lab val byvar byvar
tab byvar p1

* w rescaled y axes
/*tw (scatter rrdiff crdiff if p1factor==50, connect(l) sort(p2)) || ///
	(scatter rrdiff crdiff if p1factor==100, connect(l) sort(p2)), ///
	scheme(s1mono) by(byvar, leg(on) note(" ") yrescale) ///
	leg(lab(1 "|cov(X,Z)| low") lab(2 "|cov(X,Z)| high"))
gr export "$results\correlation_rates1.png", width(1600) replace
*/

tw (scatter rrdiff crdiff if p1factor==50, connect(l) sort(p2)) || ///
	(scatter rrdiff crdiff if p1factor==100, connect(l) sort(p2)), ///
	scheme(s1mono) by(byvar, leg(on) note(" ")) ///
	leg(lab(1 "{&rho}=0.5") lab(2 "{&rho}=1"))
gr export "$results\correlation_rates2.tif", replace width(1600)

exit
