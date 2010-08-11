function W = dlpdda(x,nu,usematlab)
%DLPDDA Distance Linear Programming Data Description attracted by the Average distance
%
%       W = DLPDDA(D,NU)
%
% This one-class classifier works directly on the distance (dissimilarity) 
% matrix D(X,R). Every entry of D is a dissimilarity between an object from 
% X and an object from R. X consists either of target examples or of both
% target and outlier examples. The same holds for R, however, for logical
% reasons, it might be better if R contains the targets only.
% The distance matrix D does not need to be square. The distance itself 
% does not need to be metric.
%
% The DLPDDA is constructed as a hyperplane in the so-called dissimilarity
% space D(X,R), such that it is attracted towards the average dissimilarity 
% output of the hyperplane. The data are still suppressed from above by 
% this hyperplane. This one-class classifier is inspired by the Campbell 
% and Bennett paper below. The setup of DLPDDA is similar to DLPDD, explained
% in our reference paper. 
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
% W = DLPDDA(D,0.05);
%
% SEE ALSO: 
% LPDD, DD_EX5, DLPDD
%
%@inproceedings{Campbell2000,
% author    = {Campbell, C. and Bennett, K.P.},
% title     = {A Linear Programming Approach to Novelty Detection},
% year      = {2000},
% pages     = {395-401},
% booktitle = {Advances in Neural Information Processing Systems}
% publisher = {MIT Press: Cambridge, MA}
%}
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

% Copyright: E. Pekalska, D. Tax, d.m.j.tax@ewi.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands


% first set up the parameters
if nargin < 3, usematlab = 0; end
if nargin < 2 | isempty(nu), nu = 0.05; end
if nargin < 1 | isempty(x) % empty
	W = mapping(mfilename,{nu});
	W = setname(W,'DLPDDA');
	return
end

% training
if ~ismapping(nu)

	% work directly on the distance matrix
	[n,d] = size(x);
%	if (n~=d)
%		error('I was expecting a square distance matrix!');
%	end

	% maybe we have example outliers...
	if isocset(x)
		labx = getoclab(x);
	else
		labx = ones(n,1);
	end
	x = +x; % no dataset please.


	% set up the LP problem:
  if nu > 0 & nu <= 1,
		C = 1./(n*nu);
		f = [1 -1 -sum(x,1)/d  repmat(C,1,n)]';
		A = [-labx labx repmat(labx,1,d).*x -eye(n)]; 
		b = zeros(n,1);
		Aeq = [0 0 ones(1,d) zeros(1,n)];
		beq = 1;
		N = n + d + 2;
		lb = zeros(N,1);
		ub = repmat(inf,N,1);
  elseif nu == 0,
		f = [1 -1 -sum(x,1)/d]';
		A = [-labx labx repmat(labx,1,d).*x];
		b = zeros(n,1);
		Aeq = [0 0 ones(1,d)];
		beq = 1;
		N = d + 2;
		lb = zeros(N,1);
		ub = repmat(inf,N,1);
  else
    error ('Wrong nu.');
  end

	% optimize::
	if (exist('lp_solve')>0) & (usematlab==0)
		if ~exist('cplex_init')
			% we can have the lp optimizer:
			e = [0; -ones(d,1)];
			[v,alf] = lp_solve(-f,sparse([Aeq;A]),[beq;b],e,lb,ub);
		else
			% the cplex optimizer:
			lpenv=cplex_init;
			disp = 0;
			[alf,y_upd_,how_upd_,p_lp]=...
			lp_solve(lpenv, f, sparse([Aeq;A]), [beq;b], lb, ub, 1, disp);
		end
	else
		% or the good old Matlab optimizer:
		alf = linprog(f,A,b,Aeq,beq,lb,ub);
	end

	% store the results
	paramalf = alf(3:2+d);
	W.I = find(paramalf>1e-8);
	W.w = paramalf(W.I);
	W.threshold = alf(1)-alf(2)+1e-12;

	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),d,2);
	W = setname(W,'DLPDDA');

else                               %testing

	% get the data:
	W = getdata(nu);
	m = size(x,1);

	% and here we go:
	D = +x(:,W.I);
	% annoying prtools:
	newout = [D*W.w repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(x,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return



