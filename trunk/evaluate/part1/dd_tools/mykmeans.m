%MYKMEANS K-means clustering
%
%      [LABS,MEANS] = MYKMEANS(X,K)
%
% Place K centers in the data X using the k-means procedure.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [labs,means,err] = mykmeans(x,k,errtol)

if nargin<3
  errtol = 1e-5;
end

% init:
[n,d] = size(x);

% use k random objects as initialization
I = randperm(n);
means = x(I(1:k),:);

% label all objects:
D = distm(x,means);
[mn, labs] = min(D,[],2);

% the reconstruction error:
err = sum(mn);
olderr = 10*err;

% update the means until the error does not change
while ((olderr-err)>errtol*err)

	% update the means:
	for i=1:k
		I = find(labs==i);
		if length(I)>0
			means(i,:) = mean(x(I,:),1);
		end
	end
	% relabel all objects:
	D = sqeucldistm(x,means);
	[mn, labs] = min(D,[],2);
	% the error:
	olderr = err;
	err = sum(mn);
end

return
