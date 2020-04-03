cd		"./data/weather/rcn/
unzipfile "Weather_Data_RCN.zip", replace
clear 	
insheet using "Weather_Data_RCN.csv", c
cd 		../../..

keep if wbanno==3761	// Includes data for PHL and other locations, keeping only PHL

gen		year = floor(utc_date/10000)
gen		month = floor((utc_date- year*10000)/100)
gen		date = utc_date- year*10000 - month*100

gen		hour = utc_time/100

gen	double time = mdyhms(month, date, year, hour, 0, 0)
format time %tc

tsset time, delta(1 hour)

sum t_calc t_hr_avg t_max t_min rh_hr_avg p_calc

** Resolve missing values **
foreach var of varlist t_calc t_hr_avg t_max t_min rh_hr_avg p_calc {
	replace `var' = . if `var'==-9999
	replace `var' = . if `var'==999
}

foreach var of varlist t_calc t_hr_avg t_max t_min p_calc {
	replace `var' = . if `var'==99
}

sum t_calc t_hr_avg t_max t_min rh_hr_avg p_calc

egen 	t_1bin = cut(t_calc), at(-20(1)38) 

save	"./data/intermediate/weather_rcn.dta", replace
