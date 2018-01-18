---
title: Vector and summary functions
---

<!-- Generated automatically from vector-summary-functions.yml. Do not edit by hand -->

# Vector and summary functions <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Manipulation basics](manip-basics.md), [Missing values](missing-values.md))</small>


``` r
library(tidyverse)
#> ── Attaching packages ─────────────────────── tidyverse 1.2.0.9000 ──
#> ✔ ggplot2 2.2.1.9000     ✔ purrr   0.2.4     
#> ✔ tibble  1.4.1          ✔ dplyr   0.7.4     
#> ✔ tidyr   0.7.2.9000     ✔ stringr 1.2.0     
#> ✔ readr   1.1.1          ✔ forcats 0.2.0
#> ── Conflicts ─────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(nycflights13)
```

`mutate()` and `summarise()` operate on data frames. You use them with
vector and summary functions which work with individual variables (or
vectors).

## Vector functions

A vector function takes one (or sometimes more) vectors as input and
returns a vector of the same length as output. These are typically used
with `mutate()` to create new variables.

I can’t list every vector function, but here’s a few that are often
useful:

  - Arithmetic operators: `+`, `-`, `*`, `/`, `^`. These are all
    vectorised, using the so called “recycling rules”. If one parameter
    is shorter than the other, it will be automatically extended to be
    the same length. This is most useful when one of the arguments is a
    single number: `air_time / 60`, `hours * 60 + minute`, etc.
    
    Arithmetic operators are also useful in conjunction with the
    aggregate functions you’ll learn about later. For example, `x /
    sum(x)` calculates the proportion of a total, and `y - mean(y)`
    computes the difference from the mean.

  - Modular arithmetic: `%/%` (integer division) and `%%` (remainder),
    where `x == y * (x %/% y) + (x %% y)`. Modular arithmetic is a handy
    tool because it allows you to break integers up into pieces. For
    example, in the flights dataset, you can compute `hour` and `minute`
    from `dep_time` with:
    
    ``` r
    flights %>% 
      transmute(
        dep_time,
        hour = dep_time %/% 100,
        minute = dep_time %% 100
      )
    #> # A tibble: 336,776 x 3
    #>    dep_time  hour minute
    #>       <int> <dbl>  <dbl>
    #>  1      517  5.00   17.0
    #>  2      533  5.00   33.0
    #>  3      542  5.00   42.0
    #>  4      544  5.00   44.0
    #>  5      554  5.00   54.0
    #>  6      554  5.00   54.0
    #>  7      555  5.00   55.0
    #>  8      557  5.00   57.0
    #>  9      557  5.00   57.0
    #> 10      558  5.00   58.0
    #> # ... with 336,766 more rows
    ```

  - Logs: `log()`, `log2()`, `log10()`. Logarithms are an incredibly
    useful transformation for dealing with data that ranges across
    multiple orders of magnitude. They also convert multiplicative
    relationships to additive, a feature we’ll come back to in
    modelling.
    
    All else being equal, I recommend using `log2()` because it’s easy
    to interpret: a difference of 1 on the log scale corresponds to
    doubling on the original scale and a difference of -1 corresponds to
    halving.

  - Logical comparisons, `<`, `<=`, `>`, `>=`, `!=`, which you learned
    about earlier. If you’re doing a complex sequence of logical
    operations it’s often a good idea to store the interim values in new
    variables so you can check that each step is working as expected.

  - `if_else()` allows you perform a conditional calculation. The first
    argument should be a logical statement; the second argument is the
    value to use if the first argument is true; the third argumetn is
    the value to use if the first argumetn is false.
    
    ``` r
    flights %>% 
      transmute(
        on_time = if_else(arr_delay < 0, "early", "late")
      )
    #> # A tibble: 336,776 x 1
    #>    on_time
    #>    <chr>  
    #>  1 late   
    #>  2 late   
    #>  3 late   
    #>  4 early  
    #>  5 early  
    #>  6 late   
    #>  7 late   
    #>  8 early  
    #>  9 early  
    #> 10 late   
    #> # ... with 336,766 more rows
    ```

  - `case_when()` allows you to combine multiple logical conditions,
    evaluated in turn. Each condition goes on the left hand side of the
    `~`, and the result goes on the right hand side.
    
    ``` r
    flights %>% 
      transmute(
        on_time = case_when(
          abs(arr_delay) < 10 ~ "on time",
          arr_delay < 0 ~ "early",
          arr_delay > 0 ~ "late",
          is.na(arr_delay) ~ "cancelled"
        )
      )
    #> # A tibble: 336,776 x 1
    #>    on_time
    #>    <chr>  
    #>  1 late   
    #>  2 late   
    #>  3 late   
    #>  4 early  
    #>  5 early  
    #>  6 late   
    #>  7 late   
    #>  8 early  
    #>  9 on time
    #> 10 on time
    #> # ... with 336,766 more rows
    ```

## Summary functoins

A summary function takes a vector of inputs and returns a single output.
They are most commonly used with `summarise()`.

Just using means, counts, and sum can get you a long way, but R provides
many other useful summary functions:

  - Measures of location: we’ve used `mean(x)`, but `median(x)` is also
    useful. The mean is the sum divided by the length; the median is a
    value where 50% of `x` is above it, and 50% is below it.
    
    It’s sometimes useful to combine aggregation with logical
    subsetting. We haven’t talked about this sort of subsetting yet, but
    you’ll learn more about it later.
    
    ``` r
    flights %>% 
      group_by(year, month, day) %>% 
      summarise(
        avg_delay1 = mean(arr_delay),
        avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
      )
    #> # A tibble: 365 x 5
    #> # Groups: year, month [?]
    #>     year month   day avg_delay1 avg_delay2
    #>    <int> <int> <int>      <dbl>      <dbl>
    #>  1  2013     1     1         NA         NA
    #>  2  2013     1     2         NA         NA
    #>  3  2013     1     3         NA         NA
    #>  4  2013     1     4         NA         NA
    #>  5  2013     1     5         NA         NA
    #>  6  2013     1     6         NA         NA
    #>  7  2013     1     7         NA         NA
    #>  8  2013     1     8         NA         NA
    #>  9  2013     1     9         NA         NA
    #> 10  2013     1    10         NA         NA
    #> # ... with 355 more rows
    ```

  - Measures of spread: `sd(x)`, `IQR(x)`, `mad(x)`. The mean squared
    deviation, or standard deviation or sd for short, is the standard
    measure of spread. The interquartile range `IQR()` and median
    absolute deviation `mad(x)` are robust equivalents that may be more
    useful if you have outliers.
    
    ``` r
    # Why is distance to some destinations more variable than to others?
    flights %>% 
      group_by(dest) %>% 
      summarise(distance_sd = sd(distance)) %>% 
      arrange(desc(distance_sd))
    #> # A tibble: 105 x 2
    #>    dest  distance_sd
    #>    <chr>       <dbl>
    #>  1 EGE         10.5 
    #>  2 SAN         10.3 
    #>  3 SFO         10.2 
    #>  4 HNL         10.0 
    #>  5 SEA          9.98
    #>  6 LAS          9.91
    #>  7 PDX          9.88
    #>  8 PHX          9.86
    #>  9 LAX          9.66
    #> 10 IND          9.46
    #> # ... with 95 more rows
    ```

  - Measures of rank: `min(x)`, `quantile(x, 0.25)`, `max(x)`. Quantiles
    are a generalisation of the median. For example, `quantile(x, 0.25)`
    will find a value of `x` that is greater than 25% of the values, and
    less than the remaining 75%.
    
    ``` r
    # When do the first and last flights leave each day?
    flights %>% 
      group_by(year, month, day) %>% 
      summarise(
        first = min(dep_time),
        last = max(dep_time)
      )
    #> # A tibble: 365 x 5
    #> # Groups: year, month [?]
    #>     year month   day first  last
    #>    <int> <int> <int> <dbl> <dbl>
    #>  1  2013     1     1    NA    NA
    #>  2  2013     1     2    NA    NA
    #>  3  2013     1     3    NA    NA
    #>  4  2013     1     4    NA    NA
    #>  5  2013     1     5    NA    NA
    #>  6  2013     1     6    NA    NA
    #>  7  2013     1     7    NA    NA
    #>  8  2013     1     8    NA    NA
    #>  9  2013     1     9    NA    NA
    #> 10  2013     1    10    NA    NA
    #> # ... with 355 more rows
    ```

  - Measures of position: `first(x)`, `nth(x, 2)`, `last(x)`. These work
    similarly to `x[1]`, `x[2]`, and `x[length(x)]` but let you set a
    default value if that position does not exist (i.e. you’re trying to
    get the 3rd element from a group that only has two elements). For
    example, we can find the first and last departure for each day:
    
    ``` r
    flights %>% 
      group_by(year, month, day) %>% 
      summarise(
        first_dep = first(dep_time), 
        last_dep = last(dep_time)
      )
    #> # A tibble: 365 x 5
    #> # Groups: year, month [?]
    #>     year month   day first_dep last_dep
    #>    <int> <int> <int>     <int>    <int>
    #>  1  2013     1     1       517       NA
    #>  2  2013     1     2        42       NA
    #>  3  2013     1     3        32       NA
    #>  4  2013     1     4        25       NA
    #>  5  2013     1     5        14       NA
    #>  6  2013     1     6        16       NA
    #>  7  2013     1     7        49       NA
    #>  8  2013     1     8       454       NA
    #>  9  2013     1     9         2       NA
    #> 10  2013     1    10         3       NA
    #> # ... with 355 more rows
    ```
    
    These functions are complementary to filtering on ranks. Filtering
    gives you all variables, with each observation in a separate row:
    
    ``` r
    flights %>% 
      group_by(year, month, day) %>% 
      mutate(r = min_rank(desc(dep_time))) %>% 
      filter(r %in% range(r))
    #> # A tibble: 8,269 x 20
    #> # Groups: year, month, day [365]
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     1     1       NA           1630        NA       NA
    #>  2  2013     1     1       NA           1935        NA       NA
    #>  3  2013     1     1       NA           1500        NA       NA
    #>  4  2013     1     1       NA            600        NA       NA
    #>  5  2013     1     2       NA           1540        NA       NA
    #>  6  2013     1     2       NA           1620        NA       NA
    #>  7  2013     1     2       NA           1355        NA       NA
    #>  8  2013     1     2       NA           1420        NA       NA
    #>  9  2013     1     2       NA           1321        NA       NA
    #> 10  2013     1     2       NA           1545        NA       NA
    #> # ... with 8,259 more rows, and 13 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>, origin
    #> #   <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute
    #> #   <dbl>, time_hour <dttm>, r <int>
    ```

  - Counts: You’ve seen `n()`, which takes no arguments, and returns the
    size of the current group. To count the number of non-missing
    values, use `sum(!is.na(x))`. To count the number of distinct
    (unique) values, use `n_distinct(x)`.
    
    ``` r
    # Which destinations have the most carriers?
    flights %>% 
      group_by(dest) %>% 
      summarise(carriers = n_distinct(carrier)) %>% 
      arrange(desc(carriers))
    #> # A tibble: 105 x 2
    #>    dest  carriers
    #>    <chr>    <int>
    #>  1 ATL          7
    #>  2 BOS          7
    #>  3 CLT          7
    #>  4 ORD          7
    #>  5 TPA          7
    #>  6 AUS          6
    #>  7 DCA          6
    #>  8 DTW          6
    #>  9 IAD          6
    #> 10 MSP          6
    #> # ... with 95 more rows
    ```

  - Counts and proportions of logical values: `sum(x > 10)`, `mean(y
    == 0)`. When used with numeric functions, `TRUE` is converted to 1
    and `FALSE` to 0. This makes `sum()` and `mean()` very useful:
    `sum(x)` gives the number of `TRUE`s in `x`, and `mean(x)` gives the
    proportion.
    
    ``` r
    # How many flights left before 5am? (these usually indicate delayed
    # flights from the previous day)
    flights %>% 
      group_by(year, month, day) %>% 
      summarise(n_early = sum(dep_time < 500))
    #> # A tibble: 365 x 4
    #> # Groups: year, month [?]
    #>     year month   day n_early
    #>    <int> <int> <int>   <int>
    #>  1  2013     1     1      NA
    #>  2  2013     1     2      NA
    #>  3  2013     1     3      NA
    #>  4  2013     1     4      NA
    #>  5  2013     1     5      NA
    #>  6  2013     1     6      NA
    #>  7  2013     1     7      NA
    #>  8  2013     1     8      NA
    #>  9  2013     1     9      NA
    #> 10  2013     1    10      NA
    #> # ... with 355 more rows
    
    # What proportion of flights are delayed by more than an hour?
    flights %>% 
      group_by(year, month, day) %>% 
      summarise(hour_perc = mean(arr_delay > 60))
    #> # A tibble: 365 x 4
    #> # Groups: year, month [?]
    #>     year month   day hour_perc
    #>    <int> <int> <int>     <dbl>
    #>  1  2013     1     1        NA
    #>  2  2013     1     2        NA
    #>  3  2013     1     3        NA
    #>  4  2013     1     4        NA
    #>  5  2013     1     5        NA
    #>  6  2013     1     6        NA
    #>  7  2013     1     7        NA
    #>  8  2013     1     8        NA
    #>  9  2013     1     9        NA
    #> 10  2013     1    10        NA
    #> # ... with 355 more rows
    ```

