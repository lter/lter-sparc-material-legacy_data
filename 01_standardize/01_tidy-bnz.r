## -------------------------------------------- ##
# Standardize Data - Bonanza Creek (BNZ)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-bnz.r`

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
  "00_BNZ__390_JFSP_seedrain_counts.txt"), sep = "\t")

# Check structure
dplyr::glimpse(bnz_seed_v01)

# Check for non-numbers in ostensibly numeric column(s)
supportR::num_check(data = bnz_seed_v01, col = "Seeds")

# Fix existing columns, generate new ones
bnz_seed_v02 <- bnz_seed_v01 %>% 
  dplyr::mutate(
    Seeds = as.numeric(ifelse(Seeds == "n/a", yes = NA, no = Seeds)),
    per_trap_area_m2 =  (52 / 100) * (22.5 / 100), # Traps were 52cm x 22.5cm (from EDI docs)
    trap_area_m2 = X.Traps * per_trap_area_m2) 

# Check structure
dplyr::glimpse(bnz_seed_v02)
    
# Filter out unwanted rows
bnz_seed_v03 <- bnz_seed_v02 %>% 
  dplyr::filter(Date %in% c("25-Aug-05", "09-Jun-07"))

# Check structure
dplyr::glimpse(bnz_seed_v03)

# Summarize these data across samples within date, then across dates
bnz_seed_v04 <- bnz_seed_v03 %>% 
  dplyr::group_by(Site, Date) %>% 
  dplyr::summarize(seeds = sum(Seeds, na.rm = TRUE),
    traps_area = sum(trap_area_m2, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::mutate(seed.total.m2 = seeds / traps_area) %>% 
  dplyr::group_by(Site) %>% 
  dplyr::summarize(seed.total.m2.mean = mean(seed.total.m2, na.rm = TRUE),
    seed.total.m2.se = (sd(seed.total.m2, na.rm = TRUE) / sqrt(dplyr::n())),
    .groups = "drop")

# Check structure
dplyr::glimpse(bnz_seed_v04)

## -------------------------------------------- ##
# Tidy Tree Data ----
## -------------------------------------------- ##

# Load in the data file
bnz_tree_v01 <- read.csv(file = file.path("data", "raw", 
  "00_BNZ__342_JFSP_sitedata_2011.txt"), sep = "\t")

# Check structure
dplyr::glimpse(bnz_tree_v01)

# Rename and calculate necessary columns
bnz_tree_v02 <- bnz_tree_v01 %>% 
  dplyr::mutate(black.spruce.standing.basal.area = BS.ba * X.Standing_Num) %>% 
  dplyr::rename(black.spruce.basal.area = BS.ba) # cm2 stem / ha

# Check structure
dplyr::glimpse(bnz_tree_v02)

# Pare down to only rows / columns that are needed
bnz_tree_v03 <- bnz_tree_v02 %>% 
  dplyr::filter(type != "ext") %>% 
  dplyr::select(burn, site, dplyr::starts_with("black.spruce"))

# Check structure
dplyr::glimpse(bnz_tree_v03)

## -------------------------------------------- ##
# Combine Seed & Tree Data ----
## -------------------------------------------- ##

# Join the data
bnz_v01 <- dplyr::full_join(x = bnz_tree_v03, y = bnz_seed_v04,
  by = c("site" = "Site"))

# Check structure
dplyr::glimpse(bnz_v01)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
bnz_v99 <- bnz_v01 %>% 
  dplyr::rename_with(.fn = ~ tolower(gsub(pattern = "_", replacement = ".", x = .))) %>% 
  dplyr::select(burn, site, 
    black.spruce.basal.area.cm2.m2 = black.spruce.basal.area, 
    mean.seeds.m2 = seed.total.m2.mean)

# One last structure check
dplyr::glimpse(bnz_v99)

# Export locally
write.csv(bnz_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_BNZ_forest-fire.csv"))

# End ----
