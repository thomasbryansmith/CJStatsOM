# Title: Poisson and Negative Binomial Regression
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

library(tidyverse)
library(MASS)

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

# Create the victimization variable
person$VIC <- person$VIOLENT + person$NONVIOLENT

## ---- end_setup
############################################################################## #
###              2. DESCRIPTIVE STATISTICS AND VISUALIZATION                ====
############################################################################## #
## ---- descr_vis

## Check your data to ensure that your dependent variable only consists of
## positive integers - remember, Poisson is intended for counts.
table(person$VIC)

## To visualize the relationship between a categorical variable and
## your dependent variable, you can plot them as a grouped histogram.
ggplot(person, aes(x = VIC, fill = EDUC)) +
  geom_histogram(aes(y = 0.5 * after_stat(density)),
                 binwidth = 0.5,
                 position = "dodge")

## At a glance, you can see that victimization is severely zero inflated.
## In this situation, you might want to subset the data to non-zero responses.
ggplot(subset(person, VIC > 0), aes(x = VIC, fill = EDUC)) +
  geom_histogram(aes(y = 0.5 * after_stat(density)),
                 binwidth = 0.5,
                 position = "dodge")

## You can visualize the relationship between a count variables and a
## continous variable using a scatterplot with a fitted Poisson model.
ggplot(person, aes(x = YIH, y = VIC)) +
  geom_point() +
  geom_smooth(method = "glm",
              method.args = list(family = "poisson"),
              se = TRUE)

## Or you could fit a negative binomial model:
ggplot(person, aes(x = YIH, y = VIC)) +
  geom_point() +
  geom_smooth(method = "glm.nb",
              se = TRUE)

## ---- end-descr_vis
############################################################################## #
###                  3. ESTIMATING POISSON MODELS                           ====
############################################################################## #
## ---- poisson-models

# Let's start by fitting a Poisson model with the glm() function:
summary(m1 <- glm(VIC ~ log(YIH) +                 # Log Years in Household
                        scale(as.numeric(AGE)) +   # Age (Ordinal)
                        scale(as.numeric(EDUC)) +  # Education (Ordinal)
                        SEX,                       # Sex (Binary)
                  family = "poisson",
                  data = person))

## The only difference to fitting a Logit and a Poisson is the "family"
## option, which informs R of the link function for the generalized
## linear model.

# Interpreting the results
## Log Count
summary(m1)
### Intercept: -2.92      When all IVs are 0, we expect the average
###                       log count of victimization to be -2.92.

### AGE: -0.10            For each standard deviation increase in age, we expect
###                       an average reduction of 0.10 in the log count
###                       of victimization, net of control variables.

### SEX (Female): 0.13    On average, women are expected to score 0.09
###                       greater than men on the log count of victimization.

### As with logit, the log count can be a little clunky to interpret.
### So, we can transform into the incidence rate ratio (IRR):
exp(cbind(coef(m1), confint(m1)))
### Intercept: 0.054      When all IVs are 0, we the expected count
###                       of victimizations experienced by a participant
###                       is 0.054. This could also be interpreted as
###                       roughly 1 in 18 people.

### AGE: 0.91             For each interval increase in age (1 standard
###                       deviation), we expect a 0.91 factor change in
###                       the count of victimizations. This can also
###                       be interpreted as a 9% reduction.

### SEX (Female): 1.14    Women are expected to experience 1.14 times
###                       (aka 14%) more victimizations than men.

## The sandwich package can be used to manually calculate
## robust standard errors:
library(sandwich)

cov_m1 <- vcovHC(m1, type = "HC0")
std_err <- sqrt(diag(cov_m1))
r_est <- cbind(Estimate = coef(m1), "Robust SE" = std_err,
"Pr(>|z|)" = 2 * pnorm(abs(coef(m1) / std_err), lower.tail = FALSE),
LL = coef(m1) - 1.96 * std_err,
UL = coef(m1) + 1.96 * std_err)

print(r_est)

## These standard errors are recommended when the variance of the
## dependent variable does not perfectly match the mean.

## Given that this is often the case, it is advised you use these
## standard errors in the majority of cases.

## But we can also check for this violation ourselves:
mean(person$VIC)

var(person$VIC)

abs(mean(person$VIC) - var(person$VIC))

## The variance is over twice the mean, implying that these data
## are overdispersed - this is common among zero-inflated measures.

## ---- end-poisson-models
############################################################################## #
###               4. ESTIMATING NEGATIVE BINOMIAL MODELS                    ====
############################################################################## #
## ---- nb-models

## Formally checking for overdispersion:
library(AER)

summary(nm <- glm(VIC ~ 1,
                  family = "poisson",
                  data = person))

dispersiontest(nm, trafo = 1)

## A significant overdispersion test confirms that your dependent variable
## is overdispersed. So, we might consider fitting a negative binomial model.

## As noted in the accompanying slides to this workshop, the interpretation of
## a Negative Binomial Regression is identical to a Poisson model.
## So, to interpret the following model, refer to the previous section.

## Now we fit a the Negative Binomial model with the glm.nb() function
## from the MASS package:

summary(m2 <- glm.nb(VIC ~ log(YIH) +                 # Log Years in Household
                           scale(as.numeric(AGE)) +   # Age (Ordinal)
                           scale(as.numeric(EDUC)) +  # Education (Ordinal)
                           SEX,                       # Sex (Binary)
                     data = person))

## Again, we can calculate the incidence rate ratios with the exp() function:
exp(cbind(coef(m2), confint(m2)))


## ---- end-nb-models
############################################################################## #
###                5. ESTIMATING ZERO-INFLATED MODELS                       ====
############################################################################## #
## ---- zi-models

## If we look at the mean and variance of the dependent variable
## when dropping the 0s, you'll notice that the distribution is
## no longer overdispersed.

subset(person, VIC > 0)$VIC %>% mean()

subset(person, VIC > 0)$VIC %>% var()

## In this case, you might want to consider fitting a zero-inflated Poisson:
library(pscl)

summary(m2 <- zeroinfl(VIC ~ log(YIH) +                 # Log Years in Household
                             scale(as.numeric(AGE)) +   # Age (Ordinal)
                             scale(as.numeric(EDUC)) +  # Education (Ordinal)
                             SEX |                      # Sex (Binary)

                             log(YIH) +                 # Log Years in Household
                             scale(as.numeric(AGE)) +   # Age (Ordinal)
                             scale(as.numeric(EDUC)) +  # Education (Ordinal)
                             SEX,                       # Sex (Binary)
                       data = person))

## This function will fit two models:
### A Logit to model the distinction between 0 and non-zero.
### A Poisson to model the distribution of non-zero values.

## When defining the function, note that we have specified
## the regression equation twice, separated by a vertical bar: |

## Critically, this allows you to fit different sets of predictors
## for each of the two models. If, for example, you have reason to believe
## that the independent variables that predict experiencing victimization
## are different to the independent variables that predict the number of
## experienced victimizations, this model would be more appropriate
## than the negative binomial. It allows you to draw different hypotheses.

## Interpretation is, again, simple. We have already covered Logit models
## extensively, and the interpretation of the Poisson component is the
## same as above. Just remember the key difference between the two models
## (noted above).

## ---- end-zi-models