# nik obrien with no_code #
# 2/14/2022 #

##################################################################
# function - new comic pull list
# the goal here is to use web scraping on comic book
# publisher's websites to generate a weekly new
# comic list in order to text box subscribers
# and let them know what they have and how much it will cost
##################################################################

new_comic_scraper <- function(publisher = c(NA_character_), content_type = c('Comic Book')){
  # publisher is a vector string to determine who we are scraping from; dc, marvel etc #
  # content type is a vector or strings such as comic books, graphic novels etc #'
  
  ##### 1. Import Libraries and Initialize Output #####
  library(tidyverse)
  library(rvest)
  library(data.table)
  library(lubridate)
  library(dplyr)
  library(tidyr)
  
  new_comics <- data.table()
  
  
  ##### 2. DC Comics #####
  if('DC' %in% publisher | (length(publisher) == 1 & is.na(publisher))){
    ##### 2a. Pull the Titles #####
    # link for dc new comics #
    dc_link <- 'https://www.dccomics.com/comics?all=1#browse'
    
    # read in the html #
    dc_html <- read_html(dc_link)
    
    # extract the new comics from css node #
    comic_title <- as.data.table(dc_html %>% html_nodes('.slick--optionset--comics-and-graphic-novels a') 
                                 %>% html_text())
    setnames(comic_title, 'V1', 'comic_titles')
    
    # transform into data table and remove blanks #
    comic_title <- comic_title[comic_titles != '',]
    
    
    ##### 2b. Pull Each Title's Specific Info #####
    comic_type <-  as.data.table(dc_html %>% html_nodes('.content-type') %>% html_text())
    setnames(comic_type, 'V1', 'comic_types')
    dc_comics <- cbind(comic_title, comic_type)
    
    dc_comics <- dc_comics[comic_types %in% content_type,]
    
    dc_comics <- separate(dc_comics, comic_titles, into = c('comic_titles', 'comic_issues'), sep = "#",
                                                            remove = F)
    
    dc_comics[, `:=` (comic_titles = tolower(comic_titles),
                      comic_issues = as.numeric(comic_issues))]
    
  }
  
  
  ##### 3. Marvel Comics #####
  if(publisher == 'Marvel'){
    
  }
  
  
  ##### 4. Image Comics #####
  if(publisher == 'Image'){
    
  }
}