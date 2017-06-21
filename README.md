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
