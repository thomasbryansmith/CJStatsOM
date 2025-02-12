# Title: Ordinary Least Squares Regression
# Subtitle: CJ 702 Advanced Criminal Justice Statistics
# Author: Thomas Bryan Smith <tbsmit10@olemiss.edu>
# GitHub: thomasbryansmith/CJStatsOM
#
# Released under MIT License
# https://github.com/thomasbryansmith/CJStatsOM?tab=MIT-1-ov-file

############################################################################## #
###                     1. Setting up your environment                      ====
############################################################################## #
## ---- setup

# Load Packages
library(tidyverse)
library(psych)
library(bda)
library(mediation)
library(car)

# ============================================================================ #

# Load the USArrests dataset.
# This is a built-in dataset for practicing with and testing R functions.
# It is loaded with the data() function, and does not need to be assigned.
data("USArrests")

# Check your data:
head(USArrests)

# Take note of the variables:
## Murder: Murder arrests (per 100,000)
## Assault: Assault arrests (per 100,000)
## Rape: Rape arrests (per 100,000)
## UrbanPop: Percent urban population

# ============================================================================ #

# Load the NCVS dataset we have been working with:
person <- readRDS("./Data/person.rds")

# Check your data:
head(person)

# Take note of the variables:
## ID: Person ID                                (numeric)
## IDHH: Household ID                           (numeric)
## PER_WGT: Person Weight                       (numeric)
## VIOLENT: Violent victimization count         (numeric, count, ratio)
## VLNT_WGT: Violent victimization weight       (numeric)
## NONVIOLENT: Nonviolent victimization count   (numeric, count, ratio)
## NVLNT_WGT: Nonviolent victimization weight   (numeric)
# YIH: Years in household                       (numeric, years, interval)
# EDUC: Education level                         (factor, ordinal)
# AGE: Age                                      (factor, years, ordinal)
# SEX: Sex                                      (factor, nominal)

# Check for missingness:
missing <- person %>%
  filter(!complete.cases(VIOLENT, NONVIOLENT,
                         YIH, EDUC, AGE, SEX)) %>%
  nrow()
n <- person %>% nrow()
missing / n

# Satisfied with sufficiently low missingness,
# you can perform listwise deletion:
person <- person %>%
  filter(complete.cases(VIOLENT, NONVIOLENT,
                        YIH, EDUC, AGE, SEX))

# If you want to create any scales or indices,
# you can check the internal consistency of a set
# of measures with psych's alpha() function:
person %>% dplyr::select(VIOLENT, NONVIOLENT) %>% alpha()

# These variables were never really intended to be
# aggregated, so Cronbach's Alpha is very low (around 0.14).
# In your own research, you want to be aiming for 0.7 or
# above. For a modern peer-review publication, you should also be
# supplementing it with exploratory factory analysis (EFA),
# confirmatory factor analysis (CFA), or item response theory (IRT).
# All of these can be performed in R!

# If you did want to create an additive scale, you could use
# the composite() function:
person %>% 
  dplyr::select(VIOLENT, NONVIOLENT) %>%
  mutate(VIC = rowSums(.))

# If you wanted to retain this variable, you would need to
# assign this string of functions over the original person object.



## ---- end_setup
############################################################################## #
###                    2. ESTIMATING LINEAR MODELS                          ====
############################################################################## #
## ---- linear-models

# Start out with the correlation coefficient:
USArrests %>% dplyr::select(Murder, Assault, Rape, UrbanPop) %>% cor()

# To estimate a bivariate linear model you use the lm() function.

# The lm() function is a little different in that you need to specify
# the data you are working with and tell R how you want to build
# your linear model. The 'data = ' option is where you indicate
# the data frame you are working with, and is an option in many
# other R functions that analyze data.

# You specify the regression equation at the beginning of the function
# input. If you want the equation 'Murder = b0 + (b1 * UrbanPop) + e',
# then you would enter 'Murder ~ UrbanPop', where '~' is used to denote
# approximate equality. The intercept and error terms are assumed by the
# function. Putting this all together, we get the following:
lm(Assault ~ UrbanPop, data = USArrests)

# However, you'll notice that it only returns the slope and intercept
# coefficients. As ever, you need to assign the results to an object
# if you want to explore them further:
m1 <- lm(Assault ~ UrbanPop, data = USArrests)

# Once assigned, you can use the summary() function to return a
# complete read out of the results:
summary(m1)

# For efficiency, you can combine this into a single line of code:
summary(m1 <- lm(Assault ~ UrbanPop, data = USArrests))

## Interpretation:
### b0: the intercept, the average value of the DV when all IVs are 0.
### b1: the average change in the DV for each interval increase in the IV.
### Pr(>|t|): P-value, probability of observing the current (or a more extreme)
###           effect size under the assumption that the null hypothesis is true.
### Degrees of freedom: n - (k + 1); n = # obs; k = # IVs.
### R-squared: Proportion of variance in the DV explained by the IVs.
### F-test: Overall model significance.

# ============================================================================ #

# Multiple Regression:
summary(m1 <- lm(Murder ~ Assault + UrbanPop, data = USArrests))

### b1-k: the average change in the DV for each interval increase in the IV,
###       net of all other IVs in the model.

# ============================================================================ #

# In the above example, we are estimating the change in the Assault
# rate per 100,000 people for each interval increase (1 percentage point)
# in the Urban Population Percentage.

# As you'll recall, the UrbanPop variable is a percentage.
# It is not reasonable to assume that 0 percent of the population
# in a given state resides in a city. The lowest we observe is 32%:
min(USArrests$UrbanPop)

# So, we might want to mean center and / or standardize the variable.
## Mean centered:
summary(m1 <- lm(Assault ~ scale(UrbanPop, scale = FALSE), data = USArrests))

## Z-score standardized, but uncentered:
summary(m1 <- lm(Assault ~ scale(UrbanPop, center = FALSE), data = USArrests))

## Z-score standardized and mean centered:
summary(m1 <- lm(Assault ~ scale(UrbanPop), data = USArrests))

# In the above example, we are estimating the change in the Assault
# rate per 100,000 people for each standard deviation increase in the
# Urban Population Percentage.

# ============================================================================ #

# If you want to fit an intercept-only model, that is a model that is
# specified such that 'y = b0 + e' (includes no independent variables)
# you simple need to replace the independent variable with a 1.
summary(m1 <- lm(Assault ~ 1, data = USArrests))

# ============================================================================ #

# If you want to fit the model to a subset of your data (e.g., males),
# you can use the 'subset = ' option. This performs the same function
# as R's subset() function, but within the lm() function:
summary(m1 <- lm(Assault ~ scale(UrbanPop),
                 data = USArrests,
                 subset = Murder < 8))

# In the above example, we are estimating the change in the Assault
# rate per 100,000 people for each standard deviation increase in the
# Urban Population Percentage, but only for states with a below average
# murder rate.

# ============================================================================ #

# You can also specify the way that lm() deals with missingness using
# the 'na.action = ' option. If you want the model to return an error
# when there is any missing present, you can set this to 'na.fail':
summary(m1 <- lm(Murder ~ scale(Assault) + scale(UrbanPop),
                 data = USArrests,
                 na.action = na.fail))

# However, the default setting is 'na.omit', like so:
summary(m1 <- lm(Murder ~ scale(Assault) + scale(UrbanPop),
                 data = USArrests,
                 na.action = na.omit))

# ============================================================================ #

# You can introduce polynomials by raising a given variable to
# the appropriate power.
## Quadratic:
summary(lm(Assault ~ UrbanPop + I(UrbanPop^2),
           data = USArrests))

## Cubic:
summary(lm(income ~ UrbanPop + I(UrbanPop^2) + I(UrbanPop^3),
           data = USArrests))

## Quartic:
summary(lm(income ~ UrbanPop + I(UrbanPop^2) + I(UrbanPop^3) + I(UrbanPop^4),
           data = USArrests))

### But we will get more into this when and if we cover non-linear models.

# ============================================================================ #

# Mediation
dir <- lm(Murder ~ UrbanPop, data = USArrests)
ind1 <- lm(Assault ~ UrbanPop, data = USArrests)
ind2 <- lm(Murder ~ Assault + UrbanPop, data = USArrests)

## Sobel Test
### This test is used to check the statistical significance
### of the mediation effect. It cannot help you find effect
### size. For that, you'll want to either interpret the
### above models, or run a nonparametric bootstrap.
mediation.test(mv = USArrests$Assault,
               iv = USArrests$UrbanPop,
               dv = USArrests$Murder)

## Nonparametric Bootstrap
bsm <- mediate(ind1, ind2,
               treat = "UrbanPop",
               mediator = "Assault",
               boot = TRUE,
               sims = 1000)
summary(bsm)

## ACME: Average Causal Mediation Effect
### This is how much of the total effect is explained
### by the mediator. The average change in the DV in
### response to an interval increase in the IV via the MV.

## ADE: Average Direct Effect
### This is how much of the total effect is explained
### by the independent variable. The average change in
### the DV in response to an interval increase in the IV,
### controlling for the effect of the MV.

## Total Effect
### This is the combined effect of both the independent
### variable and the mediator. It's non-significant here
### because the indirect (ACME) and direct (ADE) effects
### appear to cancel eachother out.

## Prop. Mediated
### The indirect effect divided by the total effect.

# ============================================================================ #

# Moderation
## To integrate a moderation effect, you simply multiply the
## two variables you wish to examine. The interaction term
## is interpreted as the additional increase in the DV
## for each interval increase in the interacting variables.
mod <- lm(Murder ~ Assault * UrbanPop, data = USArrests)

# ============================================================================ #

# Post-estimation functions
## Akaike's Information Criterion (AIC)
AIC(m1)
## Bayesian Information CRiterion (BIC)
BIC(m1)

## You can extract the coefficients as a named numeric vector:
coefficients(m1)

## You can generate a named matrix of confidence intervals:
confint(m1, level = 0.95)

## You can generated a named numeric vector of predicted marginal scores:
fitted(m1)
predict(m1)

## You can convert your OLS model into an ANOVA model:
anova(m1)

## You can print your variance-covariance matrix:
vcov(m1)

## You can estimate the level of influence each observation has
## on your results. This is typically used to detect outliers:
influence(m1)

## You can compare the fit of two different models with ANOVA:
anova(dir, ind2)

## The 'car' package will let you find the variance inflation factor (VIF):
vif(m1)

# ---- end-linear-models
# ============================================================================ #
## EXERCISE 2.a:
### Using the NCVS data, estimate a linear model where education level is
### predicted by violent victimization. Assign the linear model results to
### an object. Print the results.
# ============================================================================ #
## EXERCISE 2.b:
### Using the NCVS data, estimate a linear model where education level is
### predicted by violent victimization, controlling for non-violent
### victimization, sex, age, and years in household. Assign the results to
### another object. Print the results.
# ============================================================================ #
## EXERCISE 2.c:
### Compare the fit statistics for these two models using the anova(),
### AIC(), and BIC() functions. Does introducing controls improve model fit?
# ============================================================================ #

############################################################################## #
###                    3. VISUALIZING LINEAR MODELS                         ====
############################################################################## #
## ---- visualization

# Bivariate regression results

## Use the par() function to define the graph margins.
## If you find that your plot is not displaying an axis title,
## then you may want to try running this code before using the
## plot() function. It can also be used to visualize multiple plots.
par(mar = c(5, 5, 4, 4),
    mfrow = c(1, 1))

## Scatter plot for your DV and IV:
plot(USArrests$UrbanPop, USArrests$Assault,
     main = "Association between Assault and Urban Population",
     xlab = "Urban Population (%)",
     ylab = "Assault (per 100,000)",
     pch = 20)

## Plot the results of the OLS regression, as generated by the lm() function:
abline(lm(Assault ~ UrbanPop, USArrests), col = "red")

## If you have already fit the linear model and assigned it to an object,
## you can instead just replace the lm() function within abline() with that
## object:
ols <- lm(Assault ~ UrbanPop, USArrests)
summary(ols)

abline(ols, col = "blue")

## You can also plot a line with the predicted scores from the regression:
predictions <- predict(ols)

plot(USArrests$UrbanPop, predictions,
     type = "o", col = "red",
     xlim = c(min(USArrests$UrbanPop), max(USArrests$UrbanPop)),
     ylim = c(min(USArrests$Assault), max(USArrests$Assault)),
     main = "Association between Assault and Urban Population",
     xlab = "Urban Population (%)",
     ylab = "Assault (per 100,000)",
     pch = 20)

# ============================================================================ #

# Multiple regression results

## Predicted / actual plot
### Predicted values of a multivariate linear model can be a good
### way of visualizing the goodness-of-fit. You can examine the
### model residuals by generating a scatterplot with both
### predicted and observed scores on the dependent variable.
predictions <- predict(m1)

plot(predictions, USArrests$Murder,
     xlim = c(min(USArrests$Murder), max(USArrests$Murder)),
     ylim = c(min(USArrests$Murder), max(USArrests$Murder)),
     main = "Predicted / actual plot",
     xlab = "Predicted murders (per 100,000)",
     ylab = "Observed murders (per 100,000)",
     pch = 20)
abline(a = 0, b = 1)

## 3D scatter plot
### Alternatively, if you are only working with three variables
### you could create a 3D plot:
scatter3d(Murder ~ Assault + UrbanPop,
          data = USArrests)

# ============================================================================ #

# ggplot2

## You can (and should) replicate all of the above scatterplots using ggplot2.
## Here is an example of the basic bivariate scatterplot.
ggplot(USArrests, aes(y = Assault, x = UrbanPop)) + 
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "Association between Assault and Urban Population",
       y = "Assault (per 100,000)",
       x = "Urban Population (%)")

# ---- end-visualization
# ============================================================================ #
## EXERCISE 3.a:
### Using base R graphics (the plot() function), visualize the association
### between level of education and non-violent education. You might want
### to incorporate the jitter() function!
### Appropriately label your graph (title and axes).
### Use the abline() function to fit a regression line.
# ============================================================================ #
## EXERCISE 3.b:
### Replicate the previous exercise using ggplot2.
### Attempt to plot separate regression lines for males and females.
### You will need to use the 'group = ' option.
# ============================================================================ #

############################################################################## #
###                  4. DIAGNOSTICS AND TESTING ASSUMPTIONS                 ====
############################################################################## #
## ---- testing-assumptions

# Note on terminology:
## Studentized residuals are estimated by dividing each residual by the
## standard error. Studentization follows a similar logic to standardization
## (z-scores).

# ============================================================================ #

# Checking for outliers and influential observations

## Bonferonni p-value for most extreme observations
outlierTest(m1)

## QQ plot
qqPlot(m1, main = "QQ Plot")

## Leverage Plot
leveragePlots(m1)

## Cook's D plot [with 4/(n-k-1) as the cutoff]
cutoff <- 4 / ((nrow(USArrests) - length(m1$coefficients) - 2))
plot(m1, which = 4, cook.levels = cutoff)

# ============================================================================ #

# Assumption 1: Y is a linear function of X
## Technically this assumption is simply that the model is linear in parameters.
## By this definition, simply using the lm() function satisfies the assumption.

## However, you can use the scatter.smooth() function to see if the relationship
## between two variablesis actually linear. From the following plot you can see
## that, despite being slightly squiggly, you can cleanly fit a linear
## model within the bounds of the 95% confidence interval.

ggplot(USArrests, aes(y = Assault, x = UrbanPop)) +
  geom_point() +
  geom_smooth(color = "blue", fill = "skyblue") +
  geom_smooth(method = "lm", color = "red", fill = "pink")


## Component and Residual Plots
### The following function will generate similar visualizations for
### multivariate models. Keep in mind that a plot will be generated
### for each variable. This can be a problem with saturated models.
crPlots(m1)

# ============================================================================ #

# Assumption 2: Multivariate Normality

## Histograms
studresid <- studres(m1)
hist(studresid, freq = FALSE,
     main = "Studentized Residuals Histogram")

xfit <- seq(min(studresid), max(studresid), length = 40)
yfit <- dnorm(xfit)

lines(xfit, yfit, col = "red")

## QQ Plots
qqPlot(m1, main = "QQ Plot")

# ============================================================================ #

# Assumption 3: Little or no multicollinearity

## Variance inflation factors
vif(m1)
vif(m1) > 2

### VIF = 1 / (1 - R-Squared)
### Estimated for all variables.
### A VIF over 10 suggests that there may be multicollinearity.
### A VIF over 100 suggests that there is definitely multicollinearity.

### The square root of the VIF gives you an estimate for
### how much larger the SE is when compared with the SE if the
### variable in question was uncorrelated with any other variable.

### You want this value to be lower than 2 when possible.

### The second line of code sets up a boolean output where TRUE 
### indicates possible multicollinearity in the associated variable.

# ============================================================================ #

# Assumption 4: Little or no autocorrelation

## Autocorrelation is the correlation between the same variable
## at different points in time (past behavior predicting future behavior).
## Not as relevant in our cross-sectional models.
## Regardless, this is how you'd test for autocorrelation.

## Durbin Watson Test
### We want the D-W statistic to approximately equal 2.
### A D-W statistic which is significantly different from 2 indicates
### that the linear model's residuals are correlated. This suggests
### the presence of autocorrelation.
durbinWatsonTest(m1)

## ACF Plot
### In this plot we want all the lines following the first to fall
### within the two dashed blue lines. No autocorrelation present!
resid(m1) |> acf()

# ============================================================================ #

# Assumption 5: Homoscedasticity (Little or no heteroscedasticity)

## Non-constant error variance test
ncvTest(m1)
### This function performs a chi-square test where the null hypothesis
### is homoscedasticity. We want to see a chi-square with p > 0.05.
### A high chi-square with p < 0.05 implies that the residuals are not
### consistent at all points of the regression line. You can visualize
### this concept with residual plots and spread level plots.

## Residual plots
residuals <- resid(m1)

plot(USArrests$Assault, residuals,
     ylab = "Residuals",
     xlab = "Assault (per 100,000)",
     main = "Residual Plot")
abline(lm(residuals ~ USArrests$Assault))

plot(USArrests$UrbanPop, residuals,
     ylab = "Residuals",
     xlab = "Urban Population (%)",
     main = "Residual Plot")
abline(lm(residuals ~ USArrests$UrbanPop))

## Spread level plots
### You want the blue dashed line to conform to the solid pink line.
spreadLevelPlot(m1)

# ============================================================================ #

# Additional diagnostics
## The gvlma package is very helpful for evaluating model skewness, kurtosis,
## and heteroscedasticity. It will inform you of any violated assumptions.
summary(gv <- gvlma(m1))

## The plot() function can also be used to automatically generate a battery
## of fit visualizations, including a residuals v. fitted plot, QQ plot,
## scale-location plot, and residuals v. leverage plot.
par(mfrow = c(2, 2))
plot(m1)

## Before proceeding, execute this code to reset your 'plots' tab
## to its original settings:
par(mfrow = c(1, 1))

# ---- end-testing-assumptions
# ============================================================================ #
## EXERCISE 4.a:
### Assess the skewness, kurtosis, and heteroscedasticity for the model
### you generated in EXERCISE 2.b. Does this model satisfy the assumptions?
# ============================================================================ #
## EXERCISE 4.b:
### Visualize the multivariate normality assumption with a QQ plot.
# ============================================================================ #
## EXERCISE 4.c:
### Visualize the homoscedasticty assumption with a residual plot.
# ============================================================================ #