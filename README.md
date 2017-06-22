# Experimental jit compiler for R built on [NIMBLE](http://r-nimble.org)

```r
devtools::install_github('nimble-dev/rcjit')
library(rcjit)

logistic_map <- function(start, scale, steps) {
    result <- start
    for (i in 1:steps) {
        result <- scale * result * (1.0 - result)
    }
    return(result)
}

jit_logistic_map <- jit(logistic_map)  # <---------- jit( )

print(logistic_map(0.1, 3.6, 1000000))
# 0.791767

print(jit_logistic_map(0.1, 3.6, 1000000))
# 0.791767

library(microbenchmark)
microbenchmark(jit_logistic_map(0.1, 3.6, 1000000),
                   logistic_map(0.1, 3.6, 1000000))
# Unit: milliseconds
#                              expr       min        lq      mean    median       uq       max neval
# jit_logistic_map(0.1, 3.6, 1e+06)  2.472324  2.473969  2.490519  2.476032  2.49078  2.890946   100
#     logistic_map(0.1, 3.6, 1e+06) 40.078393 40.120312 40.919318 40.298471 41.74336 47.068705   100
```

Rcjit is a thin wrapper library around [NIMBLE](http://r-nimble.org)
to make NIMBLE's compiler infrastructure easy to use.

## What can be `jit`ted?

The rcjit `jit()` function handles only a subset of NIMBLE code,
but it does try to handle simple R functions that "look like C++".
For complete detail, check out the [NIMBLE User Manual](https://r-nimble.org/manuals/NimbleUserManual.pdf).
Some features of NIMBLE are not yet avialable in rcjit, for example recursion or allowing
one jitted function to use another; if you need these features immediately, try using NIMBLE directly.

This is an experimental interface and will be changing rapidly,
but we'd love your feedback and feature requests.

## What is NIMBLE?

[NIMBLE](http://r-nimble.org) is an R package for programming with BUGS
models.
Some probabilistic programming languages perform black-box inference on
user-defined models.
NIMBLE provides more flexibility and lets users additionally define algorithms
against models: inference algorithms, experimental design algorithms, basically
anything that uses a graphical model as basic concept.
To make NIMBLE algorithms fast, the authors built a compiler from parts of R to C++.
You can read details in :

> "Programming with models: writing statistical algorithms for general model structures with NIMBLE" <br/>
> Perry de Valpine, Daniel Turek, Christopher J. Paciorek, Clifford Anderson-Bergman, Duncan Temple Lang, Rastislav Bodik <br/>
> https://arxiv.org/pdf/1505.05093.pdf
