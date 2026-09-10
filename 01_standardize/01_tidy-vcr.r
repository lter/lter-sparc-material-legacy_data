## -------------------------------------------- ##
# Standardize Data - Virginia Coastal Reserve (VCR)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Get Oyster Data into Tidy Format ----
## -------------------------------------------- ##

# Read in the data
vcr_v01 <- data.frame("x" = readLines(file.path("data", "raw", "00_VCR__VCR22348_1.csv")))

# Check structure
dplyr::glimpse(vcr_v01)

# Get it into true dataframe format
vcr_v02 <- vcr_v01 %>%
  dplyr::slice(24:nrow(.)) %>% 
  tidyr::separate_wider_delim(cols = x, delim = ",",
    names = c("Sample", "TemperatureC", "SalinityPPT", "AlgaePercent", 
      "ReefCode", "ReefType", "Site", "Acreage", "Latitude", "Longitude", 
      "ReefShape", "SuitableReference", "Date", "Restoration", "TimeSinceConstruct",
      "BuildDate", "Species", "Species_count", "PlantingSeason")) %>% 
  dplyr::filter(Sample != "Sample") %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(vcr_v02)

## -------------------------------------------- ##
# Filter & Reshape Oyster Data ----
## -------------------------------------------- ##

# Filter to only needed rows
vcr_v03 <- vcr_v02 %>% 
  dplyr::filter(species %in% c("Box Adult Oyster", "Spat Oyster", "Adult Oyster")) %>% 
  dplyr::filter(restoration == "Reference") %>% 
  dplyr::mutate(species_count = as.numeric(species_count)) %>% 
  dplyr::filter(!is.na(species_count)) %>% 
  dplyr::select(site, date, species, species_count)

# Check structure
dplyr::glimpse(vcr_v03)

# Streamline or create some columns
vcr_v04 <- vcr_v03 %>% 
  dplyr::mutate(
    date = as.Date(date),
    year = as.numeric(lubridate::year(date)),
    species = dplyr::case_when(
      species == "Spat Oyster" ~ "juvenile",
      species == "Adult Oyster" ~ "adult",
      TRUE ~ "dead"))

# Check structure
dplyr::glimpse(vcr_v04)

# Reshape data to wide format
vcr_v05 <- vcr_v04 %>% 
  tidyr::pivot_wider(names_from = "species", 
     values_from = "species_count", 
     values_fn = sum)

# Check structure
dplyr::glimpse(vcr_v05)

## -------------------------------------------- ##
# Summarize Oyster Data ----
## -------------------------------------------- ##

# Calculate means across quadrats for site and year
vcr_v06 <- vcr_v05 %>% 
  dplyr::group_by(year, site) %>% 
  dplyr::summarize(dead.mean = mean(dead, na.rm = TRUE),
    adult.mean = mean(adult, na.rm = TRUE),
    juvenile.mean = mean(juvenile, na.rm = TRUE),
    .groups = "drop")

# Check structure
dplyr::glimpse(vcr_v06)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
vcr_v99 <- vcr_v06

# One last structure check
dplyr::glimpse(vcr_v99)

# Export locally
write.csv(vcr_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_VCR_oysters.csv"))

# End ----

