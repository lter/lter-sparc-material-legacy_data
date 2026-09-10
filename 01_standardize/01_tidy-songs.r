## -------------------------------------------- ##
# Standardize Data - San Onofre Nuclear Generating Station (SONGS)
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

## -------------------------------------------- ##
# Tidy Kelp Data ---
## -------------------------------------------- ##

# Load in the data
songs_v01 <- read.csv(file.path("data", "raw", "00_SONGS__Reef community survey, macrocystis dead holdfast cover and recruit density, all years.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(songs_v01)

# Do needed wrangling
songs_v02 <- songs_v01 %>% 
  dplyr::filter(dmaho_percent_cover > 0)

# Check structure
dplyr::glimpse(songs_v02)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
songs_v99 <- songs_v02

# One last structure check
dplyr::glimpse(songs_v99)

# Export locally
write.csv(songs_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_SONGS_kelp-holdfasts.csv"))

# End ----
