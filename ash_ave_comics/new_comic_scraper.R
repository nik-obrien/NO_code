# nik obrien with no_code #
# 2/14/2022 #

##################################################################
# function - new comic pull list
# the goal here is to use web scraping on comic book
# publisher's websites to generate a weekly new
# comic list in order to text box subscribers
# and let them know what they have and how much it will cost
##################################################################

new_comic_scraper <- function(publisher = NA_character_, content_type = c('Comic Book')){
  # publisher is a string to determine who we are scraping from; dc, marvel etc #
  # content type is a vector or strings such as comic books, graphic novels etc #'
  
  ##### 1. Import Libraries #####
  library(tidyverse)
  library(rvest)
  library(data.table)
  library(lubridate)
  library(dplyr)
  
  
  ##### 2. DC Comics #####
  
}