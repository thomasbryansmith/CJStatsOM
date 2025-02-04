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
  geom_histogram()
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](Appendix-1.-Normal-Probability-Distribution_files/figure-gfm/freq-1.png)<!-- -->

# 3 The **normal** *probability distribution*

The normal probability distribution is typically denoted with the
following expression:

``` math
 N(\mu , \sigma^{2}) 
```

Quite literally denoting a normal distribution with a with a given mean,
$`\mu`$, and standard deviation, $`\sigma`$.

``` math
 f(x) = \frac{1}{\sigma \sqrt{2 \pi}}e^{\frac{1}{2}(\frac{x - \mu}{\sigma})^{2}} 
```

[^1]: University of Mississippi, <tbsmit10@olemiss.edu>
