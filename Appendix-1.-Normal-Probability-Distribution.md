Normal Probability Distribution
================
Thomas Bryan Smith[^1] <br/>
February 03, 2025

- [1 Load the USArrest data](#1-load-the-usarrest-data)
- [2 Viewing the *frequency distribution* for the **Assault**
  variable](#2-viewing-the-frequency-distribution-for-the-assault-variable)
- [3 The **normal** *probability
  distribution*](#3-the-normal-probability-distribution)

# 1 Load the USArrest data

First, let’s load in the built-in USArrest data, and take a look at it.

``` r
data(USArrests)

head(USArrests, 25)
```

    ##               Murder Assault UrbanPop Rape
    ## Alabama         13.2     236       58 21.2
    ## Alaska          10.0     263       48 44.5
    ## Arizona          8.1     294       80 31.0
    ## Arkansas         8.8     190       50 19.5
    ## California       9.0     276       91 40.6
    ## Colorado         7.9     204       78 38.7
    ## Connecticut      3.3     110       77 11.1
    ## Delaware         5.9     238       72 15.8
    ## Florida         15.4     335       80 31.9
    ## Georgia         17.4     211       60 25.8
    ## Hawaii           5.3      46       83 20.2
    ## Idaho            2.6     120       54 14.2
    ## Illinois        10.4     249       83 24.0
    ## Indiana          7.2     113       65 21.0
    ## Iowa             2.2      56       57 11.3
    ## Kansas           6.0     115       66 18.0
    ## Kentucky         9.7     109       52 16.3
    ## Louisiana       15.4     249       66 22.2
    ## Maine            2.1      83       51  7.8
    ## Maryland        11.3     300       67 27.8
    ## Massachusetts    4.4     149       85 16.3
    ## Michigan        12.1     255       74 35.1
    ## Minnesota        2.7      72       66 14.9
    ## Mississippi     16.1     259       44 17.1
    ## Missouri         9.0     178       70 28.2

# 2 Viewing the *frequency distribution* for the **Assault** variable

Now, let’s visualize the *frequency distribution* for the Assault
variable. Remember, the *observed frequency distribution* is not the
same as the *probability distribution*.

``` r
ggplot(USArrests, aes(x = Assault)) +
  geom_histogram(bins = 30)
```

![](Appendix-1.-Normal-Probability-Distribution_files/figure-gfm/freq-1.png)<!-- -->

# 3 The **normal** *probability distribution*

The normal probability distribution is typically indicated with the
following expression:

``` math
 N(\mu , \sigma^{2}) 
```

Quite literally just saying that you are working with a normal
distribution with a given mean, $`\mu`$, and standard deviation,
$`\sigma`$.

We could visually generate this probability distribution using the
following probability density function:

``` math
 f(x) = \frac{1}{\sigma \sqrt{2 \pi}}e^{- \frac{1}{2}(\frac{x - \mu}{\sigma})^{2}} 
```

This can be used to generate a normal distribution that represents all
theoretically possible values of a given normally distributed continuous
variable (where your histogram is beholden to the observations that
*actually exist*). As ever, $`\mu`$ is the mean of your variable,
$`\sigma`$ is the standard deviation of your variable,

``` r
# Find the mean:
mu <- USArrests$Assault %>% mean(na.rm = TRUE)

# Find the standard deviation:
sigma <- USArrests$Assault %>% sd(na.rm = TRUE)

# Generate a sequence of all possible values for x:
min <- USArrests$Assault %>% min(na.rm = TRUE)
max <- USArrests$Assault %>% max(na.rm = TRUE)

x <- seq(min, max, by = 0.1)

# Insert these values into the normal probability density function:
head((1 / (sigma * sqrt(2 * pi))) * exp(1)^(-(x - mu)^2 / (2 * sigma^2)), 20)
```

    ##  [1] 0.001533132 0.001535910 0.001538690 0.001541473 0.001544259 0.001547048
    ##  [7] 0.001549840 0.001552634 0.001555431 0.001558231 0.001561034 0.001563840
    ## [13] 0.001566648 0.001569459 0.001572273 0.001575090 0.001577909 0.001580731
    ## [19] 0.001583556 0.001586384

``` r
head(dnorm(x, mu, sigma), 20)
```

    ##  [1] 0.001533132 0.001535910 0.001538690 0.001541473 0.001544259 0.001547048
    ##  [7] 0.001549840 0.001552634 0.001555431 0.001558231 0.001561034 0.001563840
    ## [13] 0.001566648 0.001569459 0.001572273 0.001575090 0.001577909 0.001580731
    ## [19] 0.001583556 0.001586384

[^1]: University of Mississippi, <tbsmit10@olemiss.edu>
