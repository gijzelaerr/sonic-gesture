%PARZEN_DD Parzen data description.
% 
%       W = parzen_dd(A,fracrej)
% 
% Fit a Parzen density on dataset A. The threshold is put such that
% fracrej of the target objects is rejected.
% 
%       W = parzen_dd(A,fracrej,h)
% 
% If the width parameter is known, it can be given as third parameter,
% otherwise it is optimized using parzenml.
% 
% See also datasets, mappings, dd_roc, nparzen_dd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = parzen_dd(a,fracrej,h)

if nargin < 3, h = []; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) 
	W = mapping(mfilename,{fracrej,h});
	W = setname(W,'Parzen');
	return
end

if ~ismapping(fracrej)           %training

	% Make sure a is an OC dataset:
	a = target_class(a);
	k = size(a,2);

	% Train it:
	if (nargin<3) | (isempty(h))
		h = parzenml(a);
	end
	%DXD parzendc expects at least 2 classes nowadays, that's ok, we
	%now just have to do it ourselves:
	%w = parzendc(a,h);
	w = mapping('parzen_map','trained',{a,h}, getlablist(a),k,1);

	% Obtain the threshold:
	d = +(a*w);
	thr = dd_threshold(d,fracrej);

	%and save all useful data:
	W.w = w;
	%(Strictly speaking h is already stored in w, but for inspection
	%reasons I still want to have it here:)
	W.h = h;
	W.threshold = thr;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Parzen');

else                               %testing

	W = getdata(fracrej);  % unpack
	m = size(a,1);

	%compute:
	out = +(a*W.w);
	newout = [out, repmat(W.threshold,m,1)];

	% Store the density:
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[0 inf] [0 inf]});
end
return


