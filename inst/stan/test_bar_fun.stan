/// @file test-foo_dist.stan
/// @brief Test file for the `foo_dist` distribution.
///
/// Here is a simple test mechanism for each of the four `foo_dist` wrappers, i.e., with or without derivatives wrt each of `y` and `mu`.

functions {
  // forward declaration: *required* by `rstan::stanc()` (tested)
  real bar_fun(real[] alpha, real[] beta);
  // convenience function to assign variable with or without gradients
  real[] set_grad(real[] var_data, real[] var, int var_grad) {
    real var_[num_elements(var_data)];
    if(var_grad == 0) {
      var_ = var_data;
    } else {
      var_ = var;
    }
    return var_;
  }
}

data {
  int N;
  // data version of the arguments
  real alpha_dat[N];
  real beta_dat[N];
  // 0/1 for whether to take gradient wrt to given argument
  int<lower=0,upper=1> alpha_grad;
  int<lower=0,upper=1> beta_grad;
}

parameters {
  // parameter version of the arguments
  real alpha[N];
  real beta[N];
}

model {
  // actual version of the arguments
  real alpha_[N] = set_grad(alpha_dat, alpha, alpha_grad);
  real beta_[N] = set_grad(beta_dat, beta, beta_grad);
  target += bar_fun(alpha_, beta_);
}
