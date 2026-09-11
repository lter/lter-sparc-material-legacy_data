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

# Scale response/explanatory to Z scores
and_z <- and_df %>% 
  dplyr::mutate(
    tree.growth.m2.indiv.yr_z = scale(and_df$tree.growth.m2.indiv.yr)[, 1],
    dead.wood.mass.kg.ha_z = scale(and_df$dead.wood.mass.kg.ha)[, 1] )

# Check structure
dplyr::glimpse(and_z)
      
# Fit GLMM and add to list
glm_list[["AND"]] <- glmmTMB::glmmTMB(
  tree.growth.m2.indiv.yr_z ~ dead.wood.mass.kg.ha_z + (1 | stand),
  data = and_z, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Bonanza Creek (BNZ) ----
## -------------------------------------------- ##

# Load data
bnz_df <- read.csv(file.path("data", "standard", "01_BNZ_forest-fire.csv"))

# Check structure
dplyr::glimpse(bnz_df)

# Scale response/explanatory to Z scores
bnz_z <- bnz_df %>% 
  dplyr::mutate(
    mean.seeds.m2_z = scale(bnz_df$mean.seeds.m2)[, 1],
    black.spruce.basal.area.cm2.m2_z = scale(bnz_df$black.spruce.basal.area.cm2.m2)[, 1] )

# Check structure
dplyr::glimpse(bnz_z)
    
# Fit GLMM and add to list
glm_list[["BNZ"]] <- glmmTMB::glmmTMB(
  mean.seeds.m2_z ~ black.spruce.basal.area.cm2.m2_z + (1 | burn/site),
  data = bnz_z, family = stats::gaussian())
## [KK]: False convergence warning; tried many alternative options, none of which resolved this.
## Proceeding anyway, but with caution; diagnostics dests won't run due to non-convergence

## -------------------------------------------- ##
# Analyze Florida Coastal Everglades (FCE) ----
## -------------------------------------------- ##

# Load data
fce_df <- read.csv(file.path("data", "standard", "01_FCE_root-litter.csv"))

# Check structure
dplyr::glimpse(fce_df)

# Scale response/explanatory to Z scores
fce_z <- fce_df %>% 
  dplyr::mutate(
    mean.root.production.g.m2.yr_z = scale(fce_df$mean.root.production.g.m2.yr)[, 1],
    mean.litter.g_z = scale(fce_df$mean.litter.g)[, 1] )

# Check structure
dplyr::glimpse(fce_z)

# Fit GLMM and add to list
glm_list[["FCE"]] <- glmmTMB::glmmTMB(
  mean.root.production.g.m2.yr_z ~ mean.litter.g_z + (1 | site),
  data = fce_z, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Georgia Coastal Ecosystems (GCE) ----
## -------------------------------------------- ##

# Load data
gce_df <- read.csv(file.path("data", "standard", "01_GCE_marsh-biomass.csv")) %>% 
  dplyr::mutate(disturbance = ordered(disturbance, levels = c("absent", "present")))

# Check structure
dplyr::glimpse(gce_df)

# Scale response/explanatory to Z scores
gce_z <- gce_df %>% 
  dplyr::mutate(mean.plant.biomass.g.m2_z = scale(gce_df$mean.plant.biomass.g.m2)[, 1] )

# Check structure
dplyr::glimpse(gce_z)

# Fit GLMM and add to list
glm_list[["GCE"]] <- glmmTMB::glmmTMB(
  mean.plant.biomass.g.m2_z ~ disturbance + (1 | site) + (1 | year),
  data = gce_z, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Harvard Forest (HFR) ----
## -------------------------------------------- ##

# Load data
hfr_df <- read.csv(file.path("data", "standard", "01_HFR_hemlock-removal.csv")) %>% 
  dplyr::mutate(treatment = factor(treatment, levels = c("logged", "girdled")))

# Check structure
dplyr::glimpse(hfr_df)

# Scale response/explanatory to Z scores
hfr_z <- hfr_df %>% 
  dplyr::mutate(hemlock.density.ha_z = scale(hfr_df$hemlock.density.ha)[, 1] )

# Check structure
dplyr::glimpse(hfr_z)

# Fit GLMM and add to list
glm_list[["HFR"]] <- glmmTMB::glmmTMB(
  hemlock.density.ha_z ~ treatment + (1 | block/plot) + (1 | year),
  dispformula = ~ treatment,
  # (^^^) Allow residual variance to differ by treatment to account for heteroscedasticity
  data = hfr_z, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Konza Prairie (KNZ) ----
## -------------------------------------------- ##

# Load data
knz_df <- read.csv(file.path("data", "standard", "01_KNZ_grass.csv")) %>% 
  dplyr::mutate(burn = as.factor(burn))

# Check structure
dplyr::glimpse(knz_df)

# Scale response/explanatory to Z scores
knz_z <- knz_df %>% 
  dplyr::mutate(mean.live.grass.g.dm2_z = scale(knz_df$mean.live.grass.g.dm2)[, 1] )

# Check structure
dplyr::glimpse(knz_z)

# Fit GLMM and add to list
glm_list[["KNZ"]] <- glmmTMB::glmmTMB(
  mean.live.grass.g.dm2_z ~ burn + (1 | year) + (1 | transect),
  data = knz_z, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Luquillo (LUQ) ----
## -------------------------------------------- ##

# Load data
luq_df <- read.csv(file.path("data", "standard", "01_LUQ_seedlings.csv")) %>% 
  dplyr::mutate(dplyr::across(.cols = treatment:plot, .fns = as.factor))

# Check structure
dplyr::glimpse(luq_df)

# Scale response/explanatory to Z scores
luq_z <- luq_df %>% 
  dplyr::mutate(seedling.count_z = scale(luq_df$seedling.count)[, 1] )

# Check structure
dplyr::glimpse(luq_z)

# Fit GLMM and add to list
glm_list[["LUQ"]] <- glmmTMB::glmmTMB(
  seedling.count_z ~ treatment + (1 | block/plot) + (1 | year),
  data = luq_z, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze Moorea Coral Reef (MCR) ----
## -------------------------------------------- ##

# Load data
mcr_df <- read.csv(file.path("data", "standard", "01_MCR_corals.csv")) %>% 
  dplyr::mutate(year = as.factor(year))

# Check structure
dplyr::glimpse(mcr_df)

# Scale response/explanatory to Z scores
mcr_z <- mcr_df %>% 
  dplyr::mutate(
    coral.live.percent.change_z = scale(mcr_df$coral.live.percent.change)[, 1],
    coral.dead.m2.start_z = scale(mcr_df$coral.dead.m2.start)[, 1] )

# Check structure
dplyr::glimpse(mcr_z)

# Fit GLMM and add to list
glm_list[["MCR"]] <- glmmTMB::glmmTMB(
  coral.live.percent.change_z ~ coral.dead.m2.start_z + (1 | treatment/plot) + (1 | year),
  data = mcr_z, family = stats::gaussian())

## -------------------------------------------- ##
# Analyze SONGS ----
## -------------------------------------------- ##
# San Onofre Nuclear Generating Station (SONGS)

# Load data
songs_df <- read.csv(file.path("data", "standard", "01_SONGS_kelp-holdfasts.csv"))

# Check structure
dplyr::glimpse(songs_df)

# Scale response/explanatory to Z scores
songs_z <- songs_df %>% 
  dplyr::mutate(
    kelp.recruit.density.m2_z = scale(songs_df$kelp.recruit.density.m2)[, 1],
    kelp.holdfast.dead.percent.cover_z = scale(songs_df$kelp.holdfast.dead.percent.cover)[, 1] )

# Check structure
dplyr::glimpse(songs_z)

# Fit GLMM and add to list
glm_list[["SONGS"]] <- glmmTMB::glmmTMB(
  kelp.recruit.density.m2 ~ kelp.holdfast.dead.percent.cover_z + (1 | reef/transect) + (1 | year),
  ## Note (^^^): response is unscaled, _NOT_ the scaled Z score version!
  data = songs_z, family = glmmTMB::nbinom2(link = "log"))

## -------------------------------------------- ##
# Analyze Virginia Coastal Reserve (VCR) ----
## -------------------------------------------- ##

# Load data
vcr_df <- read.csv(file.path("data", "standard", "01_VCR_oysters.csv"))

# Check structure
dplyr::glimpse(vcr_df)

# Scale response/explanatory to Z scores
vcr_z <- vcr_df %>% 
  dplyr::mutate(
    mean.juvenile.oyster.count.quarter.m2_z = scale(vcr_df$mean.juvenile.oyster.count.quarter.m2)[, 1],
    mean.dead.oyster.count.quarter.m2_z = scale(vcr_df$mean.dead.oyster.count.quarter.m2)[, 1] )

# Check structure
dplyr::glimpse(vcr_z)

# Fit GLMM and add to list
glm_list[["VCR"]] <- glmmTMB::glmmTMB(
  mean.juvenile.oyster.count.quarter.m2_z ~ mean.dead.oyster.count.quarter.m2_z + (1 | site) + (1 | year),
  data = vcr_z, family = stats::gaussian())

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
