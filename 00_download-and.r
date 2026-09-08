## -------------------------------------------- ##
# Download Data - Andrews Forest (AND)
## -------------------------------------------- ##
# Purpose
## Download data from this site from the Environmental Data Initiative

# Load libraries
# install.packages("librarian")
librarian::shelf(EDIutils, tidyverse, tools)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

# Define 3-letter site abbreviation
site_abbrev <- "AND"

## -------------------------------------------- ##
# Authenticate with EDI ----
## -------------------------------------------- ##
# Due to a number of DDoS attacks on EDI, you need to authenticate before being able to download data
# For instructions, see either of the following:
## YouTube Tutorial -- < https://youtu.be/fieZSmHk2H4?si=Wo9a5GsAOYp3dnWS >
## Identity & Access Manager (IAM) -- < https://auth.edirepository.org >

# Once you have a key,
## 1. Create a file in the top-level of this folder called "secret_my-edi-key.md"
### DO NOT COMMIT THIS FILE! 
### The above name has been preemptively added to the `.gitignore` but if you name it something else, you'll be at risk of committing it
## 2. Copy/paste it into the "Console" of your IDE when prompted by the following code

# Define your EDI key
(edi_key <- readline(prompt = "Copy/paste your EDI Access Key here: "))

# Log in with that key
EDIutils::login(key = edi_key)

# Set HTTP option
options(HTTPUserAgent = "EDI_CodeGen")

## -------------------------------------------- ##
# Download Data ----
## -------------------------------------------- ##

# Define package ID
pkg_id <- "knb-lter-and.4032.10"

# Check out data
(ents <- EDIutils::read_data_entity_names(packageId = pkg_id))

# Loop across entities
for(k in seq_along(ents$entityName)){
  # k <- 2

  # Grab just that entity
  focal_ent <- ents[k, ]

  # Progress message
  message("Downloading file ", k, " of ", nrow(ents))
  
  # Assemble URL to that entity
  in_url <- paste0("https://pasta.lternet.edu/package/data/eml/",
    gsub(pattern = "\\.", "/", x = pkg_id), "/",
    focal_ent$entityId, "?key=", edi_key)

  # Identify entity file type
  ent_type <- tools::file_ext(focal_ent$entityName)
  
  # If unidentified, assume CSV
  if(nchar(ent_type) == 0 | is.na(ent_type)){
    focal_ent$entityName <- paste0(focal_ent$entityName, ".csv")
  }
  
  # Assemble local file name
  in_file <- file.path("data", "raw",
    paste0("00_", site_abbrev, "__", focal_ent$entityName))

  # Download it!
  download.file(url = in_url, destfile =  in_file,
    method = "curl", extra = paste0(' -A "', getOption("HTTPUserAgent"), '"'))
}

# End ----
