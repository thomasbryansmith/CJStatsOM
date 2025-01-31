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
# install.packages(c("readr", "Hmisc", "pastecs", "psych",
#                    "scatterplot3d", "rgl", "Rcmdr", "ggplot2",
#                    "scales"))

# Load relevant packages:
library(tidyverse)
library(readr)
library(Hmisc)
library(pastecs)
library(psych)
library(scatterplot3d)
library(rgl)
library(Rcmdr)
library(scales)

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
# This function returns the minimum, 25th percentile,
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

# Frequency tables for a single categorical variable can be generated using
# the table() function. This is something mentioned in the previous module.

# Tabling the age variable:
table(df$AGE)

# Tabling the education variable:
table(df$EDUC)

# The table function generates named, numeric vectors. So all of the
# operations and functions we have previously applied to vectors,
# can also be applied to the results of the table() function:
age <- table(df$AGE)
age[1]
age["30-34"]
age[c("30-34", "50-59")]
sum(age)
min(age)
max(age)

# Crosstabs are created by adding a second variable after a comma:
(myxtab <- table(df$AGE, df$EDUC))

# From this crosstab, you can estimate the marginal frequencies
# with the margin.table() function:
margin.table(myxtab)        # Total number of observations
margin.table(myxtab, 1)     # Row frequencies (summed over columns)
margin.table(myxtab, 2)     # Col frequencies (summed over rows)

# You can also generate the cell, row, and column proportions:
prop.table(myxtab)          # Cell proportions
prop.table(myxtab, 1)       # Row proportions (by column)
prop.table(myxtab, 2)       # Column proportions (by row)

# The summary() function can also be applied to crosstabs.
# It will give you the total number of cases, number of variables,
# Chi Square, Degrees of Freedom, and p-value.
summary(myxtab)

# All of the above can also be achieved working in the tidyverse suite:
df %>% count(AGE)
df %>% group_by(AGE) %>% count(EDUC)

# However, unlike in R, tidyverse provides you with much more flexibility
# with how you subset or manage your data:
myxtab <- df %>%
  filter(VIOLENT == 1) %>%
  group_by(AGE) %>%
  count(EDUC)

# Given that the data produced by this method are presented
# listwise rather than an adjacency matrix, you have to generate
# row, column, and cell frequencies, proportions, et al. using mutate():
myxtab %>%

  group_by(AGE) %>%
  mutate(ColPcnt = (n / sum(n)) * 100) %>%        # Col Percentages

  ungroup() %>%
  group_by(EDUC) %>%
  mutate(RowPcnt = (n / sum(n)) * 100) %>%        # Row Percentages

  ungroup() %>%
  mutate(CellPcnt = (n / sum(n)) * 100)           # Cell Percentagees

## ---- end_freq-tab
# ============================================================================ #
## EXERCISE 3.a
### Tabulate the violent education level variable.
### Assign this table to an object and then estimate the mean, minimum,
### and maximum of the members.
# ============================================================================ #
## EXERCISE 3.b
### Generate a crosstab of education level and violent victimization.
### Find the row, column, and cell frequencies.
### Find the cell proportions.
# ============================================================================ #

############################################################################## #
###                     4. BASIC GRAPH FUNCTIONS                            ====
############################################################################## #
## ---- basic-graphs

# You can use the hist() function to generate histograms. You simply insert
# the vector which distribution you wish to visualize into the parentheses.
hist(df$YIH)

# The col option lets you change the colour of the histogram's bars:
hist(df$YIH, col = "plum2")

# For a list of available colours you can go to this url:
# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf

# You can also specify the range of values the axes can take. For histograms,
# you only need to specify the range for the x-axis. This determines what
# "slice" of the histogram you want to extract. If you set it to the min()
# and max(), it will show you the entire figure:
max_yih <- max(df$YIH, na.rm = TRUE)
min_yih <- min(df$YIH, na.rm = TRUE)

hist(df$YIH, col = "plum2",
     xlim = c(min_yih, max_yih))

# But you could also "slice" the histogram so it only shows you the distribution
# between the 25th and 75th percentile:
yih_25 <- fivenum(df$YIH)[2]
yih_75 <- fivenum(df$YIH)[4]

hist(df$YIH, col = "plum2",
     xlim = c(yih_25, yih_75))

# You can also modify the number of breaks in the histogram.
# Let's try 4 breaks:
hist(df$YIH, breaks = 4)

# If you want a break to appear at every 2 year interval, you'd need 30 breaks:
hist(df$YIH, breaks = 30)

# Rather than guessing, you can integrate arithemetic functions. For instance,
# you could divide the maximum score of the variable by the interval at which
# you want the breaks to occur. If you want breaks every 5 years, then:
b <- max_yih / 5
hist(df$YIH, breaks = b)

# You can then change the labels of the
# histogram with the main and xlab options:
hist(df$YIH,
     main = "Time lived at current address",
     xlab = "Years")

# Finally, the freq option allows you to switch between Frequency and Density:
hist(df$YIH, freq = FALSE)

# Put this all together to create a histogram to your exact specifications:
hist(df$YIH,
     col = "plum2",
     xlim = c(min_yih, max_yih),
     breaks = b,
     main = "Time lived at current address",
     xlab = "Years",
     ylab = "Proportion",
     freq = FALSE)

# ============================================================================ #

# The barplot() function is used to generate bar plots / graphs for count data:
(educ_table <- table(df$EDUC))
barplot(educ_table)

# All of the above options for histograms also apply to barplots().
# Here, I've introduced a few extra visual options (border and density),
# and also specified the individual colors and densities of each and
# every bar appearing in the plot. Note that this is defined as a vector
# created using the c() function:
barplot(educ_table,
        main = "Education Level",
        xlab = "Highest Degree Earned",
        ylab = "Total",
        col = c("plum2", "yellow", "lightblue", "blue", "red"),
        border = c("red", "brown", "blue", "darkblue", "darkred"),
        density = c(10, 20, 30, 40, 50))

# Note that the default setting is to name the barplot() using the labels
# from the table() function (your factor labels). If you want to edit them,
# you can use the names.arg option:
barplot(educ_table,
        main = "Education Level",
        xlab = "Highest Degree Earned",
        ylab = "Total",
        col = c("plum2", "yellow", "lightblue", "blue", "red"),
        border = c("red", "brown", "blue", "darkblue", "darkred"),
        density = c(10, 20, 30, 40, 50),
        names.arg = c("No Formal Education",
                      "High School Equivalent",
                      "Bachelor's Degree",
                      "Master's Degree",
                      "Doctoral Degree"))

# You can also visualize crosstabs:
barplot(table(df$SEX, df$EDUC))

# However, without a legend, these can be difficult to read.
# So, let's add some extra visual options to help make it
# more easy to interpret. So, we can add a legend using 
# the legend() function:
barplot(table(df$SEX, df$EDUC),
        main = "Education Level by Gender",
        ylab = "Total",
        col = c("blue", "pink"),
        beside = TRUE)
legend("topright", c("Male", "Female"), 
       cex = 1,
       bty = "n",
       fill = c("blue", "pink"))

# The first two options should be the location and labels.
# cex specifies the size of the legend.
# bty specifies the type of box you want to surround the legend.
# fill specifies the colours associated with each
# (make sure they are in the same order as in the barplot).

# Reminder: the exact specification of the legend() function
# depends on the figure for which you are creating the legend.

# ============================================================================ #

# The pie() function generates pite charts, and functions very
# similarly to bar plots.
pie(table(df$EDUC),
    col = rainbow(5),
    main = "Education Level",
    labels = c("No Formal Education",
               "High School Equivalent",
               "Bachelor's Degree",
               "Master's Degree",
               "Doctoral Degree"))

legend("topleft", 0.5, c("No Formal Education",
                         "High School Equivalent",
                         "Bachelor's Degree",
                         "Master's Degree",
                         "Doctoral Degree"),
       cex = 0.8,
       fill = rainbow(5))

# ============================================================================ #

# The boxplot function generates boxplots:
boxplot(df$YIH)

# As with the other graphing functions, boxplots come with it its own set of
# options, some of which are shared by other basic graph functions:
boxplot(df$YIH ~ df$EDUC,
        main = "Years in Home",
        ylab = "Years",
        xlab = "Education Level",
        col = heat.colors(5),
        notch = TRUE)

# ============================================================================ #

# Both line charts and scatterplots use the plot() function.
# The plot() function tends to be a little more complex than the
# prior functions.

# To plot an example line graph we begin by plotting a vector
# of 5 numbers. In this example let's assume each number is a score
# out of 10 on a maths test.

# The plot() function will simply plot these points on a 2D plane.

mathscores <- c(2, 5, 6, 3, 5)
plot(mathscores)

# By introducing the type option we tell R what we want to plot.
# The type="l" option will plot lines, the type="o" option
# will plot both points and lines.

plot(mathscores, type = "l",col = "red")

plot(mathscores, type = "o",col = "red")

# If we have scores on an maths test for two people, we can combine
# the plot() and line() functions.

personA <- c(2, 5, 6, 3, 5)
personB <- c(3, 4, 7, 2, 2)

plot(personA, type = "o", col = "red", ylim = c(0, 10))

# The lines() function will then overlay a second set of lines and points.
# The pch, lty, and col options identifies the shape of the points,
# the type of line, and the color of the line.
lines(personB, type = "o", pch = 22, lty = 2, col = "blue")

# You can then use the title() function to add a title.
title(main = "Maths Test Scores by Day", font.main = 2)

# You will notice that certain functions add to previously generated graphs.
# This applies to the axis(), box(), lines(), title(), and legend() functions.
# Using these functions in conjunction with plot() you can plot a graph from
# the ground up. Run the following lines of code one at a time for an example:

par(mar = c(5, 5, 4, 4))

plot(personA,
     type = "o",
     col = "red",
     ylim = c(1, 10),
     axes = FALSE,
     ann = FALSE)

axis(1, 1:5, lab = c("Mon", "Tue", "Wed", "Thu", "Fri"))

axis(2, 1:10)

box()

lines(personB, type = "o", pch = 22, lty = 2, col = "blue")

title(main = "Test Scores by Day", font.main = 2)

title(xlab = "Days", font.main = 3)

title(ylab = "Test Scores", font.main = 3)

legend(4, 9, c("Person A", "Person B"),
       cex = 0.8,
       col = c("red", "blue"),
       pch = 21:22,
       lty = 1:2)


# The par() function defines the graph margins.
# If you find that your plot is not displaying an
# axis title then you may want to try running this
# code before using the plot() function.
par(mar = c(5, 5, 4, 4))

# You generate scatterplots in much the same way, except this time you
# identify the two variable vectors from your data which you wish
# to plot with one another. In this example we have Years in Household
# on the y axis and Age on the x axis.
plot(x = as.numeric(df$AGE),
     y = df$YIH,
     main = "Scatterplot Example",
     xlab = "Age",
     ylab = "Years in Household",
     pch = 19)

# You can use the jitter() function in situations where you have a lot
# of overlaid points on the scatterplot:
x <- jitter(as.numeric(df$AGE), 1.5)
y <- jitter(df$YIH, 20)

plot(x = x,
     y = y,
     main = "Scatterplot Example",
     xlab = "Age",
     ylab = "Years in Household",
     pch = 19)

# Using the abline() function we can plot the results of an ordinary
# least squares (OLS) regression, which are fit using the lm()
# function. We will be covering linear models in the next workshop.
abline(lm(YIH ~ as.numeric(AGE), df),
       lwd = 5,
       col = "red")

## ---- end_basic-graphs
# ============================================================================ #
## EXERCISE 4.a
### Generate a bar plot for the crosstab of age by violent victimization.
### Specify colours for each group, and appropriately label the axes.
# ============================================================================ #
## EXERCISE 4.b
### Generate a scatter plot where year in household is on the y-axis,
### and data collection year is on the x-axis. Use the jitter() function
### to clearly show overlapping points. Fit a simple OLS regression line
### to the figure.
# ============================================================================ #

############################################################################## #
###                         5. 3D SCATTER PLOTS                             ====
############################################################################## #
## ---- 3d-plots

# Once you have mastered the basic graph functionality in R, you can start
# using packages which apply similar logic but with more impressive output.

# 2D visualizations of scatter plots with 3 variables using scatterplot3d:
plt <- scatterplot3d(as.numeric(df$AGE), as.numeric(df$EDUC), df$YIH,
                      pch = 16,
                      highlight.3d = TRUE,
                      type = "h",
                      main = "3D Scatterplot",
                      xlab = "Age",
                      ylab = "Education Level",
                      zlab = "Years in Household")
fit <- lm(YIH ~ as.numeric(AGE) + as.numeric(EDUC), df)
plt$plane3d(fit)

# 3D visualizations of scatter plots with 3 variables:
## rgl
plot3d(df$AGE, df$EDUC, df$YIH, col = "red", size = 3)

## Rcmdr
scatter3d(YIH ~ as.numeric(AGE) + as.numeric(EDUC),
          data = df)

## ---- end_3d-plots
############################################################################## #
###                            6. GGPLOT2                                   ====
############################################################################## #
## ---- ggplot2

# Arguably the most comprehensive graphical package in R,
# ggplot2 can be used to generate impressive graphics.
# It is part of the tidyverse suite of packages.

# ggplot2 produces more impressive graphics with far fewer options:
## Base R
hist(df$YIH,
     col = "plum2",
     xlim = c(min_yih, max_yih),
     breaks = b,
     main = "Time lived at current address",
     xlab = "Years",
     ylab = "Proportion",
     freq = FALSE)

## ggplot2
ggplot(df, aes(x = YIH)) +
  geom_histogram(fill = "plum2",  # fill specifies bar color
                 col = "pink",    # col specifies border color
                 bins = b)          # bins specifies the number of bars

# You can also visualize bar plots:
ggplot(df, aes(x = EDUC, fill = SEX)) +
  geom_bar(position = "dodge")

# But ggplot2 is especially good at generating scatter plots:
ggplot(df, aes(x = as.numeric(AGE), y = YIH)) +
  geom_point()

# And a jittered scatterplot is considerably less effort:
ggplot(df, aes(x = as.numeric(AGE), y = YIH)) +
  geom_jitter()

# As with everything in R, you can assign the "core" of your graph
# to an object:
mygraph <- ggplot(df, aes(x = as.numeric(AGE), y = YIH))

# Printing this object will show the graph (currently empty!):
mygraph

# This will allow us to examine the influence of a third, grouping
# variable much easier than when using base R functions:
mygraph + geom_jitter(aes(color = SEX))
mygraph + geom_jitter(aes(color = NONVIOLENT > 0))

# Fitting regression lines to the scatterplot is also much easier:
ggplot(df, aes(x = as.numeric(AGE), y = YIH)) +
  geom_jitter() +
  geom_smooth(method = "lm")

# By default, regression lines automatically estimate and visualize
# a confidence interval. This can be removed with the fill option:
ggplot(df, aes(x = as.numeric(AGE), y = YIH)) +
  geom_jitter() +
  geom_smooth(method = "lm", fill = NA)

# You can also fit non-linear, non-parametric regression lines.
# This will help you ascertain which regression model you
# should be using with these data. The default is Loess regression:
ggplot(df, aes(x = as.numeric(YEAR), y = YIH)) +
  geom_jitter() +
  geom_smooth()

## Note: I switched to the "year" variable as Loess regression requires
## a minimum of 10 unique values for the x-axis. Due to the tendency
## of NCVS to collect ordinal data (and the skewness of the collected 
## interval and ratio level variables), I have been intentionally liberal
## with the treatment of ordinal variables.

# You can use geom_text() to replace the points with text:
ggplot(sample_n(df, 100), aes(x = as.numeric(AGE), y = YIH)) +
  geom_text(aes(label = SEX))

# Or you can use the color and shape option in the original function call:
ggplot(df, aes(x = as.numeric(AGE), y = YIH, color = SEX, shape = SEX)) +
  geom_jitter()

# One benefit of this approach is that it allows you to fit multiple
# regression lines, one for each group. This allows you to visualize
# statistical interactions:
ggplot(df, aes(x = as.numeric(AGE), y = YIH, color = SEX, shape = SEX)) +
  geom_jitter() +
  geom_smooth(method = "lm")

# Customizing your graph labels is also very intuitive if using labs():
graph <- ggplot(df, aes(x = as.numeric(AGE),
               y = YIH,
               color = SEX,
               shape = SEX)) +
  geom_jitter() + 
  geom_smooth(method = "lm") +
  labs(title = "Relationship between Age and Time in Household",
       subtitle = "Moderated by Sex",
       x = "Age (Years)",
       y = "Time in Household (Years)",
       color = "Sex",
       shape = "Sex")

graph

# Finally, the theme() family of functions can be used to easily
# change the aesthetic of your graph. Here are four examples:
## Classic
graph + theme_classic()

## Dark
graph + theme_dark()

## Minimal
graph + theme_minimal()

## Void
graph + theme_void()

# You could also spend hours generating custom themes,
# and tinkering with the various options, creating your
# own custom color scales. The real benefit of this
# package is your ability to produce figures that are
# eye catching and impressive:
graph + 
  scale_color_manual(values = c("#e1ff00", "deeppink")) +
  theme(legend.background = element_rect(fill = "black"),
        legend.key = element_rect(fill = "black", color = "black"),
        panel.background = element_rect(fill = "black"),
        plot.background = element_rect(fill = "black"),
        text = element_text(color = "#77ff77"),
        axis.text = element_text(color = "#029b02"),
        panel.grid = element_line(color = "deeppink4"))

## ---- end_ggplot2