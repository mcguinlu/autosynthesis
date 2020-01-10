# Extract abstract --------------------------------------------------------
df <- read.csv(here("data","medRxiv_link_list.csv"))

df$link <- trimws(df$link)

abstract_data <- data.frame(
  title = character(),
  abstract = character(),
  link = character(),
  date = character(),
  subject = character(),
  authors = character(),
  bibtex = character(),
  pdf = character(), 
  extraction_date = character())


print(paste0("Estimated time to completion: ",
             round(length(df$link)*13/60/60,2), " hours"))

for (linkno in 1:length(df$link)){
  
  while(TRUE){  
    sleep_time <- runif(1,10,13)
    Sys.sleep(sleep_time)
    print(paste0("DOI ", linkno," of ", length(df$link)))
    page <- try(read_html(paste0("https://www.medrxiv.org/",df$link[linkno])))
    if(!is(page, 'try-error')) break
  }
  
  id <- linkno
  
  title <- page %>%
    html_node(".highwire-cite-title") %>%
    html_text()
  
  abstract <- page %>%
    html_node("#p-2") %>%
    html_text()
  
  pdf_link <- page %>%
    html_node(".article-dl-pdf-link") %>%
    html_attr('href')
  
  date <- page %>%
    html_node(".pane-1 .pane-content") %>%
    html_text()
  
  subject <- page %>%
    html_node(".highlight") %>%
    html_text()
  
  authors <- page %>%
    html_node(".nlm-surname") %>%
    html_text
  
  ### Only exists for bioRxiv ###
  # article_type <- page %>%
  #                 html_node(".biorxiv-article-type") %>%
  #                 html_text()
  
  bibtex <- page %>%
    html_node(".first .hw-download-citation-link") %>%
    html_attr('href')
  
  
  
  tmp <- data.frame(title = title,
                    abstract = abstract,
                    link = df$link[linkno],
                    pdf = pdf_link, 
                    date = date,
                    subject = subject,
                    authors = authors,
                    bibtex = bibtex,
                    id=id)
  
  abstract_data <- rbind(abstract_data, tmp)
  
  if ((linkno%%250==0)==TRUE) {
    pushover(paste0("Abstract ", linkno, " of ", length(df$link),
                    " complete! (", round(linkno/length(df$link)*100,0),"%) "))
  }
  
}

if (length)


abstract_data$date  <- gsub("Posted","", abstract_data$date)
abstract_data$date  <- gsub("\\.","", abstract_data$date)
abstract_data$date  <- trimws(abstract_data$date)
abstract_data$authors  <- trimws(abstract_data$authors)

abstract_data_daily$pdf_name <- paste0(format(Sys.Date(),"%d%m%y"),"-",abstract_data_daily$id)

abstract_data$extraction_date <- format(Sys.Date(), format="%d-%m-%Y")

# Save
write.csv(abstract_data, here("data","medRxiv_abstract_list.csv"), row.names = FALSE)



if ((length(abstract_data$title)==length(df$link))==TRUE){
  pushover("Abstract extraction complete!")
} else {
  pushover("Abstract extraction failed. . .")
}