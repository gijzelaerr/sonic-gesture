%ROB_GAUSS_DD Robust Gaussian data description.
% 
%       W = ROB_GAUSS_DD(A,FRACREJ)
% 
% Fit a robust Gaussian density on dataset A. The algorithm is taken
% from 
%  Huber, P.J. "Robust Statistics", John Wiley&Sons, 1981, pg 238
%
% To be perfectly honest, there are some personal choices for some weighting
% factors, which might be important. I have no real idea what the most optimal
% settings would be, but the ones here seem to work reasonably well...
% 
% See also dd_roc, gauss_dd, mcd_gauss_dd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = rob_gauss_dd(x,fracrej,etol)

if nargin < 3 | isempty(etol),  etol = 1e-3; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(x) 
	W = mapping(mfilename,{fracrej,etol});
	W = setname(W,'Robust Gaussian description');
	return
end

if ~ismapping(fracrej)           %training

	x = +target_class(x);     % only use the target class
	[nrx,dim] = size(x);

	% initialize:
	t = mean(x);
	S = cov(x-repmat(t,nrx,1));
	[B,p] = chol(S);
	if (p~=0)
		error(sprintf('Just %d (of %d) dimensions non-singular!\n',p,dim));
	end
	V = inv(B);
	W = zeros(dim,dim);
	h = 1000*ones(1,dim); % is this an appropriate 'bad' initial.?

	% repeat until the covariance and mean update vanishes
	while (norm(W-eye(dim))>etol) | (norm(h*V)>etol)

		% Robust estimate of C (sigma of normalized data)
		y = (x-repmat(t,nrx,1))*V;
		leny = sqrt(sum(y.*y,2));  %(length of vectors y)

		%         Put here your own definition of u(leny):
		u = ones(nrx,1); 
		sy = u./(leny.*leny);
		symat = repmat(sy,1,dim);
		%         Put here your own definition of v(leny):
		%vy = 1e-8*ones(nrx,1);  % does not work
		vy = sy;                % does work
		%vy = sqrt(leny);        % does not work
		C =  (symat.*y)'*y / mean(vy);

		% update the V  (sigma=inv(V*V'))
		[B,p] = chol(C);
		W = inv(B);
		V = V*W;

		mx = repmat(t,nrx,1);
		y = (x-mx)*V;
		leny = sqrt(sum(y.*y,2));

		%          Put here your own definition of w(leny):
		%wy = ones(nrx,1);
		wy = 1./sqrt(+leny);  % this + is to avoid a Matlab bug.
		wymat = repmat(wy,1,dim);

		h = mean( wymat.*(x-mx)) / mean(wy);

		t = t+h;
	end
	sig = inv(V'*V);

	% obtain the threshold:
	p = mahaldist(x,t,sig);
	thr = dd_threshold(p,1-fracrej);

	%and save all useful data:
	W.m = t;
	W.sinv = V'*V;
	W.threshold = thr;
	%  W = {+mu,sig,thr,mean(d)};
	W = mapping('gauss_dd','trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'Robust Gaussian description');

else                               %testing

	error('The evaluation of rob_gauss_dd is taken care of by gauss_dd');

end
return


