/* MASTER DO FILE FOR REAL-TIME ELECTRICITY-BASED INDEX OF ECONOMIC DISRUPTION
*   Chris Severen, research assistance by Nathan Schor */

cls
clear

*cd		XXXXX // Users: set to local github repository
cd	C:\GitHub\PA-Electricity-Economic-Disruption
local 	lastday 30apr2020 // Set last day sometime after most recent data; can help contain graphs


*===== LET RUN =====*
do		"./code/1_construct_electricity.do"
do		"./code/1_construct_lcd_weather.do"
do		"./code/1_construct_rcn_weather.do"
do		"./code/2_assemble_lcd.do"
do		"./code/2_assemble_rcn.do"
do		"./code/3_analyze_lcd.do"	 			"`lastday'"
do		"./code/3_analyze_rcn.do"	 			"`lastday'"
do		"./code/4_picture_rawweekly.do"	 		/* Might need to fiddle with dates in here by hand */

do		"./code/4_picture_dailyestimates.do" 	"`lastday'"

local datafiles: dir "./data/intermediate/" files "*.dta"

foreach df of local datafiles {
	rm "./data/intermediate/`df'"
}

rm	"./data/electricity/PJM_Data.csv"
rm	"./data/weather/rcn/Weather_data_RCN.csv"
rm	"./data/weather/lcd/1.csv"
rm	"./data/weather/lcd/2.csv"
rm	"./data/weather/lcd/3.csv"
rm	"./data/weather/lcd/4.csv"
rm	"./data/weather/lcd/5.csv"
rm	"./data/weather/lcd/6.csv"
rm	"./data/weather/lcd/7.csv"
rm	"./data/weather/lcd/8.csv"
rm	"./data/weather/lcd/Philly_2000_2009.csv"
rm	"./data/weather/lcd/Philly_2010_2019.csv"
rm	"./data/weather/lcd/Philly_All_2020.csv"