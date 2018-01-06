---
title: Scoped verbs
---

<!-- Generated automatically from manip-scoped.yml. Do not edit by hand -->

# Scoped verbs <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Iteration](iteration.md), [Manipulation basics](manip-basics.md))</small>  
<small>(Leads to: [Programming with dplyr](manip-programming.md))</small>


## dplyr 0.6.0

First, make sure you have the latest version of dplyr, 0.6.0. You can
check what version you currently have with `packageVersion()`:

``` r
packageVersion("dplyr")
#> [1] '0.7.4'
```

(If you’re using the development version, version 0.5.0.9005 is also
ok.)

If you’re version is older, use `install.packages()` to update it.

## Scoped verbs

In the latest version of dplyr each of the single table verbs comes in
three additional forms with the suffixes `_if`, `_at`, and `_all`. These
**scoped** variants allow you to affect multiple variables at once:

  - `_if` allows you to pick variables based on a predicate function
    like `is.numeric()` or `is.character()`.

  - `_at` allows you to pick variables using the same syntax as
    `select()`.

  - `_all` operates on all variables.

I’ll illustrate the three variants in detail for `summarise()`, then
explore in less detail how you can use similar techniques with
`mutate()` and `filter()`. You’ll need the scoped variants of the other
verbs less frequently, but when you do, it should be straightforward to
generalise what you’ve learn here.

## Summarise

### `summarise_all()`

The simplest variant to understand is `summarise_all()`. It takes a
tibble and a function and applies that function to each column:

``` r
df <- tibble(
  x = runif(100),
  y = runif(100),
  z = runif(100)
)
summarise_all(df, mean)
#> # A tibble: 1 x 3
#>       x     y     z
#>   <dbl> <dbl> <dbl>
#> 1 0.451 0.503 0.485
```

If you want to apply multiple summaries, use the `funs()` helper:

``` r
summarise_all(df, funs(min, max))
#> # A tibble: 1 x 6
#>     x_min   y_min   z_min x_max y_max z_max
#>     <dbl>   <dbl>   <dbl> <dbl> <dbl> <dbl>
#> 1 0.00515 0.00685 0.00801 0.998 0.952 0.986
```

There are two slightly inconsistent ways to use an inline function (this
inconistency will get ironed out in a future version).

``` r
# For a single function, use ~ 
summarise_all(df, ~ sd(.) / mean(.))
#> # A tibble: 1 x 3
#>       x     y     z
#>   <dbl> <dbl> <dbl>
#> 1 0.632 0.567 0.588

# For multiple functions, use funs(), dropping the ~
# Typically you'll want to name the function so you get reasonable
# variable names.
summarise_all(df, funs(cv = sd(.) / mean(.), mean))
#> # A tibble: 1 x 6
#>    x_cv  y_cv  z_cv x_mean y_mean z_mean
#>   <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>
#> 1 0.632 0.567 0.588  0.451  0.503  0.485
```

### `summarise_at()`

`summarise_at()` allows you to pick columns in the same way as
`select()`, that is, based on their names. There is one small
difference: you need to wrap the complete selection with the `vars()`
helper (this avoids ambiguity).

``` r
summarise_at(df, vars(-z), mean)
#> # A tibble: 1 x 2
#>       x     y
#>   <dbl> <dbl>
#> 1 0.451 0.503
```

By default, the newly created columns have the shortest names needed to
uniquely identify the output.

``` r
summarise_at(df, vars(x), funs(min, max))
#> # A tibble: 1 x 2
#>       min   max
#>     <dbl> <dbl>
#> 1 0.00515 0.998
summarise_at(df, vars(x, y), min)
#> # A tibble: 1 x 2
#>         x       y
#>     <dbl>   <dbl>
#> 1 0.00515 0.00685
summarise_at(df, vars(-z), funs(min, max))
#> # A tibble: 1 x 4
#>     x_min   y_min x_max y_max
#>     <dbl>   <dbl> <dbl> <dbl>
#> 1 0.00515 0.00685 0.998 0.952
```

See the examples in the documentation if you want to force names when
they’re not otherwise needed.

### `summarise_if()`

`summarise_at()` allows you to pick variables to summarise based on
their name. `summarise_if()` allows you to pick variables to summarise
based on some property of the column. Typically this is their type
because you want to (e.g.) apply a numeric summary function only to
numeric columns:

``` r
starwars %>%
  group_by(species) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE)
#> # A tibble: 38 x 4
#>   species  height  mass birth_year
#>   <chr>     <dbl> <dbl>      <dbl>
#> 1 Aleena     79.0  15.0      NaN  
#> 2 Besalisk  198   102        NaN  
#> 3 Cerean    198    82.0       92.0
#> 4 Chagrian  196   NaN        NaN  
#> 5 Clawdite  168    55.0      NaN  
#> # ... with 33 more rows
```

(Note that `na.rm = TRUE` is passed on to `mean()` in the same way as in
`purrr::map()`.)

## Mutate

`mutate_all()`, `mutate_if()` and `mutate_at()` work in a similar way to
their summarise equivalents.

``` r
mutate_all(df, log10)
#> # A tibble: 100 x 3
#>         x       y       z
#>     <dbl>   <dbl>   <dbl>
#> 1 -0.0826 -0.0477 -0.212 
#> 2 -1.16   -1.73   -0.145 
#> 3 -0.869  -0.301  -0.495 
#> 4 -0.494  -0.475  -0.444 
#> 5 -0.0567 -0.123  -0.0624
#> # ... with 95 more rows
```

Often you’ll want to use an inline expression. As above, either use `~`
for a single function or `funs()` for multiple functions:

``` r
mutate_all(df, ~ round(. * 25))
#> # A tibble: 100 x 3
#>       x     y     z
#>   <dbl> <dbl> <dbl>
#> 1 21.0  22.0  15.0 
#> 2  2.00  0    18.0 
#> 3  3.00 13.0   8.00
#> 4  8.00  8.00  9.00
#> 5 22.0  19.0  22.0 
#> # ... with 95 more rows
mutate_all(df, funs(half = . / 2, double = . * 2))
#> # A tibble: 100 x 9
#>        x      y     z x_half  y_half z_half x_double y_double z_double
#>    <dbl>  <dbl> <dbl>  <dbl>   <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1 0.827  0.896  0.614 0.413  0.448    0.307    1.65    1.79      1.23 
#> 2 0.0684 0.0184 0.715 0.0342 0.00921  0.358    0.137   0.0369    1.43 
#> 3 0.135  0.500  0.320 0.0676 0.250    0.160    0.270   1.00      0.639
#> 4 0.320  0.335  0.360 0.160  0.168    0.180    0.641   0.671     0.720
#> 5 0.878  0.753  0.866 0.439  0.376    0.433    1.76    1.51      1.73 
#> # ... with 95 more rows
```

The default names are generated in the same way as `summarise()`. That
means that you may want to use a `transmute()` variant if you want to
apply multiple transformations and don’t want the original values:

``` r
transmute_all(df, funs(half = . / 2, double = . * 2))
#> # A tibble: 100 x 6
#>   x_half  y_half z_half x_double y_double z_double
#>    <dbl>   <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1 0.413  0.448    0.307    1.65    1.79      1.23 
#> 2 0.0342 0.00921  0.358    0.137   0.0369    1.43 
#> 3 0.0676 0.250    0.160    0.270   1.00      0.639
#> 4 0.160  0.168    0.180    0.641   0.671     0.720
#> 5 0.439  0.376    0.433    1.76    1.51      1.73 
#> # ... with 95 more rows
```

## Filter

`filter_all()` is the most useful of the three `filter()` variants. You
use it conjunction with `all_vars()` or `any_vars()` depending on
whether or not you want rows where all variables meet the criterion, or
where just one variable meets it.

It’s particularly useful finding missing values:

``` r
library(nycflights13)

# Rows where any value is missing
filter_all(weather, any_vars(is.na(.)))
#> # A tibble: 3,109 x 15
#>   origin  year month   day  hour  temp  dewp humid wind… wind… wind… prec…
#>   <chr>  <dbl> <dbl> <int> <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 EWR     2013  1.00     1    17  39.2  28.4  64.9   270 16.1  18.5      0
#> 2 EWR     2013  1.00     1    18  39.2  28.4  64.9   330 15.0  17.2      0
#> 3 EWR     2013  1.00     3    16  30.9  14.0  49.0    NA  4.60  5.30     0
#> 4 EWR     2013  1.00     6    10  33.8  30.2  86.5   210  4.60  5.30     0
#> 5 EWR     2013  1.00     6    12  33.8  32.0  93.0   220  9.21 10.6      0
#> # ... with 3,104 more rows, and 3 more variables: pressure <dbl>, visib
#> #   <dbl>, time_hour <dttm>

# Rows where all wind variables are missing
filter_at(weather, vars(starts_with("wind")), all_vars(is.na(.)))
#> # A tibble: 3 x 15
#>   origin  year month   day  hour  temp  dewp humid wind… wind… wind… prec…
#>   <chr>  <dbl> <dbl> <int> <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 EWR     2013  3.00    27    21  52.0  19.0  27.0    NA    NA    NA     0
#> 2 JFK     2013  7.00     4    10  73.0  71.1  93.5    NA    NA    NA     0
#> 3 JFK     2013  7.00    20    10  81.0  71.1  71.9    NA    NA    NA     0
#> # ... with 3 more variables: pressure <dbl>, visib <dbl>, time_hour <dttm>
```

