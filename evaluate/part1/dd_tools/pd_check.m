function posdef = pd_check(a)
%PD_CHECK Check if the matrix is positive (semi-) definite
%
%     POSDEF = PD_CHECK(A)
%
% Check for a symmetric matrix A if it is positive definite.
% POSDEF = 1 if A is safely pos.def, i.e. each diagonal element is
% > tol in the Chol.factorization.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

n = size(a,1);
tol = 1e-15;
posdef = 0;
for j = 1:n
	if (j > 1),
		a(j:n,j) = a(j:n,j) - a(j:n,1:j-1) * a(j,1:j-1)';
	end;
	if (a(j,j) < tol),
		 return;
	end;
	a(j:n,j) = a(j:n,j) / sqrt( a(j,j) );
end;
posdef = 1;   %G = tril( a);  this could be used as cholesky factor

return
