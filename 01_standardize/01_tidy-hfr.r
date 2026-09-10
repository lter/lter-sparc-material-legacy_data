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
# Tidy Predictor Data ----
## -------------------------------------------- ##

# Load predictor variables
hfr_pred_v01 <- read.csv(file.path("data", "from-drive", "DeadByPlot.csv"))

# Check structure
dplyr::glimpse(hfr_pred_v01)

# Summarize to get unique rows
hfr_pred_v02 <- hfr_pred_v01 %>% 
  dplyr::group_by(plot, trt, group, block, year) %>% 
  dplyr::summarize(volm3ha.mean = mean(volm3ha, na.rm = TRUE),
    massgm2.mean = mean(massgm2, na.rm = TRUE),
    .groups = "drop")

# Reshape wider
hfr_pred_v03 <- hfr_pred_v02 %>% 
  tidyr::pivot_wider(names_from = group, 
    values_from = c(volm3ha.mean, massgm2.mean))

# Check structure
dplyr::glimpse(hfr_pred_v03)

## -------------------------------------------- ##
# Tidy Response Data ----
## -------------------------------------------- ##

# Load response data
hfr_resp_v01 <- read.csv(file.path("data", "from-drive", "TreeSapDensSpecies.csv"))

# Check structure
dplyr::glimpse(hfr_resp_v01)

# Simplify some categorical columns in data
hfr_resp_v02 <- hfr_resp_v01 %>% 
  dplyr::mutate(
    species = ifelse(nchar(species) == 0 | is.na(species),
      yes = "none", no = species),
    spgroup = dplyr::case_when(
      species == "TSCA" ~ "hemlock",
      species %in% c("BEAL", "BELE") ~ "birch",
      TRUE ~ "other"))

# Check structure
dplyr::glimpse(hfr_resp_v02)

# Summarize within needed columns
hfr_resp_v03 <- hfr_resp_v02 %>% 
  dplyr::group_by(plot, trt, block, year, spgroup, stratum) %>%
  dplyr::summarize(dens_ha = sum(dens.ha, na.rm = TRUE),
    biomass_gm2 = sum(biomass.gm2, na.rm = TRUE),
    .groups = "drop")

# Check structure
dplyr::glimpse(hfr_resp_v03)

# Reshape and calculate needed metrics
hfr_resp_v04 <- hfr_resp_v03 %>% 
  tidyr::pivot_wider(names_from = spgroup, 
    values_from = c(dens_ha, biomass_gm2),
    values_fill = 0) %>% 
  dplyr::mutate(
    dens_ha_total = dens_ha_hemlock + dens_ha_birch + dens_ha_other,
    biomass_gm2_total = biomass_gm2_hemlock + biomass_gm2_birch + biomass_gm2_other 
  )

# Check structure
dplyr::glimpse(hfr_resp_v04)

## -------------------------------------------- ##
# Combine & Filter Data ----
## -------------------------------------------- ##

# Join the two data files
hfr_v01 <- hfr_resp_v04 %>% 
  dplyr::inner_join(x = ., y = hfr_pred_v02,
    by = c("plot", "year", "trt", "block"))

# Check structure
dplyr::glimpse(hfr_v01)

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
