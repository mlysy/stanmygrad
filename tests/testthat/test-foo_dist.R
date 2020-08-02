
context("foo_dist")

source("stanmygrad-testfunctions.R")

test_that("foo_dist log-density is correct.", {
  ntest <- 10
  for(ii in 1:ntest) {
    # generate data
    data <- foo_dist_sim()
    # create foo_dist model object
    capture_output(
      fit <- rstan::sampling(stanmodels$test_foo_dist,
                             data = c(as_data(data), list(type = 0L)),
                             iter = 1, chains = 1, algorithm = "Fixed_param")
    )
    # generate parameters
    pars <- foo_dist_sim()
    # log-posterior in R
    lp_r <- do.call(foo_dist, data)[["lp"]]
    # log-posterior in Stan
    upars <- rstan::unconstrain_pars(fit, pars)
    lp_stan <- rstan::log_prob(fit, upars)
    expect_equal(lp_r, lp_stan)
  }
})

test_that("foo_dist gradient wrt mu is correct.", {
  ntest <- 10
  for(ii in 1:ntest) {
    # generate data
    data <- foo_dist_sim()
    # create foo_dist model object
    capture_output(
      fit <- rstan::sampling(stanmodels$test_foo_dist,
                             data = c(as_data(data), list(type = 1L)),
                             iter = 1, chains = 1, algorithm = "Fixed_param")
    )
    # generate parameters
    pars <- foo_dist_sim()
    # R calculations
    pars_r <- r_args(data, pars, par_args = "mu")
    calc_r <- do.call(foo_dist, pars_r)
    lp_r <- calc_r[["lp"]]
    grad_r <- calc_r[["mu"]]
    # Stan calculations
    upars <- rstan::unconstrain_pars(fit, pars)
    calc_stan <- rstan::grad_log_prob(fit, upars)
    lp_stan <- attr(calc_stan, "log_prob")
    grad_stan <- calc_stan[2]
    expect_equal(lp_r, lp_stan)
    expect_equal(grad_r, grad_stan)
  }
})

test_that("foo_dist gradient wrt y is correct.", {
  ntest <- 10
  for(ii in 1:ntest) {
    # generate data
    data <- foo_dist_sim()
    # create foo_dist model object
    capture_output(
      fit <- rstan::sampling(stanmodels$test_foo_dist,
                             data = c(as_data(data), list(type = 2L)),
                             iter = 1, chains = 1, algorithm = "Fixed_param")
    )
    # generate parameters
    pars <- foo_dist_sim()
    # R calculations
    pars_r <- r_args(data, pars, par_args = "y")
    calc_r <- do.call(foo_dist, pars_r)
    lp_r <- calc_r[["lp"]]
    grad_r <- calc_r[["y"]]
    # log-posterior in Stan
    upars <- rstan::unconstrain_pars(fit, pars)
    calc_stan <- rstan::grad_log_prob(fit, upars)
    lp_stan <- attr(calc_stan, "log_prob")
    grad_stan <- calc_stan[1]
    expect_equal(lp_r, lp_stan)
    expect_equal(grad_r, grad_stan)
  }
})

test_that("foo_dist gradient wrt y and mu is correct.", {
  ntest <- 10
  for(ii in 1:ntest) {
    # generate data
    data <- foo_dist_sim()
    # create foo_dist model object
    capture_output(
      fit <- rstan::sampling(stanmodels$test_foo_dist,
                             data = c(as_data(data), list(type = 3L)),
                             iter = 1, chains = 1, algorithm = "Fixed_param")
    )
    # generate parameters
    pars <- foo_dist_sim()
    # R calculations
    pars_r <- r_args(data, pars, par_args = c("y", "mu"))
    calc_r <- do.call(foo_dist, pars_r)
    lp_r <- calc_r[["lp"]]
    grad_r <- c(calc_r[["y"]], calc_r[["mu"]])
    # log-posterior in Stan
    upars <- rstan::unconstrain_pars(fit, pars)
    calc_stan <- rstan::grad_log_prob(fit, upars)
    lp_stan <- attr(calc_stan, "log_prob")
    grad_stan <- as.numeric(calc_stan)
    expect_equal(lp_r, lp_stan)
    expect_equal(grad_r, grad_stan)
  }
})
