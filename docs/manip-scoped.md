---
title: Scoped verbs
---

<!-- Generated automatically from manip-scoped.yml. Do not edit by hand -->

# Scoped verbs <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Manipulation basics](manip-basics.md))</small>  
<small>(Leads to: [Programming with dplyr](manip-programming.md))</small>


## Introduction

Each of the single table verbs comes in three additional forms with the
suffixes `_if`, `_at`, and `_all`. These **scoped** variants allow you
to work with multiple variables with a single call:

  - `_if` allows you to pick variables based on a predicate function
    like `is.numeric()` or `is.character()`.

  - `_at` allows you to pick variables using the same syntax as
    `select()`.

  - `_all` operates on all variables.

These variants are coupled with `funs()` and `vars()` helpers that let
you describe which functions you want to apply to which variables.

I’ll illustrate the three variants in detail for `summarise()`, then
show how you can use the same ideas with `mutate()` and `filter()`.
You’ll need the scoped variants of the other verbs less frequently,
but when you do, it should be straightforward to generalise what you’ve
learn here.

## Summarise

### `summarise_all()`

The simplest variant to understand is `summarise_all()`. The first
argument is a tibble. The second argument is one of more functions
wrapped inside of the `funs()` helper:

``` r
df <- tibble(
  x = runif(100),
  y = runif(100),
  z = runif(100)
)
summarise_all(df, funs(mean))
#> # A tibble: 1 x 3
#>       x     y     z
#>   <dbl> <dbl> <dbl>
#> 1 0.485 0.515 0.539
summarise_all(df, funs(min, max))
#> # A tibble: 1 x 6
#>    x_min   y_min   z_min x_max y_max z_max
#>    <dbl>   <dbl>   <dbl> <dbl> <dbl> <dbl>
#> 1 0.0105 0.00337 0.00222 0.996 0.992 0.997
```

You might wonder why we need `funs()`. You don’t actually need it if you
have a single function, but it’s necessary for technical reasons for
more than one function, and always using it makes your code more
consistent.

### `summarise_at()`

`summarise_at()` allows you to pick columns to summarise in the same way
as `select()`. There is one small difference: you need to wrap the
complete selection with the `vars()` helper:

``` r
summarise_at(df, vars(-z), funs(mean))
#> # A tibble: 1 x 2
#>       x     y
#>   <dbl> <dbl>
#> 1 0.485 0.515
```

You can put anything inside `vars()` that you can put inside a call to
`select()`:

``` r
library(nycflights13)
summarise_at(flights, vars(contains("delay")), funs(mean), na.rm = TRUE)
#> # A tibble: 1 x 2
#>   dep_delay arr_delay
#>       <dbl>     <dbl>
#> 1      12.6      6.90
summarise_at(flights, vars(starts_with("arr")), funs(mean), na.rm = TRUE)
#> # A tibble: 1 x 2
#>   arr_time arr_delay
#>      <dbl>     <dbl>
#> 1     1502      6.90
```

(Note that `na.rm = TRUE` is passed on to `mean()` in the same way as in
`purrr::map()`.)

If the function doesn’t fit on one line, put each argument on a new
line:

``` r
flights %>%
  group_by(dest) %>% 
  summarise_at(
    vars(contains("delay"), distance, air_time), 
    funs(mean), 
    na.rm = TRUE
  )
#> # A tibble: 105 x 5
#>   dest  dep_delay arr_delay distance air_time
#>   <chr>     <dbl>     <dbl>    <dbl>    <dbl>
#> 1 ABQ       13.7       4.38     1826    249  
#> 2 ACK        6.46      4.85      199     42.1
#> 3 ALB       23.6      14.4       143     31.8
#> 4 ANC       12.9     - 2.50     3370    413  
#> 5 ATL       12.5      11.3       757    113  
#> # ... with 100 more rows
```

By default, the newly created columns have the shortest names needed to
uniquely identify the output. See the examples in the documentation if
you want to force names when they’re not otherwise needed.

``` r
# Note the use of extra spaces to make the 3rd argument line
# up - this makes it easy to scan the scoe and see what's different
summarise_at(df, vars(x),    funs(mean))
#> # A tibble: 1 x 1
#>       x
#>   <dbl>
#> 1 0.485
summarise_at(df, vars(x),    funs(min, max))
#> # A tibble: 1 x 2
#>      min   max
#>    <dbl> <dbl>
#> 1 0.0105 0.996
summarise_at(df, vars(x, y), funs(mean))
#> # A tibble: 1 x 2
#>       x     y
#>   <dbl> <dbl>
#> 1 0.485 0.515
summarise_at(df, vars(x, y), funs(min, max))
#> # A tibble: 1 x 4
#>    x_min   y_min x_max y_max
#>    <dbl>   <dbl> <dbl> <dbl>
#> 1 0.0105 0.00337 0.996 0.992
```

### `summarise_if()`

`summarise_if()` allows you to pick variables to summarise based on some
property of the column, specified by a **predicate** function. A
predicate function is a function that takes a whole column and returns
either a single `TRUE` or a single `FALSE`. Commonly this a function
that tells you if a variable is a specific type like `is.numeric()`,
`is.character()`, or `is.logical()`.

This makes it easier to summarise only numeric columns:

``` r
starwars %>%
  group_by(species) %>%
  summarise_if(is.numeric, funs(mean), na.rm = TRUE)
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

## Mutate

`mutate_all()`, `mutate_if()` and `mutate_at()` work in a similar way to
their summarise equivalents.

``` r
mutate_all(df, funs(log10))
#> # A tibble: 100 x 3
#>          x       y       z
#>      <dbl>   <dbl>   <dbl>
#> 1 -0.00575 -2.21   -0.0611
#> 2 -0.736   -0.105  -0.101 
#> 3 -0.434   -0.0502 -0.104 
#> 4 -0.266   -0.242  -0.619 
#> 5 -0.821   -0.490  -0.0652
#> # ... with 95 more rows
```

If you need a transformation that is not already a function, it’s
easiest to create your own function:

``` r
double <- function(x) x * 2
half <- function(x) x / 2

mutate_all(df, funs(half, double))
#> # A tibble: 100 x 9
#>       x       y     z x_half  y_half z_half x_double y_double z_double
#>   <dbl>   <dbl> <dbl>  <dbl>   <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1 0.987 0.00623 0.869 0.493  0.00311  0.434    1.97    0.0125    1.74 
#> 2 0.184 0.786   0.793 0.0918 0.393    0.396    0.367   1.57      1.59 
#> 3 0.368 0.891   0.787 0.184  0.445    0.394    0.737   1.78      1.57 
#> 4 0.542 0.573   0.240 0.271  0.286    0.120    1.08    1.15      0.481
#> 5 0.151 0.323   0.861 0.0754 0.162    0.430    0.302   0.647     1.72 
#> # ... with 95 more rows
```

The default names are generated in the same way as `summarise()`. That
means that you may want to use a `transmute()` variant if you want to
apply multiple transformations and don’t want the original values:

``` r
transmute_all(df, funs(half, double))
#> # A tibble: 100 x 6
#>   x_half  y_half z_half x_double y_double z_double
#>    <dbl>   <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1 0.493  0.00311  0.434    1.97    0.0125    1.74 
#> 2 0.0918 0.393    0.396    0.367   1.57      1.59 
#> 3 0.184  0.445    0.394    0.737   1.78      1.57 
#> 4 0.271  0.286    0.120    1.08    1.15      0.481
#> 5 0.0754 0.162    0.430    0.302   0.647     1.72 
#> # ... with 95 more rows
```

