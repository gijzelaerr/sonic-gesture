function out = dist2dens(in,sigm)
%DENS_EST map a distance to a posterior probability
%
% out = dist2dens(in,sigm)
%
% Map the output of a reconstruction method to a posterior
% probability:
%     out=exp(-in/sigm)
% Per default sigm = mean(in).

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<2
	sigm = mean(in);
end

out = exp(-in/sigm);

return
