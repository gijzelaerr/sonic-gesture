%KCENTER_DD k-center data description.
% 
%       W = kcenter_dd(A,fracrej,K)
% 
% Train a k-center method with K prototypes on dataset A.
% 
% See also kmeans_dd, som_dd, dd_roc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = kcenter_dd(a,fracrej,K,nrtries)

if nargin < 4, nrtries = 25; end
if nargin < 3 | isempty(K), K = 5; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) % empty nndd
	W = mapping(mfilename,{fracrej,K,nrtries});
	W = setname(W,'K-Centers data description');
	return
end


if ~ismapping(fracrej)           %training

	a = +target_class(a);     % make sure a is an OC dataset
	k = size(a,2);

	% train it:
	D = sqrt(sqeucldistm(a,a));
	w = dkcenter_dd(target_class(D),fracrej,K,nrtries);

	%and save all useful data:
	W.w = w;
	W.train_a = a;
	W.threshold = w.data.threshold;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'K-Centers data description');

else                               %testing

	W = getdata(fracrej);  % unpack

	%compute:
	D = sqrt(sqeucldistm(+a,+W.train_a));
	newout = +(D*W.w);

	% Store the distance as output (note that the 'w' already took care
	% of the minus-sign for the distance):
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return


