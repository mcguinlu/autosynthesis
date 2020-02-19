library(stringr)
library(rvest)
library(here)
library(pushoverr)
library(readr)
library(tidyr)
library(git2r)


# Set working directory
WORKING_DIR=readLines("WORKING_DIR.txt")
setwd(WORKING_DIR)

# Read in credentials
PUSHOVER_USER=readLines("PUSHOVER_USER.txt")
PUSHOVER_APP=readLines("PUSHOVER_APP.txt")
GITHUB_USER <- readLines("GITHUB_USER.txt")
GITHUB_PASS <- readLines("GITHUB_PASS.txt")

# Get link info -----------------------------------------------------------

# source(here::here("R", "extract_links.R"))

# Get metadata ------------------------------------------------------------

# source(here::here("R", "extract_metadata_initial.R"))

# Get pdfs ----------------------------------------------------------------

# source(here::here("R", "download_pdfs.R"))

# Perform daily data extraction -------------------------------------------

source("R/cross_check_medrxiv.R")

source("R/extract_daily.R")

extract <- try(extractdailyfn())

if (!is(page, 'try-error')){
  pushover(paste0("Data extraction error: \n", extract[1],
                  "\nCross-check: ", cross_check()),
           user = PUSHOVER_USER,
           app = PUSHOVER_APP)
} else {
  if (cross_check()=="Success") {
    pushover(paste0("Data extraction: Success!\nCross check: Success!"),
             user = PUSHOVER_USER,
             app = PUSHOVER_APP)
    
    current_time <- format(Sys.time(), "%Y-%m-%d %H:%M")
    
    writeLines(current_time, "data/timestamp.txt")
    
    add(repo = getwd(),
        path = "data/medRxiv_abstract_list.csv")
    
    add(repo = getwd(),
        path = "data/timestamp.txt")
    
    # Commit the file
    
    
    commit(repo = getwd(),
           message = paste0("Data Dump: ", current_time)
    )
    
    # Push the repo again
    push(object = getwd(),
         credentials = cred_user_pass(username = GITHUB_USER,
                                      password = GITHUB_PASS))
    
    pushover(paste0("Data extraction: Success!\nCross check: Success!\nData upload: Success!"),
             user = PUSHOVER_USER,
             app = PUSHOVER_APP)
  } else {
    pushover(paste0("Data extraction: Success!\nCross check: Failed. . ."),
             user = PUSHOVER_USER,
             app = PUSHOVER_APP)
  }
}




