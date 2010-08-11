function k = knn_optk(D,d)
%KNN_OPTK Optimization of k for the knndd
%
% k = knn_optk(D,d)
%
% Optimize the k for the knndd using leave-one-out density
% estimation. D is the distance matrix of the original data,
% d is the dimensionality of the data.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% avoid zero distances:
smallD = 1e-20;

% find the nearest neighbors in the training set:
n = size(D,1);
D = sort(+D,2);
D(:,1) = []; % smallest distance is always 0: so remove that

% find the volume of the k-nn hypersphere:
logVsph = volsphere(d,1,1);
s = warning('off');  % log of zero is no disaster here...
	logDr = logVsph + d*log(D)/2;
warning(s);
Dr = exp(logDr);
% the density becomes:
Dr(Dr==0) = smallD;
vol = repmat((1:n-1),n,1) ./ Dr;

% And the loglikelihood:
s = warning('off');  % again log of zero is no disaster here...
	vol  = sum(log(vol),1);
warning(s);
% take the maximum:
[maxvol,k] = max(vol);

%vol  = std(log(vol),1)
%[maxvol,k] = min(vol);

return
