#' Cloning the stanmygrad package.
#'
#' Assumes the following packages have been installed:
#' - **rstantools**.
#' - **usethis**.
#' - **stanmygrad** with its unit tests.

# step 1: create the package infrastructure

# locations of relevant files in the stanmygrad package

path <- file.path(tempdir(), "stanmygrad2") # where to install the package
# where to get the Stan/C++/R files from
lib <- system.file("", package = "stanmygrad")
stan_files <- Sys.glob(file.path(lib, "stan", "*.stan"))
cpp_files <- Sys.glob(file.path(lib, "include", "*.hpp"))
test_files <- Sys.glob(file.path(lib, "tests", "testthat" , "*.R"))

# create package skeleton and add stan files
rstantools::rstan_create_package(path = path,
                                 stan_files = stan_files,
                                 roxygen = TRUE,
                                 rstudio = FALSE,
                                 open = FALSE,
                                 travis = FALSE,
                                 auto_config = FALSE)

setwd(path)

# append the following lines to NAMESPACE directly
# to avoid complaint from `devtools::document()`
cat("import(Rcpp)",
    "import(methods)",
    "importFrom(rstan, sampling)",
    "useDynLib(stanmygrad2, .registration = TRUE)",
    sep = "\n", file = "NAMESPACE", append = TRUE)

# The provided `.Rbuildignore file contains the values
# `^rcppExports.cpp$` and `^stanExports_*`.  This is has the
# consequence of excluding these files from the tarball created by
# `devtools::build()`, which means that it won't install properly.
# Since there's nothing else important in this file let's simply delete it.
unlink(file.path(".Rbuildignore"))

# add C++ files
file.copy(from = cpp_files,
          to = file.path("inst", "include"),
          overwrite = TRUE)

# add test files
usethis::use_testthat()
file.copy(from = test_files,
          to = file.path("tests", "testthat"),
          overwrite = TRUE)

# step 2: compile the Stan/C++ source files
# convert the Stan code to C++
# run this every time you add/modify Stan files in the package
rstantools::rstan_config()
pkgbuild::compile_dll() # compile the C++ code

# step 3: finish installing the package
devtools::document()
devtools::install(quick = TRUE) # set `quick = FALSE` to recompile all C++ code

# step 4: run package tests to make sure everything worked
# -- QUIT AND RESTART R ---
# then:
testthat::test_package("stanmygrad2", reporter = "progress")

