/// @file var_ldet_stan.hpp
/// @brief Example of wrapping the `var_ldet()` function and its gradient in Stan.

#ifndef stanmygrad_var_ldet_stan_hpp
#define stanmygrad_var_ldet_stan_hpp 1

#include "var_ldet.hpp"
/// FIXME: not sure which other stan header files need to be included.
/// seems that R/stan interface includes them all for you...

template <typename T_X>
inline auto var_ldet(const Eigen::Matrix<T_X, Eigen::Dynamic, Eigen::Dynamic>& X) {
  // import stan names
  using stan::math::operands_and_partials;
  using stan::partials_return_t;
  // create the return type
  using T_partials_return = partials_return_t<T_X>;
  // create the gradient wrt Eigen::Matrix type (i.e., stan matrix)
  using T_partials_matrix = Eigen::Matrix<T_partials_return, Eigen::Dynamic, Eigen::Dynamic>;

  // FIXME: add argument checks
  int N = X.rows();

  // create the return object containing the function and its gradients
  operands_and_partials<Eigen::Matrix<T_X, Eigen::Dynamic, Eigen::Dynamic> >
    ops_partials(X);

  // evaluate the function and its gradient.
  // we'll only evaluate the gradient if necessary.
  bool calc_dX = !stan::is_constant_all<T_X>::value;
  T_partials_matrix dX;
  // only allocate memory if necessary
  if(calc_dX) dX = Eigen::MatrixXd::Zero(N,N);

  stanmygrad::var_ldet vld(N); // the function object
  // wrap input as Eigen::MatrixXd
  const auto& X_val = value_of(X);
  double ans_val = vld.eval(dX, X_val, calc_dX);

  // put the gradient into the return object
  if(calc_dX) {
    ops_partials.edge1_.partials_ = dX;
  }
  // put the function value into the return object
  T_partials_return ans(ans_val);
  return ops_partials.build(ans);
}

/// Stan wrapper
template <typename T0__>
typename boost::math::tools::promote_args<T0__>::type
var_ldet(const Eigen::Matrix<T0__, Eigen::Dynamic, Eigen::Dynamic>& X,
	   std::ostream* pstream__) {
  return var_ldet(X);
}

#endif
