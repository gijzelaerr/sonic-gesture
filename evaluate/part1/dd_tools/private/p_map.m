%PARZEN_MAP Map a dataset on a Parzen densities based classifier
% 
% 	F = p_map(A,W)
% 
% Maps the dataset A by the Parzen density based classfier W. It
% outputs just the raw class probabilities (i.e. non-normalized).
% W should be trained by a 
% classifier like parzenc. This routine is called automatically to 
% solve A*W if W is trained by parzenc. Furthermore it checks if the
% testing data is the same as the training data. When a point equal to
% a training point is tested, this training point is temporary removed
% and only the other (N-1) objects are used.
% 
% The global PRMEMORY is read for the maximum size of the internally 
% declared matrix, default inf.
% 
% See also mappings, datasets, parzenc, testp

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function F = p_map(T,W)
if nargin < 2, W = parzenc(T); end
[a,classlist,type,k,c,v,h] = mapping(W);
%if ~strcmp(type,'parzen_map') 
%	error('Wrong type of classifier')
%end
[nlab,lablist,m,k,c,p] = dataset(a);
p = p(:)';
h = h(:)';
[mt,kt] = size(T);
if kt ~= k, error('Wrong feature size'); end

if length(h) == 1, h = h * ones(1,c); end
if length(h) ~= c
	error('Wrong number of smoothing parameters')
end
maxa = max(max(abs(a)));
if size(a)==size(T) & sum(sum(a-T))==0
  withtrset = 1;
else
  withtrset = 0;
end
%a = a/maxa;
%T = T/maxa;
%h = h/maxa;
alf=sqrt(2*pi)^k;
[num,n] = dd_mem(mt,m);
F = ones(mt,c);
for j = 0:num-1
	if j == num-1
		nn = mt - num*n + n;
	else
		nn = n;
	end
	range = [j*n+1:j*n+nn];
	D = distm(a,T(range,:));
  if withtrset % avoid overtraining on training set.
    D(i*n+1:n+1:i*n+nn*n) = inf*ones(1,nn);
  end
	for i=1:c
		I = find(nlab == i);
		if length(I) > 0
			F(range,i) = mean(exp(-D(I,:)*0.5./(h(i).^2)),1)';
		end
	end
end
F = F.*repmat(p./(alf.*h.^k),mt,1);
%if max(h) ~= min(h)	% avoid this when possible (problems with large k)
%	F = F.*repmat(p./(h.^k),mt,1);
%else
%	F = F.*repmat(p,mt,1);
%end
%F = F + realmin;
%F = F ./ (sum(F')'*ones(1,c));
%F = invsig(F);
[nlab,lablist,m,k,c,p,lablistp,imheight] = dataset(T);
F = dataset(F,getlab(T),classlist,p,lablist,imheight);
return
