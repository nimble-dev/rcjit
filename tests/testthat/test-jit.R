context('JIT compilation')

nimTypeOfValues <- list(
    list('double(0)', 1.2),
    list('double(0)', c(1.2)),
    list('double(1)', c(1.2, 3.4)),
    list('integer(0)', 1L),
    list('integer(0)', c(1L)),
    list('integer(1)', c(2L, 1L)),
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
