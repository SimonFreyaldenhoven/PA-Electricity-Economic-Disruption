library('tictoc')
library('ggplot2')
library(readxl)
library('lubridate')
library('dplyr')
library('tidyr')
library(reshape2)

setwd('C:/Users/Simon/Documents/GitHub/PA-Electricity-Economic-Disruption/')
input_location_qcew_phl='./data/ip/raw/SeriesReport-20200602143625_fba6a2.xlsx'
input_location_qcew_pa='./data/ip/raw/SeriesReport-20200602143723_def470.xlsx'
input_location_ces_pa='./data/ip/raw/SeriesReport-20200602144447_81cf15.xlsx'

output_location = './data/temp/ip_prepared.Rds'


qcew_phl <- read_excel(input_location_qcew_phl, skip = 13)
qcew_pa <- read_excel(input_location_qcew_pa, skip = 13)
ces_pa <- read_excel(input_location_ces_pa, skip = 12)

data_ip=as.data.frame(seq(ymd("2015-01-01"), ymd("2020-05-01"), by = "months"))
names(data_ip)='monthly_date'

qcew_pa=melt(qcew_pa[,1:13], id.vars = "Year", value.name='qcew_pa')

qcew_pa$Date <- ymd(paste(test$Year, qcew_pa$variable, "01", sep = "-"))
qcew_pa <- qcew_pa[order(qcew_pa$Date), ]
