## -------------------------------------------- ##
# Download Data - Florida Coastal Everglades (FCE)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-fce.r`

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Litter Data ----
## -------------------------------------------- ##

# Read in litter data
fce_lit_v01 <- read.csv(file.path("data", "raw", "00_FCE__LT_PP_Castaneda_001.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(fce_lit_v01)

# Do needed filtering and preparatory wrangling
fce_lit_v02 <- fce_lit_v01 %>% 
  dplyr::filter((date > as.Date("2017-09-17") & date < as.Date("2019-03-01")))

# Check structure
dplyr::glimpse(fce_lit_v02)

# Summarize to deal with nested experimental design
fce_lit_v03 <- fce_lit_v02 %>% 
  dplyr::group_by(sitename, plot_id, basket_id) %>% 
  dplyr::summarize(total_weight = sum(total_weight, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::group_by(sitename, plot_id) %>% 
    dplyr::summarize(litter.mean = mean(total_weight, na.rm = TRUE),
  litter.sd = sd(total_weight, na.rm = TRUE),
  litter.n = dplyr::n(),
  litter.se = (litter.sd / sqrt(litter.n)),
    .groups = "drop") %>% 
  dplyr::select(-litter.sd, -litter.n)

# Check structure
dplyr::glimpse(fce_lit_v03)

## -------------------------------------------- ##
# Tidy Root Data ----
## -------------------------------------------- ##

# Read in root data
fce_root_v01 <- read.csv(file.path("data", "raw", "00_FCE__FCE_1278_Root_Production_post-Irma.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(fce_root_v01)

# Do needed filtering and preparatory wrangling
fce_root_v02 <- fce_root_v01 %>% 
  dplyr::filter(root_size_class == "Fine" & root_production > 0) %>% 
  dplyr::mutate(plot_id = ifelse(point %in% c("A", "B"),
    yes = 1, no = 2))

# Check structure
dplyr::glimpse(fce_root_v02)

# Summarize by site & plot
fce_root_v03 <- fce_root_v02 %>% 
  dplyr::group_by(sitename, plot_id) %>% 
  dplyr::summarize(root.prod.mean = mean(root_production, na.rm = TRUE),
    root.prod.sd = sd(root_production, na.rm = TRUE),
    root.prod.n = dplyr::n(),
    root.prod.se = (root.prod.sd / sqrt(root.prod.n)),
    .groups = "drop") %>% 
  dplyr::select(-root.prod.sd, -root.prod.n)

# Check structure
dplyr::glimpse(fce_root_v03)

## -------------------------------------------- ##
# Join Roots & Litter ----
## -------------------------------------------- ##

# Join the two data types
fce_v01 <- fce_root_v03 %>% 
  dplyr::left_join(x = ., y = fce_lit_v03, by = c("sitename", "plot_id"))

# Check structure
dplyr::glimpse(fce_v01)

# Ditch any sites without both litter and root info
fce_v02 <- fce_v01 %>% 
  dplyr::filter(!is.na(root.prod.mean) & !is.na(litter.mean))

# Check structure
dplyr::glimpse(fce_v02)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
fce_v99 <- fce_v02

# One last structure check
dplyr::glimpse(fce_v99)

# Export locally
write.csv(fce_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_FCE.csv"))

# End ----
