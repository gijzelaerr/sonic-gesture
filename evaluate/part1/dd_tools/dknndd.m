%DKNNDD Distance K-Nearest neighbour data description method.
% 
%       W = DKNNDD(D,FRACREJ,K,METHOD)
% 
% Calculates the K-Nearest neighbour data description on distance
% dataset D.  Two methods are defined to compute a distance to the
% dataset using the k-nearest neighbours:
%
% METHOD     does:
% 'kappa'      use distance to the k-th nearest neighbor
% 'gamma'      average distance to the k-nn's
%
% When no K is defined, it will be optimized using knn_optk, when it
% is smaller than 0, sqrt(n) will be used.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function W = dknndd(D,fracrej,k,method)

if nargin < 4, method = 'kappa'; end
if nargin < 3, k = []; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(D) % empty knndd
	W = mapping(mfilename,{fracrej,k,method});
	W = setname(W,'Dist. K-Nearest neighbour data description');
	return
end

if ~ismapping(fracrej)           %training

	% some checking of datatypes and sizes:
	%D = +target_class(D);  % make sure we have a OneClass dataset
	[m,d] = size(D);
%	if (m~=d)
%		error('In this version I expect a square distance matrix');
%	end
	if (m<2)
		warning([mfilename ': Dataset contains less than 2 objects']);
	end
	if (k>=d)
		error(['More neighbors than training samples are requested! (max=',...
                num2str(d-1),')']);
	end
   if isa(k,'char')
      error('Argument k should define the number of neighbors');
   end
	% is k is not defined, find the optimal k optimizing the loglikelihood:
	if isempty(k)
		k = knn_optk(+D,d);
	else  %tricky, when k<=0 we use the default sqrt(n) solution...
		if (k<=0)
			k = round(sqrt(m));
		end
	end
	if (k<1)
		warning([mfilename ': K must be positive (>0)']);
	end
	[sD,I] = sort(D,2);

	% different treatment by different methods:
	switch method
	case 'kappa'
		fit = sD(:,k+1);  
	case 'gamma'
		fit = mean(sD(:,(2:(k+1))),2);
	otherwise
		error([mfilename,': Unknown method']);
	end

	%now obtain the threshold:
	thresh = dd_threshold(fit,1-fracrej);
	%and save all useful data:
	W.k = k;
	W.method = method;
	W.threshold = thresh;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	W = setname(W,'K-Nearest neighbour data description');

else                               %testing

	W = getdata(fracrej);  % unpack
	[m,d] = size(D);

	%compute:
	[sD,I] = sort(D,2);

	% different treatment by different methods:
	switch W.method
	case 'kappa'
		ind = sD(:,W.k);
		%ind = sD(:,W.k+1);
	case 'gamma'
		ind = mean(sD(:,(1:(W.k))),2);
	otherwise
		error([mfilename,': Unknown method']);
	end

	% store the results in the final dataset:
	out = [ind repmat(W.threshold,[m,1])];

	% and use the distance as output:
	W = setdat(D,-out,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return
