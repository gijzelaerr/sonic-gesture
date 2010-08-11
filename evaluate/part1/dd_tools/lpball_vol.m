function v = lpball_vol(par,x,fracrej,takelog)
%LPBALL_VOL Volume L_p ball
%
%        V = LPBALL_VOL(PAR,X,FRACREJ)
%
% Compute the volume V of the L_p ball in n-D. The radius is the distance
% from the center of the ball to the 1-FRACREJ percentile of dataset X.
% The parameter PAR contains the P in the Lp distance and the mean MN:
%         PAR = [P MN];
%
% See also: lpball_dd, lpball_distmean, svdd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<4
	takelog = 1;
end
if nargin<3
	fracrej = 0;
end

[N,n] = size(x);

p = par(1);
a = par(2:n+1);
a = a(:)';
if length(a)~=n
	error('Mismatch dim. of x and center a');
end

goodp = exp(p);
diff = abs(x - repmat(a,N,1)).^goodp;
diff = sum(diff,2).^(1/goodp);
r = dd_threshold(diff,1-fracrej);

if takelog
	v = n*log(r) + n*log(2) + n*gammaln(1+1./goodp) - gammaln(1+n./goodp);
else
	v = ((r*2*gamma(1+1/goodp))^n)/(gamma(1+n/goodp));
end

return
