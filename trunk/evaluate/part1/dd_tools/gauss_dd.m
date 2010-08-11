%GAUSS_DD Gaussian data description.
% 
%       W = gauss_dd(A,fracrej,r)
% 
% Fit a Gaussian density on dataset A. If requested, the r can be
% given to add some regularization to the estimated covariance matrix:
% sig_new = (1-r)*sig + r*eye(dim). Default r = 0.01!!! (might be
% dangerous!)
%
% This version acutally computes just the Mahalanobis distance to the
% mean. This should avoid underflows at the computation of a real Gaussian
% density (especially problematic in high dimensional spaces).
%
% See also mcd_gauss_dd, rob_gauss_dd, mappings, dd_roc
% <a href="http://www-ict.ewi.tudelft.nl/~davidt/functions/mcd_gauss_dd.html">mcd_gauss_dd</a>

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = gauss_dd(a,fracrej,r)

if nargin < 3 | isempty(r), r = 0.01; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) 
	W = mapping(mfilename,{fracrej,r});
	W = setname(W,'Gaussian OC');
	return
end

if ~ismapping(fracrej)           %training

	a = target_class(a);     % only use the target class
	[n,k] = size(a);

	% Train it:
	[mu,sig] = meancov(+a);
	sig = (1-r)*sig + r*mean(diag(sig))*eye(k);
	% invert the covariance matrix:
	sinv = inv(sig);

	% get the distances on the training set:
	X = a - repmat(mu,n,1);
	d = sum((X*sinv).*X,2);
	
	% Obtain the threshold:
	thr = dd_threshold(d,1-fracrej);

	%and save all useful data:
	W.m = +mu;
	W.sinv = sinv;
	W.threshold = thr;
	W.scale = mean(d);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Gaussian OC');

else                               %testing

	% Extract the data:
	W = getdata(fracrej);
	m = size(a,1);

	% Compute the Mahalanobis distance (to avoid problems in the non-essential
	% normalization factor):
	X = +a - repmat(W.m,m,1);
	out = sum((X*W.sinv).*X,2);
	newout = [out repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(a,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return


