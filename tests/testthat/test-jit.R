context('JIT compilation')

nimTypeOfValues <- list(
    list('double(0)', 1.2),
    list('double(0)', c(1.2)),
    list('double(1)', c(1.2, 3.4)),
    list('double(2)', matrix(double(1:4), 2, 2)),
    list('integer(0)', 1L),
    list('integer(0)', c(1L)),
    list('integer(1)', c(2L, 1L)),
    list('integer(2)', matrix(1:4, 2, 2)),
    list('logical(0)', TRUE),
    list('logical(0)', c(TRUE)),
    list('logical(1)', c(FALSE, TRUE)),
    list('character(0)', 'foo'),
    list('character(1)', c('foo', 'bar'))
)

for (value in nimTypeOfValues) {
    object <- capture.output(dput(value[[2]]))
    test_that(paste('nimTypeOf:', object), {
        expect_equal(deparse(nimTypeOf(value[[2]])), value[[1]])
    })
}

test_that('annotateTypes a * x + y', {
    fun <- function(a, x, y) a * x + y
    expected <- function(a = double(0), x = double(1), y = double(1)) {
        returnType(double(1))
        a * x + y
    }
    argTypes <- list(a = call('double', 0), x = call('double', 1), y = call('double', 1))
    returnType <- call('double', 1)
    actual <- annotateTypes(fun, argTypes, returnType)
    expect_identical(actual, expected)
})

test_that('jit() works', {
    logistic_map <- function(start, scale, steps) {
        result <- start
        for (i in 1:steps) {
            result <- scale * result * (1.0 - result)
        }
        return(result)
    }
    jit_logistic_map <- jit(logistic_map)
    expect_equal(jit_logistic_map(0.1, 3.6, 1000), logistic_map(0.1, 3.6, 1000))
})
