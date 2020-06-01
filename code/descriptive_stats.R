library('tictoc')
library('ggplot2')
library('lubridate')
library('dplyr')
library('tidyr')

setwd('C:/Users/Simon/Documents/GitHub/PA-Electricity-Economic-Disruption/')
input_location='./data/temp/data_PE.Rds'
data_in=readRDS(input_location)
data_in$datetime_beginning_ept=force_tz(data_in$datetime_beginning_ept, "US/Eastern")
outcome="mw"

main <- function(data_in, outcome) {
  weekly_data=create_weeks(data_in,outcome)
  plot_weeks(weekly_data, outcome)
  
}

create_weeks <- function(data_in, outcome) {

  start_dates=data_in[(wday(data_in$datetime_beginning_ept,label = TRUE, abbr = FALSE)=='Saturday') 
                      ,'datetime_beginning_ept']
  start_dates=start_dates[(hour(start_dates$datetime_beginning_ept)==0),]
  clock_change=c(0,0,tail(dst(start_dates[[1]]), -1)- head(dst(start_dates[[1]]), -1))
  end_dates=start_dates$datetime_beginning_ept + days(7)
  #start_dates=as.list(start_dates)
  weekly_data=data.frame()

  for (ii in seq_along(start_dates[[1]])) {
    if (clock_change[ii]==0) {
      temp=subset(data_in, datetime_beginning_ept >= start_dates[ii,] & datetime_beginning_ept < end_dates[ii])
      hour_of_week=int_length(interval(start_dates[[ii,1]],temp$datetime_beginning_ept))/3600
      y=temp[outcome]
      date_begin=rep(start_dates[[ii,1]],length(hour_of_week))
      temp=data.frame(hour_of_week, y, date_begin)
      weekly_data <- rbind(weekly_data, temp) 
    }
  }
  #Daylight savings is a bit of a pain here:Probably affects the weekly pattern too. Drop those weeks for now.
  
  weekly_data <- spread(weekly_data, hour_of_week, outcome) 
  return(weekly_data)
}

#convert_to_weekly <- function(data_in) {
  begin_week=(wday(data_in$datetime_beginning_ept,label = TRUE, abbr = FALSE)=='Saturday'
              & (hour(data_in$datetime_beginning_ept)==0))

  start_dates=start_dates[(hour(start_dates$datetime_beginning_ept)==0),]
  end_dates=start_dates$datetime_beginning_ept + days(7)
  #start_dates=as.list(start_dates)
  weekly_data=data.frame()
  
  for (ii in seq_along(start_dates[[1]])) {
    temp=subset(data_in, datetime_beginning_ept >= start_dates[ii,] & datetime_beginning_ept < end_dates[ii])
    hour_of_week=int_length(interval(start_dates[[ii,1]],temp$datetime_beginning_ept))/3600
    y=temp[outcome]
    Date_Monday=rep(start_dates[[ii,1]],length(hour_of_week))
    temp=data.frame(hour_of_week, y, Date_Monday)
    weekly_data <- rbind(weekly_data, temp) 
  }
  
  data_in$week_year=as.factor(week(data_in$datetime_beginning_ept)) #Week begins Sat morning 0am
  data_in$year_ind=as.factor(year(data_in$datetime_beginning_ept))
  data_in$week_ind=data_in$week_ind:data_in$year_ind
  #weekday_ind=wday(data_in$datetime_beginning_ept)  
  return(weekly_data)
}


plot_weeks <- function(weekly_data, outcome) {
  theme_set(theme_minimal())
  ggplot(weekly_data)  + aes_string("hour_of_week", outcome, group="Date_Monday", color = "Date_Monday") + geom_line() 
  ggsave('./output/descriptive/weekly.png')
}



extract_within_variation <- function(weekly_data, y) {
  temp=group_by(weekly_data, Date_Monday) %>% mutate(weekly_average=mean(y))
  within_deviation=weekly_data$mw-temp$weekly_average
  weekly_average=temp$weekly_average
  weekly_within <- cbind(weekly_data, temp$weekly_average, within_deviation)
  
  return(weekly_within)
}

average_within_variation <- function(weekly_within, y) {
  temp=weekly_within %>% group_by(hour_of_week, year(weekly_within$Date_Monday)) %>% summarize(avg_y=mean(within_deviation))
  names(temp)[2]="year"
  return(temp)
}


plot_within <- function(weekly_within) {
  theme_set(theme_minimal())
  ggplot(weekly_within)  + aes(hour_of_week, within_deviation, group=Date_Monday, color = Date_Monday) + geom_line()
  ggsave('./output/descriptive/weekly_within.png')
  
}


main(data_in, y)