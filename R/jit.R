supportedBackends <- c('C++', 'Nimble')

# This attempts to determine a NIMBLE type spec from an example value.
nimTypeOf <- function(value) {
    value <- eval(value)
    switch(
        class(value),
        'logical' = call('logical', if (length(value) == 1) 0 else 1),
        'integer' = call('integer', if (length(value) == 1) 0 else 1),
        'double' = call('double', if (length(value) == 1) 0 else 1),
        'character' = call('character', if (length(value) == 1) 0 else 1),
        'numeric' = switch(
            typeof(value),
            'logical' = call('logical', if (length(value) == 1) 0 else 1),
            'integer' = call('integer', if (length(value) == 1) 0 else 1),
            'double' = call('double', if (length(value) == 1) 0 else 1),
            stop(paste('Unsupported type:', typeof(value)))
        ),
        'matrix' = switch(
            typeof(value),
            'logical' = call('logical', 2),
            'integer' = call('integer', 2),
            'double' = call('double', 2),
            stop(paste('Unsupported type:', typeof(value)))
        ),
        stop(paste('Unsupported class:', class(value))))
}

# Determines Nimble type specs by possibly calling the function.
inferTypes <- function(fun, argValues, control) {
    if (is.null(control$returnType)) {
        control$returnType <- nimTypeOf(do.call(fun, argValues))
    }
    for (argName in names(argValues)) {
        if (is.null(control$argTypes[[argName]])) {
            control$argTypes[[argName]] <- nimTypeOf(eval(argValues[[argName]]))
        }
    }

    return(control)
}

# This adds Nimble type specs by modifying the function code.
annotateTypes <- function(fun, argTypes, returnType) {
    for (argName in names(argTypes)) {
        formals(fun)[[argName]] <- argTypes[[argName]]
    }
    body(fun) <- call('{', call('returnType', returnType), body(fun))
    return(fun)
}

compile <- function(fun, control) {
    fun <- annotateTypes(fun, control$argTypes, control$returnType)
    nimFun <- nimble::nimbleFunction(run = fun, name = control$name)
    if (control$backend == 'Nimble') {
        return(nimFun)
    } else {
        return(nimble::compileNimble(nimFun))
    }
}

#' Compiles an R function to C++ or Nimble DSL code the first time it is called.
#'
#' The first time the function is called, it will be executed and compiled.
#' Subsequent calls will run the compiled version.
#'
#' @param fun The function to be compiled.
#' @param argTypes An optional list of some or all Numble type specs for function arguments.
#'     If any argument types are missing these will be determined at the first invocation.
#' @param returnType An optional Nimble type spec for the return value.
#'     If not provided, this will be determined by calling the uncompiled function once.
#' @param name An optional name to be used for the compiled code.
#' @param backend The target back-end for compilation. Options include:
#'     'C++', or 'Nimble' for the Nimble DSL.
#'
#' @export
jit <- function(fun, argTypes = list(), returnType = NULL, name = NA, backend = 'C++') {
    if (!is.function(fun)) stop(paste('Expected a function, but got a', typeof(fun)))
    if (!(backend %in% supportedBackends)) stop(paste('Unsupported backend:', backend))
    control <- list(argTypes = argTypes, returnType = returnType, name = name, backend = backend)
    compiledFun <- NULL
    function(...) {
        if (is.null(compiledFun)) {
            argValues <- as.list(match.call(fun)[-1])
            control <- inferTypes(fun, argValues, control)
            compiledFun <<- compile(fun, control)
        }
        return(compiledFun(...))
    }
}
