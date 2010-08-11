%KWHITEN Whiten the data in kernel space.
% 
%       W = kwhiten(A,DIM,KTYPE,PAR1)
% 
% Apply a kernel PCA to dataset A and retain DIM dimensions, or a
% fraction DIM of the total variance. The data A is then rescaled to
% unit variance in the feature space. The kernel space is defined by
% the kernel function KTYPE, with the free parameter PAR1. The types
% of kernels are defined in myproxm.m.
% 
%       W = kwhiten(A,DIM,KTYPE,PAR1,REG)
% 
% In some cases the kernel matrix has to be regularized. In that case
% the parameter REG has to be given.
% 
% See also datasets, mappings, myproxm
%
%@conference{Tax2002,
%	author = {Tax, D.M.J. and Juszczak, P.},
%	title = {Kernel whitening for one-class classification},
%	booktitle = {International workshop on pattern recognition with support vector machines},
%	year = {2002},
%	address = {Niagara Falls, Canada}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function [W,orglambda] = kwhiten(a,dim,ktype,par1,reg)

if nargin < 5, reg = []; end
if nargin < 4, par1 = 2; end
if nargin < 3, ktype = 'p'; end
if nargin < 2 | isempty(dim), dim = 0.95; end
if nargin < 1 | isempty(a) 
	W = mapping(mfilename,{dim,ktype,par1,reg});
	W = setname(W,'Kernel Whiten mapping');
	return
end

if nargin>2
	if ~isa(ktype,'char')
		error('Expecting a string for the kernel type (did you forget dim?)!');
	end
end

if isa(dim,'double')           %training

	%x = +target_class(a);     % only use the target class
	x = a;                    % apply it to all the data
	[m,k] = size(x);

	% Train it:
	wK = myproxm(x,ktype,par1);
	K = +(a*wK);
	% Hm hm, maybe some regularization?:
	if ~isempty(reg)
		K = K + eye(m)*reg;
	end
	W.Korg = K;  % we have to store this for later.
	K = center(K,K);
	% Find eigenvectors and eigenvalues:
	[alf,D] = eig(K);
	lambda = abs(diag(D));
	% Sort them according to size:
	[sl,I] = sort(-lambda);
	lambda = lambda(I);
	alf = alf(:,I);
	% Ok, have eigenvalues larger than 0 or get a specific number of
	% dimensions:  (magic)
	orglambda = lambda;
	if (dim<1)
		I = find(cumsum(lambda)>(dim*sum(lambda)));
		dim = I(1);
	end
	% Take only these dimensions:
	if (dim>size(alf,2))
		warning('dd_tools:InsufficientFeatures',...
			'Requested more dims than available!');
		dim = size(alf,2);
	end
	I = (1:dim);
	alf = alf(:,I);
	lambda = lambda(I);
	% Normalize the eigen vectors;
	alength = sum(alf.*alf,1);  % in matlab already normalized a.a=1
	ascale = sqrt(m-1)./(lambda'.*sqrt(alength));
	alf= repmat(ascale,m,1).*alf;

	%and save all useful data:
	W.wK = wK;
	W.alf = alf;
	W = mapping(mfilename,'trained',W,[],k,length(I));
	W = setname(W,'Kernel Whiten mapping');

else                               %testing/mapping

	W = getdata(dim);  % unpack
	[m,k] = getsize(a);

	% Compute the mapping
	n = size(W.alf,2);
	% Compute the kernel matrix and center it
	K = +(a*W.wK);
	K = center(K,W.Korg);
	% Map the data on the eigenvectors:
	mapped = zeros(m,n);
	for i=1:n
		mp = repmat(W.alf(:,i)',m,1).*K;
		mapped(:,i) = sum(mp,2);
	end

	W = setdat(a,mapped,dim);
end
return


