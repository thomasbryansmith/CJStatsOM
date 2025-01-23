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
yih %>% head()

# Get "education level" variable as a separate factor vector.
educ <- df$EDUC
educ %>% head()

# Invidual statistics were introduced in the previous classes
# so here we are going to focus on approaches to calculating complete
# tables of descriptive statistics.

# But, just to recap:
# Median
median(yih, na.rm = TRUE)

# Mean
mean(yih, na.rm = TRUE)

# Variance
var(yih, na.rm = TRUE)

# Standard Deviation
sd(yih, na.rm = TRUE)

# Minimum
min(yih, na.rm = TRUE)

# Maximum
max(yih, na.rm = TRUE)

# The stats package equips you with the fivenum() function.
# This functipn returns the minimum, 25th percentile,
# median, 75th percentile, and maximum in a single vector.
fivenum(yih)

# The sapply() function, from the apply() family of functions,
# can be used to apply a statistical function across all columns
# of an input data frame. You just need to make sure you index
# the data frame to extract the columns you want to describe:
sapply(df[, c("YEAR", "YIH", "VIOLENT", "NONVIOLENT")],
       mean,
       na.rm = TRUE)

# But, after a little bit of practice with these functions,
# it is much easier to generate descriptives for all of your
# variables using dplyr:
df %>%
  summarise(median = c(median(YIH, na.rm = TRUE),
                       median(as.numeric(AGE), na.rm = TRUE)),
            mean = c(mean(YIH, na.rm = TRUE),
                     mean(as.numeric(AGE), na.rm = TRUE)),
            sd = c(sd(YIH, na.rm = TRUE),
                   sd(as.numeric(AGE), na.rm = TRUE)),
            min = c(min(YIH, na.rm = TRUE),
                    min(as.numeric(AGE), na.rm = TRUE)),
            max = c(max(YIH, na.rm = TRUE),
                    max(as.numeric(AGE), na.rm = TRUE)))

# Note: this code is "deprecated", meaning that the developers
# of dplyr consider it to be "of little value". As in most cases,
# this is because there is a "better" (easier or more appropriate) 
# approach to getting the same result. Here, if you read the error,
# it is telling us to use the newer reframe() function:
df %>%
  reframe(median = c(median(YIH, na.rm = TRUE),
                     median(as.numeric(AGE), na.rm = TRUE)),
          mean = c(mean(YIH, na.rm = TRUE),
                   mean(as.numeric(AGE), na.rm = TRUE)),
          sd = c(sd(YIH, na.rm = TRUE),
                 sd(as.numeric(AGE), na.rm = TRUE)),
          min = c(min(YIH, na.rm = TRUE),
                  min(as.numeric(AGE), na.rm = TRUE)),
          max = c(max(YIH, na.rm = TRUE),
                  max(as.numeric(AGE), na.rm = TRUE)))

# If your eyes are rolling back into your head reading this code,
# that's fine! That was the point. Working with these base functions
# can be complicated very quickly, which is why we have packages!

# As with the stats fivenum() function, there is a suite of functions
# we can use to calculate a range of statistics at the same time:
##  Summary (Base R)
summary(yih)

## Descriptive Statistics (pastecs)
stat.desc(yih)

## Describe (Hmisc)
Hmisc::describe(yih)

## Describe (Psych)
psych::describe(yih)

### Note: when you have two functions with the same name from
### two different packages, the package you read in most
### recently will "mask" the function from the earlier package.
### This means that, when you call that function, it will
### prioritize the most recent package. It is generally to avoid
### these conflicts, but in situations where you need both, you
### can use the "[package name]::" prefix to tell R which
### package you want to pull the function from. Above, we told
### R that we wanted to use Hmisc in the first instance,
### and psych in the second instance.

# Conveniently, some of these functions are already equipped
# to generate descriptives for multiple variables:
df %>%
  select(YIH, AGE, EDUC) %>%
  psych::describe()

## Some of the output from this function have asterisks (*),
## this is psych's describe() function trying to inform you that
## these variables were not numeric vectors (remember, they are factors,
## but describe() is able to automatically treat them as numeric!)
## If you use mutate() to convert them into numeric vectors, these
## asterisks will go away:
df %>%
  select(YIH, AGE, EDUC) %>%
  mutate(AGE = as.numeric(AGE),
         EDUC = as.numeric(EDUC)) %>%
  psych::describe()

# ============================================================================ #

# In cases where your goal is to compare groups within your data, and plan on
# implementing interaction terms in your statistical models, you will need
# to generate descriptive statistics for specific subsets of your data.

# This can be achieved through logical indexing.
# So, if we wanted to find the mean "years in household" for men,
# we would write:
mean(df$YIH[df$SEX == "Male"], na.rm = TRUE)

# Alternatively, for women:
mean(df$YIH[df$SEX == "Female"], na.rm = TRUE)

# You can also use dplyr:
df %>%
  filter(SEX == "Male",
         complete.cases(df)) %>%
  summarise(mean = mean(YIH))

# You can combine dplyr with the sapply() function to calculate
# a given descriptive for every column in the data:
df %>%
  filter(SEX == "Male",
         complete.cases(df)) %>%
  mutate(AGE = as.numeric(AGE),
         EDUC = as.numeric(EDUC)) %>%
  select(YIH, AGE, EDUC) %>%
  sapply(mean)

# Any of the above functions can accept any of the logical operations:
mean(df$YIH[as.numeric(df$AGE) >= 4], na.rm = TRUE)   # 4 is "35-39 y/o"

df %>%
  mutate(AGE = as.numeric(AGE)) %>%
  filter(AGE >= 4,
         !is.na(YIH)) %>%
  summarise(mean = mean(YIH))

# Or, any combination of logical operations and functions
# (remember, "|" is "or", "&" is "and"):
mean(df$YIH[(as.numeric(df$AGE) >= 5) |       # TRUE if >= "35-39 y/o"
            (as.numeric(df$AGE) <= 2)],       # TRUE if <= "18-24 y/o"
     na.rm = TRUE)

mean(df$YIH[(as.numeric(df$AGE) >= 4) &       # TRUE if >= "35-39 y/o"
            (!is.na(df$YIH))])                # TRUE for non-missing

# ---- end_mct
# ============================================================================ #
## EXERCISE 2.a
### Find the median "years in household" for respondents who are
### older than 34.
# ============================================================================ #
## EXERCISE 2.b
### Calculate the summary statistics for level of education (ordinal, factor)
### for female respondents.
# ============================================================================ #
## EXERCISE 2.c
### Calculate the summary statistics for "years in household" and
### "level of education" for male victims of violent crime.
# ============================================================================ #

############################################################################## #
###                        3. FREQUENCY TABLES                              ====
############################################################################## #
## ---- freq-tab



## ---- end_freq-tab
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #

############################################################################## #
###                     4. BASIC GRAPH FUNCTIONS                            ====
############################################################################## #
## ---- basic-graphs



## ---- end_basic-graphs
# ============================================================================ #
# ============================================================================ #
# ============================================================================ #

############################################################################## #
###                         5. 3D SCATTER PLOTS                             ====
############################################################################## #
## ---- 3d-plots



## ---- end_3d-plots
############################################################################## #
###                            6. GGPLOT2                                   ====
############################################################################## #
## ---- ggplot2



## ---- end_ggplot2
# ============================================================================ #
# ============================================================================ #