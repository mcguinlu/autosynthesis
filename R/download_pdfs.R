df <- read.csv(here("data","medRxiv_abstract_list.csv"))

PUSHOVER_USER="u5axb7d9uwvhfzrjvqwb52jqfx1v97"
PUSHOVER_APP="agn73s1hv29un4ocfv95ajzs7wjgxu"


number <- 1

for (file_location in df$pdf) {
  
  if (file.exists(here("pdf",paste0(df$pdf_name[which(df$pdf==file_location)],".pdf")))) {
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
}

if ((length(list.files("pdf"))==length(df$link))==TRUE){
  pushover("PDF extraction complete!")
} else {
  pushover("Error: missing PDFs . . .")
}


