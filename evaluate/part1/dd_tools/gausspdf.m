function [y,d2] = gausspdf(x,mu,sigma,lambda)
%GAUSSPDF Multivariate Gaussian probability density function
%
%    Y = GAUSSPDF(X,MU,SIGMA)
%
% High dimensional version of normpdf. Given the mean MU and
% covariance matrix SIGMA, the density at points X is computed. It is
% assumed that all objects are row objects.
% Per default, just the inverse of the covariance matrix is computed.
%
%    Y = GAUSSPDF(X,MU,SIGMA,lambda)
%
% When lambda>0, the covariance matrix is regularized by:
%
%  sigma' = sigma + lambda*eye(dim)
%
% For lambda<0 the pseudo-inverse is used.
%
% default 1D mu=0, sigma=1

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<4
	lambda = [];
end
if nargin<3
	sigma = 1;
end
if nargin<2
	mu = 0;
end
if nargin<1
	error('Gausspdf requires at least one input argument.');
end

% First the Mahanalobis distance:
d2 = mahaldist(x,mu,sigma,lambda);

% When lambda>0 is supplied, the regularized sigma should also be
% used in the computation of the detS:
dim = size(x,2);
if ~isempty(lambda) & (lambda>0)
	sigma = sigma + lambda*eye(dim);
end

% Normalize to pdf:
detS = det(sigma);
if (detS<0)  % annoying when near-singular cov.matrix
  detS = -detS;  %DXD: hack hack hack
end

% and finally the density computation:
y = exp(-d2/2)/sqrt(detS*(2*pi)^dim);

return

