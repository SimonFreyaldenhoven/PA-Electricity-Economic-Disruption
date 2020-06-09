library('tictoc')
library('ggplot2')
library('lubridate')
library('dplyr')
library('tidyr')
library(reshape2)

setwd('C:/Users/Simon/Documents/GitHub/PA-Electricity-Economic-Disruption/')
input_location='./data/temp/data_PE.Rds'
output_location = './data/temp/extended_data_PE.Rds'

data_in=readRDS(input_location)
data_in$datetime_beginning_ept=force_tz(data_in$datetime_beginning_ept, "US/Eastern")
outcome="dd_resids_nofe"

main <- function(data_in, outcome) {
  weekly_data <- create_weeks(data_in,outcome)
  
  this_spring <- weekly_data[(weekly_data$date_begin >= ymd("2020-03-01") & weekly_data$date_begin <= ymd("2020-05-15")),]
  last_spring <- weekly_data[(weekly_data$date_begin >= ymd("2019-03-01") & weekly_data$date_begin <= ymd("2019-05-15")),]
  compare_weekly_pattern(this_spring, last_spring)#This year

  weekly_data <- add_features(weekly_data)
  saveRDS(weekly_data,output_location)
  
}

#Main functions 
create_weeks <- function(data_in, outcome) {
  data_in[outcome]=as.numeric(data_in[[outcome]])
  start_dates=data_in[(wday(data_in$datetime_beginning_ept,label = TRUE, abbr = FALSE)=='Saturday') 
                      ,'datetime_beginning_ept']
  start_dates=start_dates[(hour(start_dates$datetime_beginning_ept)==0),]
  clock_change=c(tail(dst(start_dates[[1]]), -1)- head(dst(start_dates[[1]]), -1),0)
  end_dates=start_dates$datetime_beginning_ept + days(7)
  #start_dates=as.list(start_dates)
  weekly_data=data.frame()

  for (ii in seq_along(start_dates[[1]])) {
    if (clock_change[ii]==0) {  #Daylight savings is a bit of a pain here:Probably affects the weekly pattern too. Drop those weeks for now.
      temp=subset(data_in, datetime_beginning_ept >= start_dates[ii,] & datetime_beginning_ept < end_dates[ii])
      hour_of_week=int_length(interval(start_dates[[ii,1]],temp$datetime_beginning_ept))/3600
      y=temp[outcome]
      date_begin=rep(start_dates[[ii,1]],length(hour_of_week))
      temp=data.frame(hour_of_week, y, date_begin)
      weekly_data <- rbind(weekly_data, temp) 
    }
  }
 
  
  weekly_data <- spread(weekly_data, hour_of_week, outcome) 
  weekly_data$date_begin= ymd(weekly_data$date_begin)
  return(weekly_data)
}

compare_weekly_pattern <- function(current, past) {
  
  current_hourly_avg = colMeans(current[,-1], na.rm = TRUE)
  past_hourly_avg = colMeans(past[,-1], na.rm = TRUE)
  full_set=as.data.frame(t(rbind(current_hourly_avg, past_hourly_avg)))
  full_set$hour_of_week = 0:(length(current_hourly_avg)-1)
  full_set=melt(full_set, id='hour_of_week')
  
  ggplot(full_set, aes(x = hour_of_week, y = value, color=variable, group=variable)) + geom_line() + geom_point() +
  scale_x_continuous(name="Hour of week", breaks=seq(0,168,24))
}

add_features <- function(weekly_data, outcome) {
  temp_data <- head(weekly_data,-1)#drop current (partial) week for now

  extra_features=data.frame(date_begin=temp_data$date_begin)
  extra_features$weekday_rush=rowMeans(temp_data[,c(65,66, 89,90, 113,114, 137,138)]) #Mon-Th 5-6pm
  extra_features$weekday_night= rowMeans(temp_data[,c(73,74,75,76, 97,98,99,100, 121,122,123,124, 145,146,147,148 )]) #Mon-Th 1-4am
  commuting_peak= 1#weekday difference betwen 7 am and 9am 
  pm_am= 1#Weekday diff between PM peak and AM peak
  #Morning peak at 7 am during th week, 10 am on weekends. relevant?
  #Afternoon dip clear in winter, AC in summer? relevant?
    
  pcas = extract_pcas(temp_data[,-1], 10)
  plot_pcas(pcas)
  extra_features$pca1 = pcas$factors[,1]
  extra_features$pca2 = pcas$factors[,2]
  extra_features$pca3 = pcas$factors[,3]

  full_data <- merge(temp_data,extra_features,by=c("date_begin")) 
  return(full_data)
}

#Helper fucntions
extract_pcas <- function(input, k) {
  pcas <-list()
  #temp <- input[, which(colMeans(is.na(input)) < 0.01)] #Delete those with more than 1% missing
  #temp =Filter(function(x) sd(x, na.rm = TRUE) >= 0.01, temp)
  #temp <- imputePCA(as.matrix(temp),ncp=k+5)
  pcas$vars = names(input)
  pca_results <- prcomp(input, center = TRUE,scale. = TRUE)
  pcas$loadings <- pca_results$rotation[,1:k]
  pcas$factors <- pca_results$x[,1:k]
  return(pcas)
}

plot_pcas <- function(pcas) {
  temp=cbind(as.data.frame(pcas$vars), as.data.frame(pcas$loadings))
  pcas_long <- gather(temp, PCA, loading, PC1:paste0("PC",10), factor_key=TRUE)
  names(pcas_long)[1] <- "hour_of_week"
  to_plot=c('PC1','PC2')
  pcas_plot <- pcas_long %>% filter(PCA %in% to_plot)
  theme_set(theme_minimal())
    ggplot(pcas_plot) + scale_x_continuous(name="Hour of week", breaks=seq(0,168,24))  + geom_line(aes(as.numeric(hour_of_week), loading, group=PCA, color=PCA))
  
  ggsave('./output/descriptive/weekly_pcas.png')
}



main(data_in, outcome)