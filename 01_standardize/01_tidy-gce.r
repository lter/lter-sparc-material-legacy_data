## -------------------------------------------- ##
# Standardize Data - Georgia Coastal Ecosystems (GCE)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-gce.r`

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, supportR)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Marsh Data ----
## -------------------------------------------- ##

# Load the raw data
gce_v01 <- data.frame("x" = readLines(file.path("data", "raw", "00_GCE__PLT-GCES-1609_Biomass_Stats.csv")))

# Check structure
dplyr::glimpse(gce_v01)

# Get this into dataframe format
gce_v02 <- gce_v01 %>%
  dplyr::slice(6:nrow(.)) %>% 
  tidyr::separate_wider_delim(cols = x, delim = ",",
    names = tolower(c("Year", "Site", "Zone", "Plot", "Quadrat_Area", 
    "Plot_Disturbance", "Percent_Calculated_Biomass", "Num_Plant_Biomass_m2", 
    "Min_Plant_Biomass_m2", "Max_Plant_Biomass_m2", "Total_Plant_Biomass_m2", 
    "Mean_Plant_Biomass_m2", "StdDev_Plant_Biomass_m2", "SE_Plant_Biomass_m2"))) %>% 
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
    .fns = as.numeric))

# Check structure
dplyr::glimpse(gce_v02)

# Filter to only needed rows
gce_v03 <- gce_v02 %>% 
  dplyr::filter(quadrat_area == 0.25) %>% 
  dplyr::filter(!is.na(total_plant_biomass_m2))

# Check structure
dplyr::glimpse(gce_v03)

# Clarify disturbance column and summarize
gce_v04 <- gce_v03 %>% 
  dplyr::mutate(plot_disturbance = ifelse(plot_disturbance == 1,
    yes = "yes", no = "no")) %>% 
  dplyr::group_by(site, year, plot_disturbance) %>% 
  dplyr::summarize(biomass.mean = mean(total_plant_biomass_m2, na.rm = TRUE),
    biomass.sd = sd(total_plant_biomass_m2, na.rm = TRUE),
    biomass.n = dplyr::n(),
    biomass.se = (biomass.sd / sqrt(biomass.n)),
    .groups = "drop") %>% 
  dplyr::select(-biomass.sd, -biomass.n)

# Check structure
dplyr::glimpse(gce_v04)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
gce_v99 <- gce_v04

# One last structure check
dplyr::glimpse(gce_v99)

# Export locally
write.csv(gce_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_GCE_marsh-biomass.csv"))

# End ----
