cd		"./data/weather/lcd/"
unzipfile "lcd.zip", replace
cd 		../../..

clear

local 	flagvars 	hourlydrybulbtemperature hourlywetbulbtemperature hourlypressurechange hourlysealevelpressure hourlyrelativehumidity hourlywindgustspeed hourlystationpressure hourlyvisibility hourlydewpointtemperature 

local 	dropvars	daily* monthly* shortduration* backup* hourlyaltimetersetting v??? // CS: Don't care about any of these variables, so drop

*=============*

import 	delim "./data/weather/lcd/Philly_2000_2009.csv"
drop 	`dropvars' v??
foreach v of varlist `flagvars' {
	capture gen `v'_flag = (substr(`v',-1,.)=="s")
	destring `v', replace i("s" "V")
}

tempfile Philly_2000_2009
save 	"`Philly_2000_2009'", replace

clear

import 	delim "./data/weather/lcd/Philly_2010_2019.csv"
drop 	`dropvars' v??
tostring source hourlywindspeed, replace	// CS added this line, rectifies differences (append, force -> values to missing)

foreach v of varlist `flagvars' {
	capture gen `v'_flag = (substr(`v',-1,.)=="s")
	destring `v', replace i("s" "V")
}

append 	using "`Philly_2000_2009'"

tempfile Philly_2000_2019
save 	"`Philly_2000_2019'", replace

clear

import 	delim "./data/weather/lcd/Philly_All_2020.csv"
drop 	`dropvars' v??
tostring source hourlywindspeed, replace

foreach v of varlist `flagvars' {
	capture gen `v'_flag = (substr(`v',-1,.)=="s")
	destring `v', replace i("s" "V")
}

append 	using "`Philly_2000_2019'"

tempfile Philadelphia_Finished
save 	"`Philadelphia_Finished'", replace

clear

*=============*
// Finished Philadelphia, adding Allentown Atlantic City and Dover
*=============*


foreach n of numlist 1/8 {
	import 	delim "./data/weather/lcd\\`n'.csv" // Note use of \\ here, because \` means <read as text `>
	drop 	`dropvars'
	capture drop  v??
	tostring source hourlywindspeed, replace
	
	foreach v of varlist `flagvars' {
		capture gen `v'_flag = (substr(`v',-1,.)=="s")
		destring `v', replace i("s" "*" "V")
	}

	tempfile merge_`n'
	save 	"`merge_`n''"
	clear
}

use		"`Philadelphia_Finished'"

foreach n of numlist 1/8 {
	append using "`merge_`n''"
}

*=============*
format station %11.0f
keep if report_type=="FM-15"

compress
save	"./data/intermediate/weather_lcd.dta", replace

