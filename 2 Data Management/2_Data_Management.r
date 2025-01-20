# Title: Data Management
# Subtitle: CJ 702 Advanced Criminal Justice Statistics
# Author: Thomas Bryan Smith <tbsmit10@olemiss.edu>
# GitHub: thomasbryansmith/CJStatsOM
#
# Released under MIT License
# https://github.com/thomasbryansmith/CJStatsOM?tab=MIT-1-ov-file

############################################################################## #
###                   1. Setup Environment and Import Data                  ====
############################################################################## #
## ---- import

# As always, we want to start by loading in the package(s) we plan on using:
library(tidyverse)

# Next, we need to read in the data we need to manage. We are going
# to work with a small subset of the National Crime Victimization
# Survey (NCVS) MSA Public-Use Data, 2000-2015. I have already
# prepared a subset of these data, but you can download the full
# data here: https://www.icpsr.umich.edu/web/NACJD/studies/38321

#   United States. Bureau of Justice Statistics.
#   National Crime Victimization Survey: MSA Public-Use Data,
#   2000-2015. Inter-university Consortium for Political and
#   Social Research [distributor], 2022-03-21.
#   https://doi.org/10.3886/ICPSR38321.v1

# In this module we are going to practice some subsetting
# and cleaning, then merge the different levels of data
# datasets so that we have something to work with when we
# reach the multilevel modelling module

# Read in the data:
household <- readRDS("./Data/household.rds")
person <- readRDS("./Data/person.rds")
incident <- readRDS("./Data/incident.rds")

# Variables
## YEAR: Year of Interview
## YEARQ: Year and Quarter of Interview
## IDPER: Person ID
## IDHH: Household ID
## MSAIND: MSA Indicator

## Household
### V2026: Household income
### V2125: Land Use (Urban v. Rural)
### WGTHH: Household Weight

## Person
### V3014: Age
### V3018: Sex
### V3020: Educational Attainment
### V3022: Race (2000 - 2002)
### V3023: Race (2003 - 2015)
### WGTPER: Person Weight

## Incident
### MSAIND: MSA Indicator
### TOC_RECODE: Violent Crime Code
### WGTVIC: Victimization Weight
### SERIESWGT: Series Weight

## ---- end_import

############################################################################## #
###                            2. Indexing                                  ====
############################################################################## #
## ---- index

## ---- end_index
# ============================================================================ #
## EXERCISE:
###
###
# ============================================================================ #

############################################################################## #
###                         3. Data Manipulation                            ====
############################################################################## #
## ---- manip

## ---- end_manip
# ============================================================================ #
## EXERCISE:
###
###
# ============================================================================ #

############################################################################## #
###                       4. Missingness and Cleaning                       ====
############################################################################## #
## ---- missi

## ---- end_missi
# ============================================================================ #
## EXERCISE:
###
###
# ============================================================================ #

############################################################################## #
###                          5. Sampling Weights                            ====
############################################################################## #
## ---- weigh

## ---- end_weigh
# ============================================================================ #
## EXERCISE:
###
###
# ============================================================================ #

############################################################################## #
###                          6. Exporting your Data                         ====
############################################################################## #
## ---- exprt

## ---- end_exprt
# ============================================================================ #
## EXERCISE:
###
###
# ============================================================================ #