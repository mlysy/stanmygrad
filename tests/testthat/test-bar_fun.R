
context("bar_fun")

source("stanmygrad-testfunctions.R")

grad_cases <- expand.grid(alpha_grad = 0:1,
                          beta_grad = 0:1)
par_names <- c("alpha", "beta")

for(jj in 1:nrow(grad_cases)) {
  grads <- grad_cases[jj,]
  grad_names <- par_names[as.logical(unlist(grads))]
  test_that(paste0("bar_fun evaluation + gradients: ",
                   parse_grad(grad_names)), {
    ntest <- 10
    for(ii in 1:ntest) {
      # generate data
      N <- sample(5:10, 1)
      pars_data <- bar_fun_sim(N)
      # create foo_dist model object
      data <- c(list(N = N), as_data(pars_data), as.list(unlist(grads)))
      capture_output(
        fit <- rstan::sampling(stanmodels$test_bar_fun,
                               data = data,
                               iter = 1, chains = 1, algorithm = "Fixed_param")
      )
      # generate parameters
      pars_grad <- bar_fun_sim(N)
      # R calculations
      pars_r <- r_args(pars_data, pars_grad, grad_names)
      calc_r <- do.call(bar_fun, pars_r)
      # Stan calculations
      upars <- rstan::unconstrain_pars(fit, pars_grad)
      calc_stan <- rstan::grad_log_prob(fit, upars)
      expect_equal(calc_r$lp, attr(calc_stan, "log_prob"))
      for(gn in grad_names) {
        expect_equal(calc_r[[gn]], get_grad(calc_stan, pars_grad, gn))
      }
    }
  })
}
