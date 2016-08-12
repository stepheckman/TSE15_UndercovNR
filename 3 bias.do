
use sim_results, replace

/* include sims where X,Z same var are (X=Z for all cases)
append using xz, gen(new)
* flag w p1=99
replace p1 = 99 if new
replace p1factor = 99 if new
drop new
*/

li p? bias_better absbiasdiff
 

gen scen = 1 if p3==2 & p4==2 & p5==2 & p6==2 & p1>0
replace scen = 2 if p3==-2 & p4==-2 & p5==2 & p6==2 & p1>0
replace scen = 3 if p3==-2 & p4==2 & p5==2 & p6==2 & p1>0
replace scen = 4 if p3==.2 & p4==.2 & p5==.2 & p6==.2 & p1>0
replace scen = 5 if p3==2 & p4==2 & p5==2 & p6==2 & p1<0
replace scen = 6 if p3==-2 & p4==-2 & p5==2 & p6==2 & p1<0
replace scen = 7 if p3==-2 & p4==2 & p5==2 & p6==2 & p1<0
replace scen = 8 if p3==.2 & p4==.2 & p5==.2 & p6==.2 & p1<0
lab def scen 1 "Scenario 1" ///
	2 "Scenario 2" ///
	3 "Scenario 3" ///
	4 "Scenario 4" ///
	5 "Scenario 5" ///
	6 "Scenario 6" ///
	7 "Scenario 7" ///
	8 "Scenario 8" 
lab val scen scen

tab scen
tab scen p1

sort scen
li scen p? crdiff rrdiff absbiasdiff if !mi(scen) & p2 == 4 & p1 == .5

* results when p1=1 are same as when X,Z same var (p1=99)
* so not including them here (just make graph crowded)
tw (scatter absbiasdiff crdiff if p1factor==50, connect(l) sort(p2)) || ///
	(scatter absbiasdiff crdiff if p1factor==100, connect(l) sort(p2)), ///
	scheme(s1mono) by(scen, leg(on) note(" ") cols(4)) ///
	leg(lab(1 "{&rho}=0.5") lab(2 "{&rho}=1") lab(3 "X,Z same")) ///
	ytitle("Change in Absolute Bias, in % points") 
gr export "$results\scens.tif", replace width(1600)

li scen p? if !mi(scen)

mean bias_better, over(betas_samesign)
	

exit
