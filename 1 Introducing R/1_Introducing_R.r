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
install.packages("dplyr")

# Once the package is installed, you need to load it. You will need to do
# this in EVERY session, so the best practice is to include it at the
# beginning of each script.
library(dplyr)

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
rm(x, results, name)

# You can also completely wipe your workspace of all objects:
rm(list = ls())

# Now your workspace will be empty:
ls()

# ...and you will not be able to "call" any of these objects:
result

# ...but you can load in any saved objects with the load() function:
load(file = "myobjects.rda")

# The saved objects are now back in the workspace:
ls()

# Before moving on, let's wipe the workspace again:
rm(list = ls())

## ---- end_objects
############################################################################## #
###                        2. Vectors and Matrices                          ====
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
install.packages("readxl")
library(openxlsx)
write.xlsx(df, file = "my_data.xlsx")

# or as a Stata dataset (.dta):
install.packages("haven")
library(haven)
write_dta(df, "my_data.dta")

# or as a Feather (.feather):
install.packages("feather")
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
###                         3. Logical Operations                           ====
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

## ---- end_rsd_lop
# ============================================================================ #
## EXERCISE 3.a:
### 
# ============================================================================ #
## EXERCISE 3.b:
### 
# ============================================================================ #
## EXERCISE 3.c:
### 
# ============================================================================ #

############################################################################## #
###                 4. Performing Simple Statistical Functions              ====
############################################################################## #
## ---- stats



## ---- end_stats
# ============================================================================ #
## EXERCISE 4.a:
### 
# ============================================================================ #
## EXERCISE 4.b:
### 
# ============================================================================ #

############################################################################## #
###                         5. Types and Classes                            ====
############################################################################## #
## ---- type_class



## ---- end_type_class
# ============================================================================ #
## EXERCISE 5:
### 
# ============================================================================ #

############################################################################## #
###                             6. Functions                                ====
############################################################################## #
## ---- functions



## ---- end_functions
# ============================================================================ #
## EXERCISE 6:
### 
# ============================================================================ #