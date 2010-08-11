%MCD_GAUSS_DD Minimum Covariance Determinant Robust Gaussian data description.
% 
%       W = MCD_GAUSS_DD(A,FRACREJ)
% 
% Fit a Minimum-Covariance-Determinant Gaussian density on dataset A. The
% algorithm is taken from :
%
%  Rousseeuw, P.J. and Van Driessen, Katrien, "A fast algorithm for
%  the minimum covariance determinant estimator", 15 Dec. 1998
% 
% See also: dd_roc, fastmcd, gauss_dd, rob_gauss_dd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function [W,out] = mcd_gauss_dd(x,fracrej)

if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(x) 
	W = mapping(mfilename,{fracrej});
	W = setname(W,'Minimum Covariance Determinant Gaussian');
	return
end

if isa(fracrej,'double')           %training

	x = +target_class(x);     % only use the target class
	[n,dim] = size(x);

	% call the function:
	options.alpha = 1-fracrej;
	options.cor = 1; % a robust corr. matrix will be returned...
	options.lts = []; % display nothing!
   warning off MATLAB:eigs:NoEigsConverged;
	res = fastmcd(x,options);
   warning on MATLAB:eigs:NoEigsConverged;

	% invert the covariance matrix:
	sinv = inv(res.cov);

	% get the distances on the training set:
	X = +x - repmat(res.center,n,1);
	d = sum((X*sinv).*X,2);
	
	% Obtain the threshold:
	thr = dd_threshold(d,1-fracrej);

	%and save all useful data:
	W.m = res.center;
	W.sinv = sinv;
	W.threshold = thr;
	%W = mapping(mfilename,'trained',W,str2mat('target','outlier'),dim,2);

	% actually, we can just call 'gauss_dd' now!
	W = mapping('gauss_dd','trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'Minimum Covariance Determinant Gaussian');

else
	error('Evaluation of mcd_gauss_dd is treated by gauss_dd!');
end
return


