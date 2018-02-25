---
title: Vector functions
---

<!-- Generated automatically from vector-functions.yml. Do not edit by hand -->

# Vector functions <small class='wrangle'>[wrangle]</small>
<small>(Builds on: [Manipulation basics](manip-basics.md))</small>


<<<<<<< HEAD
Vector functions
----------------

It's often easy to create a **scalar function**, that is a function, that takes length one input and produces a length one output. You can always turn this into a vectored function by figuring out the appropriate purrr `map_` function. It's also easy to accidentally use a vectored function as if it's a scalar function; doing so makes life harder for yourself than it needs to be. This reading illustrates each problem with an example.

Letter grades
-------------
||||||| merged common ancestors
## Vector functions

It’s often easy to create a scalar function, that is a function, that
takes length 1 input, and produces a length one output. You can always
turn this into a vectorised function by figuring out the appropriate
purrr `map_` function. It’s also easy to accidentally use a vectorised
function as if it’s a scalar function, doing making life harder for
yourself than it needs to be. This reading illustrates each problem with
an example.

## Letter grades
=======
## Letter grades
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1

<<<<<<< HEAD
For example, you might write the following function that converts a numeric grade to a letter grade:
||||||| merged common ancestors
For example, might write the following function that converts a numeric
grade to a letter grade:
=======
It’s easy to inadvertently create a **scalar function**, i.e. a function
that takes length 1 input and produces length 1. You can always apply a
scalar function to a vector of values by using the appropriate purrr
`map_` function, but you can often find a more efficient approach by
relying on an existing vectorised function.

A common way to create a scalar function is by using a if-else
statement. For example, might write the following function that converts
a numeric grade to a letter grade:
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1

``` r
grade_1 <- function(x) {
  if (x >= 90) {
    "A"
  } else if (x >= 80) {
    "B"
  } else if (x >= 70) {
    "C"
  } else if (x >= 60) {
    "D"
  } else {
    "F"
  }
}
```

<<<<<<< HEAD
grade_1(92)
||||||| merged common ancestors
grade(92)
=======
This works well when applied to single values:

``` r
grade(92)
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1
#> [1] "A"
grade_1(76)
#> [1] "C"
grade_1(60)
#> [1] "D"
```

<<<<<<< HEAD
But if you attempt to an entire column of a data frame, you have a problem:
||||||| merged common ancestors
But if you attempt to an entire column of a data frame, you have a
problem:
=======
But fails if you attempt to apply it to an entire column of a data
frame:
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1

``` r
df <- tibble(
  score = sample(100, 10, replace = TRUE)
)

df %>%
  mutate(grade = grade_1(score))
#> Warning in if (x >= 90) {: the condition has length > 1 and only the first
#> element will be used
#> Warning in if (x >= 80) {: the condition has length > 1 and only the first
#> element will be used
#> Warning in if (x >= 70) {: the condition has length > 1 and only the first
#> element will be used
#> Warning in if (x >= 60) {: the condition has length > 1 and only the first
#> element will be used
#> # A tibble: 10 x 2
#>   score grade
#>   <int> <chr>
<<<<<<< HEAD
#> 1    62 D    
#> 2    25 D    
#> 3    68 D    
#> 4    88 D    
#> 5    47 D    
||||||| merged common ancestors
#> 1    93 A    
#> 2    82 A    
#> 3    86 A    
#> 4     9 A    
#> 5    80 A    
=======
#> 1    97 A    
#> 2    43 A    
#> 3    77 A    
#> 4    24 A    
#> 5    11 A    
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1
#> # ... with 5 more rows
```

<<<<<<< HEAD
`if` can only work with a single element at a time, so if `grade()` is given a vector it will only use the first element. You can always work around this problem by using one of the `map_` functions from purrr. In this case, `grade()` returns a character vector so we'd use `map_chr()`:
||||||| merged common ancestors
`if` can only work with a single element at a time. You can always work
around this problem using one of the `map_` functions from purrr. In
this case, `grade()` returns a character vector so we’d use `map_chr()`:
=======
You can always work around this problem using one of the `map_`
functions from purrr. In this case, `grade()` returns a character vector
so we’d use `map_chr()`:
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1

``` r
df %>%
  mutate(grade = map_chr(score, grade_1))
#> # A tibble: 10 x 2
#>   score grade
#>   <int> <chr>
<<<<<<< HEAD
#> 1    62 D    
#> 2    25 F    
#> 3    68 D    
#> 4    88 B    
#> 5    47 F    
||||||| merged common ancestors
#> 1    93 A    
#> 2    82 B    
#> 3    86 B    
#> 4     9 F    
#> 5    80 B    
=======
#> 1    97 A    
#> 2    43 F    
#> 3    77 C    
#> 4    24 F    
#> 5    11 F    
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1
#> # ... with 5 more rows
```

However, there is often an alternative, more elegant approach by relying on an existing vector function. For example, you can always rewrite a set of nested if-else statements to use `case_when()`:

``` r
grade_2 <- function(x) {
  case_when(
    x >= 90 ~ "A",
    x >= 80 ~ "B",
    x >= 70 ~ "C",
    x >= 60 ~ "D",
    TRUE    ~ "F"
  )
}

grade_2(seq(0, 100, by = 10))
#>  [1] "F" "F" "F" "F" "F" "F" "D" "C" "B" "A" "A"

df %>%
  mutate(grade = grade_2(score))
#> # A tibble: 10 x 2
#>   score grade
#>   <int> <chr>
<<<<<<< HEAD
#> 1    62 D    
#> 2    25 F    
#> 3    68 D    
#> 4    88 B    
#> 5    47 F    
||||||| merged common ancestors
#> 1    93 A    
#> 2    82 B    
#> 3    86 B    
#> 4     9 F    
#> 5    80 C    
=======
#> 1    97 A    
#> 2    43 F    
#> 3    77 C    
#> 4    24 F    
#> 5    11 F    
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1
#> # ... with 5 more rows
```

<<<<<<< HEAD
And for this particular case, there's an even more targeted function from base R: `cut()`. Its job is to divided a numeric range into named intervals. You give it a vector of breaks, and a vector of labels, and it produces a factor for you:
||||||| merged common ancestors
And for this particular case, there’s an even more targetted function
from base R: `cut()`. Its job is to divided a numeric range into named
intervals. You give it a vector of breaks, and a vector of labels, and
it produces a factor for you:
=======
For this particular case, there’s an even more targetted function from
base R: `cut()`. Its job is to “cut” a number into labelled intervals.
You give it a vector of breaks and a vector of labels, and it produces a
factor for you:
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1

``` r
grade_3 <- function(x) {
  cut(x, 
    breaks = c(-Inf, 60, 70, 80, 90, Inf), 
    labels = c("F", "D", "C", "B", "A"),
    right = FALSE
  )
}

grade_3(seq(0, 100, by = 10))
#>  [1] F F F F F F D C B A A
#> Levels: F D C B A
```

<<<<<<< HEAD
In general, there's no easy way to find out that there's an existing function that will make your life much easier. The best technique is to continually expand your knowledge of R by reading widely; a good place to start are the weekly highlights on <http://rweekly.org/>.
||||||| merged common ancestors
In general, there’s no easy way to find out that there’s an existing
function that will make your life much easier. The best technique is to
continually expand your knowledge of R by reading widely; a good place
to start are the weekly highlights on <http://rweekly.org/>.
=======
(Note that you supply it one less `label` than `breaks`; if this is
confusing, try drawing a picture.)

In general, there’s no easy way to find out that there’s an existing
function that will make your life much easier. The best technique is to
continually expand your knowledge of R by reading widely; a good place
to start are the weekly highlights on <http://rweekly.org/>.
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1

Matching many patterns
----------------------

<<<<<<< HEAD
So far when you've used stringr, we've always used a single `pattern`. But imagine you have a new challenge: you have a single string and you want see which of a possible set of patterns it matches:
||||||| merged common ancestors
So far when you’ve used stringr, we’ve always used a single `pattern`.
But imagine you have a new challenge: you have a single string and you
want see which of a possible set of patterns it matches:
=======
A similar problem is accidentally using a vectorised function as if it’s
a scalar function, making life harder for yourself. I’ll illustrate the
problem with a function that you’ll already familiar with
`stringr::str_detect()`. So far when you’ve used stringr, we’ve always
used a single `pattern`. But imagine you have a new challenge: you have
a single string and you want see which of a possible set of patterns it
matches:
>>>>>>> 8ee078a2481245f7e5771f84e027d04d6e276be1

``` r
private <- tribble(
  ~ name,  ~ pattern,
  "ssn",   "\\d{3}-\\d{2}-\\d{4}",
  "email", "[a-z]+@[a-z]+\\.[a-z]{2,4}",
  "phone", "\\d{3}[- ]?\\d{3}[- ]?\\d{4}"
)

string <- "My social security number is 231-57-7340 and my phone number is 712-458-2189"
```

You might be tempted to use `map_lgl()`:

``` r
match <- map_lgl(private$pattern, ~ str_detect(string, pattern = .))
private$name[match]
#> [1] "ssn"   "phone"
```

But if you carefully read the documentation for `str_detect()` you'll discover that this is unnecessary because `str_detect()` is vectored oven `pattern`. That means you don't need `map_lgl()`!

``` r
private$name[str_detect(string, private$pattern)]
#> [1] "ssn"   "phone"
```

It's sometimes hard to tell from the documentation whether or not an argument is vectored. If reading the docs doesn't help, just try it with a vector; if it works you'll have learned something new and saved yourself a little typing.

