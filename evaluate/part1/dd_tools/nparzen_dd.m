%NPARZEN_DD Naive Parzen data description.
% 
%       W = nparzen_dd(A,fracrej)
% 
% Fit a Parzen density on each individual feature in dataset A and
% multiply the results for the final density estimate. This is similar
% to the Naive Bayes approach used for classification.
% The threshold is put such that fracrej of the target objects is
% rejected.
% 
%       W = parzen_dd(A,fracrej,h)
% 
% If the width parameter is known, it can be given as third parameter,
% otherwise it is optimized using parzenml.
% 
% See also parzen_dd, dd_roc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = nparzen_dd(a,fracrej,h)

if nargin < 3, h = []; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) 
	W = mapping(mfilename,{fracrej,h});
	W = setname(W,'NaiveParzen');
	return
end

if ~ismapping(fracrej)           %training

	% Make sure a is an OC dataset:
	a = target_class(a);
	k = size(a,2);

	% Train it:
	if (nargin<3) | (isempty(h))
		for i=1:k
			h(i) = parzenml(+a(:,i));
			%DXD BAD patch!!
			% When the dataset contains identical objects, or when it
			% contains discrete features, the optimization of h using LOO
			% will fail. h -> NaN. If that is the case, I patch it and
			% replace h(i) by a small value
			% Actually, in the future I should implement that the features
			% are discrete (so, define it in the dataset) and use a
			% discrete probability density here.
			if ~isfinite(h(i))
				h(i) = 1e-12; 
			end
		end
	end
	% check if h is not the correct size:
	if length(h)~=k
		error('NParzen_dd expects k smoothing parameters');
	end

	% Get the mappings:
	w = {};
	for i=1:k
		w{i} = mapping('parzen_map','trained',{a(:,i), h(i)}, 'target',1,1);
	end
	% Map the training data and obtain the threshold:
	d = zeros(size(a));
	for i=1:k
		d(:,i) = +(a(:,i)*w{i});
	end
	s = warning('off'); % these annoying 0 densities...
		p = sum(log(d),2);
	warning(s);
	thr = dd_threshold(p,fracrej);

	%and save all useful data:
	W.w = w;
	W.h = h;
	W.threshold = thr;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'NaiveParzen');

else                               %testing

	W = getdata(fracrej);  % unpack
	[m,k] = size(a);

	%compute:
	d = zeros(size(a));
	for i=1:k
		d(:,i) = +(a(:,i)*W.w{i});
	end
	s = warning('off'); % these annoying 0 densities...
		out = sum(log(d),2);
	warning(s);
	newout = [out, repmat(W.threshold,m,1)];

	% Store the density:
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[0 inf] [0 inf]});
end
return


