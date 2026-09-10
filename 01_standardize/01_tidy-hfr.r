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
librarian::shelf(tidyverse, janitor)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Hemlock Data ----
## -------------------------------------------- ##

# Load relevant data
hfr_v01 <- read.csv(file.path("data", "from-drive", "TreeSapDensSpecies.csv"))

# Check structure
dplyr::glimpse(hfr_v01)

# Simplify some categorical columns in data
hfr_v02 <- hfr_v01 %>% 
  dplyr::mutate(
    species = ifelse(nchar(species) == 0 | is.na(species),
      yes = "none", no = species),
    spgroup = dplyr::case_when(
      species == "TSCA" ~ "hemlock",
      species %in% c("BEAL", "BELE") ~ "birch",
      TRUE ~ "other"))

# Check structure
dplyr::glimpse(hfr_v02)

# Do some needed filtering
hfr_v03 <- hfr_v02 %>% 
  dplyr::filter(trt %in% c("girdled", "logged")) %>% 
  dplyr::filter(stratum == "Sapling") %>% 
  dplyr::filter(year > 2004)

# Check structure
dplyr::glimpse(hfr_v03)

# Summarize within needed columns
hfr_v04 <- hfr_v03 %>% 
  dplyr::group_by(plot, trt, block, year, spgroup) %>%
  dplyr::summarize(dens_ha = sum(dens.ha, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::group_by(plot, trt, block, year) %>% 
  dplyr::mutate(dens_ha_total = sum(dens_ha, na.rm = TRUE)) %>% 
  dplyr::ungroup()

# Check structure
dplyr::glimpse(hfr_v04)

# Filter to only hemlock density data
hfr_v05 <- hfr_v04 %>% 
  dplyr::filter(spgroup == "hemlock") %>% 
  dplyr::rename(dens_ha_hemlock = dens_ha) %>% 
  dplyr::select(-spgroup)

# Check structure
dplyr::glimpse(hfr_v05)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
hfr_v99 <- hfr_v05

# One last structure check
dplyr::glimpse(hfr_v99)

# Export locally
write.csv(hfr_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_HFR_hemlock-removal.csv"))

# End ----
