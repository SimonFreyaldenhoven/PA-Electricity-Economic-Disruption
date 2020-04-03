cd		"./data/electricity/
unzipfile "PJM_Data.zip", replace
insheet using "PJM_Data.csv", c
cd 		../..

keep if load_area=="PE" // Data includes many different load areas, only those with >177k have full temporal covereage

save 	"./data/intermediate/electricity_demand.dta", replace
clear
