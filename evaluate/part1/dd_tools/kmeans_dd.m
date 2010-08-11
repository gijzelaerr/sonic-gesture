%KMEANS_DD k-means data description.
% 
%       W = KMEANS_DD(A,FRACREJ,K)
% 
% Train a k-means method with K prototypes on dataset A. Parameter
% fracrej gives the fraction of the target set which will be rejected.
% 
% Optionally, one may give the error tolerance as last argument as
% stopping criterion.
% 
% See also knndd, kcenter_dd, som_dd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function [W,out] = kmeans_dd(a,fracrej,K,errtol)

if nargin < 4,  errtol = 1e-5; end
if nargin < 3 | isempty(K), K = 5; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) % empty dd
	W = mapping(mfilename,{fracrej,K,errtol});
	W = setname(W,'K-Means data description');
	return
end

if ~ismapping(fracrej)           %training

	a = +target_class(a);     % make sure a is an OC dataset
	k = size(a,2);

	% train it:
	[labs,w] = mykmeans(a,K,errtol);

	% obtain the threshold:
	d = sqrt(min(sqeucldistm(a,w),[],2));
	if (size(d,2)~=1)
		d = d';
	end
	thr = dd_threshold(d,1-fracrej);

	%and save all useful data:
	W.w = w;
	W.threshold = thr;
	W.scale = mean(d);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'K-Means data description');

else                               %testing

	W = getdata(fracrej);  % unpack
	m = size(a,1);

	%compute:
	out = [sqrt(min(sqeucldistm(+a,W.w),[],2)) repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(a,-out,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end

return

