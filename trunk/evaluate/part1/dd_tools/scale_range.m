%SCALE_RANGE Give a vector of scales
%
%     SIG = SCALE_RANGE(X,NR)
%
% Give a reasonable range of scales SIG for the dataset X. The largest
% scale is given first. If NR is given, the number of scales is NR.
% This function is useful in consistent_occ.
%
%     SIG = SCALE_RANGE(X,NR,NMAX)
%
% The (reasonable) range of scales is derived from the distance matrix
% computed from dataset X. When X is very large, computing this distance
% matrix is too expensive. Therefore you can subsample to NMAX objects
% before to speedup the process.
% (Thanks Anthony Brew)
%
% Default: NR = 20, NMAX = 100
%
% See also: consistent_occ, parzen_dd, svdd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function sig = scale_range(x,nr,Nmax)

if nargin<3
	Nmax = 100;
end
if nargin<2
	nr = 20;
end

% Ok, if we are working with huge datasets, the distance computation
% will take ages. Therefore just use a subsample:
if size(x,1)>Nmax
	x = gendat(x,Nmax);
end
if isdataset(x)
	x = +x;
end

% Compute the distances
d = sqrt(sqeucldistm(x,x));

% Find the largest and the smallest distance:
dmax = max(d(:));
d(d<=1e-12) = dmax;
dmin = min(d(:));

% ... and compute the range:
%log10 = log(10);
%sig = logspace(log(dmax)/log10,log(dmin)/log10,nr);
sig = linspace(dmax,dmin,nr);

return

