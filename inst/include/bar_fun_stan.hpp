/// @file bar_fun_stan.hpp
/// @brief Example of wrapping the `bar_fun` function and its gradients in Stan.
///
/// This closely follows `stan-dev/math/stan/math/prim/prob/hmm_marginal.hpp`

#ifndef stanmygrad_bar_fun_stan_hpp
#define stanmygrad_bar_fun_stan_hpp 1

#include "bar_fun.hpp"
#include <vector>
/// FIXME: not sure which other stan header files need to be included.
/// seems that R/stan interface includes them all for you...
// #include <stan/math/prim/functor/operands_and_partials.hpp>

template <typename T_alpha, typename T_beta>
inline auto bar_fun(const std::vector<T_alpha>& alpha,
		    const std::vector<T_beta>& beta) {
  // import stan names
  using stan::math::operands_and_partials;
  using stan::partials_return_t;
  // create the return type
  using T_partials_return = partials_return_t<T_alpha, T_beta>;
  // create the gradient wrt std::vector type (i.e., stan reals)
  using T_partials_reals = std::vector<T_partials_return>;

  // FIXME: add argument checks
  int N = alpha.size();

  // create the return object containing the function and its gradients
  operands_and_partials<std::vector<T_alpha>,
                        std::vector<T_beta> >
    ops_partials(alpha, beta);

  // evaluate the function and its gradients.
  // we'll only evaluate the necessary gradients.
  bool calc_dalpha = !stan::is_constant_all<T_alpha>::value;
  bool calc_dbeta = !stan::is_constant_all<T_beta>::value;
  T_partials_reals dalpha;
  T_partials_reals dbeta;
  // only allocate memory if necessary
  if(calc_dalpha) dalpha.resize(N);
  if(calc_dbeta) dbeta.resize(N);

  stanmygrad::bar_fun bar; // the function object
  // wrap inputs as vector<double>
  const auto& alpha_val = value_of(alpha);
  const auto& beta_val = value_of(beta);
  double ans_val = bar.eval(dalpha, dbeta,
			    alpha_val, beta_val, calc_dalpha, calc_dbeta);

  // put the gradients into the return object
  // NOTE: dalpha and dbeta are of type std::vector<...>,
  // but pos_partials.edge*_.partials is of type Eigen::Vector<...>
  // since we can't automatically convert between the two,
  // use for-loop for assignment.
  if(calc_dalpha) {
    for(int ii=0; ii<N; ii++) {
      ops_partials.edge1_.partials_[ii] = dalpha[ii];
    }
  }
  if(calc_dbeta) {
    for(int ii=0; ii<N; ii++) {
      ops_partials.edge2_.partials_[ii] = dbeta[ii];
    }
  }
  // put the function value into the return object
  T_partials_return ans(ans_val);
  return ops_partials.build(ans);
}

/// Stan wrapper
template <typename T0__, typename T1__>
typename boost::math::tools::promote_args<T0__, T1__>::type
bar_fun(const std::vector<T0__>& alpha,
	const std::vector<T1__>& beta, std::ostream* pstream__) {
  return bar_fun(alpha, beta);
}

#endif
