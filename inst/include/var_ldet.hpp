#ifndef stanmygrad_var_ldet_hpp
#define stanmygrad_var_ldet_hpp 1

namespace stanmygrad {

  using namespace Eigen;

  /// Log-determinant of a variance matrix and its gradient.
  ///
  /// The gradient of the log-determinant is
  /// ```
  /// d/dX log|X| = X^{-1}.
  /// ``` 
  class var_ldet {
  private:
    int N_; ///< Size of matrix
    LLT<MatrixXd> llt_; ///< cholesky computor
  public:
    /// Evaluate the log-determinant and its gradient.
    ///
    /// @param[out] dX `N x N` matrix to store the gradient.
    /// @param[in] X `N x N` variance matrix.
    /// @param[in] calc_dX If `true` calculate the gradient.
    /// @return The value of the log-determinant.
    double eval(Ref <MatrixXd> dX,
		const Ref <const MatrixXd> X,
		bool calc_dX) {
      double ldet = 0.0;
      llt_.compute(X); // cholesky decomposition
      // log-determinant
      for(int ii=0; ii<N_; ii++) {
	ldet += log(llt_.matrixL()(ii,ii));
      }
      ldet *= 2.0;
      // gradient
      if(calc_dX) {
	dX = MatrixXd::Identity(N_, N_);
	llt_.solveInPlace(dX); // solveInPlace avoids memory allocation
      }
      return ldet;
    }    
    /// Constructor.
    ///
    /// Allocates memory to compute multiple log-determinants on matrices of the same size.
    /// @param[in] N Size of variance matrix.
    ///
    var_ldet(int N) {
      N_ = N;
      llt_.compute(MatrixXd::Identity(N, N)); // memory allocation
    }
  };
  
} // end namespace stanmygrad

#endif

