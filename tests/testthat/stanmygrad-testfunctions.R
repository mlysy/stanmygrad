
# foo_dist log-density and its gradients
foo_dist <- function(y, mu) {
  list(lp = dnorm(y, mean = sin(mu) + mu, log = TRUE),
       y = (sin(mu) + mu) - y,
       mu = (y - (sin(mu) + mu)) * (cos(mu) + 1))
}

# generate random foo_dist arguments
foo_dist_sim <- function() {
  list(y = rnorm(1), mu = rnorm(1))
}

# bar_fun function and its gradients
bar_fun <- function(alpha, beta) {
  list(lp = sum(sin(alpha) * beta^2),
       alpha = cos(alpha) * beta^2,
       beta = 2 * sin(alpha) * beta)
}

# generate random bar_fun arguments
bar_fun_sim <- function(N) {
  list(alpha = runif(N), beta = runif(N))
}


# give `_dat` extension to named arguments.
as_data <- function(args, data_args) {
  if(missing(data_args)) data_args <- names(args)
  out_data <- names(args) %in% data_args
  names(args)[out_data] <- paste0(names(args)[out_data], "_dat")
  args
}

# combine data and pars arguments
r_args <- function(data, pars, par_args) {
  out_pars <- names(data) %in% par_args
  data[out_pars] <- pars[out_pars]
  data
}

# extract the gradient values for a given parameter name
get_grad <- function(grad, pars, par_name) {
  igrad <- unlist(lapply(names(pars), function(pn) {
    rep(par_name == pn, length(pars[[pn]]))
  }))
  grad[igrad]
}

# parse names of gradients
parse_grad <- function(grad_names) {
  if(length(grad_names) == 0) {
    test_name <- "none."
  } else {
    test_name <- paste0(grad_names, collapse = ", ")
  }
  test_name
}
