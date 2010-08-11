%SVDD_OPTRBF  Quadratic optimizer for the SVDD
%
%    [ALF,R2,DX,I] = SVDD_OPTRBF(SIGMA,X,LABX,C)
%
% Quadratic optimizer for the SVDD. Preferably called by svdd.m.
%
% Given the dataset X with labels LABX, and the parameters SIGMA and C the
% quadratic optimization is performed, and the resulting weights ALF and R2
% are returned. Upon request, also the distances of the training objects X to
% the center DX are returned, and the indices of the support vectors I.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [alf,R2,Dx,I] = svdd_optrbf(sigma,x,labx,C);

% Setup the parameters for the optimization:
nrx = size(x,1);
K = exp(-distm(x,x)/(sigma*sigma));
D = (labx*labx').*K;
f = labx.*diag(D);
% Make sure D is positive definite:
i = -30;
while (pd_check(D + (10.0^i)*eye(nrx)) == 0)
	i = i+1;
end
i = i+5;
D = D + (10.0^i)*eye(nrx);

% Equality constraints:
A = labx';
b = 1.0;

% Lower and upper bounds:
lb = zeros(nrx,1);
if length(C)>2
	ub = C;
else
	ub = lb;
	ub(find(labx==1)) = C(1);
	ub(find(labx==-1)) = C(2);
end

% Initialization (not sure if this is really necessary):
rand('seed', sum(100*clock));
p = [ 0.5*rand(nrx,1) ];

% These procedures *maximize* the functional L
if (exist('qld') == 3)
	alf = qld (2.0*D, -f, -A, b, lb, ub, p, 1);
else
	opt = optimset; opt.LargeScale='off'; opt.Display='off';
	alf = quadprog(2.0*D,-f,[],[],A,b,lb,ub,p,opt);
end

% So we found the alpha's, check the results
if (isempty(alf))
	warning('dd_tools:OptimFailed','No solution for the SVDD could be found.');
	alf = ones(nrx,1)/nrx;
end

% Important: change sign for negative examples:
alf = labx.*alf;

% The support vectors and errors:
I = find(abs(alf)>1e-8);

% Distance to center of the sphere (ignoring the offset):
Dx = - 2*sum( (ones(nrx,1)*alf').*K, 2);

% Threshold squared radius:
borderx = I(find((alf(I) < ub(I))&(alf(I) > 0)));
if (size(borderx,1)<1)  % hark hark
	borderx = I;
end
% Although all support vectors should give the same results, sometimes
% they do not.
R2 = mean(Dx(borderx,:));

% Set all nonl-support-vector alpha to 0
J = find(abs(alf)<1e-8);
alf(J) = 0.0;


return


