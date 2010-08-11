function [W,startc] = Wstartup(x, y, C, kernel, kpar)
% W = Wstartup(x, y, C, kernel, kpar)
%
% Start the incremental Support vector data description. It puts the
% data in a global matlab matrix, initializes all sets and gives the
% first basic solution, using the minimum number of objects for which
% the constraints can be satisfied. All variables are stored in a
% structure, containing the following fields:
%    x, y
%    kernel,
%    C, tol,
%    alf, b, grad, R,
%    setR, setS, setE, Kr, Ks, Ke
%
% Unfortunately, there is still some ugly code for generating
% intermediate plots. Maybe this will be removed later.
%
% See also: incsvdd, inckernel, Wadd, svdd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


% initialize
global X_incremental;      % hm, probably the best??
X_incremental = [];
W.x = 'global';             % the data with labels
n = size(x,1);
W.y = y;
W.kernel = kernel;   % the kernel with the parameters
W.kpar = kpar;
W.C = C;
W.tol = 1e-12;       % tolerance to say alf = 0;
%W.alf = zeros(n,1);  % weights
W.alf = zeros(0,1);
W.b = 0;
W.grad = [];         % the gradients of seen objects
W.R = [];
W.setR = [];         % the set indices
W.setS = 0;
W.setE = [];
W.Kr = [];           % the kernel matrices
W.Ks = [];
W.Ke = [];

% ok, a bit of trickery, to set up variables such that constraints are
% fullfilled:
if W.C>=1
  % assume all labels are +1, and C>1  (DXD)
  X_incremental = x(1,:);
  W.y = 1;
  W.setS = 1;
  W.setE = [];          % error set
  W.Ke = [];            % kernel matrix of the error objects(ExS)
  K = feval(W.kernel,W.kpar,1,1);
  W.Ks = [0 W.y(1); W.y(1) 2*K];
  W.alf(1) = 1;
  W.b = -W.Ks(2,2)/2;  % make sure gradient of object 1 = 0
  W.grad = 0;
  W.R = inv(W.Ks);
  start_c = 2;
else
  % now we are more brave, and try C<1
  N = floor(1/W.C); % we need at least N+1 objects to satisfy sum_i \ai=1
  X_incremental = x(1:(N+1),:);
  W.y = y(1:(N+1));

  % the weights:
  set0 = (1:(N+1))';
  W.alf(set0,1) = [repmat(W.C,N,1); 1-N*W.C];
  % the gradient:
  K = feval(W.kernel,W.kpar,set0,set0);
  W.grad = 2*K*W.alf(set0) - diag(K);
  % set b such that for the bounded objects, the gradient is 0 or
  % smaller:
  W.b = -max(W.grad(1:(end-1))) - W.tol;  %DXD: OOPS
  %W.b = -max(W.grad);
  % update the gradient therefore:
  W.grad = W.grad + W.b.*W.y(set0);
  % set up the sets:
  W.setS = [];
  W.setE = (1:N)';
  W.setR = [];
  % the kernel caches:
  W.Ks = 0;
  W.Ke = [];
  W.Kr = [];
  % update R:
  W.R = inf;
  c = N+1;

  W = Wadd(W,[],[],1);
  start_c = N+2;
end
%alf

% We added upto start_c objects. Now we have to add the rest:
for c=start_c:n
	if ((n>1000) & (mod(c,10)==0)), fprintf('%d/%d\t',c,n); end
	W = Wadd(W,x(c,:),y(c));
end
return
