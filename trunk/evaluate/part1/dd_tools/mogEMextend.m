function [means,invcovs,priors] = mogEMextend(b,covtype,means,invcovs,priors,maxiter)
%MOGEMEXTEND Extend a MoG with one cluster and apply EM
%
%    [MEANS,INVCOVS,PRIORS] = MOGEMEXTEND(X,COVTYPE,MEANS,INVCOVS,PRIORS,
%                             NRITERS)
%
% Add one cluster to the MOG and apply Expectation-Maximization to
% update the MEANS, INVCOVS and PRIORS on the dataset X. Maximally
% NRITERS iterations are performed.
%
% See also: mog_extend, mog_P, mogdd, mog_init, mog_update

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


if ~strcmp(covtype,'full')
	error('Sorry, not defined for other than FULL covariance matrices');
end

% initialize
[n,d] = size(b);
f = sum(mog_P(b,covtype,means,invcovs,priors),2);
% and another magic parameter:
k = size(means,1);
MAXPROB = 1/(k+1);

% fixed sigm
E = max(eig(cov(b)));
sig = 0.5*E*(4/((d+2)*n))^(1/(d+4));

% make a speedup for the computation of the new models phi
kij = ((2*pi*sig*sig)^(-d/2)) * exp(-0.5*sqeucldistm(b,b)/(sig*sig));

% define the delta:
F = repmat(f,1,n);
fmin = F-kij;
fplus = F+kij;
delta = fmin./fplus;
% find the improvements
L = sum(log(fplus/2),1) + 0.5*sum(delta,1).^2/sum(delta.^2,1);
[Lmax,maxi] = max(L);
%heeheee we have it:
mb = b(maxi,:);
cb = sig*sig*eye(d);
alf = 0.5-0.5*sum(delta(:,maxi))/sum(delta(:,maxi).^2);

% start the loop:
iter = 1;
LL1 = 2*Lmax;
LL2 = Lmax;
% update loop:
while (abs(LL2/LL1-1)>1e-6) & (iter<=maxiter)
	% compute the densities
	aphi = alf*gausspdf(b,mb,cb);
	Ptotal = (1-alf)*f + aphi;

	% follow the progress
	iter = iter+1;
	LL1=LL2;
	LL2=sum(log(Ptotal));
	
	% compute the memberships
	P = aphi./Ptotal;
	alf = mean(P,1);
	
	%HMMM, limit the size of the new cluster:
	if alf>MAXPROB, alf=MAXPROB; end

	% and update the other parameters
	mb = mean(repmat(P,1,d).*b,1)/alf;
	dff = (b - repmat(mb,n,1)).*sqrt(repmat(P,1,d));
	cb = inv((dff'*dff)/(n*alf));
end
% We are done, check if we have a sensible outcome:
if iter>maxiter
	warning('dd_tools:ConvergenceFailed','Maximum number of iterations reached');
end

% Update the data and store it back in the mapping:
priors = (1-alf)*priors;
priors = [priors; alf];
means = [means; mb];
invcovs(end+1,:,:) = cb;

return
