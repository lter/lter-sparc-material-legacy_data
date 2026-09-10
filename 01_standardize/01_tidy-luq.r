## -------------------------------------------- ##
# Standardize Data - Luquillo (LUQ)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-luq.r`

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, supportR)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Treatment Metadata ----
## -------------------------------------------- ##

# Load the metadata
luq_meta_v01 <- read.csv(file.path("data", "raw", "00_LUQ__Canopy Trimming Experiment (CTE) Treatments.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(luq_meta_v01)

# Simplify this
luq_meta_v02 <- luq_meta_v01 %>% 
  janitor::clean_names() %>% 
  dplyr::select(-latitude, -longitude, -subplot) %>% 
  dplyr::distinct()

# Check structure
dplyr::glimpse(luq_meta_v02)

## -------------------------------------------- ##
# Tidy Seed Data ----
## -------------------------------------------- ##

# Load the data
luq_v01 <- read.csv(file.path("data", "raw", "00_LUQ__CTE Seedlings Measurements.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(luq_v01)

# Do some high-level wrangling & add metadata
luq_v02 <- luq_v01 %>% 
  dplyr::mutate(start_date = as.character(start_date),
    year = as.numeric(substr(x = start_date, start = 1, stop = 4)),
    new = as.factor(new)) %>% 
  dplyr::left_join(x = ., y = luq_meta_v02,
    by = c("block", "plot"))

# Check structure
dplyr::glimpse(luq_v02)

# Fiter to only desired rows & simplify treatment names
luq_v03 <- luq_v02 %>% 
  dplyr::filter(is.na(lessthan10cm) != TRUE) %>% 
  dplyr::filter(treatment %in% c("Trim&clear", "Trim+Debris")) %>% 
  dplyr::filter(year %in% (2005:13)) %>% 
  dplyr::mutate(treatment = ifelse(treatment == "Trim&clear",
      yes = "removed", no = "added"))

# Check structure
dplyr::glimpse(luq_v03)

# Summarize
luq_v04 <- luq_v03 %>% 
  dplyr::group_by(treatment, year, block, plot) %>% 
  summarize(seedling.count = sum(lessthan10cm, na.rm = TRUE),
    .groups = "drop")

# Check structure
dplyr::glimpse(luq_v04)
    
## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
luq_v99 <- luq_v04

# One last structure check
dplyr::glimpse(luq_v99)

# Export locally
write.csv(luq_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_LUQ_seedlings.csv"))

# End ----
