function V = volsphere(d,R,takelog)
%VOLSPHERE Compute the volume of a hypersphere
%
%      V = VOLSPHERE(D,R)
%
% Compute the volume of a hypersphere in D dimensions, with radius R.
%
%      V = VOLSPHERE(D,R,TAKELOG)
%
% If TAKELOG>0 than the log(V) is computed (more useful for computations
% in high dimensional feature spaces)
%
% Default: R=1; TAKELOG=0

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<3
	takelog=0;
end
if nargin<2
	R = 1;
end

if takelog
	V = log(2) + d*log(R*sqrt(pi)) - log(d) - gammaln(d/2);
else
	V = 2*(R*sqrt(pi))^d/(d*gamma(d/2));
end

return
