## -------------------------------------------- ##
# Standardize Data - Andrews Forest (AND)
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
# Load Live & Dead Wood Data ----
## -------------------------------------------- ##

# Load dead data
and_dead <- read.csv(file = file.path("data", "from-drive", "OHJA_downed wood summary_v2.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(and_dead)

# Load live data
and_live <- read.csv(file = file.path("data", "from-drive", "PSP_Plot_Change_20year_PSME.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(and_live)

## -------------------------------------------- ##
# Combine Live & Dead Wood ----
## -------------------------------------------- ##

# Join these files
and_v01 <- dplyr::inner_join(x = and_dead, y = and_live,
    by = c("stand", "plot", "year" = "cwd_year"))

# Check structure
dplyr::glimpse(and_v01)

# Calculate desired metrics
and_v02 <- and_v01 %>% 
  dplyr::mutate(dw_mass_ha = (total_mass / area_ha),
    dw_vol_ha = (total_volume / area_ha),
    dw_cover_ha = (total_cover / area_ha),
    dw_area_ha = (total_area / area_ha),
    tree_growth_ind = (growth_baph_spp / (tph0_spp * surv_prop_spp) / d_year))

# Check structure
dplyr::glimpse(and_v02)

# Pare down to only needed columns
and_v03 <- and_v02 %>% 
  dplyr::select(stand, plot, year, baph0_spp, baoh1_spp, dw_mass_ha:tree_growth_ind)

# Check what was lost
supportR::diff_check(old = names(and_v02), new = names(and_v03))

# Check structure
dplyr::glimpse(and_v03)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
and_v99 <- and_v03

# One last structure check
dplyr::glimpse(and_v99)

# Export locally
write.csv(and_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_AND_live-dead-wood.csv"))

# End ----
