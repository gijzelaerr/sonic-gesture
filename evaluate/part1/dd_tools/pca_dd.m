%PCA_DD Principal Component data description
%
%       W = PCA_DD(A,FRACREJ,N)
%
% Traininig of a PCA, with N features (or explaining a fraction N of
% the variance).
%
% Default: N=0.9

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function W = pca_dd(a,fracrej,n)

if (nargin<3)
	n = 0.9;
end
if (nargin<2)
	fracrej = 0.05;
end
if (nargin<1)|isempty(a)
	W = mapping(mfilename,{fracrej,n});
	W = setname(W,'PCA occ');
	return
end

if ~ismapping(fracrej)           %training

	% remove the labels:
	a = target_class(a);     % only use the target class
	[m,k] = size(a);
	% Be careful with the mean:
	meana = repmat(mean(a),m,1);
	a = (a - meana);

	% Train it and compute the reconstruction error:
%	if (n<0) % we requested the low- instead of high-variance directions!
%		% derive the dimenionality
%		if (n<=-1)
%			n = -n;
%		else
%			n = ceil(-n*k)
%		end
%		G = cov(+a);
%		[F,V] = eig(G);
%		a
%		w = pca(a,k)
%		% extract the projection matrix from the eigenvectors:
%		W = w.data.rot(:,(k-n+1):k);
%		W
%	else
	w = pca(a,n);
	W = w.data.rot;
%	end
	dim = size(W,2);
	if dim==k
		warning('dd_tools:NoFeatureReduction',...
			'Output dimensionality is equal to input dimensionality!');
	end
	Proj = W*inv(W'*W)*W';
	% project and find the distribution of the distance:
	dif = a - a*Proj;
	d = sum(dif.*dif,2);

	% obtain the threshold:
	thr = dd_threshold(d,1-fracrej);

	%and save all useful data:
	% (I know I just have to store W instead of Proj, but I do not like
	% to compute the inverse of W'*W over and over again, this uses just
	% some disk/memory space):
	W = [];  % W was already used, forget that one...
	W.P = Proj;
	W.mean = meana(1,:);
	W.dim = dim;  %just for inspection...
	W.threshold = thr;
	W.scale = mean(d);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'PCA occ');

else                               %testing

	W = getdata(fracrej);  % unpack
	m = size(a,1);

	%compute reconstruction error:
	dif = +a - repmat(W.mean,m,1);
	dif = dif - dif*W.P;
	out = sum(dif.*dif,2);
	newout = [out, repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(a,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end

return
