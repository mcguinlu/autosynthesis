library(stringr)
library(rvest)
library(here)
library(pushoverr)

# Remember to edit the link to display all search results on a single page
# Save results page as html file and then read it in.
# Robots.txt disallows scraping of search/ paths, so this approach is a hacky fix
# Robots.txt has no problem with scraping content/ paths


# Extract links to each paper ---------------------------------------------
page <- read_html("https://www.biorxiv.org/archive?field_highwire_a_epubdate_value%5Bvalue%5D&page=0")

pages <- page %>%
  html_nodes(".pager-last a") %>%
  html_text()  %>%
  as.numeric()

print(paste("Time to completion: ", round(pages*10/60/60,2), " hours"))

df <- data.frame(link = character(), 
                  stringsAsFactors=FALSE)

df2 <- data.frame(x=character(),
                  y=numeric())

pages <- 1324

for (pageno in 61:pages){
  print(paste0("Page ", pageno+1," of ", pages+1))
 
  page <- read_html(paste0("https://www.biorxiv.org/search/%252A%20numresults%3A75%20sort%3Apublication-date%20direction%3Aascending?page=", pageno))
  
    tmp <- page %>%
    html_nodes(".highwire-cite-linked-title") %>%
    html_attr('href') %>%
    as.data.frame()
  
  colnames(tmp)[1] <- "link"
  
  tmp <- as.data.frame(tmp[which(tmp$link %in% df$link),])
  
  df <- rbind(df, tmp)
  name <- paste0("page", pageno)
  # assign(name, tmp)
  
  tmp2 <- data.frame(x=name,y=length(tmp$link))
  
  print(tmp2$y)
  
  df2 <- rbind(df2, tmp2)
  
  print(length(df$link))
  
  sleep_time <- runif(1,6,6)
  Sys.sleep(sleep_time)
}

write.csv(df, here("data","bioRxiv_link_list_1-66000.csv"), row.names = FALSE)





if ((length(df$link)>65889)==TRUE){
  pushover("bioRxiv ink extraction complete!")
} else {
  pushover("bioRxiv link extraction failed. . .")
}





