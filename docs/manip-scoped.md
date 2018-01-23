---
title: Scoped verbs
---

<!-- Generated automatically from manip-scoped.yml. Do not edit by hand -->

# Scoped verbs <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Iteration](iteration.md), [Manipulation basics](manip-basics.md))</small>  
<small>(Leads to: [Programming with dplyr](manip-programming.md))</small>


## Scoped verbs

In the latest version of dplyr each of the single table verbs comes in
three additional forms with the suffixes `_if`, `_at`, and `_all`. These
**scoped** variants allow you to affect multiple variables at once:

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
#> 1 0.500 0.492 0.500
summarise_all(df, funs(min, max))
#> # A tibble: 1 x 6
#>    x_min   y_min    z_min x_max y_max z_max
#>    <dbl>   <dbl>    <dbl> <dbl> <dbl> <dbl>
#> 1 0.0105 0.00958 0.000404 0.999 0.990 0.999
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
#> 1 0.500 0.492
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
#> 1 0.500
summarise_at(df, vars(x),    funs(min, max))
#> # A tibble: 1 x 2
#>      min   max
#>    <dbl> <dbl>
#> 1 0.0105 0.999
summarise_at(df, vars(x, y), funs(mean))
#> # A tibble: 1 x 2
#>       x     y
#>   <dbl> <dbl>
#> 1 0.500 0.492
summarise_at(df, vars(x, y), funs(min, max))
#> # A tibble: 1 x 4
#>    x_min   y_min x_max y_max
#>    <dbl>   <dbl> <dbl> <dbl>
#> 1 0.0105 0.00958 0.999 0.990
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
#>        x      y       z
#>    <dbl>  <dbl>   <dbl>
#> 1 -0.211 -0.119 -0.577 
#> 2 -1.92  -1.32  -0.0797
#> 3 -0.470 -0.344 -0.0921
#> 4 -1.20  -0.386 -0.213 
#> 5 -0.426 -0.478 -0.266 
#> # ... with 95 more rows
```

If you need a transformation that is not already a function, it’s
easiest to create your own function:

``` r
double <- function(x) x * 2
half <- function(x) x / 2

mutate_all(df, funs(half, double))
#> # A tibble: 100 x 9
#>        x      y     z  x_half y_half z_half x_double y_double z_double
#>    <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1 0.615  0.760  0.265 0.308   0.380   0.132   1.23     1.52      0.530
#> 2 0.0119 0.0483 0.832 0.00597 0.0242  0.416   0.0239   0.0967    1.66 
#> 3 0.339  0.453  0.809 0.169   0.227   0.404   0.677    0.907     1.62 
#> 4 0.0638 0.411  0.613 0.0319  0.206   0.306   0.128    0.822     1.23 
#> 5 0.375  0.333  0.542 0.187   0.166   0.271   0.750    0.665     1.08 
#> # ... with 95 more rows
```

The default names are generated in the same way as `summarise()`. That
means that you may want to use a `transmute()` variant if you want to
apply multiple transformations and don’t want the original values:

``` r
transmute_all(df, funs(half, double))
#> # A tibble: 100 x 6
#>    x_half y_half z_half x_double y_double z_double
#>     <dbl>  <dbl>  <dbl>    <dbl>    <dbl>    <dbl>
#> 1 0.308   0.380   0.132   1.23     1.52      0.530
#> 2 0.00597 0.0242  0.416   0.0239   0.0967    1.66 
#> 3 0.169   0.227   0.404   0.677    0.907     1.62 
#> 4 0.0319  0.206   0.306   0.128    0.822     1.23 
#> 5 0.187   0.166   0.271   0.750    0.665     1.08 
#> # ... with 95 more rows
```

