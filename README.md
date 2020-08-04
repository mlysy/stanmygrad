# **stanmygrad**: Examples of Custom Gradients in Stan

*Martin Lysy*

---

### Description

[Stan](https://mc-stan.org/) is a probabilistic programming language which provides a variety of fast efficient algorithms for statistical inference.  High computational performance is achieved due to Stan's state-of-the-art autodiff [Math Library](https://github.com/stan-dev/math).  

Unlike many other high-performance autodiff tools, Stan's allow the user to supply custom functions and gradients written directly in C++.  This is especially useful when there are analytic gradient formulas for functions containing iterative solvers, in which case a custom gradient implementation is far more efficient than propagating the autodiff through each step of the iterative solution.  However, interacting with Stan's heavily templated C++ autodiff library and [technical documentation](https://arxiv.org/abs/1509.07164) can be somewhat daunting for novice or intermediate C++ programmers.  A much more accessible tutorial is provided [here](https://github.com/stan-dev/stan/wiki/Contributing-New-Functions-to-Stan#adding-a-function-with-known-partials) on the Stan developper [wiki](https://github.com/stan-dev/stan/wiki).  However, it is based on a somewhat outdated approach of defining overloaded functions with all combinations of grad/no-grad inputs by hand, whereas the Stan Math Library itself uses a more streamlined approach combining all these functions into a single [`operands_and_partials`](https://github.com/stan-dev/math/blob/develop/stan/math/prim/functor/operands_and_partials.hpp) construct, as for example [here](https://github.com/stan-dev/math/blob/develop/stan/math/prim/prob/dirichlet_lpdf.hpp).

The purpose of **stanmygrad** is to provide a working R/Stan package containing several extensively-documented and tested examples of custom C++ functions and gradients connected to Stan.  The examples strive to be accessible to users with some but not extensive knowledge of C++, and attempt as much as possible to use current best practices for building R/Stan packages and interfacing custom C++ code with Stan.  In this last respect, [feedback](https://github.com/mlysy/stanmygrad/issues) is most warmly welcome.

### Installation

Install the R package [**devtools**](https://CRAN.R-project.org/package=devtools) and run
```r
devtools::install_github("mlysy/stanmygrad", INSTALL_opts = "--install-tests")
```
The last argument ensures that the unit tests get installed as well.  It is recommended to run these to ensure that everything installed correctly.  To do this, first install the [**testthat**](https://CRAN.R-project.org/package=testthat) package, then run:
```r
testthat::test_package("stanmygrad", reporter = "progress")
```

### Examples Provided

The **stanmygrad** package currently provides the following examples:

- `foo_dist`: This is a distribution on a scalar (Stan: `real`) variable `y` with a scalar parameter `mu` such that
    ```
	y ~ foo_dist(mu)   <=>   y ~ N(sin(mu) + mu, 1)
	```
	The example is set up such that the Stan code may be called with `y ~ foo_dist(mu)`.

- `bar_fun`: This is a scalar-valued function of two arrays (Stan: `real[]`) `alpha` and `beta` such that
    ```
	bar_fun(alpha, beta) = sum(sin(alpha) * beta^2)
	```
	
- `var_ldet`: This scalar-valued function returns the log-determinant of an `N x N` variance matrix `X` (Stan: `matrix`).  

The relevant source files are located in `inst/stan` and `inst/include` for Stan and C++ files, respectively.  The associate unit test files are in `tests/testthat`.


### Building an R/Stan Package from Scratch

The following instructions show to create a copy of **stanmygrad** from "scratch".  That is, the Stan, C++, and R test files will be copied over from the installed version of **stanmygrad**, whereas the remaining package infrastructure is created from the following resources (which you need install):

- **stanmygrad**. It needs to be installed on your system so that the script below can find the necessary files.
- [**usethis**](https://CRAN.R-project.org/package=usethis) for creating R packages.
- [**rstantools**](https://CRAN.R-project.org/package=rstantools) for creating R packages that contain Stan code.  In particular, it explains [here](https://mc-stan.org/rstantools/reference/rstan_create_package.html) where various Stan files in your package should go:

	- `inst/include`: Your C++ files.
	- `inst/include/stan_meta_header.hpp`: Where to put all `#include` statements for Stan to find your C++ files.
	- `inst/stan`: Where to put package `.stan` files, including those which wrap your C++ code.

Once all these packages are installed, you can create an exact copy of the **stanmygrad** package -- called **stanmygrad2** -- using the following R script.

```r
# --- step 1: create the package infrastructure --- 

# Where to install the package.  Please change `getwd()` as needed
path <- file.path(getwd(), "stanmygrad2") 

# Where to find the Stan/C++/R files in the stanmygrad installation
lib <- system.file("", package = "stanmygrad")

# files to copy over from stanmygrad
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


# --- step 2: compile the Stan/C++ source files ---

# convert the Stan code to C++
# run this every time you add/modify Stan files in the package
rstantools::rstan_config()
pkgbuild::compile_dll() # compile the C++ code

# --- step 3: finish installing the package ---

devtools::document()
devtools::install(quick = TRUE) # set `quick = FALSE` to recompile all C++ code

# --- step 4: run package tests to make sure everything worked ---

# *** QUIT AND RESTART R ***
# then:
testthat::test_package("stanmygrad2", reporter = "progress")
```

### TODO

- Add input checks to C++ code.
- Add an example with a multivariate output.
