## -------------------------------------------- ##
# Fit GLMMs to Data
## -------------------------------------------- ##
# Purpose
## Analyze data and extract Z scores/other model metrics
## Works for all sites (but depends on outputs of respective `01` scripts)

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, glmmTMB)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()


# End ----
