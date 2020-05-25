
use 	"./data/intermediate/weather_rcn_electricity.dta", clear

** Original Model, save residuals as "h_resids" **
reghdfe lmw dayc1 dayc2 dayc3 daily_lmw_lag364 daily_lmw_lag365 daily_lmw_lag371 sandy p_calc p_calc2 p_calc_w p_calc2_w rhum rhum_*, a(hxdoy hxdow hxtemp) vce(robust) res(h_resids)

** Degree Day Model, save residuals as "dd_resids" **

gen 	hdd = max(18-t_calc,0)
gen 	cdd = max(t_calc-18,0)

foreach h of numlist 0/23 {
	gen		hdd_hr_`h' = hdd if hour==`h'
	replace hdd_hr_`h' = 0 if hour!=`h'
	
	gen		cdd_hr_`h' = cdd if hour==`h'
	replace cdd_hr_`h' = 0 if hour!=`h'
}


reghdfe lmw ?dd_hr_* if tin(1jan2015 00:00,) , noa vce(robust) res(dd_resids_nofe)

reghdfe lmw ?dd_hr_* if tin(1jan2015 00:00,) , a(dow hour) vce(robust) res(dd_resids_fe1)

reghdfe lmw ?dd_hr_* if tin(1jan2015 00:00,) , a(hxdoy hxdow hour) vce(robust) res(dd_resids_fe2)

save 	"./data/intermediate/resids_rcn.dta", replace

zipfile "./data/intermediate/resids_rcn.dta", saving("./data/processed/resids_rcn.dta", replace)

** Set up variables to help with analysis **

gen 	wktime = dow(dofc(time))*24 + hh(time)

sort	time

foreach w of numlist 1/8 {
	local 	tdiff = 168*`w'
	gen		llmw_`w'w = L`tdiff'.lmw
	gen		dlmw_`w'w = lmw - L`tdiff'.lmw
}

gen			weekcounter = 0 if tin(16feb2020 00:00, 22feb2020 23:59)
replace		weekcounter = 1 if tin(23feb2020 00:00, 29feb2020 23:59)
replace		weekcounter = 2 if tin(1mar2020 00:00, 7mar2020 23:59)
replace		weekcounter = 3 if tin(8mar2020 00:00, 14mar2020 23:59)
replace		weekcounter = 4 if tin(15mar2020 00:00, 21mar2020 23:59)
replace		weekcounter = 5 if tin(22mar2020 00:00, 28mar2020 23:59)
replace		weekcounter = 6 if tin(29mar2020 00:00, 4apr2020 23:59)
replace		weekcounter = 7 if tin(5apr2020 00:00, 11apr2020 23:59)
replace		weekcounter = 8 if tin(12apr2020 00:00, 18apr2020 23:59)
replace		weekcounter = 9 if tin(19apr2020 00:00, 25apr2020 23:59)
replace		weekcounter = 10 if tin(26apr2020 00:00, 2may2020 23:59)
replace		weekcounter = 11 if tin(3may2020 00:00, 9may2020 23:59)

bys weekcounter: egen avelmw = mean(lmw) if !mi(weekcounter)
sort	time

gen			dlmw_ave = lmw - avelmw

** Standard Graphs in Raw Demand **

twoway (scatter lmw wktime if tin(16feb2020 00:00, 22feb2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(black) mc(black)) || ///
		(scatter lmw wktime if tin(23feb2020 00:00, 29feb2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs3) mc(gs3)) || ///
		(scatter lmw wktime if tin(1mar2020 00:00, 7mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs6) mc(gs6)) || ///
		(scatter lmw wktime if tin(8mar2020 00:00, 14mar2020 23:59), m(O) msize(tiny) c(l) lp(dash) lw(thin) lc("168 117 117") mc("186 117 117")) || ///
		(scatter lmw wktime if tin(15mar2020 00:00, 21mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 97 97") mc("186 97 97"))  || ///
		(scatter lmw wktime if tin(22mar2020 00:00, 28mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 77 77") mc("186 77 77"))  || ///
		(scatter lmw wktime if tin(29mar2020 00:00, 4apr2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 57 57") mc("186 57 57"))  || ///
		(scatter lmw wktime if tin(5apr2020 00:00, 11apr2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 27 27") mc("186 27 27")) || ///
		(scatter lmw wktime if tin(12apr2020 00:00, 18apr2020 23:59), m(Oh) msize(smal) c(l) lp(solid) lw(thin) lc(dkorange) mc(dkorange)), ///
		xsc(range(0 168)) xlab(0 24 48 72 96 120 144 168) xtitle("Hour of week (Sunday 12am = 0)") ytitle("Log-MW electric demand") ///
		legend(pos(6) row(1) order(1 "2/16" 2 "2/23" 3 "3/1" 4 "3/8" 5 "3/15" 6 "3/22" 7 "3/29" 8 "4/5" 9 "4/12"))

*graph export "./output/weekly.png", replace
		
twoway (scatter dlmw_1w wktime if tin(23feb2020 00:00, 29feb2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs3) mc(gs3)) || ///
		(scatter dlmw_2w wktime if tin(1mar2020 00:00, 7mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs6) mc(gs6)) || ///
		(scatter dlmw_3w wktime if tin(8mar2020 00:00, 14mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 117 117") mc("186 117 117")) || ///
		(scatter dlmw_4w wktime if tin(15mar2020 00:00, 21mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 97 97") mc("186 97 97"))  || ///
		(scatter dlmw_5w wktime if tin(22mar2020 00:00, 28mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 77 77") mc("186 77 77"))  || ///
		(scatter dlmw_6w wktime if tin(29mar2020 00:00, 4apr2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 57 57") mc("186 57 57"))  || ///
		(scatter dlmw_7w wktime if tin(5apr2020 00:00, 11apr2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 27 27") mc("186 27 27")) || ///
		(scatter dlmw_8w wktime if tin(12apr2020 00:00, 18apr2020 23:59), m(Oh) msize(small) c(l) lp(solid) lw(thin) lc(dkorange) mc(dkorange)), ///
		yline(0, lc(black) lp(solid)) xsc(range(0 168)) xlab(0 24 48 72 96 120 144 168) xtitle("Hour of week (Sunday 12am = 0)") ytitle("Log deviation MW from same hour week" "referenced to week of Feb 16, 2020") yscale(titlegap(*-30)) ///
		legend(pos(6) row(1) order(1 "2/23" 2 "3/1" 3 "3/8" 4 "3/15" 5 "3/22" 6 "3/29" 7 "4/5" 8 "4/12"))
		
*graph export "./output/weekly_dev.png", replace

twoway (scatter dlmw_ave wktime if tin(16feb2020 00:00, 22feb2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(black) mc(black)) || ///
		(scatter dlmw_ave wktime if tin(23feb2020 00:00, 29feb2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs3) mc(gs3)) || ///
		(scatter dlmw_ave wktime if tin(1mar2020 00:00, 7mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs6) mc(gs6)) || ///
		(scatter dlmw_ave wktime if tin(8mar2020 00:00, 14mar2020 23:59), m(O) msize(tiny) c(l) lp(dash) lw(thin) lc("168 117 117") mc("186 117 117")) || ///
		(scatter dlmw_ave wktime if tin(15mar2020 00:00, 21mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 97 97") mc("186 97 97"))  || ///
		(scatter dlmw_ave wktime if tin(22mar2020 00:00, 28mar2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 77 77") mc("186 77 77"))  || ///
		(scatter dlmw_ave wktime if tin(29mar2020 00:00, 4apr2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 57 57") mc("186 57 57"))  || ///
		(scatter dlmw_ave wktime if tin(5apr2020 00:00, 11apr2020 23:59), m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 27 27") mc("186 27 27")) || ///
		(scatter dlmw_ave wktime if tin(12apr2020 00:00, 18apr2020 23:59), m(Oh) msize(smal) c(l) lp(solid) lw(thin) lc(dkorange) mc(dkorange)), ///
		xsc(range(0 168)) xlab(0 24 48 72 96 120 144 168) xtitle("Hour of week (Sunday 12am = 0)") ytitle("Log-MW electric demand" "Demeaned within week") ///
		legend(pos(6) row(1) order(1 "2/16" 2 "2/23" 3 "3/1" 4 "3/8" 5 "3/15" 6 "3/22" 7 "3/29" 8 "4/5" 9 "4/12")) yscale(titlegap(*-10))

*graph export "./output/weekly_wkdemean.png", replace
		

** RESIDUALIZED

twoway (scatter h_resids wktime if weekcounter==0, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(black) mc(black)) || ///
		(scatter h_resids wktime if weekcounter==1, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs3) mc(gs3)) || ///
		(scatter h_resids wktime if weekcounter==2, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs6) mc(gs6)) || ///
		(scatter h_resids wktime if weekcounter==3, m(O) msize(tiny) c(l) lp(dash) lw(thin) lc("168 117 117") mc("186 117 117")) || ///
		(scatter h_resids wktime if weekcounter==4, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 97 97") mc("186 97 97"))  || ///
		(scatter h_resids wktime if weekcounter==5, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 77 77") mc("186 77 77"))  || ///
		(scatter h_resids wktime if weekcounter==6, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 57 57") mc("186 57 57"))  || ///
		(scatter h_resids wktime if weekcounter==7, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 27 27") mc("186 27 27")) || ///
		(scatter h_resids wktime if weekcounter==8, m(Oh) msize(smal) c(l) lp(solid) lw(thin) lc(dkorange) mc(dkorange)), ///
		xsc(range(0 168)) xlab(0 24 48 72 96 120 144 168) xtitle("Hour of week (Sunday 12am = 0)") ytitle("Log-MW electric demand") ///
		legend(pos(6) row(1) order(1 "2/16" 2 "2/23" 3 "3/1" 4 "3/8" 5 "3/15" 6 "3/22" 7 "3/29" 8 "4/5" 9 "4/12"))


twoway (scatter h_resids wktime if weekcounter==0, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(black) mc(black)) || ///
		(scatter h_resids wktime if weekcounter==2, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs3) mc(gs3)) || ///
		(scatter h_resids wktime if weekcounter==4, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc(gs6) mc(gs6)) || ///
		(scatter h_resids wktime if weekcounter==6, m(O) msize(tiny) c(l) lp(dash) lw(thin) lc("168 117 117") mc("186 117 117")) || ///
		(scatter h_resids wktime if weekcounter==8, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 97 97") mc("186 97 97"))  || ///
		(scatter h_resids wktime if weekcounter==10, m(O) msize(tiny) c(l) lp(solid) lw(thin) lc("168 77 77") mc("186 77 77"))  || ///
		(scatter h_resids wktime if weekcounter==11, m(Oh) msize(smal) c(l) lp(solid) lw(thin) lc(dkorange) mc(dkorange)), ///
		xsc(range(0 168)) xlab(0 24 48 72 96 120 144 168) xtitle("Hour of week (Sunday 12am = 0)") ytitle("Log-MW electric demand") ///
		legend(pos(6) row(1) order(1 "2/16" 2 "3/1" 3 "3/15" 4 "3/29" 5 "4/12" 6 "4/26" 7 "5/3"))

graph export "./output/resids_hourlybyweek.png", replace