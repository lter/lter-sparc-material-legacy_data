## -------------------------------------------- ##
# Fit GLMMs to Data
## -------------------------------------------- ##
# Purpose
## Analyze data and extract Z scores/other model metrics
## Works for all sites (but depends on outputs of respective `01` scripts)

# Need to quickly re-generate all standardized data files?
# purrr::walk(.x = dir("01_standardize", pattern = "*.r"), 
#   .f = ~ source(file.path("01_standardize", .x)))
### Note you'll need to have all the raw inputs locally downloaded already
### If you want the above to work

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, glmmTMB, broom.mixed, ggeffects)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

# Make a list for storing outputs
glm_list <- list()

## -------------------------------------------- ##
# Analyze Andrews Forest (AND) ----
## -------------------------------------------- ##

# Load data
and_df <- read.csv(file.path("data", "standard", "01_AND_live-dead-wood.csv"))

# Check structure
dplyr::glimpse(and_df)

# Fit GLMM and add to list
glm_list[["AND"]] <- glmmTMB::glmmTMB(
  tree.growth.m2.indiv.yr ~ dead.wood.mass.kg.ha + (1 | stand),
  data = and_df, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Bonanza Creek (BNZ) ----
## -------------------------------------------- ##

# Load data
bnz_df <- read.csv(file.path("data", "standard", "01_BNZ_forest-fire.csv"))

# Check structure
dplyr::glimpse(bnz_df)

# Fit GLMM and add to list
glm_list[["BNZ"]] <- glmmTMB::glmmTMB(
  mean.seeds.m2 ~ black.spruce.basal.area.cm2.m2 + (1 | burn/site),
  data = bnz_df, family = glmmTMB::tweedie(link = "log"))
## [KK]: False convergence warning; tried many alternative options, none of which resolved this.
## Proceeding anyway, but with caution; diagnostics dests won't run due to non-convergence

## -------------------------------------------- ##
# Analyze Florida Coastal Everglades (FCE) ----
## -------------------------------------------- ##

# Load data
fce_df <- read.csv(file.path("data", "standard", "01_FCE_root-litter.csv"))

# Check structure
dplyr::glimpse(fce_df)

# Fit GLMM and add to list
glm_list[["FCE"]] <- glmmTMB::glmmTMB(
  mean.root.production.g.m2.yr ~ mean.litter.g + (1 | site),
  data = fce_df, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Georgia Coastal Ecosystems (GCE) ----
## -------------------------------------------- ##

# Load data
gce_df <- read.csv(file.path("data", "standard", "01_GCE_marsh-biomass.csv")) %>% 
  dplyr::mutate(disturbance = ordered(disturbance, levels = c("absent", "present")))

# Check structure
dplyr::glimpse(gce_df)

# Fit GLMM and add to list
glm_list[["GCE"]] <- glmmTMB::glmmTMB(
  mean.plant.biomass.g.m2 ~ disturbance + (1 | site) + (1 | year),
  data = gce_df, family = stats::gaussian(link = "log"))

## -------------------------------------------- ##
# Analyze Harvard Forest (HFR) ----
## -------------------------------------------- ##

# Load data
hfr_df <- read.csv(file.path("data", "standard", "01_HFR_hemlock-removal.csv")) %>% 
  dplyr::mutate(treatment = factor(treatment, levels = c("logged", "girdled")))

# Check structure
dplyr::glimpse(hfr_df)

# Fit GLMM and add to list
glm_list[["HFR"]] <- glmmTMB::glmmTMB(
  hemlock.density.ha ~ treatment + (1 | block/plot) + (1 | year),
  data = hfr_df, family = glmmTMB::tweedie(link = "log"))

## -------------------------------------------- ##
# Analyze Konza Prairie (KNZ) ----
## -------------------------------------------- ##

# Load data
knz_df <- read.csv(file.path("data", "standard", "01_KNZ_grass.csv")) %>% 
  dplyr::mutate(burn = as.factor(burn))

# Check structure
dplyr::glimpse(knz_df)

# Fit GLMM and add to list
glm_list[["KNZ"]] <- glmmTMB::glmmTMB(
  mean.live.grass.g.dm2 ~ burn + (1 | year) + (1 | transect),
  data = knz_df, family = stats::gaussian(link = "log"))

## -------------------------------------------- ##
# Analyze Luquillo (LUQ) ----
## -------------------------------------------- ##

# Load data
luq_df <- read.csv(file.path("data", "standard", "01_LUQ_seedlings.csv")) %>% 
  dplyr::mutate(dplyr::across(.cols = treatment:plot, .fns = as.factor))

# Check structure
dplyr::glimpse(luq_df)

# Fit GLMM and add to list
glm_list[["LUQ"]] <- glmmTMB::glmmTMB(
  seedling.count ~ treatment + (1 | block/plot) + (1 | year),
  data = luq_df, family = glmmTMB::nbinom2)

## -------------------------------------------- ##
# Analyze Moorea Coral Reef (MCR) ----
## -------------------------------------------- ##

# Load data
mcr_df <- read.csv(file.path("data", "standard", "01_MCR_corals.csv"))

# Check structure
dplyr::glimpse(mcr_df)

# Fit GLMM and add to list
glm_list[["MCR"]] <- glmmTMB::glmmTMB(
  coral.live.percent.change ~ coral.dead.m2.start + (1 | treatment/plot) + (1 | year),
  data = mcr_df, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze SONGS ----
## -------------------------------------------- ##
# San Onofre Nuclear Generating Station (SONGS)

# Load data
songs_df <- read.csv(file.path("data", "standard", "01_SONGS_kelp-holdfasts.csv"))

# Check structure
dplyr::glimpse(songs_df)

# Fit GLMM and add to list
glm_list[["SONGS"]] <- glmmTMB::glmmTMB(
  kelp.recruit.density.m2 ~ kelp.holdfast.dead.percent.cover + (1 | reef/transect) + (1 | year),
  data = songs_df, family = glmmTMB::nbinom2(link = "log"))

## -------------------------------------------- ##
# Analyze Virginia Coastal Reserve (VCR) ----
## -------------------------------------------- ##

# Load data
vcr_df <- read.csv(file.path("data", "standard", "01_VCR_oysters.csv"))

# Check structure
dplyr::glimpse(vcr_df)

# Fit GLMM and add to list
glm_list[["VCR"]] <- glmmTMB::glmmTMB(
  mean.juvenile.oyster.count.quarter.m2 ~ mean.dead.oyster.count.quarter.m2 + (1 | site) + (1 | year),
  data = vcr_df, family = stats::Gamma(link = "log"))

## -------------------------------------------- ##
# Calculate Effect Sizes ----
## -------------------------------------------- ##

# Calculate effect sizes and get a tidy table
effects_v01 <- glm_list %>% 
  purrr::map(.f = ~ broom.mixed::tidy(x = .x, effects = "fixed",
    conf.int = TRUE, conf.level = 0.95)) %>% 
  purrr::imap(.f = ~ dplyr::mutate(.data = .x, lter = .y,
    .before = dplyr::everything())) %>% 
  purrr::list_rbind()
  
# Check structure
dplyr::glimpse(effects_v01)

## -------------------------------------------- ##
# Get Model Predictions ----
## -------------------------------------------- ##

# Get model predictions
pred_v01 <- glm_list %>% 
  purrr::map(.f = ~ ggeffects::ggpredict(model = .x,
    term = attr(.x$modelInfo$terms$cond$fixed, 
                "term.labels"))) %>% 
  purrr::map(.f = as.data.frame) %>% 
  purrr::imap(.f = ~ dplyr::mutate(.data = .x, lter = .y,
    .before = dplyr::everything())) %>% 
  purrr::map(.f = ~ dplyr::select(.data = .x, -dplyr::starts_with("group"))) %>% 
  purrr::map(.f = ~ dplyr::mutate(.data = .x, dplyr::across(.cols = dplyr::everything(),
    .fns = ~ as.character(.)))) %>% 
  purrr::list_rbind()

# Check structure
dplyr::glimpse(pred_v01)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# [Desired output TBD]

# End ----
