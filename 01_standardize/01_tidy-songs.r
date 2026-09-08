## -------------------------------------------- ##
# Download Data - San Onofre Nuclear Generating Station (SONGS)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, supportR)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

# Define site abbreviation
site_abbrev <- "SONGS"


# End ----
