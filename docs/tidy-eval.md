---
title: Tidy evalation
---

<!-- Generated automatically from tidy-eval.yml. Do not edit by hand -->

# Tidy evalation <small class='program'>[program]</small>
<small>(Builds on: [Tidy evalation](tidy-eval.md))</small>  
<small>(Leads to: [Tidy evalation](tidy-eval.md))</small>


## Introduction

At some point during the quarter, you may have noticed that you were
copy-and-pasting the same dplyr snippets again and again. You then might
have remembered it’s a bad idea to have more than three copies of the
same code and tried to create a function. Unfortunately if you tried,
you would have failed because dplyr verbs work a little differently to
most other R functions. In this reading, you’ll learn exactly what makes
dplyr verbs different, and a new set of techniques so that you can
program with them. The techniques, in total, are known as tidy
evaluation, and are used throughout the tidyverse.

## Quoted arguments

To understand what makes dplyr (and many other tidyverse functions)
different, we need some new vocabulary. In R, we can divide function
arguments into two classes:

  - **Evaluated** arguments are the default. Code in an evaluated
    argument executes the same regardless of whether or not its in a
    function argument.

  - Automatically **quoted** arguments are special; they behave
    differently depending on whether or not they’re inside a function.

Let’s make this concrete by talking about two important base R functions
that you learned about early in the class: `$` and `[[`. We we use `$`
the variable name is automatically quoted: if we try and use the name
outside of `$` it doesn’t work:

``` r
df <- data.frame(
  y = 1,
  var = 2
)
df$y
#> [1] 1
```

Why do we say that `$` automatically quotes the variable name? Well,
take `[[`. It evaluates its argument so you have to put quotes around
it:

``` r
df[["y"]]
#> [1] 1
```

The advantage of `$` is concision. The advantage of `[[` is that you can
refer to variables in the data frame indirectly:

``` r
var <- "y"
df[[var]]
#> [1] 1
```

In base R, there’s no consistent way to “unquote” an automatically
quoted argument. In other words, there’s no way to allow `$` to work
indirectly:

``` r
df$var
#> [1] 2
```

The tidyverse, however, uses a consistent form of unquoting which gives
the concision of automatically quoted arguments, while still allowing us
to use indirection:

``` r
df %>% pull(y)
#> [1] 1

var <- quo(y)
df %>% pull(!!var)
#> [1] 1
```

There are two key components: `quo()` which quotes expressions in a
special way, and `!!` (pronounced bang-bang) that unquotes them.

## Wrapping quoting functions

Before we go on to discuss the underlying theory, I want to briefly show
you how you can combine your new found knowledge of quoting
vs. evaluating arguments to write a wrapper around some duplicated
dplyr code. Take this hypothetical duplicated dplyr code:

``` r
df %>% group_by(x1) %>% summarise(mean = mean(y1))
df %>% group_by(x2) %>% summarise(mean = mean(y2))
df %>% group_by(x3) %>% summarise(mean = mean(y3))
df %>% group_by(x4) %>% summarise(mean = mean(y4))
```

To create a function we need to perform three steps:

1.  Identify what is constant and what we might want to vary, and which
    varying parts have been automatically quoted.

2.  Create a function template.

3.  Quote and unquote the automatically quoted arguments.

Looking at the above code, I’d say there are three primary things that
we might want to vary:

  - The input data, which I’ll call `df`.
  - The grouping variable, which I’ll call `group_var`
  - The summary variable, which I’ll call `summary_var`

`group_var` and `summary_var` need to be automatically quoted: they
won’t work when evaluated outside of the dplyr code.

Now we can create the function template using these names for our
arguments. I then copied in the duplicated code, and replace the varying
parts with the new variable names:

``` r
grouped_mean <- function(df, group_var, summary_var) {
  df %>% 
    group_by(group_var) %>% 
    summarise(mean = mean(summary_var))
}
```

This function doesn’t work (yet), but it’s useful to see the error
message we get:

``` r
grouped_mean(mtcars, cyl, mpg)
#> Error in grouped_df_impl(data, unname(vars), drop): Column `group_var` is unknown
```

The error complains that there’s no column called `group_var` - that’s
not a surprise, because we don’t want to use the variable `group_var`
directly; we want to use it indirectly to refer to `cyl`. To fix this
problem we need to perform the final step: quoting and unquoting. You
can think of quoting as being infectious: if you want your function to
vary an automated quoted argument, you also need to quote the
corresponding argument. Then to refer to the variable indirectly, you
need to unquote it.

``` r
grouped_mean <- function(df, group_var, summary_var) {
  group_var <- enquo(group_var)
  summary_var <- enquo(summary_var)
  
  df %>% 
    group_by(!!group_var) %>% 
    summarise(mean = mean(!!summary_var))
}
```

If you have eagle eyes, you’ll have spotted that I used `enquo()` here
but I showed you `quo()` before. That’s because they have slightly
different uses: `quo()` captures what you, the function writer type,
`enquo()` captures what the user has typed:

``` r
fun1 <- function(x) quo(x)
fun1(a + b)
#> <quosure>
#>   expr: ^x
#>   env:  0x7f9cf2a4f0a8

fun2 <- function(x) enquo(x)
fun2(a + b)
#> <quosure>
#>   expr: ^a + b
#>   env:  0x7f9ceaefca78
```

## Theory

To finish off, watch this video to quickly get an idea for the theory
that underlies tidy
eval.

<iframe width="560" height="315" src="https://www.youtube.com/embed/nERXS3ssntw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen>

</iframe>

