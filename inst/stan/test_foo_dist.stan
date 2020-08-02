/// @file test-foo_dist.stan
/// @brief Test file for the `foo_dist` distribution.
///
/// Here is a simple test mechanism for each of the four `foo_dist` wrappers, i.e., with or without derivatives wrt each of `y` and `mu`.

functions {
  // forward declaration: *required* by `rstan::stanc()` (tested)
  real foo_dist_lpdf(real y, real mu); 
}

data {
  real y_dat; // data version of the arguments (stan doesn't calculate derivatives)
  real mu_dat;
  int<lower=0,upper=3> type; // select which wrapper to test
}

parameters {
  real y; // parameter version of the arguments (stan calculates derivatives)
  real mu;
}

model {
  if(type == 0) {
    // no gradients
    y_dat ~ foo_dist(mu_dat);
  } else if(type == 1) {
    // gradient wrt mu
    y_dat ~ foo_dist(mu);
  } else if(type == 2) {
    // gradient wrt y
    y ~ foo_dist(mu_dat);
  } else if(type == 3) {
    // gradient wrt y and mu
    y ~ foo_dist(mu);
  }
}
