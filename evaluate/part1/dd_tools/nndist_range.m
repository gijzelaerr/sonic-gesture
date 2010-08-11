%NNDIST_RANGE Give a vector of scales
%
%     D = NNDIST_RANGE(X)
%     D = NNDIST_RANGE(X,NR)
%
% Give the average nearest neighbor distance in dataset X. When NR is
% specified, the first NR nearest distances are returned.
%
% Default: NR = 1
%
% See also: svdd

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function d = nndist_range(x,nr)

if nargin<2
	nr = 1;
end
if isdataset(x)
	x = +x;
end
if nr>(size(x,1)+1)
	error('Insufficient number of objects in dataset X.');
end

% Compute the distances
D = sqrt(sqeucldistm(x,x));

% Sort the distances:
sD = sort(D,2);

% and find the averaged distances:
d = mean(sD(:,2:(nr+1)),1);

return

