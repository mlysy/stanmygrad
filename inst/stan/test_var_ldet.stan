/// @file test_var_ldet.stan
/// @brief Test file for the `var_ldet()` distribution.
///
/// Here is a simple test mechanism for each of the `var_ldet()` wrappers, i.e., with or without derivatives wrt each of `X`.

functions {
  // forward declaration: *required* by `rstan::stanc()` (tested)
  real var_ldet(matrix X);
  // convenience function to assign variable with or without gradients
  matrix set_grad(matrix var_data, matrix var, int var_grad) {
    matrix[rows(var_data), cols(var_data)] var_;
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
  matrix[N,N] X_dat;
  // 0/1 for whether to take gradient wrt to given argument
  int<lower=0,upper=1> X_grad;
}

parameters {
  // parameter version of the arguments
  matrix[N,N] X;
}

model {
  // actual version of the arguments
  matrix[N,N] X_ = set_grad(X_dat, X, X_grad);
  target += var_ldet(X_);
}
