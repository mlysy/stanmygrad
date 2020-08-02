/// @file foo_dist_stan.hpp
/// @brief Example of wrapping the `foo_dist` log-density and its gradient in Stan.
/// @notes
///
/// This method creates explicit wrappers to overload each way that `foo_dist` will be called in stan:
///
/// 1.  Without gradients: all arguments are of type `double`.
/// 2.  With gradient only wrt `y`, such that the `y` argument is of type `stan::math::var`.
/// 3.  With gradient only wrt `mu`.
/// 4.  With gradients wrt both `y` and `mu`.
///
/// Since `foo_dist` is a probability distribution, we would like to use the `_lpdf` extension so that the Stan code can call the distribution via e.g., `y ~ foo_dist(mu)`.  For some reason this code doesn't compile if the explicit wrappers end with `_lpdf`.  Therefore, I've given the wrappers the extension `_lpdfi` (i = implementation), and the main Stan overloading function the desired extension `_lpdf` (see below).

#ifndef stanmygrad_foo_dist_stan_hpp
#define stanmygrad_foo_dist_stan_hpp 1

#include "foo_dist.hpp"
// #include <stan/math/rev/core.hpp>

/// Wrapper for the `foo_dist` log-density.
double foo_dist_lpdfi(const double& y, const double& mu,
		      std::ostream* pstream__) {
  stanmygrad::foo_dist fd; // instantiate foo_dist object.
  return fd.log_prob(y, mu);
}

/// Wrapper for the `foo_dist` gradient wrt `y`.
stan::math::var foo_dist_lpdfi(const stan::math::var& y, const double& mu,
			       std::ostream* pstream__) {
  stanmygrad::foo_dist fd;
  double y_ = y.val();
  double lp = fd.log_prob(y_, mu);
  double lp_dy = fd.log_prob_dy(y_, mu);
  return stan::math::var(new precomp_v_vari(lp, y.vi_, lp_dy));
}

/// Wrapper for the `foo_dist` gradient wrt `mu`.
stan::math::var foo_dist_lpdfi(double y, const stan::math::var& mu,
			       std::ostream* pstream__) {
  stanmygrad::foo_dist fd;
  double mu_ = mu.val();
  double lp = fd.log_prob(y, mu_);
  double lp_dmu = fd.log_prob_dmu(y, mu_);
  return stan::math::var(new precomp_v_vari(lp, mu.vi_, lp_dmu));
}

/// Wrapper for the `foo_dist` gradient wrt both `y` and `mu`.
///
/// Note that we use `precomp_vv_vari` here instead of `precomp_v_vari` because there are two arguments wrt to take derivatives.
stan::math::var foo_dist_lpdfi(const stan::math::var& y,
			       const stan::math::var& mu,
			       std::ostream* pstream__) {
  stanmygrad::foo_dist fd;
  double y_ = y.val();
  double mu_ = mu.val();
  double lp = fd.log_prob(y_, mu_);
  double lp_dy = fd.log_prob_dy(y_, mu_);
  double lp_dmu = fd.log_prob_dmu(y_, mu_);
  return stan::math::var(new precomp_vv_vari(lp, y.vi_, mu.vi_, lp_dy, lp_dmu));
}

/// Main Stan wrapper to `foo_dist` which dispatches to the desired function defined above.
///
/// Sometimes the arguments to this function are a bit hard to guess.  A trick for this is to create a file `inst/stan/foo_dist.stan` forward-declaring the `foo_dist_lpdf()` function as if you'd written it in pure Stan:
///
/// ```
/// functions {
///  real foo_dist_lpdf(real y, real mu);
/// }
///
/// model {
/// }
/// ```
///
/// When you run `rstantools::rstan_config()` on the package, it will generate a file `src/stanExports_foo_dist.h` containing the C++ forward declaration below.  Then just copy-paste these lines back here :)
template <bool propto, typename T0__, typename T1__>
typename boost::math::tools::promote_args<T0__, T1__>::type
foo_dist_lpdf(const T0__& y,
	      const T1__& mu,
	      std::ostream* pstream__) {
  // note the `_lpdfi` extension wrapped by `_lpdf`
  return foo_dist_lpdfi(y, mu, pstream__);
}


#endif //stanmygrad_foo_dist_stan_hpp
