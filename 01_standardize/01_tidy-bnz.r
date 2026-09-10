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

## -------------------------------------------- ##
# Tidy Seed Rain Data ----
## -------------------------------------------- ##

# Read in the relevant file
bnz_seed_v01 <- read.csv(file = file.path("data", "raw", 
  "00_BNZ__391_JFSP_seedrain_viab.txt"), sep = "\t")

# Check structure
dplyr::glimpse(bnz_seed_v01)

# Check for non-numbers in ostensibly numeric column(s)
supportR::num_check(data = bnz_seed_v01, col = "Viability")

# Repair non-numbers and filter out unwanted dates
bnz_seed_v02 <- bnz_seed_v01 %>% 
  dplyr::mutate(Viability = as.numeric(ifelse(Viability == "n/a", yes = NA, no = Viability))) %>% 
  dplyr::filter(Date %in% c("05-Aug", 
# "06-May", "06-Aug", 
"07-Jun"))

# "05-Aug" "06-May" "06-Aug" "07-Jun"

# Check structure
dplyr::glimpse(bnz_seed_v02)

# Repair non-numbers and summarize these data across dates
bnz_seed_v03 <- bnz_seed_v02 %>% 
  dplyr::group_by(Site) %>% 
  dplyr::summarize(
    seed.viab.mean = mean(Viability, na.rm = TRUE),
    seed.viab.se = (sd(Viability, na.rm = TRUE) / sqrt(dplyr::n())),
    total.seed.mean = mean(Seeds, na.rm = TRUE),
    total.seed.se = (sd(Seeds, na.rm = TRUE) / sqrt(dplyr::n())),
    total.germ.mean = mean(Germ, na.rm = TRUE),
    .groups = "drop")

    # average total number of spruce seeds/m2 for Aug05 and Jun07 collection periods.

# Check structure
dplyr::glimpse(bnz_seed_v03)

## -------------------------------------------- ##
# Tidy Forest Fire Data ----
## -------------------------------------------- ##

# Load in the data file
bnz_v01 <- read.csv(file = file.path("data", "raw", "00_BNZ__342_JFSP_sitedata_2011.txt"),
    sep = "\t")

# Check structure
dplyr::glimpse(bnz_v01)

# Rename and calculate necessary columns
bnz_v02 <- bnz_v01 %>% 
  dplyr::mutate(
    type = ifelse(type == "int", yes = "intensive", no = type),
    black.spruce.standing.basal.area = BS.ba * X.Standing_Num) %>% 
  dplyr::rename(black.spruce.basal.area = BS.ba) # cm2 stem / ha


# Check structure
dplyr::glimpse(bnz_v02)

# Pare down to only rows / columns that are needed
bnz_v03 <- bnz_v02 %>% 
  dplyr::filter(type != "ext") %>% 
  dplyr::select(burn, site, type, dplyr::starts_with("black.spruce"))

# Check structure
dplyr::glimpse(bnz_v03)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
bnz_v99 <- bnz_v03 %>% 
  dplyr::rename_with(.fn = ~ tolower(gsub(pattern = "_", replacement = ".", x = .)))

# One last structure check
dplyr::glimpse(bnz_v99)

# Export locally
write.csv(bnz_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_BNZ_forest-fire.csv"))

# End ----
