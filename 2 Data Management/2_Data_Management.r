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

## Household
### V2026: Household income
### V2125: Land Use (Urban v. Rural)
### WGTHH: Household Weight

## Person
### V3014: Age
### V3018: Sex
### V3020: Educational Attainment
### WGTPER: Person Weight

## Incident
### TOC_RECODE: Violent Crime Code
### WGTVIC: Victimization Weight
### SERIESWGT: Series Weight

# Before we move on, let's quickly just view these three datasets:
## Household
head(household)

## Person
head(person)

## Incident
head(incident)

## ---- end_import

############################################################################## #
###                       2. Indexing and Recoding                          ====
############################################################################## #
## ---- index

# First, let's extract a variable to work with:
income <- household$V2026

# Now let's familiarize ourself with the variable.
# What class is the vector?
class(income)

# Factors are a special type of vector, typically used for labelling
# ordinal and nominal variables. When printed, factors appear
# similar to a character vector:
head(income)

# However, you'll notice that there are 'levels':
levels(income)

# This is because the vector is, at it's core, numeric.
# Using the as.numeric() function will reveal the numbers
# underlying each response in the variable:
income |> as.numeric() |> head()
# The first 6 observations are the 14th, 13th, 9th, 12th, 9th, and 15th
# level of the factor. You can use the levels() function to cross ref.

# Finally, let's tabulate the variable:
table(income)

# ============================================================================ #

# Indexing is the process by which you tell R which elements of a vector
# you want to return. For example, if you want the first element of a vector:
income[1]

# Or the fifty-second element of the vector:
income[52]

# If you want to return a set of elements, you have to index with a
# vector of numbers. If you wanted the first 10, you would enter:
income[1:10]

# Because "1:10" generates a vector of numbers from 1 to 10:
1:10

# This also works using the seq() function:
income[seq(1, 10)]

# The index vector can be any set of numbers, as long as it
# describes a set of meaningful positions in the vector.
# For instance, you could select every other element:
(n <- length(income))
income[seq(1, n, by = 2)] |> head()

# Why is this important? Because it allows you to subset your data.
# If you wanted to extract every other element in the vector,
# you could simply assign the result of the previous code to an object:
income_subset <- income[seq(1, n, by = 2)]
head(income_subset)

# When we tabled the income variable, you may have noticed the "Residue"
# label. This is a special code in NCVS which encodes incomplete data
# collection. These data are effectively missing, but are not encoded as
# "NA" - R's missing data code. You can use indexing to find "Residue":
income[which(income == "Residue")] |> head()

# You can also set up the logical operation to check the number ("level")
# associated with the factor label, rather than the label for that level:
income[which(as.numeric(income) == 15)] |> head()

# Why is this important? Because it allows you to replace non-standard
# missing codes with the "NA" special character. This is how you
# "find and replace" using R syntax.
income[which(income == "Residue")] <- NA

# I have already performed this operation for every other variable in
# the data, but let's correct the income variable (V2026) in the data
# by recoding "Residue" as "NA" (remember: the $ character allows
# you to extract or target a specific variable from a data frame):
household$V2026[which(household$V2026 == "Residue")] <- NA

# If you tabulate the income variable in the household data frame,
# you will see that there are no more "Residue" observations:
table(household$V2026)

# However, you will also see that "Residue" still appears as a label.
# You can redefine the labels of the factor. First, extract the old
# labels using the levels() function:
(labels <- levels(household$V2026))

# We do not want the "Residue" label (and level), so let's extract
# every other label from this vector of labels:
(labels <- labels[which(labels != "Residue")])

# Now we can use the factor() variable to tell R what we want
# the new labels to be:
household$V2026 <- factor(household$V2026, labels = labels)

# On an important note, you need to make sure that your labels
# are presented in the order that match the variable coding.
# If we have a variable consisting of 3 values:
(var <- c(1:3, 2:3))

# If the encoding scheme is 1 = a, 2 = b, 3 = c, then you only
# need to specify the "labels" option because the levels of the
# oridinal variable already match the order of the labels:
factor(var, labels = c("a", "b", "c"))

# If you aren't sure what "order" the values of the vector are
# assumed to be, then you can check the order that they appear
# when tabulated:
table(var)

# But if the encoding scheme is 1 = b, 2 = c, 3 = a, then you will need
# to manually define the levels of the variable (as well as the labels):
factor(var, levels = c(2, 3, 1), labels = c("b", "c", "a"))

# ============================================================================ #

# Now that you're familiar with indexing, let's quickly use it to rename
# the variables in our household data frame.

# First, print the current data frame column names:
colnames(household)

# "YEAR" and "YEARQ" are self-explanatory,
# "IDHH", "MSAIND", "WGTHH" are convenient,
# but "V2026" and "V2125" are a little unhelpful.

# Which position are they in the colnames() vector?
which(colnames(household) %in% c("V2026", "V2125"))

# Let's take the logical operation and use it to index the colnames() vector.
# Then, once indexed, we can assign the new names:
colnames(household)[which(colnames(household) %in%
                            c("V2026", "V2125"))] <- c("INCOME", "LAND_USE")

## ---- end_index
# ============================================================================ #
## EXERCISE 2.a:
### Rename the V3014 column in the person data frame to "AGE", and
### rename the V3018 column in the person data frame to "SEX".
### You can do this by indexing colnames(person) using the which() function.
# ============================================================================ #
## EXERCISE 2.b:
### Tabulate the age of women in the NCVS. You can achieve this
### by indexing the AGE variable by a logical operation applied to the
### SEX variable, and then piping, |>, the result to the table() function.
# ============================================================================ #

############################################################################## #
###                         3. Data Manipulation                            ====
############################################################################## #
## ---- manip

# While indexing is an important skill, there are more convenient ways
# of manipulating data in R. Tidyverse, and more specifically dplyr,
# offer a range of important tools for data manipulation.

# Filtering (subsetting by logical operation):
household %>%
  filter(YEAR >= 2010,
         LAND_USE == "Rural")

# Arranging (sorting the data by a variable)
household %>%
  arrange(YEAR,
          LAND_USE)

# Selecting (extracting specific variables)
household %>%
  select(YEAR,
         LAND_USE)

# The tidyverse pipe operator, %>%, can then be used to chain any
# combination of these functions in any order. Piping to the
# summarise() function will let you quickly calculate descriptive
# statistics for a variable (after filtering by certain conditions).
household %>%

  filter(YEAR >= 2010,
         LAND_USE == "Rural") %>%

  summarise(median = median(as.numeric(INCOME), na.rm = TRUE),
            mean = mean(as.numeric(INCOME), na.rm = TRUE),
            sd = sd(as.numeric(INCOME), na.rm = TRUE),
            min = min(as.numeric(INCOME), na.rm = TRUE),
            max = max(as.numeric(INCOME), na.rm = TRUE))

# The group_by() function will let you easily calculate
# group-level descriptive statistics.
household %>%
  group_by(YEAR,
           LAND_USE)

# The mutate() function will let you quickly manipulate
# or update an existing variable, creating or overwriting
# the variable you manipulate. Here, we are creating
# a variable called "INC" that is a numeric vector
# version of the original "INCOME" factor vector.
(household <- household %>%
   mutate(INC = as.numeric(INCOME)))

# You would also use the mutate() function to create
# centered or standardized variables.
## Centered:
household %>%
  mutate(INC_CEN = INC - mean(INC, na.rm = TRUE))

## Z-Score Standardized:
household %>%
  mutate(INC_STD = (INC - mean(INC, na.rm = TRUE)) / sd(INC, na.rm = TRUE))

household %>%
  mutate(INC_STD = scale(INC))

# Creative combination of these functions can allow you
# to calculate a descriptive statistic for any combination
# of groups and variables. For example, we could calculate
# the mean() for every year, grouped by Urban / Rural,
# for both INCOME (INC) and Household Weight (WGTHH):
household %>%

  mutate(INC = as.numeric(INCOME)) %>%

  group_by(YEAR,
           LAND_USE) %>%

  summarise(across(c(INC, WGTHH), ~ mean(.x, na.rm = TRUE)))

# ============================================================================ #

# Reshaping data is unnecessarily complicated, but you can achieve it
# with the tidyr package. Any type of grouped data can be presented in a
# long format, or a wide format.

# Long format includes repeating observations for each level of the group ID.
# Wide format includes repeating variables for each level of the group ID.

# For longitudinal panel data - with repeating observations of the same people,
# states, or other unit of analysis - the group ID is the "year" variable.

# Here, I am going to demonstrate reshaping the person-level data by household.

# Long (each row is a person):
(df <- person %>%
   select(IDPER, IDHH, YEARQ, V3020))

# Wide (each row is a household):
(df <- df %>%

   group_by(IDHH, YEARQ) %>%        # Group by IDHH and Year/Quarter

   mutate(HHM = 1) %>%              # Create a 'ticker' that
   mutate(HHM = cumsum(HHM)) %>%    # numbers household members

   pivot_wider(id_cols = c(IDHH, YEARQ),            # Reshape the data
               names_from = HHM,                    # to wide format
               values_from = c(IDPER, V3020)))

# Back to Long!
(df <- df %>%
   pivot_longer(cols = IDPER_1:V3020_9,
                names_to = c(".value", "HH_MEMBER"),
                names_sep = "_") %>%
   drop_na(c(IDPER, V3020)))

# Compare the end result to our original subset:
## Start
person %>%
  select(IDPER, IDHH, YEARQ, V3020) %>%
  head()
## End
df %>% head()

## ---- end_manip
# ============================================================================ #
## EXERCISE 3:
### Find the mean and standard deviation for education level by gender and age.
### You will need to use the mutate(), group_by(), and summarise() functions.
# ============================================================================ #

############################################################################## #
###                      4. Putting it all together                         ====
############################################################################## #
## ---- weigh

# In this final section, I am going to quickly demonstrate how you
# properly apply the NCVS sampling weights and create a weighted
# violent victimization count variable at the person-level,
# by aggregating the incident-level data to the person-level.

# This code is based on the example code chunks found in the
# NCVS MSA Public-Use Data, 2000 - 2015 codebook. It will use
# a lot of the data management skills from earlier in this script,
# and also demonstrate how you merge two datasets.

# First, let's create a binary indicator of violent victimization:
incident <- incident %>%
  mutate(VIOLENT = as.numeric(TOC_RECODE) %in% 1:11,
         NONVIOLENT = !(as.numeric(TOC_RECODE) %in% 1:11),
         TYPE = ifelse(VIOLENT, "Violent", "Nonviolent"))

# Next, we need to (a) filter the incident data to only include violent
# victimizations, (b) group by person ID (and year/quarter), and
# (c) aggregate from the incident-level to the person-level.
(vbl <- incident %>%
   filter(VIOLENT) %>%
   group_by(YEARQ, IDPER) %>%
   summarise(WGTVIC_V = mean(WGTVIC),
             VIOLENT = sum(VIOLENT * SERIESWGT)))

(nvbl <- incident %>%
   filter(NONVIOLENT) %>%
   group_by(YEARQ, IDPER) %>%
   summarise(WGTVIC_NV = mean(WGTVIC),
             NONVIOLENT = sum(NONVIOLENT * SERIESWGT)))

# Now, let's merge this violent victimization variable onto the
# person-level data. To do this, you use left_join() and specify
# the variables you want to match with the "by" option:
(person <- person %>%
   left_join(vbl, by = c("YEARQ", "IDPER")) %>%
   left_join(nvbl, by = c("YEARQ", "IDPER")) %>%
   mutate(VIOLENT = if_else(is.na(VIOLENT), 0, VIOLENT),
          NONVIOLENT = if_else(is.na(NONVIOLENT), 0, NONVIOLENT)))

# Calculate the adjusted victimization adjustment factor (weights)
# per the NCVS codebook. Multiply this adjustment factor by
# the violent victimization variable (VIOLENT) to create a
# weighted violent victimization (VLNT_WGT) variable:
(person <- person %>%
   mutate(ADJINC_WT_V = if_else(!is.na(WGTVIC_V), WGTVIC_V / WGTPER, 0),
          VLNT_WGT_V = VIOLENT * ADJINC_WT_V,
          ADJINC_WT_NV = if_else(!is.na(WGTVIC_NV), WGTVIC_NV / WGTPER, 0),
          NVLNT_WGT_V = NONVIOLENT * ADJINC_WT_NV))

# Now we can use the VLNT_WGT to calculate a weighted average
# of the victimization count, or to ensure that

# We might want to quickly recode a variable so that it is more
# in line with our own operationalization for a project, or
# satisfies more statistical assumptions (e.g., normality):
(person <- person %>%
  mutate(EDUC = case_when(
    V3020 %in% c("Nev/kindergarten",
                 "Elementary") ~ "NHSE",

    V3020 %in% c("High school",
                 "12th grade (no diploma)",
                 "High school graduate (diploma or equivalent)") ~ "HSE",

    V3020 %in% c("Some college (no degree)",
                 "College",
                 "Bachelor degree") ~ "FE",

    V3020 %in% c("Master degree",
                 "Prof school degree") ~ "MA",

    V3020 %in% c("Doctorate degree") ~ "PHD",
  )))

person$EDUC <- factor(person$EDUC, levels = c("NHSE",
                                              "HSE",
                                              "FE",
                                              "MA",
                                              "PHD"))

# Now, I'll output a sample of this data frame into the next module's
# Data folder, so we can use it when practicing
# Descriptive Statistics and Graphics:
# saveRDS(person, "../3 Descriptive Statistics and Graphics/Data/person.rds")

person[sample(nrow(person), 100), ]

## ---- end_weigh