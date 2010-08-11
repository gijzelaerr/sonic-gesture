function out = roc_hull(r)
%ROC_HULL Convex hull of an ROC curve
%
%       OUT = ROCHULL(R)
%
% Computes the convex hull of ROC curve R. It just returns the operating
% points on the hull, and the rest is removed.
%
% See also: dd_roc, dd_costc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


%assume I get an ROC curve r:
if isstruct(r)
	if ~isfield(r,'err')
		error('I cannot find the "err" field');
	else
		e = r.err;
	end
else
	e = r;
end

% fix the beginning and the end:
if any(e(1,:)~=[0 1])
	e = [0 1; e];
end
if any(e(end,:)~=[1 0])
	e = [1 0; e];
end

% start with the first point:
curr = 1;
k = 1;
out = e(curr,:);
I(k) = curr;
% and proceed to the last one...
n = size(e,1);

while curr<n
	% find the steepest line:
	warning off MATLAB:divideByZero;
		rho = (e(curr+1:end,2)-e(curr,2))./(e(curr+1:end,1)-e(curr,1));
	warning on MATLAB:divideByZero;
	[minr,mini] = min(rho(end:-1:1));
	% add the point to the curve
	curr = curr + length(rho)-mini+1;
	k = k+1;
	out(k,:) = [e(curr,1) e(curr,2)];
	I(k) = curr;
end
return
