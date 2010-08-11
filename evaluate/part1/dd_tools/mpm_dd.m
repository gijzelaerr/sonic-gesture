%MPM_DD Minimax prob. machine.
%
%      W = MPM_DD(X,FRACREJ,SIGMA,LAMBDA)
%
% Computes the minimax probability machine of Lanckriet, using the RBF
% kernel with kernel-width SIGMA and quantile FRACREJ. It tries to find
% the linear classifier that separates the data from the origin,
% rejecting maximally FRACREJ of the target data. Unfortunately, it does
% not really work, and the rejection threshold is actually re-derived
% from the target data.
%
% For this method an inverse of the covariance matrix is required, and
% that might be regularized. This regularisation constant is LAMBDA.
%
%      W = MPM_DD(X,FRACREJ,SIGMA,LAMBDA,NU,RHO)
%
% The method can be made a bit more robust by introducing NU>0 and RHO>0
% that allow to move the mean and covariance matrix around a bit. (See
% their paper in NIPS2002)
%
% See also: svdd, lpdd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


function W = mpm_dd(a,fracrej,sigm,ep,nu,rho)

% Take care of empty/not-defined arguments:
if nargin < 6 rho = 0.0; end
if nargin < 5 nu = 0.0; end
if nargin < 4 ep = 1e-6; end
if nargin < 3 sigm = 1; end
if nargin < 2 fracrej = 0.05; end
if nargin < 1 | isempty(a) 
	% When no inputs are given, we are expected to return an empty
	% mapping:
	W = mapping(mfilename,{fracrej,sigm,ep,nu,rho});
	% And give a suitable name:
	W = setname(W,'Minimax probability machine');
	return
end

if ~ismapping(fracrej)           %training

	a = target_class(a);     % only use the target class
	[m,dim] = size(a);

	% train it:
	wk = myproxm(a,'r',sigm);
	kalf = sqrt(fracrej/(1-fracrej));
	K = +(a*wk);
	k = mean(K,1);
	L = (K- repmat(k,m,1))/sqrt(m);
	M = L'*L + rho*K;
	if ep>0
		invM = inv(M + ep*eye(m));
	else
		invM = pinv(M);
	end
	tmp = invM*k';
	xi = sqrt(k*tmp);
	gamma = tmp/(xi*(xi-kalf-nu));

	% probably we have to recompute the threshold, because this sucks:
	d = sum(repmat(gamma',m,1).*K,2);
	b = dd_threshold(d,fracrej);
	
	%and save all useful data in a structure:
	W.wk = wk;
	W.gamma = gamma;
	W.threshold = b;  % a threshold should *always* be defined
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'Minimax probability machine');

else                               %testing

  % Unpack the mapping and dataset:
  W = getdata(fracrej);
  [m,k] = size(a); 

  % Compute the output:
  Kz = +(a*W.wk);
  out = sum(repmat(W.gamma',m,1).*Kz,2);

  newout = [out repmat(W.threshold,m,1)];

  % Fill in the data, keeping all other fields in the dataset intact:
  W = setdat(a,newout,fracrej);
  W = setfeatdom(W,{[0 inf] [0 inf]});
end
return


