## -------------------------------------------- ##
# Standardize Data - Konza Prairie (KNZ)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-knz.r`

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor, supportR)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Biomass Data ----
## -------------------------------------------- ##

# Read in annual burn watershed data
knz_1y <- read.csv(file.path("data", "raw", "00_KNZ__PAB011.csv")) %>% 
  janitor::clean_names() %>%  
  dplyr::filter(watershed == "001d")%>%
  dplyr::rename(year = recyear)

# Check structure
dplyr::glimpse(knz_1y)

# Two year watershed
knz_2y <- read.csv(file.path("data", "raw", "00_KNZ__PAB041.csv")) %>% 
  janitor::clean_names() %>%  
  dplyr::filter(watershed == "002d") %>% 
  dplyr::rename(year = recyear)

# Check structure
dplyr::glimpse(knz_2y)

## -------------------------------------------- ##
# Tidy Burn Data ----
## -------------------------------------------- ##

# Read in burn year data
knz_burns_v01 <- read.csv(file.path("data", "raw", "00_KNZ__KFH011.csv")) %>% 
  janitor::clean_names() %>%  
  dplyr::filter(watershed == "2D")

# Check structure
dplyr::glimpse(knz_burns_v01)

# Generate table of all years & identify burn vs. no burn
knz_burns <- data.frame("year" = seq(from = 1978, to = max(c(knz_1y$year, knz_2y$year), na.rm = TRUE))) %>% 
  dplyr::mutate(burn_year = ifelse(year %in% knz_burns_v01$year,
    yes = "yes", no = "no"))

# Check structure
dplyr::glimpse(knz_burns)

## -------------------------------------------- ##
# Summarize Biomass Data ----
## -------------------------------------------- ##

# Get average grass cover for 1 year
knz_1y_avg <- knz_1y %>% 
  dplyr::group_by(year, soiltype, transect) %>% 
  dplyr::summarize(lvgrass.mean = mean(lvgrass, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::mutate(burn_cat = "burned")

# Filter two-year data to only unburned years and summarize it too
knz_2y_noburn_avg <- knz_2y %>% 
  dplyr::filter(!year %in% knz_burns_v01$year) %>% 
  dplyr::group_by(year, soiltype, transect) %>% 
  dplyr::summarize(lvgrass.mean = mean(lvgrass, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::mutate(burn_cat = "unburned")
    
# Check structure
dplyr::glimpse(knz_2y_noburn_avg)

## -------------------------------------------- ##
# Filter Annual Data to Target Years ----
## -------------------------------------------- ##

# Extract unique years from the non-burned dataset
(target_years <- unique(knz_2y_noburn_avg$year))

# Filter annual dataset to only those years
knz_1y_noburn_avg <- knz_1y_avg %>% 
 dplyr::filter(year %in% target_years)

# Combine data
knz_merge <- dplyr::bind_rows(knz_1y_noburn_avg, knz_2y_noburn_avg) %>% 
  dplyr::filter(soiltype == "fl")

# Check structure
dplyr::glimpse(knz_merge)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data


# One last structure check


# Export locally


# End ----
