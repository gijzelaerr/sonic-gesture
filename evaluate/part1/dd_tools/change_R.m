function R = change_R(R,c,beta,gammac)
% R = change_R(R,c,beta,gammac)
% 
% Auxiliary function for the incremental SVDD, see there.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Note that n is one larger than set S, because of the
% added parameter b at the beginning!
n = size(R,1);

% In some unfortunate cases the gamma_c can be very very small (like 0),
% and in these cases we don't want to blow up the whole thing. Therefore
% we define a small eps and define that as the smallest gamma_c
% possible.
smalleps = 1e-12;

if c>0                          % we add object c to R
	if abs(gammac)>smalleps
		R = [R zeros(n,1); zeros(1,n+1)] + ...
			([beta;1]/gammac)*[beta' 1];
		% Improve the numerical stability (overflow) for large beta and
		% gammac, by first dividing by gammac and then multiplying again
		% by beta.
		% Fix suggested by Mauro Del Rio
	else
		warning('dd_tools:change_R:DivideByZero','We are about to divide by 0.');
		R = [R zeros(n,1); zeros(1,n+1)] + ...
			([beta;1]/(sign(gammac)*smalleps))*[beta' 1];
	end
else                       % we remove object c from R
	c = -c; % ok, get rid of the sign
	Irm = [1:c,c+2:n];
	if R(c+1,c+1)>smalleps  % whatever...
		R = R(Irm,Irm) - R(Irm,c+1)*R(c+1,Irm)/R(c+1,c+1);
	else
		R = R(Irm,Irm) - R(Irm,c+1)*R(c+1,Irm)/smalleps;
	end
end
