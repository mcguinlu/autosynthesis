# medRxiv

library(stringr)
library(rvest)
library(here)
library(pushoverr)
library(readr)

PUSHOVER_USER="u5axb7d9uwvhfzrjvqwb52jqfx1v97"
PUSHOVER_APP="agn73s1hv29un4ocfv95ajzs7wjgxu"


extractdailyfn <- function(){
links_daily <- data.frame(link = character(), 
                 stringsAsFactors=FALSE)

links_recent_df <- read.csv("data/medRxiv_last_extracted.csv", stringsAsFactors = FALSE)
links_recent <- links_recent_df[1,1]

for (pageno in 0:100){
  print(paste0("Page ",pageno))
  page <- read_html(paste0("https://www.medrxiv.org/archive?field_highwire_a_epubdate_value%5Bvalue%5D&page=",pageno))
  
  tmp <- page %>%
    html_nodes(".highwire-cite-linked-title") %>%
    html_attr('href') %>%
    as.data.frame()

  colnames(tmp)[1] <- "link"
  
  if ((links_recent %in% tmp$link)==TRUE) {
    row_no <- which(tmp$link==links_recent)
    tmp <- as.data.frame(tmp[c(1:which(tmp$link==links_recent)-1),1])
    colnames(tmp)[1] <- "link"
    links_daily <- rbind(links_daily, tmp)
    print("Found most recent extract")
    break
  }
  
  links_daily <- rbind(links_daily, tmp)
  
  sleep_time <- runif(1,10,13)
  Sys.sleep(sleep_time)
}

if (length(links_daily$link)==0) {
  pushover("Daily data extraction for medRxiv complete! No new medRxiv records found.",
           user = PUSHOVER_USER,
           app = PUSHOVER_APP)
  stop("No new links")
}

print("Saving daily links . . . .")
write.csv(links_daily,"data/medRxiv_links_daily.csv", row.names = FALSE)

print("Saving new reference link. . .")
new_links_recent <- links_daily[1,1]
write.csv(new_links_recent,"data/medRxiv_last_extracted.csv", row.names = FALSE)

# Abstract and metadata ---------------------------------------------------

df <- links_daily

df$link <- trimws(df$link)

abstract_data_daily <- data.frame(
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
             round(length(df$link)*26/60/60,2), " hours"))

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
  
  abstract_data_daily <- rbind(abstract_data_daily, tmp)
  
}

abstract_data_daily$date  <- gsub("Posted","", abstract_data_daily$date)
abstract_data_daily$date  <- gsub("\\.","", abstract_data_daily$date)
abstract_data_daily$date  <- trimws(abstract_data_daily$date)
abstract_data_daily$authors  <- trimws(abstract_data_daily$authors)

abstract_data_daily$pdf_name <- paste0(format(Sys.Date(),"%d%m%y"),"-",abstract_data_daily$id)

abstract_data_daily$extraction_date <- format(Sys.Date(), format="%d-%m-%Y")

# Save
print("Saving new abstract list . . .")
abstract_data <- read.csv("data/medRxiv_abstract_list.csv")
abstract_data <- rbind(abstract_data, abstract_data_daily)

abstract_data$date <- gsub("Â","",abstract_data$date)
abstract_data$date <- trimws(abstract_data$date)

write.csv(abstract_data,"data/medRxiv_abstract_list.csv", row.names = FALSE)


print("Saving daily links . . . .")
write.csv(links_daily,"data/medRxiv_links_daily.csv", row.names = FALSE)

print("Saving new reference link. . .")
new_links_recent <- links_daily[1,1]
write.csv(new_links_recent,"data/medRxiv_last_extracted.csv", row.names = FALSE)

# Extract daily PDFs ------------------------------------------------------

df <- abstract_data_daily

number <- 1

for (file_location in df$pdf) {
  
  if (file.exists(paste0("pdf/",df$pdf_name[which(df$pdf==file_location)]))) {
    print(paste0("File ", number, " already downloaded."))
    number <- number + 1
    next
  }
  
  while(TRUE){ 
    sleep_time <- runif(1,10,13)
    Sys.sleep(sleep_time)
    print(paste0("PDF ", number," of ", length(df$link),": ", df$pdf_name[which(df$pdf==file_location)]))
    pdf <- try(download.file(paste0("https://www.medrxiv.org",file_location), paste0("pdf/",df$pdf_name[number],".pdf"), mode="wb"))
    if(!is(pdf, 'try-error')) break
  }
  
  number <- number+1
  
  if ((number%%250==0)==TRUE) {
    pushover(paste0("PDF ", number, " of ", length(df$link),
                    " downloaded! (", round(number/length(df$link)*100,0),"%) "))
  }
  
}


# Cross-check -------------------------------------------------------------

page <- read_html("https://www.medrxiv.org/search/%252A")

results <- page %>%
  html_nodes("#page-title") %>%
  html_text()

results <- as.numeric(word(results))

data <- read.csv("data/medRxiv_abstract_list.csv", stringsAsFactors = FALSE)

data$link <- substr(data$link,1,nchar(data$link)-2)

extracted <- as.numeric(length(unique(data$link)))

# Check number extracted matches number returned by general search
if (identical(results,extracted)==TRUE) {
  cross_check <- "success"
} else {
  cross_check <- "failure"
}

# Notification message ----------------------------------------------------
message <- paste0("MEDRXIV |",
                  " New records: ",
                  length(abstract_data_daily$title),
                  "| Cross check: ",
                  cross_check)

pushover(message, user = PUSHOVER_USER, app = PUSHOVER_APP)

}

extractdailyfn()