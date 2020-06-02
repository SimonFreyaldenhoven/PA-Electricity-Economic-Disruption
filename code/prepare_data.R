library(haven)
library('lubridate')
setwd('C:/Users/Simon/Documents/GitHub/PA-Electricity-Economic-Disruption/')


input_location="./data/processed/resids_rcn.csv"
output_location='./data/temp/data_PE.Rds'
first_day= ymd("2015-01-01")
last_day= ymd("2020-05-29")

resids_rcn <- read_csv(input_location)

data_PE = resids_rcn[resids_rcn$load_area=="PE",] #Restrict to PE if larger.
data_PE= data_PE[,c('datetime_beginning_ept', 'mw', 'lmw', 'dd_resids_nofe', 'dd_resids_fe1', 'dd_resids_fe2')]

data_PE$datetime_beginning_ept=mdy_hm(data_PE$datetime_beginning_ept)
data_PE$datetime_beginning_ept=force_tz(data_PE$datetime_beginning_ept, "US/Eastern")

data_PE=data_PE[!is.na(data_PE$datetime_beginning_ept), ]
data_PE=data_PE[(data_PE$datetime_beginning_ept>=first_day & data_PE$datetime_beginning_ept<=last_day),]

saveRDS(data_PE,output_location)

