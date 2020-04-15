local 	lastday "`1'" 

use 	"./data/intermediate/weather_rcn_electricity.dta", clear


gen 	wktime = dow(dofc(time))*24 + hh(time)

foreach w of numlist 1/8 {
	local 	tdiff = 168*`w'
	gen		llmw_`w'w = L`tdiff'.lmw
	gen		dlmw_`w'w = lmw - L`tdiff'.lmw
}


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

graph export "./output/weekly.png", replace
		
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
		
graph export "./output/weekly_dev.png", replace

clear

