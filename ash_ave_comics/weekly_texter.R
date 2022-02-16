# nik obrien with no_code #
# 2/15/2022 #

##################################################################
# script - weekly pull list text
# the goal here is to source new comic lists 
# in order to text box subscribers
# and let them know what they have and how much it will cost
##################################################################

##### 1. Import Libraries and Source Comic Scraper Fxn #####
library(tidyverse)
library(rvest)
library(data.table)
library(lubridate)
library(dplyr)
library(tidyr)
library(readxl)
library(mail)

# source and run the new comics fxn #
source('./new_comic_scraper.R')
new_comics <- new_comic_scraper(publisher = 'DC')
rm(new_comic_scraper)


##### 2. Pull Customer Info and Merge to Comic List #####
# pull customer info #
customer_info <- read_xlsx('./ash_database.xlsx',
                           sheet = 1,
                           col_names = T)

# pull box sub info #
box_info <- read_xlsx('./ash_database.xlsx',
                           sheet = 2,
                           col_names = T)

# merge to get full info #
full_info <- merge(customer_info, box_info, all = T, by = 'box_nbr')
rm(customer_info, box_info)

# merge new comics and kick out nulls #
full_info <- as.data.table(merge(full_info, new_comics, all.x = T, by.x = 'comic_subs', by.y = 'comic_title'))
full_info <- full_info[!is.na(comic_issue) & !is.na(comic_price),]

# calculate the total per customer #
full_info[, new_price := as.numeric(gsub('\\$', '', comic_price))]
full_info[, total_price := round(1.08*sum(new_price),2), by = 'box_nbr']


##### 3. Send the Alerts #####
# create an iteration list #
box_iters <- unique(full_info$box_nbr)

for(i in 1:length(box_iters)){
  box_value <- box_iters[i]
  total_price <- mean(full_info[box_nbr == box_value, total_price])
  customer_name <- str_to_title(unique(full_info[box_nbr == box_value, first_name]))
  customer_phone <- unique(full_info[box_nbr == box_value, phone_nbr])
  customer_email <- unique(full_info[box_nbr == box_value, email_addr])
  output_msg <- paste0('Hello ', customer_name,
                       '! Here is your weekly pull from Ash Ave Comics: \n\n')
  
  for(j in 1:nrow(full_info[box_nbr == box_value,])){
    output_msg <- paste0(output_msg, 
                         full_info[j, comic_subs], ' ',
                         full_info[j, comic_issue], ' ... ',
                         full_info[j, new_price], ' ... ')
  }
  
  output_msg <- paste0(output_msg, '\nYour total price plus tax is ... ', total_price)
  
  sendmail("nikobrien93@gmail.com", "hello", "hello", "rmail")
  
}

