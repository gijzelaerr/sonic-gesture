%DNNDD Distance nearest neighbour data description method.
% 
%       W = dnndd(D,fracrej)
% 
% Calculates the Nearest neighbour data description on distance data.
% Training only consists of the computation of the resemblance of all
% training objects to the training data using Leave-one-out.
% 
% See also datasets, mappings, dd_roc, nndd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = dnndd(D,fracrej)

if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(D) % empty nndd
	W = mapping(mfilename,{fracrej});
	W = setname(W,'Distance Nearest neighbour dd');
	return
end

if ~ismapping(fracrej)           %training

%	D = +target_class(D);      % make sure we have a OneClass dataset
	[m,k] = size(D);

	% Apply leave-one-out on the training set:
	fit = zeros(m,1);
	for i=1:m
		tmpD = D;
		[minD minI] = min(tmpD(i,:));  % dist. from z to 1NN in A
		tmpD(i,minI) = inf;
		intdist = min(tmpD(:,minI));   % dist. from 1NN to NN(1NN)
		fit(i) = minD./intdist;
	end
	% Now we can obtain the threshold:
	thresh = dd_threshold(fit,1-fracrej);
	% and save all useful data:
	W.threshold = thresh;
	W.fit = fit;
	W.D = min(D,[],2);
	W.scale = mean(fit);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Nearest neighbour data description');

else                               %testing

	W = getdata(fracrej);  % unpack
	m = size(D,1);

	%compute:
	[mindist I] = min(D,[],2); % find the closest dist.
	out = [mindist./(W.D(I)) repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(D,-out,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return
