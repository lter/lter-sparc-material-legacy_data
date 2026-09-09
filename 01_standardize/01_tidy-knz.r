## -------------------------------------------- ##
# Standardize Data - Konza Prairie (KNZ)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-knz.r`

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Burn Data ----
## -------------------------------------------- ##

# Identify set of all remotely plausible years
knz_years_all <- seq(from = 1950, to = 2050)

# Check structure
dplyr::glimpse(knz_years_all)

# Read in burn year data
knz_years_burn <- read.csv(file.path("data", "raw", "00_KNZ__KFH011.csv")) %>% 
  janitor::clean_names() %>%  
  dplyr::filter(watershed == "2D") %>% 
  dplyr::pull(year)

# Check structure
dplyr::glimpse(knz_years_burn)

# Identify unburned years
knz_years_unburn <- setdiff(x = knz_years_all, y = knz_years_burn)

# Check structure
dplyr::glimpse(knz_years_unburn)

## -------------------------------------------- ##
# Tidy Biomass Data ----
## -------------------------------------------- ##

# Read in annual burn watershed data
knz_1y <- read.csv(file.path("data", "raw", "00_KNZ__PAB011.csv")) %>% 
  janitor::clean_names() %>%  
  dplyr::mutate(source = "1 year")
  
# Check structure
dplyr::glimpse(knz_1y)

# Two year watershed
knz_2y <- read.csv(file.path("data", "raw", "00_KNZ__PAB041.csv")) %>% 
  janitor::clean_names() %>%  
  dplyr::mutate(source = "2 year")

# Check structure
dplyr::glimpse(knz_2y)

## -------------------------------------------- ##
# Streamline Biomass Data ---
## -------------------------------------------- ##

# Combine & filter biomass
knz_v01 <- dplyr::bind_rows(knz_1y, knz_2y) %>% 
  dplyr::rename(year = recyear) %>% 
  # Keep only one watershed for 1 year data
  dplyr::filter((source == "1 year" & watershed == "001d") |
    # Keep only one watershed for 2 year data but only in unburned years
    (source == "2 year" & watershed == "002d")) %>% 
  dplyr::filter(soiltype == "fl") %>% 
  dplyr::filter(year %in% knz_years_unburn)

# Check structure
dplyr::glimpse(knz_v01)

# Summarize biomass
knz_v02 <- knz_v01 %>% 
  dplyr::group_by(source, year, soiltype, transect) %>% 
  dplyr::summarize(lvgrass.mean = mean(lvgrass, na.rm = TRUE),
    lvgrass.sd = sd(lvgrass, na.rm = TRUE),
    lvgrass.n = dplyr::n(),
    lvgrass.se = (lvgrass.sd / sqrt(lvgrass.n)),
      .groups = "drop") %>% 
  dplyr::select(-lvgrass.sd, -lvgrass.n)

# Check structure
dplyr::glimpse(knz_v02)

# Identify burn status & do final tidying
knz_v03 <- knz_v02 %>% 
  dplyr::mutate(burn_cat = ifelse(source == "1 year", 
      yes = "burned", no = "unburned"),
    .before = lvgrass.mean) %>% 
  dplyr::select(-soiltype)

# Check structure
dplyr::glimpse(knz_v03)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
knz_v99 <- knz_v03

# One last structure check
dplyr::glimpse(knz_v99)

# Export locally
write.csv(knz_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_KNZ_grass.csv"))

# End ----
