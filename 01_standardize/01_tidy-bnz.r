## -------------------------------------------- ##
# Standardize Data - Bonanza Creek (BNZ)
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

# Define 3-letter site abbreviation
site_abbrev <- "BNZ"

## -------------------------------------------- ##
# Tidy Forest Fire Data ----
## -------------------------------------------- ##

# Load in the data file
bnz_v01 <- read.csv(file = file.path("data", "raw", "00_BNZ__342_JFSP_sitedata_2011.txt"),
    sep = "\t")

# Check structure
dplyr::glimpse(bnz_v01)

names(bnz_v01)

# Pare down the dataset to only rows/columns that are needed
bnz_v02 <- bnz_v01 %>% 
  dplyr::filter(type != "ext") %>% 
  dplyr::select(burn, site, type, BS.ba
    # , BS.stg.ba, total.m2 <absent from data; calculated by user?>
    )

# Check structure
dplyr::glimpse(bnz_v02)

# Filter as needed
bnz_v03 <- bnz_v02 %>% 
  dplyr::filter(type != "ext")

# Check structure
dplyr::glimpse(bnz_v03)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
bnz_v99 <- bnz_v03

# One last structure check
dplyr::glimpse(bnz_v99)

# Export locally
write.csv(bnz_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_BNZ_forest-fire.csv"))


# End ----
