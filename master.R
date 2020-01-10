library(stringr)
library(rvest)
library(here)
library(pushoverr)
library(readr)

setwd("C:/Users/lm16564/OneDrive - University of Bristol/Documents/rrr/autosynthesis")

# Get link info -----------------------------------------------------------

# source(here::here("R", "extract_links.R"))

# Get metadata ------------------------------------------------------------

# source(here::here("R", "extract_metadata_initial.R"))

# Get pdfs ----------------------------------------------------------------

# source(here::here("R", "download_pdfs.R"))

# Perform daily data extraction -------------------------------------------

source("R/extract_daily.R")