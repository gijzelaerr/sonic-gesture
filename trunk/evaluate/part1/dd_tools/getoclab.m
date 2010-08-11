function lab = getoclab(x)
%GETOCLAB  Get numeric labels from a OC set
%
%    LAB = GETOCLAB(X)
%
% Returns numeric labels of the objects X according to:
%   'target'  : +1
%   'outlier' : -1
% If X is not an oc-set, an error is generated.
%
% See also: isocset, isocc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if isocset(x)
	n = size(x,1);
	lab = -ones(n,1);
	lab(find_target(x)) = 1;
else
	error('Dataset is not an OCset');
end

return
