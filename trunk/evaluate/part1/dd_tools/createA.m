function [A,Nxi,A2] = createA(X,y,rtype,par,seed)
% [A,Nxi,A2] = CREATEA(X,Y,RTYPE,PAR,SEED)
%
% Create the data matrix containing all pairwise difference vectors in
% data matrix X (with their corresponding labels Y, -1/+1).
% Because the size of this data matrix can become huge (ALL pairwise
% difference vectors is a lot!), you can subsample it by choosing an
% appropriate RTYPE.
%
%  RTYPE 'full'   use all constraints
%        'subs'   randomly subsample PAR constraints 
%        'subk'   randomly subsample a fraction PAR of the constraints
%        'knn'    use the PAR nearest neighbors in the other class
%        'xval'   subsample and use remaining constraints to optimize C
%        'xvalk'  subsample a fraction k*n and use remaining constraints
%                 to optimize C
%        'kmeans' use k-means clustering with k=PAR
%        'randk'  subsample objects to get PAR*(Npos+Nneg) constraints
%
% The SEED is optional, it is the seed for the random sampling.
%
if nargin<5
	seed = [];
end
% If a seed is defined, set it:
if ~isempty(seed)
	rand('state',seed);
end

A2 = [];
%---create A for optauc

k = size(X,2);

% compute how many xi-s we expect:
Ineg = find(y==-1);
Ipos = find(y==+1);
Nneg = length(Ineg);
Npos = length(Ipos);

% depending on the reduction type
switch rtype
case 'full'  % take all the possibilities:
	Nxi = Nneg*Npos;
	A = zeros(Nxi,k);
	% run over all possibilities:
	dummyk=0;
	for i=1:Nneg
		for j=1:Npos
			dummyk = dummyk+1;
			A(dummyk,:) = X(Ineg(i),:)-X(Ipos(j),:);
		end
	end
case 'subk'  % subsample the possibilities, but now not a fixed number,
	%but k times the number of training objects:
	Nxi = ceil(par*size(X,1));
	A = zeros(Nxi,k);
	Ip = floor(Npos*rand(Nxi,1))+1; Ip = Ip(1:Nxi);
	In = floor(Nneg*rand(Nxi,1))+1; In = In(1:Nxi);
	for i=1:Nxi
		diffx = X(Ineg(In(i)),:) - X(Ipos(Ip(i)),:);
		A(i,:) = diffx;
	end
case 'subs'  % subsample the possibilities:
	Nxi = par;
	A = zeros(Nxi,k);
	Ip = floor(Npos*rand(Nxi,1))+1; Ip = Ip(1:Nxi);
	In = floor(Nneg*rand(Nxi,1))+1; In = In(1:Nxi);
	for i=1:Nxi
		diffx = X(Ineg(In(i)),:) - X(Ipos(Ip(i)),:);
		A(i,:) = diffx;
	end
case 'knn'  % only use the k nearest neighbors
	Nxi = ceil((Nneg+Npos)*par);
	A = zeros(Nxi,k);
	% first process all the neg. examples:
	D = sqeucldistm(X(Ineg,:),X(Ipos,:));
	[dummy,I] = sort(D,2);
	dummyk = 0;
	for i=1:Nneg
		for j=1:par
			thispos = I(i,j);
			diffx = X(Ineg(i),:)-X(Ipos(thispos),:);
			dummyk = dummyk+1;
			A(dummyk,:) = diffx;
		end
	end
	% then to all the pos. examples:
	D = D';  % (no need to recompute D)
	[dummy,I] = sort(D,2);
	for i=1:Npos
		for j=1:par
			thispos = I(i,j);
			diffx = -X(Ipos(i),:)+X(Ineg(thispos),:);
			dummyk = dummyk+1;
			A(dummyk,:) = diffx;
		end
	end
case 'randk'  % randomly chosen objs such that you have k(Npos+Nneg)
	           % constraints
	q = sqrt(par*(Npos+Nneg)/(Npos*Nneg));
	qpos = ceil(q*Npos); qneg = ceil(q*Nneg);
	Nxi = qpos*qneg;
	A = zeros(Nxi,k);

	% first select the neg. examples:
	I = randperm(Nneg); In = Ineg(I(1:qneg));
	% then select the pos. examples:
	I = randperm(Npos); Ip = Ipos(I(1:qpos));
	% run over all possibilities:
	dummyk=0;
	for i=1:qneg
		for j=1:qpos
			dummyk = dummyk+1;
			A(dummyk,:) = X(In(i),:)-X(Ip(j),:);
		end
	end
case 'xval'  % take all the possibilities and use part for testing:
	Nxi = Nneg*Npos;
	A = zeros(Nxi,k);
	% run over all possibilities:
	dummyk=0;
	for i=1:Nneg
		for j=1:Npos
			diffx = X(Ineg(i),:)-X(Ipos(j),:);
			dummyk = dummyk+1;
			A(dummyk,:) = diffx;
		end
	end
	% get part of data for constraints, the rest for evalation:
	I = randperm(Nxi);
   if par>=size(A,1)
		warning(sprintf('More constraints requested than available (%d and %d)',par,size(A,1)));
		disp('Now using half for training and testing');
		par = ceil(size(A,1)/2);
	end
	% if data is really really huge, then subsample more...
	Mega=100000;
	if length(I)-par>Mega
		A2 = A(I((par+1):(par+Mega)),:);
	else
		A2 = A(I((par+1):end),:);
	end
	A = A(I(1:par),:);
	Nxi = par;
case 'xvalk'  % take all the possibilities and use part for testing:
	par = par*size(X,1);
	Nxi = Nneg*Npos;
	A = zeros(Nxi,k);
	% run over all possibilities:
	dummyk=0;
	for i=1:Nneg
		for j=1:Npos
			diffx = X(Ineg(i),:)-X(Ipos(j),:);
			dummyk = dummyk+1;
			A(dummyk,:) = diffx;
		end
	end
	% get part of data for constraints, the rest for evalation:
	I = randperm(Nxi);
   if par>=size(A,1)
		warning(sprintf('More constraints requested than available (%d and %d)',par,size(A,1)));
		disp('Now using half for training and testing');
		par = ceil(size(A,1)/2);
	end
	% if data is really really huge, then subsample more...
	Mega=100000;
	if length(I)-par>Mega
		A2 = A(I((par+1):(par+Mega)),:);
	else
		A2 = A(I((par+1):end),:);
	end
	A = A(I(1:par),:);
	Nxi = par;
case 'kmeans'
	wp = kmeans_dd(X(Ipos,:),0.1,par);
	wn = kmeans_dd(X(Ineg,:),0.1,par);
	Xp = wp.data.w;
	Xn = wn.data.w;
	Nxi = par*par;
	A = zeros(Nxi,k);
	dummyk=0;
	for i=1:par
		for j=1:par
			diffx = Xn(i,:)-Xp(j,:);
			dummyk = dummyk + 1;
			A(dummyk,:) = diffx;
		end
	end
otherwise
	error(sprintf('Type %s is not defined',rtype));
end

return
