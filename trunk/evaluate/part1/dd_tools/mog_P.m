function p = mog_P(x,covtype,means,invcovs,priors)
%MOG_P Compute the probability density of a Mixture of Gaussians
%
%       P = MOG_P(X,COVTYPE,MEANS,INVCOVS,PRIORS)
%
% Calculate the probability density for all objects X for all of the
% clusters of a mixture of Gaussians, characterized with the MEANS,
% INVCOVS and PRIORS. COVTYPE indicates the shape of the covariance
% matrix, and INVCOVS means that the *inverse* of the covariance
% matrices is used!  see mogdd.
% Note that P is not normalized!
%
% See also: mog_dd, mog_init, mog_update

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Get the useful parameters
[N,d] = size(x);
k = length(priors);
p = zeros(N,k);

% Depending on the covariance matrix, the p is computed differently:
switch covtype
case 'sphr' % Spherical cov. matrices
	D = distm(x,means);
	sig = repmat(0.5*invcovs',N,1);
	Z = (sig/pi).^(d/2);
	p = Z.*exp(-D.*sig);
case 'diag' % Diagonal cov.matrix with unequal variances
	Z = (2*pi).^(-d/2);
	sig = prod(sqrt(invcovs),2);
	for i=1:k
		dif = x - repmat(means(i,:),N,1);
		p(:,i) = Z*sig(i)*exp(-0.5*sum(dif.*dif.*repmat(invcovs(i,:),N,1) ,2));
	end
case 'full' % Complete covariance matrix
	Z = (2*pi).^(-d/2);
	for i=1:k
		dif = x - repmat(means(i,:),N,1);
		c = squeeze(invcovs(i,:,:));
		p(:,i) = sqrt(det(c))*Z*exp(-0.5*sum((dif*c).*dif,2));
	end
otherwise
	error('The inverse covariance matrix parameter is not well-defined');
end

% include the priors:
p = p.*repmat(priors',N,1);

return
