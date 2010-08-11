%BALL_DD L_p ball description
%
%    W = BALL_DD(X,FRACREJ,P)
%
% Fit a L_p ball around the data X by optimizing the weights:
%      min w_0
%      s.t. \sum_j w_j|x_ij-a_j|^p <= w_0
%           \sum_j w_j = 1,   w_j>=0
% The vector a is taken as the mean of dataset X.
%
% When the (feature-) weigths w are optimized, the threshold w_0
% is set such that FRACREJ of the objects are outside the L_p ball.
%
% As a precaution, features with no variance will be removed/ignored,
% otherwise a trivial solution of only using that feature is found. You
% will get a warning though.
%
% See also lpdd, svdd, myproxm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = ball_dd(a,fracrej,p)

% Take care of empty/not-defined arguments:
if nargin < 3 p = 1; end
if nargin < 2 fracrej = 0.05; end
if nargin < 1 | isempty(a) 
	% When no inputs are given, we are expected to return an empty
	% mapping:
	W = mapping(mfilename,{fracrej,p});
	% And give a suitable name:
	W = setname(W,'Box one-class classifier');
	return
end

if ~ismapping(fracrej)           %training

	a = target_class(a);     % only use the target class
	[m,k] = size(a);

	% train it:
	x = +a;
	mn = +mean(x);
	x = x - repmat(mn,m,1);
	x = abs(x).^p;  % something like a L_p distance

	% check if all the features do something:
	orgk = k;
	I = find(var(x)<=1e-9);
	if ~isempty(I)
		warning('dd_tools:ZeroVarFeature',...
			'Removed the features with zero variance!');
		x(:,I) = [];
		k = orgk - length(I);
	end

	% setup the LP:
	f = [zeros(1,k) 1]';
	A = [    x    -ones(m,1)];
	b = zeros(m,1);
	%	  -eye(k)  zeros(k,1)   zeros(k,m)];
	%b = zeros(m+k,1);
	Aeq = [ones(1,k) 0];
	beq = 1;
	lb = zeros(k+1,1);
	ub = repmat(inf,k+1,1);

	% optimize it:
	if (exist('glpkmex')>0)
		ctype = [repmat('S',size(Aeq,1),1);
					repmat('U',size(A,1),1)];
		vartype = repmat('C',size(f,1),1);
		[w,fmin] = glpkmex(1,f,[Aeq;A],[beq;b],ctype,lb,ub,vartype);
	else
		w = linprog(f,A,b,Aeq,beq,lb,ub);
	end
	% use the k features and make a row vector
	thr = w(k+1);
	w = w(1:k);
	w = w(:)';

	% get the distances:
	d = sum(x.*repmat(w,m,1),2);
	thr = dd_threshold(d,1-fracrej);

	%and save all useful data in a structure:
	W.threshold = thr;
	W.mn = mn;
	W.w = w;
	W.p = p;
	W.I = I;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),orgk,2);
	W = setname(W,'Box one-class classifier');

else %testing

	% Unpack the mapping and dataset:
	W = getdata(fracrej);
	[m,k] = size(a); 

	% Remove the mean:
	a_mn = +a - repmat(W.mn,m,1);
	% Remove pointless features (found in training):
	if ~isempty(W.I)
		a_mn(:,W.I) = [];
	end
	% Compute that strange L-p:
	a_mn = abs(a_mn).^W.p;

	% Find the distance:
	out = sum(a_mn.*repmat(W.w,m,1),2);

	newout = [out repmat(W.threshold,m,1)];

	% Fill in the data, keeping all other fields in the dataset intact:
	W = setdat(a,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return


