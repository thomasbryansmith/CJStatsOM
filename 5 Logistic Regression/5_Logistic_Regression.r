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
library(Hmisc)
library(reshape2)

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
#### You can use this to compare model fit (Likelihood Ratio Test):
anova(m1, m2)

### You can print your variance-covariance matrix:
vcov(m2)

### The 'car' package will let you find the variance inflation factor (VIF):
vif(m2)

## ---- end-visualization
############################################################################## #
###                 5. ESTIMATING CUMULATIVE LOGIT MODELS                   ====
############################################################################## #
## ---- ordered-logit-models

# Cumulative logit models can be understood as models that try to predict the
# distribution of complex crosstabs. If, for example, we wanted to examine
# the effect of victimization (1 = experienced victimization), and sex
# (2 = Female; 1 = Male). We would start with a crosstab of all 3 variables:
ftable(xtabs(~ EDUC + VIC + SEX, data = person))

# For obvious reasons, this only works with binary independent variables
# (or categorical variables with relatively few categories). If we have a
# continuous variable we wanted to introduce into the mix, we could instead
# plot the distribution across all four variables with box plots:
ggplot(person, aes(x = EDUC, y = log(YIH))) +
  geom_jitter(alpha = 0.2) +
  geom_boxplot(size = 0.75, alpha = 0.5) +
  facet_grid(SEX ~ VIC) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))

# To run a ordered / cumulative / ordinal logit, you need to import
# the MASS package:
library(MASS)

# Otherwise, it follows much the same syntax as the OLS and Logit models:
summary(m3 <- polr(EDUC ~ VIC + SEX + YIH, data = person, Hess = TRUE))

# Unlike these other models, the polr() function does not caclulate p-values
# for you (remember: p-values are not 'native' to the 'regression' process
# whereby a line/plane of best fit is fit to probability distributions).

# You will need to use this code to caclulate your own:
## Extract model coefficients:
(ctable <- coef(summary(m3)))
## Caclulate and store p values:
p <- pnorm(abs(ctable[, "t value"]), lower.tail = FALSE) * 2
## Generate significance stars:
s <- ifelse(p <= 0.001, "***",
        ifelse(p <= 0.01, "**",
          ifelse(p <= 0.05, "**", "n.s.")))
## Add p-values to the model coefficient data frame:
(ctable <- cbind(round(ctable, 3), `Pr(>|t|)` = round(p, 3), `sig` = s))

# We can also extract the confidence intervals how we would a logit:
confint(m3)

# Then, if we want to present our results as odds ratios, we can apply
# the following code to generate the OR and the 95% CI:
exp(cbind(OR = coef(m3), confint(m3)))

# Testing the proportional odds assumption
## The following code generates the log-linear parameter estimates
## for each independent variable as if we had regressed each level
## of the dependent on each independent variable individually:
sf <- function(y) {
  c('Y>=1' = qlogis(mean(y >= 1)),
    'Y>=2' = qlogis(mean(y >= 2)),
    'Y>=3' = qlogis(mean(y >= 3)),
    'Y>=4' = qlogis(mean(y >= 4)),
    'Y>=5' = qlogis(mean(y >= 5)))
}

(s <- with(person, summary(as.numeric(EDUC) ~ VIC + SEX + log(YIH), fun = sf)))

## Compare with the results of the following logit models:
glm(I(as.numeric(EDUC) >= 2) ~ VIC, family = "binomial", data = person)
glm(I(as.numeric(EDUC) >= 3) ~ VIC, family = "binomial", data = person)
glm(I(as.numeric(EDUC) >= 4) ~ VIC, family = "binomial", data = person)
glm(I(as.numeric(EDUC) >= 5) ~ VIC, family = "binomial", data = person)

## Now, let's see if each "step up" through the dependent variable (for
## each independent variable) is approximately equidistant. Ideally,
## we want the values here to all be approximately equal.
s[, 4] - s[, 3]
s[, 5] - s[, 4]
s[, 6] - s[, 5]

## For convenience, it is easier to generate a plot that visualizes the results:
plot(s,
     which = 1:5,
     pch = 1:5,
     xlab = 'logit',
     main = ' ',
     xlim = range(s[, 3:6]))

## However, for peer-reviewed publication, I would recommend performing the
## Brant-Wald Test to make sure that the proportional odds assumption holds:
library(brant)
brant(m3)
### A low p-value for a given independent variable implies that, for that
### variable, the proportional odds assumption does not hold. So, according
### to the results, only the "Victimization" variable satisfies the assumption.
### This COULD imply that the cumulative logit model is a bad 'fit' for the
### "Education Level" dependent variable. However, if you look at our previous
### figure, the points on the line are evenly dispersed along the x-asis.

### One important thing to remember about p-values is that they rely on the
### standard error, which is 'penalized' by the sample size. For particularly
### large samples - like this one (N = 41,742) - the test might be overpowered
### and thus able to identify very small deviations that would, for smaller
### sample sizes, not "flag" as significant (this ALSO applies to the p-values
### of regression coefficients!)

### If you are worried about your sample size, you could perform the same
### analysis on a subset of your data to check the "sensitivity" of the test
### to your sample size. Here we are going to perform the same analysis on a
### random set of observations (5%; N = 2,077):
sub_person <- person[sample(nrow(person), size = floor(nrow(person) * 0.05)), ]

summary(m4 <- polr(EDUC ~ VIC + SEX + YIH,
                   data = sub_person,
                   Hess = TRUE))

brant(m4)

### As you can see, the significance test maintains that the parallel odds
### assumption does NOT hold. This implies that the relationships between
### "Sex" and "Years in Household" are likely NOT the same for each response
### category of the dependent variable (Education Level).

### In other words, we need "random slopes" by group (this could be achieved
### using multi-level or "random effects" models that are introduced later in
### this course!)

## ---- end-ordered-logit-models
############################################################################## #
###                6. ESTIMATING MULTINOMIAL LOGIT MODELS                   ====
############################################################################## #
## ---- multinomial-logit-models

# Load the nnet package (which includes multinomial logit models!)
library(nnet)

# Prepare the data:
## 1. Filter to the victimized population.
## 2. Select the variables you plan on using.
## 3. Assign to a new object, mn_pers.
mn_pers <- person %>%
  filter(!is.na(VIC_LOC)) %>%
  dplyr::select(VIC_LOC, VIOLENT, AGE, SEX, EDUC, YIH) %>%
  mutate(AGE = as.numeric(AGE),
         EDUC = as.numeric(EDUC),
         SEX = as.numeric(SEX))

# Prepare the dependent variable (optional):
## Manually set the levels of the variable
## so that "other" is the reference category.
mn_pers$VIC_LOC <- factor(mn_pers$VIC_LOC, levels = c("Home",
                                                      "Communal Area",
                                                      "Open Area",
                                                      "Other"))

# Fit the multinomial logit model:
summary(m5 <- multinom(VIC_LOC ~ VIOLENT +
                                 AGE +
                                 SEX +
                                 EDUC +
                                 YIH, data = mn_pers))


# Output the results to a format that is easily introduced
# into a manuscript document or presentation:
## Load the broom and kableExtra libraries
library(broom)
library(kableExtra)

## Convert the model results into a data frame format:
tidy(m5, conf.int = TRUE)

## Data frame format with relative risk ratios:
tidy(m5, conf.int = TRUE, exponentiate = TRUE)

## Output the data frame to a kable (html table):
tidy(m5, conf.int = TRUE, exponentiate = TRUE) %>%
  kable() %>%
  kable_styling("basic", full_width = FALSE)

## Predicted Probability of Victimization Location for each Year in Home (Visualization):
gdat <- data.frame(VIC_LOC = rep(c("Communal Area", "Open Area", "Other"), each = 57),
                   YIH = rep(c(1:57), 3),
                   VIOLENT = mean(mn_pers$VIOLENT),
                   AGE = mean(mn_pers$AGE),
                   SEX = mean(mn_pers$SEX),
                   EDUC = mean(mn_pers$EDUC))

gdat <- cbind(gdat, predict(m5,
                            newdata = gdat,
                            type = "probs",
                            se = TRUE))

by(gdat[, c("Communal Area", "Open Area", "Other")], gdat$YIH, colMeans)

# Visualize the relationship:
gdat <- melt(gdat[, c("Communal Area", "Open Area", "Other", "YIH")], id.vars = c("YIH"), value.name = "probability")

ggplot(gdat, aes(x = YIH, y = probability, colour = variable)) +
  geom_line(linewidth = 1)

## ---- end-multinomial-logit-models