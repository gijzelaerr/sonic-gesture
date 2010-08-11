function W = dlpdd(x,nu,usematlab)
%DLPDD Distance Linear Programming Data Description
%
%       W = DLPDD(D,NU)
%
% This one-class classifier works directly on the distance (dissimilarity) 
% matrix D(X,R). Every entry of D is a dissimilarity between an object from 
% X and an object from R. X consists either of target examples or of both
% target and outlier examples. The same holds for R, however, for logical
% reasons, it might be better if R contains the targets only.
% The distance matrix D does not need to be square. The distance itself 
% does not need to be metric.
%
% The DLPDD is constructed as a hyperplane in the so-called dissimilarity
% space D(X,R), such that it is attracted towards the origin. The data are,
% therefore, suppressed from above by this hyperplane. See the reference 
% paper for details. 
%
% The NU parameter gives the fraction of error on the target set. 
% If NU = 0 and D is a square target distance matrix, then DLPDD and DLPDDA 
% tend to give the same results.
%
% Although it is more or less assumed that the data is in the positive quadrant, 
% you can put other data in as well and see how it may or may not work.
%
% EXAMPLE: 
% X = OC_SET(GENDATB([40 20]),'1');
% I = FIND_TARGET(X);
% D = SQRT(DISTM(X,X(I,:)));		% R <-- X(I,:), D is now 60 x 40
% W = DLPDD(D,0.05);
%
% SEE ALSO: 
% LPDD, DD_EX5, DLPDDA
%
% @inproceedings{Pekalska2002,
%	author    = {Pekalska, E. and Tax, D.M.J. and Duin, R.P.W.},
%	title     = {One-class {LP} classifier for dissimilarity representations},
%	booktitle = {Advances in Neural Information Processing Systems},
%	year      = {2003},
%	pages     = {761-768},
% editor    = {S.~Becker and S.~Thrun and K.~Obermayer},
% volume    = {15},
% publisher = {MIT Press: Cambridge, MA}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% first set up the parameters
if nargin < 3, usematlab = 0; end
if nargin < 2 | isempty(nu), nu = 0.05; end
if nargin < 1 | isempty(x) % empty
	W = mapping(mfilename,{nu,usematlab});
	W = setname(W,'Distance Linear Programming Distance-data description');
	return
end

% training
if ~ismapping(nu)

	% work directly on the distance matrix
	[n,d] = size(x);

	% maybe we have example outliers...
	if isocset(x)
		labx = getoclab(x);
	else
		labx = ones(n,1);
	end
	x = +x; % no dataset please.
	% scale the distances to avoid numerical issues (thanks Ela!):
	sc = mean(x(:));
	x = x./sc;

	% set up the LP problem:
  if (nu > 0) & (nu <= 1),  % allow error on the training data
		C = 1./(n*nu);
		f = [1 -1 zeros(1,d) repmat(C,1,n)]';
		A = [-labx labx repmat(labx,1,d).*x  -eye(n)];
		b = zeros(n,1); 
		Aeq = [0 0 ones(1,d) zeros(1,n)];
		beq = 1;
		N = n + d + 2;
		lb = zeros(N,1);
		ub = repmat(inf,N,1);
  elseif nu == 0,       % don't allow errors on the training data
		f = [1 -1 zeros(1,d)]';
		A = [-labx labx repmat(labx,1,d).*x];
		b = zeros(n,1); 
		Aeq = [0 0 ones(1,d)];
		beq = 1;
		N = d + 2;
		lb = zeros(N,1);
		ub = repmat(inf,N,1);
  else
		error ('Illegal nu.');
  end

	% optimize::
	if (exist('glpkmex')>0) & (usematlab==0)
		% the cplex optimizer:
		ctype = [repmat('S',size(Aeq,1),1);
		         repmat('U',size(A,1),1)];
		vartype = repmat('C',size(f,1),1);
		[alf,fmin] = glpkmex(1,f,[Aeq;A],[beq;b], ctype, lb,ub, vartype);
	else
		% or the good old Matlab optimizer:
		alf = linprog(f,A,b,Aeq,beq,lb,ub);
	end

	% store the results
	paramalf = alf(3:2+d);
	W.I = find(paramalf>1e-8);
	W.w = paramalf(W.I);
	W.sc = sc;
	W.threshold = alf(1)-alf(2)+1e-12;

	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	W = setname(W,'Distance Linear Programming Distance-data description');

else                               %testing

	% get the data:
	W = getdata(nu);
	m = size(x,1);

	% and here we go:
	D = +x(:,W.I)./W.sc;
	% annoying prtools:
	newout = [D*W.w repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(x,-newout,nu);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return



