function z = gendatouts(x,N,dim,dr)
%GENDATOUTS Generate uniform outliers in a subspace
%
%          Z = GENDATOUTS(X,N,DIM,DR)
%
% Generate N artificial outliers in the DIM-dimensional PCA subspace of
% the data X. This data is rescaled to have unit variance in the
% subspace and in this subspace data is generated uniformly in a sphere.
%
% See also gendatout, gendatoutg

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
if nargin<4
	dr = 1.1;
end
if nargin<3
	dim = 0.99;
end

% remove labels:
if isocset(x)
	x = +target_class(x);
else
	x = +x;
end
[n,k] = size(x);

% get the mean of the data and remove it:
mn = mean(x);
x = x - repmat(mn,n,1);

% get the eigenvalues /vectors of the covariance matrix:
C = cov(x);
[V,D] = eig(C);
[v,I] = sort(diag(D));
% how many of them do we want to keep?
w = cumsum(v)/sum(v);
if (dim>=1)
	if (dim > k), error('illegal dimensionality requested'); end
	J = 1:dim;
else
	% and use the relative weigths:
	J = find(w <= dim);
end
% check it, we might get into trouble when variances become zero
JJ = find(abs(w(J))<1e-12);
warning('dd_tools:ZeroVarFeatures',...
	'Some of the requested PCA-subspace features have zero variance. I removed them.');
J(JJ) = [];

% project the data to the subspace:
W = V(:,J);
y = x*W;

% scale to unit variance:
sc = std(y);
y = y./repmat(sc,n,1);

% generate outliers in this space:
z = gendatout(y,N,dr,1);

% scale this back:
z = z.*repmat(sc,N,1);

% project the data back in the original space:
z = z*inv(W'*W)*W';
% and correct for the mean:
z = z + repmat(mn,N,1);



return
