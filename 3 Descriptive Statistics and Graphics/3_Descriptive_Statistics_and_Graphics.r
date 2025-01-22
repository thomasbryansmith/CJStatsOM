# Title: Descriptive Statistics and Graphics
# Subtitle: CJ 702 Advanced Criminal Justice Statistics
# Author: Thomas Bryan Smith <tbsmit10@olemiss.edu>
# GitHub: thomasbryansmith/CJStatsOM
#
# Released under MIT License
# https://github.com/thomasbryansmith/CJStatsOM?tab=MIT-1-ov-file

############################################################################## #
###                  1. Loading Packages and Reading Data                   ====
############################################################################## #
## ---- setup

# install relevant packages:
# install.packages(c("readr", "Hmisc", "pastecs", "psych"))

# Load relevant packages:
library(tidyverse)
library(readr)
library(Hmisc)
library(pastecs)
library(psych)

# Import the data
df <- readRDS("./Data/person.rds")

# Check your data
df %>% head()

# Using the indexing learned in the previous workshop further check your data.
# This can be done either by indexing by the column number:
df[, 5:9] %>% head()

# Or by indexing the column names:
df[, c("V3014", "V3018", "V3020", "WGTPER", "YIH")] %>% head()

# Or by using the select() function from dplyr:
df %>%
  select(V3014, V3018, V3020, WGTPER, YIH) %>%
  head()

# Some of the column names for variables we want to work with are
# unintuitive, let's update a couple of them:
colnames(df)[which(colnames(df) %in% c("V3014",
                                       "V3018"))] <- c("AGE",
                                                       "SEX")

# Now let's extract just the columns we want to work with:
(df <- df %>%
   select(YEAR, YEARQ, IDPER, AGE, SEX,
          EDUC, YIH, VIOLENT, NONVIOLENT))

## ---- end_setup
############################################################################## #
###            2. MEASURES OF CENTRAL TENDENCY AND DISPERSION               ====
############################################################################## #
## ---- mct

# The simplest method of estimating descriptive statistics is to do so
# individually for each vector you are interested in. Since each variable is
# a vector of your data frame you can either extract the vector for
# the variable of interest, or index your data frame object such that
# you are targeting the vector for the variable interest.

# Get "years in household" variable as a separate numeric vector.
yih <- df$YIH
yih

# Get "education level" variable as a separate factor vector.
educ <- df$EDUC
educ

# Invidual statistics were introduced in the first class, "Introducing R",
# so here we are going to focus on approaches to calculating complete
# tables of descriptive statistics.