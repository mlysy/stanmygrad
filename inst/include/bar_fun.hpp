#ifndef stanmygrad_bar_fun_hpp
#define stanmygrad_bar_fun_hpp 1

#include <vector>
#include <cmath>

namespace stanmygrad {

  /// Return value and gradients for the `bar_fun` function.
  ///
  /// The function is defined as
  ///
  /// ```
  /// bar_fun(alpha, beta) = sum_{i=1}^N sin(alpha[i]) * beta[i]^2
  /// ```
  class bar_fun {
  public:
    /// Evaluate function and gradients.
    ///
    /// @param[out] dalpha Vector to store gradient wrt `alpha`.
    /// @param[out] dbeta Vector to store gradient wrt `beta`.
    /// @param[in] alpha Vector of `alpha` values.
    /// @param[in] beta Vector of `beta` values.
    /// @param[in] calc_dalpha If `true` calculate the gradient wrt `alpha`.
    /// @param[in] calc_dbeta If `true` calculate the gradient wrt `beta`.
    ///
    /// @return Value of `bar_fun(alpha, beta)`.  Gradients are return via pass-by-reference arguments.
    double eval(std::vector<double>& dalpha,
		std::vector<double>& dbeta,
		const std::vector<double>& alpha,
		const std::vector<double>& beta,
		bool calc_dalpha,
		bool calc_dbeta) {
      int N = alpha.size();
      double ans = 0.0;
      double sa, b2;
      for(int ii=0; ii<N; ii++) {
	sa = sin(alpha[ii]);
	b2 = beta[ii] * beta[ii];
	ans += sa * b2;
	if(calc_dalpha) {
	  dalpha[ii] = cos(alpha[ii]) * b2;
	}
	if(calc_dbeta) {
	  dbeta[ii] = sa * (2.0 * beta[ii]);
	}
      }
      return ans;
    }
  };

} // end namespace stanmygrad

#endif

