/* MASTER DO FILE FOR REAL-TIME ELECTRICITY-BASED INDEX OF ECONOMIC DISRUPTION
*   Chris Severen, research assistance by Nathan Schor */

cls
clear

*cd		XXXXX // Users: set to local github repository
cd	C:\GitHub\PA-Electricity-Economic-Disruption
local 	lastday 17apr2020 // Set last day sometime after most recent data; can help contain graphs


*===== LET RUN =====*
do		"./code/1_construct_electricity.do"
do		"./code/1_construct_lcd_weather.do"
do		"./code/1_construct_rcn_weather.do"
do		"./code/2_assemble_lcd.do"
do		"./code/2_assemble_rcn.do"
do		"./code/3_analyze_lcd.do"	 			"`lastday'"
do		"./code/3_analyze_rcn.do"	 			"`lastday'"
do		"./code/4_picture_rawweekly.do"	 		/* Might need to fiddle with dates in here by hand */
local 	lastday 17apr2020 // Set last day sometime after most recent data; can help contain graphs

do		"./code/4_picture_dailyestimates.do" 	"`lastday'"