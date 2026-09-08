## -------------------------------------------- ##
# Download Data - Andrews Forest (AND)
## -------------------------------------------- ##
# Purpose
## Download data from this site from the Environmental Data Initiative

# Load libraries
# install.packages("librarian")
librarian::shelf(EDIutils, tidyverse)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

# Define the 3-letter site abbreviation
site_abbrev <- "AND"

## -------------------------------------------- ##
# Authenticate with EDI ----
## -------------------------------------------- ##
# Due to a number of DDoS attacks on EDI, you need to authenticate before being able to download data
# For instructions, see either of the following:
## YouTube Tutorial -- < https://youtu.be/fieZSmHk2H4?si=Wo9a5GsAOYp3dnWS >
## Identity & Access Manager (IAM) -- < https://auth.edirepository.org >

## -------------------------------------------- ##
# Download Data ----
## -------------------------------------------- ##
# Once you have a key,
## 1. Create a file in the top-level of this folder called "secret_my-edi-key.md"
### DO NOT COMMIT THIS FILE! 
### The above name has been preemptively added to the `.gitignore` but if you name it something else, you'll be at risk of committing it
## 2. Copy/paste it into the "Console" of your IDE when prompted by the following code

# Identify URL(s) for data entity/entities of interest
for(focal_url in c(
  "https://pasta.lternet.edu/package/data/eml/knb-lter-and/4032/10/aed12b7432db4b68e0e97f7ff6ad24b1"
  )){

  # Define your EDI key
  (edi_key <- readline(prompt = "Copy/paste your EDI Access Key here: "))

  # If no key is found, error out
  if("edi_key" %in% ls() != TRUE){
    stop("A valid EDI Access Key is required for this code to download the data!")

    # Otherwise, use it to download the relevant data file
  } else {
    # Set HTTP option
    options(HTTPUserAgent = "EDI_CodeGen")

    # Assemble link
    in_url <- paste0(focal_url, "?key=", edi_key) 

    # Assemble local file name
    in_file <- file.path("data", "raw",
      paste0("raw_", site_abbrev, ".csv"))

    # Download it!
    download.file(url = in_url, destfile =  in_file,
      method = "curl", 
      extra = paste0(' -A "', getOption("HTTPUserAgent"), '"'))
  } }

# End ----
