%NNDD Nearest neighbour data description method.
% 
%       W = NNDD(A,FRACREJ)
% 
% Calculates the Nearest neighbour data description. Training only
% consists of the computation of the resemblance of all training
% objects to the training data using Leave-one-out.
%
% WARNING: this method is basically a wrapper around dnndd, which is the
% nearest neighbor directly on distance data. In NNDD the squared
% Euclidean distance is used.
% 
% See also knndd, datasets, mappings, dd_roc, dnndd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = nndd(a,fracrej)

if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) % empty nndd
	W = mapping(mfilename,{fracrej});
	W = setname(W,'Nearest neighbour data description');
	return
end

if ~ismapping(fracrej)           %training

	a = +target_class(a);      % make sure we have a OneClass dataset
	[m,k] = size(a);

	% Compute distance matrix and remove zero distances:
	distmat = sqeucldistm(a,a);
	large_D = max(distmat(:));
	small_D = 1.0e-10;           % almost zero distance
	distmat = distmat + large_D*(distmat<small_D); %surpress 0 dist.

	% Now go to the dnndd:
	w = dnndd(distmat,fracrej);

	% and save all useful data:
	W.w = w;
	W.x = +a;
	W.threshold = w.data.threshold;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Nearest neighbour data description');

else                               %testing

	W = getdata(fracrej);  % unpack
	m = size(a,1);

	%compute:
	distmat = +sqeucldistm(+a,W.x);
	out = +(distmat*W.w);

   % and return it nicely
	W = setdat(a,out,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return
