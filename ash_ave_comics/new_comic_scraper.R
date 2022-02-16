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
  
  new_comics <- data.table(comic_title = character(),
                           comic_issue = numeric(),
                           comic_price = numeric())
  
  
  ##### 2. DC Comics #####
  if('DC' %in% publisher | is.na(publisher)){
    ##### 2a. Pull Titles, Types and Links from Front Page #####
    # link for dc new comics #
    dc_link <- 'https://www.dccomics.com/comics?all=1#browse'
    
    # read in the html #
    dc_html <- read_html(dc_link)
    
    # extract the new comic titles from css node #
    comic_title <- as.data.table(dc_html %>% html_nodes('.slick--optionset--comics-and-graphic-novels a') 
                                 %>% html_text())
    setnames(comic_title, 'V1', 'comic_title')
    comic_title <- comic_title[comic_title != '',]
    
    # extract the new comics links from the css node #
    comic_link <- unique(as.data.table(dc_html %>% html_nodes('.slick--optionset--comics-and-graphic-novels a')
                                        %>% html_attr('href')))
    setnames(comic_link, 'V1', 'comic_link')
    
    # extract the new comic types fromm the css node #
    comic_type <-  as.data.table(dc_html %>% html_nodes('.content-type') 
                                 %>% html_text())
    setnames(comic_type, 'V1', 'comic_type')
    
    # combine the data #
    dc_comics <- cbind(comic_title, comic_type, comic_link)
    rm(comic_title, comic_type, comic_link)
    rm(dc_html, dc_link)
    
    
    ##### 2b. Pull Price from Secondary Pages #####
    # we need to iterate through the links to get the prices #
    dc_comics[, comic_link := paste0('https://dccomics.com', comic_link)]
    comic_price <- c()
    for(i in 1:nrow(dc_comics)){
      # for each link extract the price and add to the table #
      temp_html <- read_html(as.character(dc_comics[i, comic_link]))
      temp_price <- temp_html %>% html_nodes('.price') %>% html_text()
      temp_price <- ifelse(length(temp_price) != 0, temp_price, '$0.00')
      comic_price <- append(comic_price, temp_price)
      rm(temp_html, temp_price)
    }
    rm(i)
    
    # turn into table and combine #
    comic_price <- as.data.table(comic_price)
    dc_comics <- cbind(dc_comics, comic_price)
    rm(comic_price)
    
    
    ##### 2c. Clean the Data and Output #####
    # keep only content types that match with content type  fxn input #
    dc_comics <- dc_comics[comic_type %in% content_type,]
    dc_comics[, c('comic_type', 'comic_link') := NULL]
    
    # separate the issue number from the title #
    dc_comics <- separate(dc_comics, comic_title, into = c('comic_title', 'comic_issue'), sep = "#",
                          remove = F)
    
    # clean the data, we'll save punctuation cleaning for the end #
    dc_comics[, `:=` (comic_title = tolower(comic_title),
                      comic_issue = as.numeric(comic_issue))]
    
    # reorder names #
    setcolorder(dc_comics, c('comic_title', 'comic_issue', 'comic_price'))
    
    # transfer to output table and delete #
    new_comics <- rbind(new_comics, dc_comics)
    rm(dc_comics)
  }
  
  
  ##### 3. Marvel Comics #####
  if(publisher == 'Marvel'){
    
  }
  
  
  ##### 4. Image Comics #####
  if(publisher == 'Image'){
    
  }
  
  
  ##### 5. Clean Data and Output #####

  
}
