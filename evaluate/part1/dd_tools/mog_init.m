function [means,invcovs,priors] = mog_init(x,k,covtype,dataSigma,reg)
%MOG_INIT Initialize a MoG
%
%    [MEANS,INVCOVS,PRIORS] = MOG_INIT(X,K,COVTYPE)
%
% Initialize a mixture of Gaussians on dataset X, using K clusters. 
% By setting CTYPE, the covariance structure of the covariance can be
% set. There are three possibilities:
%      COVTYPE = 'sphr'  : diagonal cov. matrix with equal values
%      COVTYPE = 'diag'  : diagonal cov. matrix
%      COVTYPE = 'full'  : full cov. matrix
%
%    [MEANS,INVCOVS,PRIORS] = MOG_INIT(X,K,CTYPE,DATASIGMA)
%
% When DATASIGMA is given, it is assumed that the first cluster should
% model the uniform background. The mean of this cluster is fixed to the
% mean of dataset X, and the covariance matrix is fixed to DATASIGMA.
%
% See also: mog_dd, mog_update, mog_P

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<5)
	reg = 0.01;
end
if (nargin<4)
	dataSigma = [];
end

if isa(x,'dataset')
	x = +x;
end

% Initialize the stuff:
[n,d] = size(x);
if (n<k)
	warning('dd_tools:InsufficientData',...
		'More clusters than objects requested.');
end
if isempty(dataSigma)
	COVWIDTH = mean(diag(cov(+x)));
else
	COVWIDTH = mean(diag(dataSigma));
end
reg = COVWIDTH*reg;
LARGE_S = 10;

% Now distinguish the case that we want to model the background class
% with a wide covariance matrix, or only model target data:
if ~isempty(dataSigma)
	% we want to model the outlier cluster

	% this also means that we want to have one extra cluster:
	k = k+1;

	if (n==1)
		% there is no outlier data available, so we have to fake some
		% distribution:
		means = repmat(x,k,1) + 0.01*COVWIDTH*randn(k,d);
		priors = repmat(1/k,k,1);
		switch covtype
		case 'sphr'
			invcovs = repmat(1/(LARGE_S*COVWIDTH),k,1);
		case 'diag'
			invcovs = repmat(1./(LARGE_S*diag(dataSigma))',k,1);
		case 'full'
			for i=1:k
				invcovs(i,:,:) = inv(LARGE_S*dataSigma + reg*COVWIDTH*eye(d));
			end
		end
	else
		% there is some outlier data, but we also want to fix the first
		% cluster

		% First make a fixed first cluster:
		means = mean(x);
		priors = 1;
		switch covtype
		case 'sphr'
			invcovs = 1/(LARGE_S*COVWIDTH);
		case 'diag'
			invcovs = 1./(LARGE_S*diag(dataSigma))';
		case 'full'
			invcovs = shiftdim(inv(LARGE_S*dataSigma),-1);
		end

		% Next fit on the outlier data we already have:
		if k>1
			[newmeans, newinvcovs, newpriors] = mog_init(x,k-1,covtype,[],reg);
			% and add it to the fixed first cluster:
			means = [means; newmeans];
			priors = [priors/2; newpriors/2];
			invcovs = cat(1,invcovs,newinvcovs);
		end
	end
else
	% we only want to model the target data
	if (k<1)
		error('At least one cluster has to be defined');
	end

	%random start means, and make sure that each cluster has some
	%members:
	I = randperm(n);
	means = x(I(1:k),:);
	D = sqeucldistm(x,means);
	[md,I] = min(D,[],2);
	nr_x_i = sum(full(ind2vec(I))',1);
	while (length(nr_x_i)<k) | any(nr_x_i==0)
		warning('dd_tools:insufficientclusters',...
		   'One of the clusters did not receive any members');
		I = randperm(n);
		means = x(I(1:k),:);
		D = sqeucldistm(x,means);
		[md,I] = min(D,[],2);
		nr_x_i = sum(full(ind2vec(I))',1);
	end

	%priors
	priors = nr_x_i(:)./sum(nr_x_i);

	% Set up the covariance matrix:.
	switch covtype
	case 'sphr'
		if (k==1)
			invcovs = 1/COVWIDTH;
		else
			sD = sort(sqeucldistm(means,means));
			covs = sD(2,:)';
			covs(covs<eps) = COVWIDTH;
			invcovs = 1./covs;
		end
	case 'diag'
		covs = zeros(k,d);
		for i=1:k
			x_i = x(find(I==i),:);
			dif = x_i - repmat(means(i,:),size(x_i,1),1);
			covs(i,:) = sum(dif.*dif)/nr_x_i(i);
		end
		covs(covs<eps) = COVWIDTH;
		invcovs = 1./covs;
	case 'full'
		invcovs = zeros(k,d,d);
		for i=1:k
			x_i = x(find(I==i),:);
			dif = x_i - repmat(means(i,:),size(x_i,1),1);
			covs = (dif'*dif)/nr_x_i(i);
			invcovs(i,:,:) = inv(covs + COVWIDTH*eye(d));
		end
	end
end

return
