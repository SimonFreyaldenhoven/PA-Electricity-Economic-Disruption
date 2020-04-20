library('tictoc')
library('ggplot2')
library('lubridate')

setwd('C:/Users/Simon/Documents/GitHub/PA-Electricity-Economic-Disruption/')
input_location='./data/temp/data_PE.Rds'
data_in=readRDS(input_location)
data_in$datetime_beginning_ept=force_tz(data_in$datetime_beginning_ept, "US/Eastern")

main <- function() {
  weekly_data=extract_weeks(data_in)
  plot_weeks(weekly_data)
}

extract_weeks <- function(data_in) {

  start_dates=data_in[(wday(data_in$datetime_beginning_ept,label = TRUE, abbr = FALSE)=='Sunday' & month(data_in$datetime_beginning_ept)==3),'datetime_beginning_ept']#Sundays in March
  start_dates=start_dates[(hour(start_dates)==0)]
  start_dates=start_dates[which(year(start_dates) %in% c('2008','2017', '2018', '2019', '2020'))]
  end_dates=start_dates + days(7)
  
  weekly_data=list()
  for (ii in seq_along(start_dates)) {
    weekly_data[[ii]] = subset(data_in, datetime_beginning_ept >= start_dates[ii] & datetime_beginning_ept < end_dates[ii])
  }
  return(weekly_data)
}

plot_weeks <- function(weekly_data) {
  theme_set(theme_minimal())
  
  
  ggplot()  + geom_line(data=weekly_data[[ii]],aes(datetime_beginning_ept, mw))
  
}