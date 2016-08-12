version 14.0
set more off
clear all 

global date 20151205


global dir "C:\Users\seckman\Dropbox\papers\TSE15 Nonresponse Undercoverage\analysis"

global data "$dir\data"
global code "$dir\code"
global results "$dir\results"
global sim "$data\R simulations\"

cd "$data"


* reads data set created in R
qui do "$code\1 sim prep.do"


cap log close
log using "$results\sim results $date.smcl", replace


*****************************************
* prelim
use sim_results, replace

count

tab1 p?

sum rate_b bias_b
mean tradeoff, over(p1pos)
mean bias_b, over(tradeoff)


*****************************************
* rates
qui do "$code\2 rates.do"
	
	
*****************************************
* bias
qui do "$code\3 bias.do"


cap log close
exit
