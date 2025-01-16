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

#=============================================================================#

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

#=============================================================================#

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
# the assigned value or data until it is overwritten.

# Assign the numeric value, 8, to an object by the name "x":
x <- 8

# Print the "x" object:
print(x)

# This can also be achieved by simply entering the object:
x

# You can also enter and print the assigned value simultaneously:
(name <- "Mark")

# Depending on the nature of the object, you can perform mathematical functions:
x + 2

# These output of these (mathematical) functions can be assigned:
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

## ---- end_vec_mat