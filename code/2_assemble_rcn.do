use 	"./data/intermediate/electricity_demand.dta", clear

gen double time = clock(datetime_beginning_utc, "MDYhm")
format time %tc
tsset time, delta(1 hour)

merge 1:1 time using "./data/intermediate/weather_rcn.dta"

drop 	year month hour

gen		year = year(dofc(time))
gen		month = month(dofc(time))
gen 	hour = hh(time)

gen 	lmw = ln(mw)
gen 	doy = doy(dofc(time))
gen 	dow = dow(dofc(time))

tab year if _merge!=3
drop	_merge
*****************************
set scheme plotplainblind

gen 	dayc1 = dofc(time) - 14610
gen		dayc2 = dayc1^2
gen		dayc3 = dayc1^3

gen 	t_1bin_alt = t_1bin+21

** Precipation **
gen		p_calc2 = p_calc^2

gen 	p_calc_w = p_calc*(t_calc>13)
gen 	p_calc2_w = p_calc2*(t_calc>13)


** Adjust for Leap Years **
gen	int doy2 = doy
replace doy2 = doy+1 if doy>59 & (year!=2000 & year!=2004 & year!=2008 & year!=2012 & year!=2016 & year!=2020)

** Relative Humidity **
gen 	rhum = rh_hr_avg
gen		rhum_mi = mi(rh_hr_avg) 
 
gen		rhum_xtsum = rhum*t_1bin_alt*(t_1bin_alt>34)
gen		rhum_xtwin = rhum*t_1bin_alt*(t_1bin_alt<34)

gen		rhum_misum = rhum_mi*(t_1bin_alt>34)
gen		rhum_miwin = rhum_mi*(t_1bin_alt<34)

replace	rhum = 0 if mi(rh_hr_avg) 
replace	rhum_xtsum = 0 if mi(rh_hr_avg) 
replace	rhum_xtwin = 0 if mi(rh_hr_avg) 

** Additional Fixed Effects **
egen	hmogr = group(hour month) 	// Hour-of-day X Month-of-year
egen 	hxdoy = group(doy2 hour) 	// Hour-of-day X Day-of-year
egen 	hxdow = group(dow hour)		// Hour-of-day X Day-of-week
egen	hxtemp = group(hour t_1bin_alt) // Hour-of-day X 1F temp bins

** Additional Dates (to faciliate lagged LMW) and lagged LMW ** 
gen 	date_all = dofc(time)
gen		date_lag7 = dofc(time) - 7
gen		date_lag364 = dofc(time) - 364
gen		date_lag365 = dofc(time) - 365
replace date_lag365 = dofc(time) - 366 if doy>59 & (year==2000 | year==2004 | year==2008 | year==2012 | year==2016 | year==2020)
replace date_lag365 = dofc(time) - 366 if doy<=59 & (year==2001 | year==2005 | year==2009 | year==2013 | year==2017 | year==2021)
gen		date_lag371 = dofc(time) - 371

preserve
	keep 	date_all mw
	collapse (mean) daily_mw=mw, by(date_all)
	gen		daily_lmw = ln(daily_mw)
	
	gen		date_lag7 = date_all
	gen		daily_mw_lag7 = daily_mw
	gen		daily_lmw_lag7 = daily_lmw
	
	gen		date_lag364 = date_all
	gen		daily_mw_lag364 = daily_mw
	gen		daily_lmw_lag364 = daily_lmw
	
	gen		date_lag365 = date_all
	gen		daily_mw_lag365 = daily_mw
	gen		daily_lmw_lag365 = daily_lmw
		
	gen		date_lag371 = date_all
	gen		daily_mw_lag371 = daily_mw
	gen		daily_lmw_lag371 = daily_lmw
	
	tempfile dmw
	save "`dmw'"
restore

merge m:1 date_all using "`dmw'", keepus(daily_mw daily_lmw)
drop if _merge==2
drop 	_merge

merge m:1 date_lag7 using "`dmw'", keepus(daily_mw_lag7 daily_lmw_lag7)
drop if _merge==2
drop 	_merge

merge m:1 date_lag364 using "`dmw'", keepus(daily_mw_lag364 daily_lmw_lag364)
drop if _merge==2
drop 	_merge

merge m:1 date_lag365 using "`dmw'", keepus(daily_mw_lag365 daily_lmw_lag365)
drop if _merge==2
drop 	_merge

merge m:1 date_lag371 using "`dmw'", keepus(daily_mw_lag371 daily_lmw_lag371)
drop if _merge==2
drop 	_merge

** Sandy Adjustment **
*twoway (scatter lmw time if tin(27oct2012 00:00, 8nov2012 00:00), m(O) msize(vtiny)) || ///
*		(scatter lmw time if tin(29oct2012 20:00, 30oct2012 22:00), mc(red) m(O) msize(tiny))
gen 	sandy=1 if tin(29oct2012 20:00, 30oct2012 22:00)
replace sandy=0 if sandy!=1

** Covid Adjustment **
gen 	covid_base = (dofc(time) - td(1feb2020)>=0) if !mi(time)

gen 	covid_day = (dofc(time) - td(1mar2020))
replace covid_day = 0 if covid_day<0

compress

save	"./data/intermediate/weather_rcn_electricity.dta", replace
clear
zipfile "./data/intermediate/weather_rcn_electricity.dta", saving("./data/processed/weather_rcn_electricity_processed.zip", replace)

