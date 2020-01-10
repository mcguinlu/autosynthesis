library(stringi)
library(ggplot2)
library(plotly)


data <- read.csv("data/medRxiv_abstract_list.csv")

head(data$date)

data$date <- trimws(data$date)

data$date <- stri_sub(data$date,2)

data$date <- gsub(",","",data$date)

data$date2 <- as.Date(data$date, "%B %d %Y")

head(data$date2)

ggplotly(ggplot(data) +
  geom_histogram(aes(x=date2), stat = "count"))
