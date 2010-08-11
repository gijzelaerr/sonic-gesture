%DKCENTER_DD Distance k-center data description.
% 
%       W = DKCENTER_DD(D,FRACREJ,K)
% 
% Train a k-center method with K prototypes on distance dataset D.
% 
% See also datasets, mappings, dd_roc, kcenter_dd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = dkcenter_dd(D,fracrej,K,nrtries)

if nargin < 4, nrtries = 25; end
if nargin < 3 | isempty(K), K = 5; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(D) % empty nndd
	W = mapping(mfilename,{fracrej,K,nrtries});
	W = setname(W,'K-Centers data description');
	return
end


if ~ismapping(fracrej)           %training

	% make sure a is an OC dataset
	if ~isocset(D)
		error('I expect a one-class dataset');
	end
	k = size(D,2);

	% train it:
	D(1:(k+1):end) = 0;  % *sigh* 
	[lab,J,dmin] = kcentres(D,K,nrtries);

	% obtain the threshold:
	% set the diagonal to inf:
	%D(1:(k+1):end) = inf;
	d = sqrt(min(D(:,J),[],2));
	thr = dd_threshold(d,1-fracrej);

	%and save all useful data:
	W.J = J;
	W.threshold = thr;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Dist. K-Centers data description');

else                               %testing

	W = getdata(fracrej);  % unpack
	m = size(D,1);

	%compute:
	newout = [sqrt(min(D(:,W.J),[],2)) repmat(W.threshold,m,1)];

	% store the distance as output:
	W = setdat(D,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return


