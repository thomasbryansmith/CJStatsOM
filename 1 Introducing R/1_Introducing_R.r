# Title: Introducing R
# Subtitle: CJ 702 Advanced Criminal Justice Statistics
# Author: Thomas Bryan Smith <tbsmit10@olemiss.edu>
# GitHub: thomasbryansmith/CJStatsOM
#
# Released under MIT License
# https://github.com/thomasbryansmith/CJStatsOM?tab=MIT-1-ov-file

############################################################################## #
###                  1. Working Directories and Libraries                   ====
############################################################################## #
## ---- wd_lib

# Find the current working directory (cwd):
getwd()

# =========================================================================== #

# If the current working directory does not match the location of the folder
# within which you want to work, you can change the directory with the
# following code:

# setwd("C:/the/working/directory")
# Windows style formatting (note the forward slash)

# setwd("/the/working/directory")
# Apple style formatting

# To run this code, you will need to replace the text between the
# speech marks, "", with your own working directory. This will
# depend on where you have saved your scripts, data, etc.

# The leading hashtag, #, "comments out" the code so that it is not
# interpreted by R. If you remove it, the code becomes "active"
# and will be interpreted.

# ============================================================================ #

# Having set your working directory, next you will want to install any packages
# you want to work with in your project(s). You do so with the following code:
# install.packages("tidyverse")

# Once the package is installed, you need to load it. You will need to do
# this in EVERY session, so the best practice is to include it at the
# beginning of each script.
library(tidyverse)

## ---- end_wd_lib
############################################################################## #
###                             2. Objects                                  ====
############################################################################## #
## ---- objects

# R is an inherently mathematical language, and operates in a way that resembles
# algebra. To "store" anything within R (text, single numbers, data, etc.)
# you need to "assign" it to an "object". Once assigned, this object represents
# the assigned value or data until it is overwritten, deleted, or you close the
# session.

# Assign the numeric value, 8, to an object by the name "x":
x <- 8

# Print the "x" object:
print(x)

# This can also be achieved by simply entering the object:
x

# You can also enter and print the assigned value simultaneously:
(name <- "Mark")

# Depending on the type of the object,
# you can perform mathematical operations:
x + 2

# These output of these mathematical operations can be assigned:
(result <- x + 2)

# Then you can continue to work with the new object:
(result / 2)
(result * 5)

# You can save objects with the save() function:
save(x, result, file = "myobjects.rda")
# Note that this will save them to your current working directory!

# You can view what is currently stored in your
# "workspace" (all of your objects) with the ls() function:
ls()

# Then the rm() function can be used to remove objects from that workspace:
rm(x, result, name)

# You can also completely wipe your workspace of all objects:
rm(list = ls())

# Now your workspace will be empty:
ls()

# ...and you will not be able to "call" any of these objects:
# result

# ...but you can load in any saved objects with the load() function:
load(file = "myobjects.rda")

# The saved objects are now back in the workspace:
ls()

# Before moving on, let's wipe the workspace again:
rm(list = ls())

## ---- end_objects
############################################################################## #
###                        3. Vectors and Matrices                          ====
############################################################################## #
## ---- vec_mat

# To manually creating a numeric vector, we use the
# 'combine', c(), function:
(x <- c(1, 2, 3, 4))

# In this case, we can do the same vector by generating a sequence:
y <- 1:4

# or, using the seq() function:
z <- seq(from = 1, to = 4)

# The seq() function can also be used to generated more complex numeric vectors:
seq(from = 1, to = 10, by = 2)

# Then the rep() function can be used to generate vectors with repeating values:
rep(2, times = 10)
rep(1:2, times = 10)
rep(1:2, length.out = 8)

# Sometimes it can be helpful to create a sequence, starting at 1,
# that iterates along another vector that does not start at 1:
(x <- 51:65)
seq_along(x)

# Vectors are not always numeric, they can be character vectors:
(x <- c("Benjamin", "Kathryn", "Jean", "Jonathan"))

# ...or they can be boolean (TRUE, FALSE) vectors:
(x <- c(TRUE, FALSE, FALSE, TRUE))

# ============================================================================ #

# Mathematical operations function differently for vectors of length > 1.
# Here are some examples:
(x <- 1:4)
(y <- 0:3)

# [1 2 3 4] + 1
1:4 + 1
x + 1

# [1 2 3 4] + [0 1]
1:4 + 0:1
x + 0.1

# [1 2 3 4] + [0 1 2 3]
1:4 + 0:3
x + y

# These rules also apply to other mathematical operations:
x - y
x * y
x / y

# Working with matrices is a little more complicated, and requires
# knowledge of matrix algebra. Being as most of you do not work
# with relational data, focusing more on single variables (vectors),
# we will not discuss mathematical operations for matrices.

# ============================================================================ #

# Now that you understand vectors, let's move on to matrices.
# Creating a simple matrix:
(mat <- matrix(c(0,1,0, 15,18,10, 2,6,0, 126,75,50), nrow = 3))

# Note that the matrix is populated column-by-column. The nrow
# option defines the number of rows in the matrix. By splitting
# the input vector into chunks of 3, we can easily recognize
# what each column will look like ahead of time.
# When you change the number of rows, it helps to change the input:
(mat <- matrix(c(0,1,0,15, 18,10,2,6, 0,126,75,50), nrow = 4))

# ...or, following best practice:
(mat <- matrix(c(0, 1, 0,        # column 1
                 15, 18, 10,     # column 2
                 2, 6, 0,        # column 3
                 126, 75, 50),   # column 4
               nrow = 3))

# If you want to find the number of rows and columns of the matrix:
nrow(mat)
ncol(mat)

# The dim() function finds both and outputs them as a vector,
# starting with the rows (4) and ending with the columns (3):
dim(mat)

# Remember, the output of ANY function can be assigned to an object:
(x <- dim(mat))

# Note that, right now, your matrix has no row and column names:
mat
rownames(mat)
colnames(mat)

# You can assign vectors of names to these rows and columns:
rownames(mat) <- c("Benjamin", "Kathryn", "Jonathan")
colnames(mat) <- c("sex", "age", "delinquencies", "ses")

# Now, when you print the matrix, it will show the names:
mat

# Using the as.data.frame() function you can convert this matrix
# into a 'data frame', R's version of a dataset:
as.data.frame(mat)

# However, I would recommend learning to work with
# 'tibbles', the tidyverse equivalent of R's data frame:
as_tibble(mat)

# Let's assign this tibble to an object named 'df':
df <- as_tibble(mat, rownames = "name")

# Now, we can save these data as a comma-separated values (.csv) file:
write.csv(df, file = "my_data.csv")

# or as an excel spreadsheet (.xlsx):
# install.packages("readxl")
library(openxlsx)
write.xlsx(df, file = "my_data.xlsx")

# or as a Stata dataset (.dta):
# install.packages("haven")
library(haven)
write_dta(df, "my_data.dta")

# or as a Feather (.feather):
# install.packages("feather")
library(feather)
write_feather(df, "my_data.feather")

## ---- end_vec_mat
# ============================================================================ #
## EXERCISE 2a:
### Using seq(), create a numeric vector that starts at 25, ends at 100,
### in intervals of 5. Create a character vector that contains your own name.
### Assign both of these to objects. Save the 2 vector objects to an external
### file with the .rda filetype under a name of your choosing.
# ============================================================================ #
## EXERCISE 2b:
### Create a 3 x 4 matrix object with the following rows:
###     "Jonathan", "Male", "White", 43
###     "Benjamin", "Male", "Black", 37
###     "Kathryn", "Female", "White", 41
### Label the columns of the matrix (name, sex, race, age).
### Convert the matrix object into a tibble object named 'my_df'.
# ============================================================================ #

############################################################################## #
###                         4. Logical Operations                           ====
############################################################################## #
## ---- rsd_lop

# Logical operations are useful for identifying specific case(s) in your data.
# So, let's load our data back into R:
read_csv("my_data.csv")
read_dta("my_data.dta")
read_feather("my_data.feather")

# What have we forgotten to do here? Assign it to an object!
df <- read.xlsx("my_data.xlsx")

# The openxlsx package will read the data as a data frame, not a tibble.
df

# You will need to convert it back into a tibble manually. You can do this
# in the same way you did previously, using the as_tibble() function.
df <- as_tibble(df)

# You can combine these functions using the "pipe operator" (%>% or |>).
# This operator functions a little like a mathematical operation,
# but it is instead used to chain multiple functions.
# The chained functions are executed from left to right:
read.xlsx("my_data.xlsx") %>% as_tibble()   # tidyverse (magrittr)
read.xlsx("my_data.xlsx") |> as_tibble()    # base R

# Now, let's read the .xlsx file, convert it into a tibble, assign
# the tibble to an object, and print the tibble. All at the same time!
(df <- read.xlsx("my_data.xlsx") |> as_tibble())

# ============================================================================ #

# Having loaded in our dataset, let's perform some logical operations.
# First, we extract the variable on which we want to perform the operations:
(age <- df$age)

# Now, let's check to see if any of the respondents are 18 years old:
age == 18

# Are any respondents NOT 18 years old?
age != 18

# Are any respondents older than 10 years?
age > 10

# Are any respondents less than or equal to 15 years?
age <= 15

# Are any respondents less than 12 years OR greater than 17 years?
age < 12 | age > 17

# Are any respondents greater than 12 AND less than 17?
age > 12 & age < 17

# So far, all of these logical operations have produced
# logical (TRUE / FALSE) vectors. Instead, we might want to
# know the position within the data. The which() function
# can be used to return a vector of rows (indices) that
# fulfil the conditions of the logical operation:
which(age > 12 & age < 17)

# You can invert (negate) these logical operations with a
# leading exclamation mark (!):
!(age > 12 & age < 17)

# This also works if you assign the logical vector:
(logic <- age > 12 & age < 17)
!logic

# The %in% logical operator is unique in that it can be used
# to compare multiple vectors of length > 1.

# Is the number '20' in the age vector?
20 %in% age

# What about the number '18'?
18 %in% age

# Are any of the values in the age vector also in
# a vector consisting of the numbers 10 and 18?
age %in% c(10, 18)

# These logical operators can be combined to create
# increasingly complicated logical statements.
which(!(age %in% c(10, 18)))

# Just make sure you interpret them carefully and correctly!
# In this case, we checked to see WHICH respondents' ages
# do NOT (!) appear in the vector: [10, 18].

# Logical vectors can be interpreted as a binary variable.
# They are simply encoded as "FALSE" and "TRUE", rather than 0 and 1.
# As a result, they are easily converted into a binary numeric vector:
as.numeric(age == 18)

# So, if you want to count how many respondents fulfill the condition:
sum(age == 18)

# Or, if you want to find the proportion of respondents who fulfill
# the condition:
mean(age == 18)

# For a percentage, just multiply by 100:
mean(age == 18) * 100

# For a rate per 1,000, just multiply by 1,000:
mean(age == 18) * 1000

# ============================================================================ #

# For the following exercises and the next section, we are going to load
# in one of R's "built-in" practice datasets, "USArrests", a data frame
# reporting violent crime rates in each US state:
data("USArrests")
# In this special case, we do not need to assign the data() function, because
# this function is simple importing the USArrests object from R's files.

# Let's look at the first 6 observations using the head() function:
head(USArrests)

# Let's look at the first 20 observations instead:
head(USArrests, 20)

# "USArrests" is a little long, so let's reassign it to the "df" object
df <- USArrests

# Now we check to see if the data were assigned:
head(df)

## ---- end_rsd_lop
# ============================================================================ #
## EXERCISE 3.a:
### How many of the US states have an urban population that is equal to or
### greater than 50% of their total population?
###   Note: the "UrbanPop" variable is a percentage.
# ============================================================================ #
## EXERCISE 3.b:
### Which of the US states report a murder arrest rate exceeding 15 per
### 100,000 of the population?
# ============================================================================ #

############################################################################## #
###               5. Performing Simple Statistical Functions                ====
############################################################################## #
## ---- stats

# Say we're interested in calculating descriptive statistics for murder.
# First, let's extract the murder variable from the dataset:
murder <- df$Murder
murder

# Median
median(murder)

# Mean
mean(murder)

# Standard Deviation
sd(murder)

# Minimum and Maximum
min(murder)
max(murder)

# Frequency Tables
## Let's create a nominal variable to work with:
sex <- c(rep("male", 15), rep("female", 8))
sex

## Now let's tabulate the results:
table(sex)

# Missing Data
# R does not always "know" what to do with missing data.
# Let's introduce some missingness to the murder variable:
murder <- c(murder, rep(NA, 5))
murder

# Now let's try to calculate the mean again:
mean(murder)

# It doesn't work! You have to tell R whether or not to remove
# missing data from the calculation. Under the default setting
# for some functions (e.g., mean), R will try to complete
# calculations with the "NA" values included. As a result,
# the mean cannot be computed. To remove "NA" values, simply
# set the na.rm option to "TRUE":
mean(murder, na.rm = TRUE)

# Similarly, R does not know how to perform logical functions
# on missing values:
murder > 5

# You can check for NA's using the is.na() logical function:
is.na(murder)

# Counting missingness in the variable:
sum(is.na(murder))
murder |> is.na() |> sum()
murder %>% is.na %>% sum

# Proportion of missingness in the variable:
mean(is.na(murder))
murder |> is.na() |> mean()
murder %>% is.na %>% mean

# Percent missingness:
mean(is.na(murder)) * 100
(murder |> is.na() |> mean()) * 100
(murder %>% is.na %>% mean) * 100

## ---- end_stats
# ============================================================================ #
## EXERCISE 4.a:
### Calculate the range statistics for the Assault variable.
# ============================================================================ #
## EXERCISE 4.b:
### Find the number of states with an urban population that is greater than
### or equal to the average urban population in the US.
# ============================================================================ #

############################################################################## #
###                       6. Creating Custom Functions                      ====
############################################################################## #
## ---- functions

# R is a language that is based on functions. mean(), sd(), min(), and every
# other task you have asked R to perform is based on an underlying function
# stored within the base R installation, or an installed R package.

# You can print the underlying function by entering the function call
# without the succeeding parentheses.

# So, to print the 'mean' function, you would simply enter:
mean
# If this looks like nonsense to you, don't worry, it should.
# The base R mean function does not use R syntax.
# So, let's build a function that DOES use R syntax!

mymean <- function(input, rm_na = FALSE) {
  x <- sum(input, na.rm = rm_na)
  if (rm_na == TRUE){
    y <- sum(!is.na(input))
  } else {
    y <- length(input)
  }
  result <- x / y
  return(result)
}

# Now let's test the function!
mymean(murder)

# Oops! Forgot to remove missing values with the "rm_na" option
# we included in the custom function!
mymean(murder, rm_na = TRUE)

# Compare to the native function:
mean(murder, na.rm = TRUE)

# Then, if we want to print our function in the console:
mymean

## ---- end_functions
# ============================================================================ #
## EXERCISE 5:
### Create a function that calculates the range for a given variable.
### Use your answer to 4.b to help complete this exercise.
# ============================================================================ #