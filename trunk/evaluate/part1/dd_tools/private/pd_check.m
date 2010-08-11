function posdef = pd_check( a)
% golub version of cholesky, with nonpos. test
% input: a  ... sym. matrix
% output: posdef
% call: posdef = pd_check( a)
% posdef = 1 if a is safely pos.def, ie each diag > tol in chol.faktor
% otherwise posdef = 0;

[n, n1] = size( a); posdef = 0; tol = 1e-15;
for j = 1:n
        if j > 1,
        a( j:n,j) = a( j:n,j) - ...
           a( j:n,1:j-1) * a(j, 1:j-1)';
        end;
        if a(j,j) < tol, return, end;
        a( j:n,j) = a( j:n,j) / sqrt( a(j,j) );
end;
posdef = 1;   %G = tril( a);  this could be used as cholesky factor
