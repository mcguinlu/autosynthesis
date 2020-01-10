library(stringr)
library(rvest)
library(here)
library(pushoverr)

# Remember to edit the link to display all search results on a single page
# Save results page as html file and then read it in.
# Robots.txt disallows scraping of search/ paths, so this approach is a hacky fix
# Robots.txt has no problem with scraping content/ paths


# Extract links to each paper ---------------------------------------------

df <- data.frame(link = character(), 
                  stringsAsFactors=FALSE)

for (pageno in 0:67){
  print(paste0("Page ", pageno+1," of 68"))
  
  page <- read_html(paste0("https://www.medrxiv.org/archive?field_highwire_a_epubdate_value%5Bvalue%5D&page=",pageno))
  
    tmp <- page %>%
    html_nodes(".highwire-cite-linked-title") %>%
    html_attr('href') %>%
    as.data.frame()
  
  colnames(tmp)[1] <- "link"
  
  df <- rbind(df, tmp)
  
  sleep_time <- runif(1,10,13)
  Sys.sleep(sleep_time)
}

write.csv(df, here("data","medRxiv_link_list.csv"), row.names = FALSE)

if ((length(df$link)>670)==TRUE){
  pushover("Link extraction complete!")
} else {
  pushover("Link extraction failed. . .")
}





