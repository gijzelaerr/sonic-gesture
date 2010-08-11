%SOM_DD Self-Organizing Map data description
%
%           W =  SOM_DD(X,FRACREJ,K)
%
% Train a 2D SOM on dataset X. In K the size of the map is defined. The
% map can maximally be 2D. When K contains just a single value, it is
% assumed that a 1D map should be trained.
%
% For further features of SOM_DD, see som.m (the same parameters
% NRRUNS, ETA and H can be added).
%
% Default: K=[5 5]
%
% See also: pca_dd, kmeans_dd, som

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = som_dd(x,fracrej,k,nrruns,eta,h)

if nargin <6 | isempty(h)
	h = [0.6 0.2 0.01];
end
if nargin <5 | isempty(eta)
	eta = [0.5 0.3 0.1];
end
if nargin <4 | isempty(nrruns)
	nrruns = [20 40 40];
end
if nargin < 3 k = [5 5]; end
if nargin < 2 fracrej = 0.05; end
if nargin < 1 | isempty(x) 
	W = mapping(mfilename,{fracrej,k,nrruns,eta,h});
	W = setname(W,'Self-organising Map data description');
	return
end

if ~ismapping(fracrej)           %training

	x = +target_class(x);     % only use the target class
	[nrx,dim] = size(x);

	% Now, all the work is being done by som.m:
	w = som(x,k,nrruns,eta,h);
	w = +w;  % can you still follow it?
	w = w.w;
	% Now map the training data:
	mD = min(sqeucldistm(x,w),[],2);
	thresh = dd_threshold(mD,1-fracrej);

	% And save all useful data:
	W.threshold = thresh;  % a threshold should always be defined
	W.k = k;  %(only for plotting...)
	W.w = w;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'Self-organising Map data description');
else
    
	W = getdata(fracrej); %unpack
	m = size(x,1); 

	% compute the distance to the nearest neuron in the map:
	mD = min(sqeucldistm(+x,W.w),[],2);
	newout = [mD repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(x,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end

return


