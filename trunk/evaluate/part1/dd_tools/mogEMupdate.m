function [means,invcovs,priors] = mogEMupdate(x,covtype,means,invcovs,priors,nriters,fixedcl,reg)
%MOGEMUPDATE Apply EM to a MoG
%
%    [MEANS,INVCOVS,PRIORS] = MOGEMUPDATE(X,COVTYPE,MEANS,INVCOVS,PRIORS,...
%                             NRITERS)
%
% Apply Expectation-Maximization to update the MEANS, INVCOVS and PRIORS on
% the dataset X. NRITERS iterations are performed.
%
%    [MEANS,INVCOVS,PRIORS] = MOGEMUPDATE(X,MEANS,INVCOVS,PRIORS,NRITERS,...
%                             FIXEDCL)
% When FIXEDCL=1, the first cluster will fixed, so no updates on its
% position, shape or prior will be made. This is used to model a uniform
% background distribution.
%
% See also: mog_P, mog_dd, mog_init, mog_update

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<8) | isempty(reg)
  reg = 0.01;
end
if (nargin<7) | isempty(fixedcl)
	fixedcl = [];
end
if (nargin<6) | isempty(nriters)
  nriters = 100;
end

% initialize the stuff:
[n,d] = size(x);
k = length(priors);
COVWIDTH = mean(diag(cov(+x)));
reg = COVWIDTH*reg;
if ~isempty(fixedcl) & (fixedcl>0)
	clear fixedcl;
	fixedcl.mean = means(1,:);
	switch covtype
	case 'sphr'
		fixedcl.icov = invcovs(1);
	case 'diag'
		fixedcl.icov = invcovs(1,:);
	case 'full'
		fixedcl.icov = invcovs(1,:,:);
	end
else
	fixedcl = [];
end
MINPB = 1/k;
%MINPB = 0;

% startup for the loop:
iter = 1;
LL1 = -2e6;
LL2 = -1e6;

% now we start to optimize:
while (abs(LL2/LL1-1)>1e-6) & (iter<=nriters)

	% calculate the old P:
	P = mog_P(x,covtype,means,invcovs,priors);

	% remember the LL:
	iter = iter+1;
	LL1 = LL2;
	LL2 = sum(log(sum(P,2)));

	% normalize P:
	sumP = sum(P,2);
	sumP(sumP==0) = 1;
	normP = P./repmat(sumP,1,k);

	% update the params:
	new_priors = sum(normP,1)';
	I = find(new_priors==0);
	new_priors(I) = realmin*10;
	new_means = normP' * x;

	% thus:
	priors = new_priors/n;
	% make sure that the global outlier cluster does not disappear:
	if ~isempty(fixedcl) & (1==1)
		if priors(1)<MINPB % the cluster becomes too small
			% rescale all priors slightly lower and add the rest to the
			% main cluster:
			priors = priors * (1+priors(1)-MINPB)/sum(priors(2:end));
			priors(1) = MINPB;
		end
	end
	% normalize the means
	means = new_means ./ repmat(new_priors,1,d);
	% update the covariance matrices
	switch covtype
   case 'sphr'
		D = sqeucldistm(x,means);
      news = zeros(k,1);
      for i=1:k
        news(i) = (normP(:,i)'*D(:,i));
      end
      covs = (news./new_priors')/d + reg*ones(k,1);
		invcovs = 1./covs;
	case 'diag'
      for i=1:k
			dif = x - ones(n,1)*means(i,:);
			invcovs(i,:) = sum(dif.*dif.*repmat(normP(:,i),1,d))./new_priors(i) +...
				reg*ones(1,d);
      end
		invcovs = 1./invcovs;
   case 'full'
      for i=1:k
			dif = (x - repmat(means(i,:),n,1)) .* sqrt(normP(:,i)*ones(1,d));
			invcovs(i,:,:) = inv((dif'*dif)/new_priors(i) + reg*eye(d));
      end 
   otherwise
      error('Unknown covariance type requested.');
	end

	% If we train with using outlier data, reset the first cluster to cover
	% the whole dataset:
	if ~isempty(fixedcl)
		means(1,:) = fixedcl.mean;
		switch covtype
		case 'sphr'
			invcovs(1) = fixedcl.icov;
		case 'diag'
			invcovs(1,:) = fixedcl.icov;
		case 'full'
			invcovs(1,:,:) = fixedcl.icov;
		end
	end
end

if iter>nriters
	warning('dd_tools:ConvergenceFailed','Maximum number of iterations reached');
end
if isempty(fixedcl) & abs(sum(priors)-1)>1e-6
	warning('dd_tools:OptimFailed','Something went wrong in the EM optimization: priors do not sum to 1.');
end

return


function v=ind2vec(i)

vectors = length(i);
v = sparse(i,1:vectors,ones(1,vectors));

return
