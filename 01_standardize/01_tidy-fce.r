## -------------------------------------------- ##
# Download Data - Florida Coastal Everglades (FCE)
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

# Define 3-letter site abbreviation
site_abbrev <- "FCE"


# End ----
