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

output_location_daily = './data/temp/daily_ip_prepared.Rds'
output_location_weekly = './data/temp/weekly_ip_prepared.Rds'


qcew_phl <- read_excel(input_location_qcew_phl, skip = 13)
qcew_pa <- read_excel(input_location_qcew_pa, skip = 13)
ces_pa <- read_excel(input_location_ces_pa, skip = 12)

main <- function(data_in, outcome) {
  daily_data <- create_daily_data(monthly_ip,outcome)
  weekly_data <- create_weeks(daily_data,outcome)
  
  ggplot(weekly_data, aes(x=date_begin)) + geom_line(aes( y=weekly_ip_raw), color='red')

}
  
create_daily_data <- function(monthly_ip, outcome) {  

  monthly_ip=melt(monthly_ip[,1:13], id.vars = "Year", value.name=outcome)
  monthly_ip=subset(monthly_ip, Year>2009)
  monthly_ip$Date <- ymd(paste(monthly_ip$Year, monthly_ip$variable, "01", sep = "-"))
  monthly_ip <- monthly_ip[order(monthly_ip$Date), ]
  
  Days <- seq(from = min(as.Date(monthly_ip$Date)),
              to = ceiling_date(max(as.Date(monthly_ip$Date)), "month") - days(1),
              by = "1 days")
  
  daily_ip=data.frame(Date = Days,
                      Value = setNames(monthly_ip[[outcome]], monthly_ip$Date)[format(Days, format = "%Y-%m-01")])
  
  saveRDS(daily_ip,output_location_daily)
  return(daily_ip)
}


create_weeks <- function(data_in, outcome) {
  
  start_dates=data_in[(wday(data_in$Date,label = TRUE, abbr = FALSE)=='Saturday') 
                      ,'Date']
  end_dates=start_dates + days(7)
  weekly_data=data.frame()
  
  for (ii in seq_along(start_dates)) {
      temp=subset(data_in, Date >= start_dates[ii] & Date < end_dates[ii])
      temp=data.frame(date_begin=start_dates[ii], weekly_ip_raw=mean(temp$Value))
      weekly_data <- rbind(weekly_data, temp) 
  }
  saveRDS(weekly_data,output_location_weekly)
  return(weekly_data)
}



monthly_ip= qcew_pa
outcome="qcew_pa"

main(monthly_ip, outcome)


