# Title: Logistic (Logit) Regression
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

# ============================================================================ #

# Load the NCVS dataset we have been working with:
person <- readRDS("../Data/person.rds")

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

# Create your binary dependent variable (victimization)
person <- person %>%
  mutate(VIC = as.numeric((VIOLENT > 0) | (NONVIOLENT > 0)))

## ---- end_setup
############################################################################## #
###                 2. DESCRIPTIVES AND BINARY VISUALIZATION                ====
############################################################################## #
## ---- descr_vis

# You can generate a simple plot of the Bernoulli distribution of your
# dependent variable with the plot() and table() functions:
person$VIC |> table() |> plot()

# This is useful for your own diagnostics, and understanding what proportion
# of respondents in your data were victimized. However, it's not analytically
# interesting and best described with the mean() function.

# Remember, the mean() of a Bernoulli random variable is the proportion, 'p',
# of observations with the affirmative / TRUE / "1" response:
person$VIC |> mean()

# You can find the variance, which is defined as p * (1 - p),
# with the var() function. However, like the plot, you typically
# wouldn't include this in a publication (it doesn't tell you much!)
person$VIC |> var()

# The table() function by itself will provide you the frequencies for
# the variable:
person$VIC |> table()




# ============================================================================ #
## EXERCISE:
###
# ============================================================================ #

## ---- end-descr_vis
############################################################################## #
###                  3. ESTIMATING LOGISTIC (LOGIT) MODELS                  ====
############################################################################## #
## ---- logit-models

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

    # Mediation
    dir <- lm(Murder ~ UrbanPop, data = USArrests)
    ind1 <- lm(Assault ~ UrbanPop, data = USArrests)
    ind2 <- lm(Murder ~ Assault + UrbanPop, data = USArrests)

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
## EXERCISE:
###
# ============================================================================ #

############################################################################## #
###                    4. VISUALIZING LOGIT MODELS                          ====
############################################################################## #
## ---- visualization



# ---- end-visualization
# ============================================================================ #
## EXERCISE:
### 
# ============================================================================ #