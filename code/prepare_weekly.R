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
  weekly_data <- create_weeks(data_in,outcome)
  weekly_data <- create_features(weekly_data)
}

#Main functions 
create_weeks <- function(data_in, outcome) {

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
  return(weekly_data)
}

create_features <- function(weekly_data, outcome) {
  temp_data <- head(weekly_data,-1)#drop current (partial) week for now
  temp_data <- temp[1014:968,]#drop current (partial) week for now
  hourly_avg = colMeans(temp_data[,-1], na.rm = TRUE)
  ggplot(data.frame(hour_of_week = 0:(length(hourly_avg)-1), average_outcome = hourly_avg),
         aes(x = hour_of_week, y = average_outcome)) + geom_line() + geom_point() + scale_x_continuous(name="Hour of week", breaks=seq(0,168,24))
  
  weekday_rush=rowMeans(temp_data[,c(65,66, 89,90, 113,114, 137,138)]) #Mon-Th 5-6pm
  weekday_night= rowMeans(temp_data[,c(73,74,75,76, 97,98,99,100, 121,122,123,124, 145,146,147,148 )]) #Mon-Th 1-4am
  weekend_night= rowMeans(temp_data[,c(74,75,76, 98,99,100, 122,123,124, 146,147,148 )]) #Mon-Th 2-4am
  #Afternoon dip clear in winter, AC in summer?
  #Morning peak at 7 am during th week, 10 am on weekends.
  
  pcas = extract_pcas(temp_data[,-1], 10)
  plot_pcas(pcas)
  
  
  #full_data <- transform(temp_data, weekly_avg = rowMeans(temp_data[,-1], na.rm = TRUE)) #Add weekly average
  full_data <- cbind(temp_data,pcas$factors[,1:2]) #Add PCs
  
  return(weekly_data)
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

main(data_in, y)