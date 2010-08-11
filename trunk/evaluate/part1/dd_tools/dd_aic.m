function e = dd_aic(w,x)
%DD_AIC compute the Akaike Information Criterion for MoG
%
%      E = DD_AIC(W,X)
%
% Compute the Akaike Information Criterion of the Mixture of
% Gaussians. We assume we have a trained classifier W and data X.
%
% Also see: dd_error, dd_roc, dd_auc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Note: smaller values of aic are good...

% Compute the probability
p = x*w; p = +p(:,1);

% Depending on the model, the AIC is different;
switch getmapping_file(w)
	case 'gauss_dd'
		nrparam = d + d*(d+1)/2;  %mean and cov.matrix
   	
	case 'parzen_dd'
		param = 1;   %width parameter
    
	case 'mog_dd'
		W = getdata(w);
		c = size(W.m,1);
		[n,d] = size(x);

		% determine what type of covariance matrices we have:
		ctype = ndims(W.c);
		if ((ctype==2)&(size(W.c,2)==1))
			ctype = 1;
		end

		% the number of parameters
		% for all covariance versions, the priors and the means are the same:
		nrparam = c + c*d;
		switch ctype
		case 1  % sphere covariance matrix
			nrparam = nrparam + c;
		case 2  % diagonal covariance matrix
				nrparam = nrparam + c*d;
		case 3  % full covariance matrix
			nrparam = nrparam + c*d*(d+1)/2;
		otherwise
			error('Type of covariance matrix not recognized')
		end
	otherwise
		error('AIC cannot be computed for this mapping!');
end

% For the loglikelihood:
e = -2*sum(log(p)) + 2*nrparam;
%strangely this one does not seem to work!:
%e = -2*sum(log(sum(p,2))) + 2*nrparam/n;

return
