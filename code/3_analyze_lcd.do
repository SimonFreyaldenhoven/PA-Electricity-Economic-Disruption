local 	lastday "`1'" 

use 	"./data/intermediate/weather_lcd_electricity.dta", clear

** Initial Pictures **

scatter lmw temp, m(O) msize(vtiny) jitter(2) ytitle("Log Megawatts of Demand, Hourly")
graph export "./output/temp_demand.png", replace

twoway (scatter lmw temp if hour==0, m(o) msize(tiny) jitter(2)) || ///
		(scatter lmw temp if hour==12, m(O) msize(vtiny) jitter(2) mc(red)), ///
		leg(pos(6) row(1) lab(1 "Midnight") lab(2 "Noon")) ytitle("Log Megawatts of Demand, Hourly")
graph export "./output/temp_lcd_demand_hours.png", replace

twoway (scatter lmw temp if tin(1jan2019 00:00, 18mar2020 23:00), m(o) msize(vtiny)) || ///
		(scatter lmw temp if tin(19mar2020 00:00, `lastday' 00:00), m(O) msize(tiny)  mc(blue)), ///
		leg(pos(6) row(1) lab(1 "Before March 19, 2020") lab(2 "On or After March 19, 2020")) ytitle("Log Megawatts of Demand, Hourly")
graph export "./output/temp_lcd_sincemar19.png", replace

** Diagnostic models **

/*
reghdfe lmw dayc1 dayc2 i.t_1bina i.dow, a(hour doy2) vce(robust)
reghdfe lmw dayc1 dayc2 i.t_1bina i.dow, a(hmogr doy2) vce(robust)
reghdfe lmw dayc1 dayc2 i.t_1bina i.dow prec prec2 pmiss prec_w prec2_w, a(hmogr doy) vce(robust)
reghdfe lmw dayc1 dayc2 i.t_1bina i.dow prec prec2 pmiss prec_w prec2_w rhum*, a(hmogr doy) vce(robust)
reghdfe lmw dayc1 dayc2 i.t_1bina i.dow prec prec2 pmiss prec_w prec2_w rhum* windsp windsp2 wmiss, a(hmogr doy) vce(robust)
reghdfe lmw dayc1 dayc2 i.t_1bina i.dow prec prec2 pmiss prec_w prec2_w rhum* windsp windsp2 wmiss windm?_? windm??_?, a(hmogr doy) vce(robust)
reghdfe lmw dayc1 dayc2 i.t_1bina prec prec2 pmiss prec_w prec2_w rhum* windsp windsp2 wmiss windm?_? windm??_?, a(hxdoy hxdow) vce(robust)
reghdfe lmw daily_lmw_lag364 daily_lmw_lag371 dayc1 dayc2 i.t_1bina prec prec2 pmiss prec_w prec2_w rhum* windsp windsp2 wmiss windm?_? windm??_?, a(hxdoy hxdow) vce(robust)
*/
*=======*
		
reghdfe lmw dayc1 dayc2 sandy prec prec2 pmiss prec_w prec2_w rhum* windsp windsp2 wmiss windm?_? windm??_?, a(hxdoy hxdow hxtemp) vce(robust) res(resid1)

reghdfe lmw dayc1 dayc2 dayc3 daily_lmw_lag364 daily_lmw_lag365 daily_lmw_lag371 sandy prec prec2 pmiss prec_w prec2_w rhum* windsp windsp2 wmiss windm?_? windm??_?, a(hxdoy hxdow hxtemp) vce(robust) res(resid2)

local	bwn = 24*28
ivreghdfe lmw covid_base i.covid_day dayc1 dayc2 dayc3 daily_lmw_lag364 daily_lmw_lag365 daily_lmw_lag371 sandy prec prec2 pmiss prec_w prec2_w rhum* windsp windsp2 wmiss windm?_? windm??_?, a(hxdoy hxdow hxtemp) robust bw(`bwn') // Use ivreghdfe bc it has better SE options (HAC robust)

parmest, sa("./data/intermediate/covid_lcd", replace) list(parm estimate min95 max95 p, clean noobs)

gen date_track = dofc(time)
format date_track %td
collapse (mean) resid1 resid2, by(date_track doy)
tsset date_track

tssmooth ma resid1_sm7 = resid1, window(6 1 0)
tssmooth ma resid1_sm14 = resid1, window(13 1 0)
tssmooth ma resid1_sm28 = resid1, window(27 1 0)
tssmooth ma resid1_sm91 = resid1, window(90 1 0)
tssmooth ma resid1_sm365 = resid1, window(364 1 0)

tssmooth ma resid2_sm7 = resid2, window(6 1 0)
tssmooth ma resid2_sm14 = resid2, window(13 1 0)
tssmooth ma resid2_sm28 = resid2, window(27 1 0)
tssmooth ma resid2_sm91 = resid2, window(90 1 0)
tssmooth ma resid2_sm365 = resid2, window(364 1 0)

twoway (scatter resid1 date_track, m(O) msize(vtiny)) || ///
		(line resid1_sm7 date_track, lc(red) lp(solid) lw(vthin)) || ///
		(line resid1_sm365 date_track, lc(blue) lp(solid) lw(vthin)), ///
		leg(pos(6) row(1) lab(1 "Daily Ave") lab(2 "7-day Ave") lab(3 "365-day Ave")) ///
		ytitle("residual (daily ave), model 1") xtitle("")
graph export "./output/model1_long.png", replace
		
twoway (scatter resid2 date_track, m(O) msize(vtiny)) || ///
		(line resid2_sm7 date_track, lc(red) lp(solid) lw(vthin)) || ///
		(line resid2_sm365 date_track, lc(blue) lp(solid) lw(vthin)), ///
		leg(pos(6) row(1) lab(1 "Daily Ave") lab(2 "7-day Ave") lab(3 "365-day Ave")) ///
		ytitle("residual (daily ave), model 2") xtitle("")
graph export "./output/model2_long.png", replace

twoway (scatter resid1 date_track if tin(1jan2018, `lastday'), m(O) msize(vtiny)) || ///
		(line resid1_sm7 date_track if tin(1jan2018, `lastday'), lc(red) lp(solid) lw(vthin)) || ///
		(line resid1_sm28 date_track if tin(1jan2018, `lastday'), lc(black) lp(solid) lw(vthin)) || ///
		(line resid1_sm365 date_track if tin(1jan2018, `lastday'), lc(blue) lp(solid) lw(vthin)), ///
		leg(pos(6) row(1) lab(1 "Daily Ave") lab(2 "7-day Ave") lab(3 "28-day Ave") lab(4 "365-day Ave")) ///
		ytitle("residual (daily ave), model 1") xtitle("")
graph export "./output/model1_recent.png", replace

twoway (scatter resid2 date_track if tin(1jan2018, `lastday'), m(O) msize(vtiny)) || ///
		(line resid2_sm7 date_track if tin(1jan2018, `lastday'), lc(red) lp(solid) lw(vthin)) || ///
		(line resid2_sm28 date_track if tin(1jan2018, `lastday'), lc(black) lp(solid) lw(vthin)) || ///
		(line resid2_sm365 date_track if tin(1jan2018, `lastday'), lc(blue) lp(solid) lw(vthin)), ///
		leg(pos(6) row(1) lab(1 "Daily Ave") lab(2 "7-day Ave") lab(3 "28-day Ave") lab(4 "365-day Ave")) ///
		ytitle("residual (daily ave), model 2")	xtitle("")	
graph export "./output/model2_recent.png", replace		

twoway (line resid1_sm28 date_track  if tin(1jan2018, `lastday'), lc(red) lp(solid) lw(vthin)) || ///
	(line resid2_sm28 date_track  if tin(1jan2018, `lastday'), lc(black) lp(solid) lw(vthin)), ///
	legend(pos(6) row(1) lab(1 "Model 1, 28-day Ave") lab(2 "Model 2, 28-day Ave")) ///
		ytitle("residual (28-day Ave)")	xtitle("")		

graph export "./output/modelcomp_recent.png", replace	
