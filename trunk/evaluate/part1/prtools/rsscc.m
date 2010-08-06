%RSSCC Random subspace combining classifier
%
%    W = RSSCC(A,CLASSF,NFEAT,NCLASSF)
%
% INPUT
%   A       Dataset
%   CLASSF  Untrained base classifier
%   NFEAT   Number of features for training CLASSF
%   NCLASSF Number of base classifiers
% 
% OUTPUT
%   W       Combined classifer
%
% DESCRIPTION
% This procedure computes a combined classifier consisting out of NCLASSF
% base classifiers, each trained by a random set of NFEAT features of A.
% W is just the set of base classifiers and still needs a combiner, e.g.
% use W*MAXC or W*VOTEC.
%
% SEE ALSO
% DATASETS, MAPPINGS, PARALLEL

function w = rsscc(a,classf,nfeat,nclassf)

if nargin < 4, nclassf = []; end
if nargin < 3, nfeat   = []; end
if nargin < 2, classf = nmc; end
if nargin < 1 | isempty(a)
	w = mapping(mfilename,'untrained',{classf,nfeat,nclassf});
	w = setname(w,'rsscc');
elseif isuntrained(classf) % training
	isvaldset(a,1,1);
	[m,k] = size(a);
	if isempty(nfeat)
		nfeat = max(round(m/10),2); % use at least 2D feature spaces
	end
	if isempty(nclassf)
		nclassf = max(ceil(k/nfeat),10); % use at least 10 classifiers
	end
	nsets = ceil(nfeat*nclassf/k);
	featset = [];
	for j=1:nsets
		featset = [featset, randperm(k)];
	end
	featset = featset(1:nfeat*nclassf);
	featset = reshape(featset,nclassf,nfeat);
	
	w = [];
	for j=1:nclassf
		w = [w; a(:,featset(j,:))*classf];
	end
	w = mapping(mfilename,'trained',{w,featset},getlablist(a),k,getsize(a,3));
else % execution, trained classifier stored in classf
	wdata = getdata(classf);
	w = wdata{1};
	featset = wdata{2}';
	w = a(:,featset(:))*w;
end
	
	
		