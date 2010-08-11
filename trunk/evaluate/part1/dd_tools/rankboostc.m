function W = rankboostc(a,fracrej,T)
%RANKBOOSTB Binary rankboost
%
%    W = RANKBOOSTC(A,FRACREJ,T)
%
% Train a simple binary version of rankboost containing T weak
% classifiers. The base (weak) classifiers only threshold a single
% feature.
%
% See also  dd_auc, auclpm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Take care of empty/not-defined arguments:
if nargin < 3 T = 10; end
if nargin < 2 fracrej = 0.1; end
if nargin < 1 | isempty(a) 
	% When no inputs are given, we are expected to return an empty
	% mapping:
	W = mapping(mfilename,{fracrej,T});
	% And give a suitable name:
	W = setname(W,'Rankboost (T=%d)',T);
	return
end

if ~ismapping(fracrej)           %training

	%some other magic parameter: reduce the maximum weight to:
		maxW = 1e6;

	[m,k] = size(a);
	y = 2*getnlab(a)-3;
	Ipos = find(y==+1);  % target
	Ineg = find(y==-1);  % outlier
	Npos = length(Ipos);
	Nneg = length(Ineg);

	%the weights per pair can be decomposed by an outer product on
	%vectors nu:
	nu(Ipos,1) = 1/Npos;
	nu(Ineg,1) = 1/Nneg;

	% some warning, we will get confused by zero-variance directions:
	% then we might suddenly get a good score, just by the fact that the
	% original objects were well ordered in the dataset
	Izerovariance = find(var(a)<=eps);
	if ~isempty(Izerovariance)
		warning('Some features have zero variance; they will be ignored.');
	end

	%now train T weak rankers:
	for i=1:T
		% recompute the weights per pair
		D = repmat(nu(Ipos),1,Nneg).*repmat(nu(Ineg)',Npos,1);
		% train the weak ranker
		w(i) = weakrank(a,D,Izerovariance);
		% find its weight
		if abs(w(i).r)<1
			w(i).alf = 0.5*log(1+w(i).r) - 0.5*log(1-w(i).r+10*eps);
			if w(i).alf > maxW, w(i).alf=maxW; end
			if w(i).alf <-maxW, w(i).alf=-maxW; end
		else
			if w(i).r==1 % perfect solution, good order:
				w(i).alf = +maxW;
			else %w(i).r==-1, perfecto solution, negative order:
				w(i).alf = -maxW;
			end
		end
		% find the classifier output
		h = (+a(:,w(i).featnr)>w(i).threshold);
		% update the weights
		n1 = nu(Ipos).*exp(-w(i).alf*h(Ipos));
		nu(Ipos) = n1/sum(n1);
		n2 = nu(Ineg).*exp(+w(i).alf*h(Ineg));
		nu(Ineg) = n2/sum(n2);

		% If it is perfectly separable, in principle we should stop, It
		% think. But I am lazy and I just restart it:
		if w(i).r==1
			%disp('reset');
			nu(Ipos) = 1/Npos;
			nu(Ineg) = 1/Nneg;
		end
	end

	% now evaluate the training set for the threshold:
	out = zeros(Npos,1);
	for i=1:length(w)
		out = out + w(i).alf*(+a(Ipos,w(i).featnr)>w(i).threshold);
	end
	thr = dd_threshold(out,fracrej);

	% store the results
	W.w = w;
	W.threshold = thr;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Rankboost (T=%d)',T);

else                               %testing

	% Unpack the mapping and dataset:
	W = getdata(fracrej);
	[m,k] = size(a); 

	% the boosting is a sum over simple feature-threshold classifiers:
	out = zeros(m,1);
	for i=1:length(W.w)
		out = out + W.w(i).alf*(+a(:,W.w(i).featnr)>W.w(i).threshold);
	end

	% store the outcome, and pack it nicely:
	out = [out repmat(W.threshold,m,1)];
	W = setdat(a,out,fracrej);
	W = setfeatdom(W,{[0 inf] [0 inf]});

end

return


function w = weakrank(a,D,Izerovariance)
%   W = WEAKRANK(A,D)
%
% Weak ranker, it only thresholds a single feature from dataset A.
% Matrix D contains the weights for each point-pair.
if nargin<3
	Izerovariance = [];
end

[nra,n] = size(a);
y = getoclab(a);
Ipos = find(y==+1);  % target
Ineg = find(y==-1);  % outlier
% the weights pi:
p(Ipos) = -sum(D,2);
p(Ineg) = sum(D,1)';
% possible thresholds:first sort the data
[sa,I] = sort(+a,1);
% then re-sort also the pi:
pI = p(I);
% find the r,
r = cumsum(pI);
% suppress the features with zero variance:
if ~isempty(Izerovariance)
	r(:,Izerovariance) = 0;
end
% find the best feature and threshold
[mxr,J] = max(abs(r));
% j is the feature number
[Rmax,j] = max(mxr);
% J is the threshold number
J = J(j);
% find the fitting threshold
if J>=nra
	thr = sa(nra,j);
else
	thr = (sa(J,j)+sa(J+1,j))/2;
end
% store it
w.featnr = j;
w.threshold = thr;
w.r = r(J,j);
w.alf = 0;

return
