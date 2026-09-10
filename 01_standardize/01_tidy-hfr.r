## -------------------------------------------- ##
# Standardize Data - Harvard Forest (HFR)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites

## !!! DATA SOURCE NOTE !!!

# Data taken from Google Drive (_not_ EDI)

## !!! SEE ABOVE !!!

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, supportR)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()


## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
hfr_v99 <- hfr_v01

# One last structure check
dplyr::glimpse(hfr_v99)

# Export locally
write.csv(hfr_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_HFR_hemlock-removal.csv"))

# End ----
