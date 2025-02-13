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
library(car)
library(ggpubr)

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


# Bivariate Graphs
## Visualizing the relationship between two variables as a scatter plot:
ggplot(person, aes(x = YIH, y = VIC)) +
  geom_jitter(width = 0.01, height = 0.01) +
  geom_smooth(method = "glm",
              method.args = list(family = "binomial"),
              se = TRUE) +
  labs(x = " ",
       y = "Victimization (Binary)") +
  theme(text = element_text(size = 10))

## Visualizing the relationship between two variables as a bar chart:
person %>%
  select(YIH, VIC) %>%
  group_by(YIH) %>%
  summarise(`pi` = mean(VIC)) %>%
  ggplot(aes(x = YIH, y = `pi`)) +
    geom_bar(stat = "identity") +
    labs(x = "Years in Household",
         y = expression(pi)) +
    theme(text = element_text(size = 10))

## Combining both approaches:
### Prepare the bar data using what we know about pi = f(x):
person <- person %>%
  group_by(YIH) %>%
  mutate(n = n(),
         `pi` = mean(VIC),
         `pi/n` = `pi` / n) %>%
  ungroup()

### Build the combined plot:
ggplot(person, aes(x = YIH, y = VIC)) +
  geom_smooth(method = "lm",
              se = TRUE,
              color = "red",
              fill = "pink") +
  geom_smooth(method = "glm",
              method.args = list(family = "binomial"),
              se = TRUE) +
  geom_bar(aes(y = `pi/n`), stat = "identity") +
  labs(x = "Years in Household",
       y = "Victimization (Binary)") +
  theme(text = element_text(size = 10))


## Looking at the previous plots, you may notice that the
## "years in household" variable is right-skewed.
## To 'normalize' the variable, we can log-transform it:
ggarrange(ggplot(person, aes(x = YIH)) + geom_histogram(),
          ggplot(person, aes(x = log(YIH))) + geom_histogram())

## We can apply this log transformation to the code for the
## above combined plot to examine how it affects bivariate
## model fit:
person <- person %>%
  group_by(log(YIH)) %>%
  mutate(n = n(),
         `pi` = mean(VIC),
         `pi/n` = `pi` / n) %>%
  ungroup()

ggplot(person, aes(x = log(YIH), y = VIC)) +
  geom_smooth(method = "lm",
              se = TRUE,
              color = "red",
              fill = "pink") +
  geom_smooth(method = "glm",
              method.args = list(family = "binomial"),
              se = TRUE) +
  geom_bar(aes(y = `pi/n`), stat = "identity") +
  labs(x = "Years in Household",
       y = "Victimization (Binary)") +
  theme(text = element_text(size = 10))

## ---- end-descr_vis
# ============================================================================ #
## EXERCISE:
### Build a scatter plot where AGE is along the x-axis, and NONVIOLENT
### victimization is along the y-axis. Fit a logit generalized linear
### model to this plot using geom_smooth().
# ============================================================================ #

############################################################################## #
###                  3. ESTIMATING LOGISTIC (LOGIT) MODELS                  ====
############################################################################## #
## ---- logit-models

# Let's start by fitting a linear probability model using the lm() function:
summary(m1 <- lm(VIC ~ log(YIH) +                 # Log Years in Household
                       I(log(YIH)^2) +            # Log Years in Household^2
                       scale(as.numeric(AGE)) +   # Age (Ordinal)
                       scale(as.numeric(EDUC)) +  # Education (Ordinal)
                       SEX,                       # Sex (Binary)
                 data = person))

## Model Specification:
### Pr(VIC = 1) ~ b0 + b1(YIH) + b2(YIH^2) + b3(AGE) + b4(EDUC) + b5(SEX) + e

## Interpretation (same as OLS, but the DV is a probability):
### b0: the intercept, the average value of the DV when all IVs are 0.
### bk: the average change in the probability of the DV (1),
###     for each interval increase in the IV, controlling for the other IVs.
### Pr(>|t|): P-value, probability of observing the current (or a more extreme)
###           effect size under the assumption that the null hypothesis is true.
### Degrees of freedom: n - (k + 1); n = # obs; k = # IVs.
### R-squared: Proportion of variance in the DV explained by the IVs.
### F-test: Overall model significance.

## For all of the reasons discussed in class, and demonstrated in the figures
## you generated in the previous section of this R module, it is typically
## ill-advised to fit a linear probability model.

# ============================================================================ #

# Now, let's fit a logit model with the same specification, but
# Pr(VIC = 1) becomes log(VIC / (1 - VIC)):

summary(m2 <- glm(VIC ~ log(YIH) +                 # Log Years in Household
                        I(log(YIH)^2) +            # Log Years in Household^2
                        scale(as.numeric(AGE)) +   # Age (Ordinal)
                        scale(as.numeric(EDUC)) +  # Education (Ordinal)
                        SEX,                       # Sex (Binary)
                  data = person,
                  family = binomial(logit)))

## Note that the only changes to the code are: (1) the function, which
## changes from lm() [linear model] to glm() [generalized linear model],
## and we introduce the "family ="" option with the "binomial(logit)"
## link function.

# Interpreting the results
## Log Odds
summary(m2)
### Intercept: -3.18      When all IVs are 0, we expect the average
###                       log odds of victimization to be -3.18.

### AGE: -0.14            For each standard deviation increase in age, we expect
###                       an average reduction of 0.14 in the log odds
###                       of victimization, net of control variables.

### SEX (Female): 0.09    On average, women are expected to score 0.09
###                       greater than men on the log-odds of victimization.

### Note that these interpretations are all a little clunky. This is because
### there is no real 'meaningful' interpretation for the log-odds.
### It is an unintuitive transformation.


## Odds Ratios
### Conveniently, you can use this handy line of code to simultaneously
### exponentiate your coefficients AND confidence intervals!
exp(cbind(coef(m2), confint(m2)))
### Intercept: 0.04       When all IVs are 0, we expect the average
###                       odds of victimization to be 0.04.

### AGE: 0.87             For each standard deviation increase in age, we expect
###                       a 0.87 factor change in victimization likelihood/
###                       a 13 percent reduction in the odds of victimization.

### SEX (Female): 1.10    On average, women are expected to report at
###                       least one victimization 10% more frequently than men.


# ---- end-logit-models
# ============================================================================ #
## EXERCISE:
### Fit a logit model where AGE, SEX, Years in Household (YIH), and AGE
### predict NONVIOLENT victimization. Introduce an interaction between
### SEX and YIH. Calculate the Odds Ratios for the model beta coefficients
### and confidence intervals.
# ============================================================================ #

############################################################################## #
###                   4. POST-ESTIMATION AND VISUALIZATION                  ====
############################################################################## #
## ---- visualization

# Predicted Probabilities
## Whole sample:
head(predict(m2, type = "response"))


## Typical / interesting individuals:
pred_prob <- function(y){
  exp(y) / (1 + exp(y))
}

### Keep in mind the order of your variables / coefficients:
#### 1. Intercept
#### 2. Years in Household
#### 3. Years in Household (Squared)
#### 4. Age (Centered, Z-Score)
#### 5. Education (Centered, Z-Score)
#### 6. Sex (Female = 1, Binary)

### Men (0 years in home, average age and education level):
sum(coef(m2) * c(1, 0, 0, 0, 0, 0)) %>%
  pred_prob()

### Women (0 years in home, average age and education level):
sum(coef(m2) * c(1, 0, 0, 0, 0, 1)) %>%
  pred_prob()

### Women w. a PhD (0 years in home, average age):
sum(coef(m2) * c(1,
                 0,
                 0,
                 0,
                 person$EDUC %>% as.numeric() %>% scale() %>% max(),
                 1)) %>%
  pred_prob()


## Testing the effect of specific parameters on the sample:
### The following code will give you the predicted probabilities
### for the whole sample (maintaining their observed scores for
### most variables), but treat all observations as FEMALE.
### This is achieved by "forcing" the "SEX" variable to be "Female".
### If you View() the ppf object, you can verify that all observations
### are treated as "Female" for the purpose of generating predictions.
### You can do this for any regression, and any variable!
ppf <- data.frame("YIH" = person$YIH,
                  "AGE" = person$AGE,
                  "EDUC" = person$EDUC,
                  "SEX" = as.factor("Female"))
head(fm_pp <- predict(m2, newdata = ppf, type = "response"))

### If we generate the same for men, we could look at how the distribution
### changes when comparing men and women:
ppm <- data.frame("YIH" = person$YIH,
                  "AGE" = person$AGE,
                  "EDUC" = person$EDUC,
                  "SEX" = as.factor("Male"))
head(m_pp <- predict(m2, newdata = ppm, type = "response"))

### Now we can plot the distributions for males v. females side by side.
### Note that, because females a predicted to report victimization
### more frequently, their distribution has shifted slightly to the right.
ggplot(data.frame("p" = c(m_pp, fm_pp),
                  "sex" = c(rep("Male", length(m_pp)),
                            rep("Female", length(fm_pp)))),
      aes(x = p, fill = sex)) +
  geom_density(alpha = 0.5)


## Calculating predicted probabilities for a range of values:
pp <- data.frame("YIH" = seq(min(person$YIH), max(person$YIH), by = 0.5) %>%
                   rep(each = 2),
                 "AGE" = mean(as.numeric(person$AGE)),
                 "EDUC" = mean(as.numeric(person$EDUC)),
                 "SEX" = as.factor(c("Male", "Female")))
pp$prob <- predict(m2, newdata = pp, type = "response")

ggplot(pp, aes(x = YIH, y = prob, color = SEX)) +
  geom_point()

### Note that this particular approach to visualizing your
### model predictions is particularly helpful for visualizing
### non-linear model paramters (and interactions).

### In general, generating model predicitons are a very good
### way of understanding what a complex model might be telling
### you about your sample!

# ============================================================================ #

# Post-estimation functions
## Most of the same post-estimation functions that we used for OLS
## also apply to Logit (you should see some of them in the above code!)
## As a reminder:

### Akaike's Information Criterion (AIC)
AIC(m2)

### Bayesian Information CRiterion (BIC)
BIC(m2)

### You can extract the coefficients as a named numeric vector:
coef(m2)

### You can generate a named matrix of confidence intervals:
confint(m2, level = 0.95)

### You can generated a named numeric vector of predicted marginal scores:
fitted(m2) %>% head()
predict(m2) %>% head()

### Analysis of Deviance:
anova(m2)
#### You can use this to compare model fit:
anova(m1, m2)

### You can print your variance-covariance matrix:
vcov(m2)

### The 'car' package will let you find the variance inflation factor (VIF):
vif(m2)

# ---- end-visualization