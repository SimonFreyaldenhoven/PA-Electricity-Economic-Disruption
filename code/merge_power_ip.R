library('tictoc')
library('ggplot2')
library('lubridate')
library('dplyr')
library('tidyr')
library(reshape2)

setwd('C:/Users/Simon/Documents/GitHub/PA-Electricity-Economic-Disruption/')
input_location_power='./data/temp/extended_data_PE.Rds'
input_location_ip = './data/temp/weekly_ip_prepared.Rds'

weekly_power=readRDS(input_location_power)
weekly_ip=readRDS(input_location_ip)

full_data=inner_join(weekly_power, weekly_ip)


ggplot(full_data, aes(x=date_begin)) + geom_line(aes( y=weekly_ip_raw), color='red')

ggplot(full_data, aes(x=date_begin)) + geom_line(aes( y=pca1), color='blue')


