local 	lastday "`1'" 

use 	"./data/intermediate/covid_rcn", clear

gen 	covid = strpos(parm, "covid_day")
drop if covid==0

gen 	model="rcn"

destring parm, i(".covid_day" "b") replace
rename 	parm day_after_mar1
replace	day_after_mar1 = day_after_mar1 + td(1mar2020)
tsset	day_after_mar1
format 	day_after_mar1  %td

tempfile rcn_est
save "`rcn_est'", replace
clear

use 	"./data/intermediate/covid_lcd", clear

gen 	covid = strpos(parm, "covid_day")
drop if covid==0

gen 	model="lcd"

destring parm, i(".covid_day" "b") replace
rename 	parm day_after_mar1
replace	day_after_mar1 = day_after_mar1 + td(1mar2020)
tsset	day_after_mar1
format 	day_after_mar1  %td

append using "`rcn_est'"

replace day_after_mar1 = day_after_mar1+0.2 if model=="lcd"

twoway (rcap max95 min95 day_after_mar1 if tin(1mar2020, `lastday') & model=="lcd", lc(ltblue) lw(vthin)) || ///
		(scatter estimate day_after_mar1 if tin(1mar2020, `lastday') & model=="lcd", mc(ltblue) ms(Oh) c(l) lc(gray) lw(vthin) lp(solid)) || ///
		(rcap max95 min95 day_after_mar1 if tin(1mar2020, `lastday') & model=="rcn", lc(gs10) lw(vthin)) || ///
		(scatter estimate day_after_mar1 if tin(1mar2020, `lastday') & model=="rcn", mc(black) ms(Oh) c(l) lc(gray) lp(solid)), /// 
		legend(pos(6) r(2) order(2 "LCD - Daily Point Estimate" 1 " LCD - 95\% Confidence Interval" 4 "RCN - Daily Point Estimate" 3 " RCN - 95\% Confidence Interval")) ///
		xtitle("") ytitle("Estimated Daily Deviation (%)") yline(0, lp(solid) lc(black)) tline(16mar2020, lc(pink) ) tline(19mar2020, lc(red) )


graph export "./output/dailydevs_both_model2.png", replace




