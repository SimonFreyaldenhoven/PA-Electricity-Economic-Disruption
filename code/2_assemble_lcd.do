clear
use 	"./data/intermediate/weather_lcd.dta"

format station %11.0f
keep if station==72408013739

gen 	date2 = subinstr(date,"T"," ",1)
gen 	time2 = clock(date2,"YMD hms")
format 	time2 %tc
sort 	time2

drop 	date
gen		date = dofc(time2)
format 	date %td
gen		year = year(date)
gen		month = month(date)
gen		daynum = day(date)

gen 	hour = hh(30 * 60000 * ceil(time2 / (30 * 60 * 1000)))
*gen 	double hour = 30 * 60000 * ceil(time2 / (30 * 60 * 1000))
*format %tchh:MM hour

gen	double time = mdyhms(month, daynum, year, hour, 0, 0)
format time %tc
drop 	time2

egen timegroup = group(month daynum year hour)
duplicates tag month daynum year hour, gen(duphours)
gen		isC = (source=="C")
bys timegroup: egen hasC=max(isC)
drop if duphours>0 & hasC==1 & source!="C"

drop timegroup duphours
egen timegroup = group(month daynum year hour)
duplicates tag month daynum year hour, gen(duphours)
gen		is4 = (source=="4")
bys timegroup: egen has4=max(is4)
drop if duphours>0 & has4==1 & source!="4"

drop timegroup duphours isC is4 hasC has4
duplicates drop month daynum year hour, force

tsset time, delta(1 hour)
tsfill 
tsset time, delta(1 hour)

	gen hourlyprecipitation_flag = (substr(hourlyprecipitation,-1,.)=="s")
	replace hourlyprecipitation="0.01" if hourlyprecipitation=="T"
	destring hourlyprecipitation, replace i("s")

replace hourlywinddirection="990" if hourlywinddirection=="000" // 99 will be low winds
replace hourlywinddirection="980" if hourlywinddirection=="VRB" // 98 will be variable winds

destring hourlywinddirection, replace
replace hourlywinddirection = floor(hourlywinddirection/10)

rename 	hourlydrybulbtemperature temp
sum 	hourlydrybulbtemperature hourlyrelativehumidity hourlyprecipitation hourlywindspeed hourlywinddirection

egen 	t_1bin = cut(temp), at(1(1)105) 

tempfile weather
save	"`weather'", replace


*****************
use 	"./data/intermediate/electricity_demand.dta", clear

gen double time = clock(datetime_beginning_utc, "MDYhm")
format time %tc
tsset time, delta(1 hour)

gen double time2 = time-5*60*60*1000
format time2 %tc

drop time
rename time2 time
tsset time, delta(1 hour)

merge 1:1 time using "`weather'"
drop _merge

*****************************
set scheme plotplainblind

drop 	year month hour

gen		year = year(dofc(time))
gen		month = month(dofc(time))
gen 	hour = hh(time)

gen 	lmw = ln(mw)
gen 	doy = doy(dofc(time))
gen 	dow = dow(dofc(time))

** Day Tracking **
gen		dayc1 = dofc(time) - 14610
gen		dayc2 = dayc1^2
gen		dayc3 = dayc1^3

** Temperature Bins **
gen		t_1bina = t_1bin
replace t_1bina = 5 if t_1bina<5
replace t_1bina = 100 if t_1bina>100 & !mi(t_1bina)

compress

** Adjust for Leap Years **
gen	int doy2 = doy
replace doy2 = doy+1 if doy>59 & (year!=2000 & year!=2004 & year!=2008 & year!=2012 & year!=2016 & year!=2020)

** Precipation **
gen 	prec = hourlyprecipitation
replace prec = 1 if hourlyprecipitation >1 & !mi(hourlyprecipitation)
gen 	pmiss = mi(hourlyprecipitation)
replace prec = 0 if pmiss==1

gen		prec2 = prec^2

gen 	prec_w = prec*(t_1bina<60)
gen 	prec2_w = prec2*(t_1bina<60)

** Relative Humidity **
gen 	rhum = hourlyrelativehumidity  
gen		rhum_xtsum = rhum*t_1bina*(t_1bina>60)
gen		rhum_xtwin = rhum*t_1bina*(t_1bina<60)

** Windspeed and Direction (indicator for missing) **

destring hourlywindspeed, gen(windsp)
gen		wmiss = mi(windsp)
replace windsp = 40 if windsp>40 & !mi(windsp)
replace windsp = 0 if wmiss==1
gen		windsp2 = windsp^2

gen		winddir = .
replace	winddir = 1 if hourlywinddirection>=33 & hourlywinddirection<=36
replace	winddir = 1 if hourlywinddirection>=1 & hourlywinddirection<=5
replace	winddir = 2 if hourlywinddirection>=6 & hourlywinddirection<=14
replace	winddir = 3 if hourlywinddirection>=15 & hourlywinddirection<=23
replace	winddir = 4 if hourlywinddirection>=24 & hourlywinddirection<=32
replace	winddir = 8 if hourlywinddirection==98

foreach n of numlist 1/4 {
	gen		windm1w_`n' = windsp*(winddir==`n')*(t_1bina<60)
	gen		windm2w_`n' = windsp2*(winddir==`n')*(t_1bina<60)
	gen		windm1_`n' = windsp*(winddir==`n')
	gen		windm2_`n' = windsp2*(winddir==`n')
}

** Additional Fixed Effects **
egen	hmogr = group(hour month) 	// Hour-of-day X Month-of-year
egen 	hxdoy = group(doy2 hour) 	// Hour-of-day X Day-of-year
egen 	hxdow = group(dow hour)		// Hour-of-day X Day-of-week
egen	hxtemp = group(hour t_1bina) // Hour-of-day X 1F temp bins

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
*		(scatter lmw time if tin(29oct2012 15:00, 30oct2012 17:00), mc(red) m(O) msize(tiny))
gen 	sandy=1 if tin(29oct2012 15:00, 30oct2012 17:00)
replace sandy=0 if sandy!=1

** Covid Adjustment **
gen 	covid_base = (dofc(time) - td(1feb2020)>=0) if !mi(time)

gen 	covid_day = (dofc(time) - td(1mar2020))
replace covid_day = 0 if covid_day<0

compress

save	"./data/intermediate/weather_lcd_electricity.dta", replace
clear
zipfile "./data/intermediate/weather_lcd_electricity.dta", saving("./data/processed/weather_lcd_electricity_processed.zip", replace)


