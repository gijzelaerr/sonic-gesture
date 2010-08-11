function err = dd_auc(e,bnd)
% DD_AUC compute the integrated error under the ROC curve
%
%   ERR = DD_AUC(E,BND)
%
% Compute the integrated error under the ROC curve, given in E (as
% obtained by dd_roc).
% The user can supply a lower and upper bound over which the ROC is
% integrated: BND = [lowerbnd, upperbnd], for instance BND = [0.05 0.5].
%
% IMPORTANT: According to the definition of AUC, high values are good
% (so it is a performance measure, not an error measure). Therefore
% the definition has been changed!! Take care!!
%
% See also: dd_error, dd_roc.
%
%@article{Bradley1997,
%	author = {Bradley, A.P.},
%	title = {The use of the area under the {ROC} curve in the
%	evaluation of machine learning algorithms},
%	journal = {Pattern Recognition}, year = {1997}, volume = {30},
%	number = {7}, pages = {1145-1159}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<2)
	bnd = [0.05 0.5];
end

% First check if we are dealing with the extended ROC structure as it is
% delivered by dd_roc:
if isa(e,'struct')
	if isfield(e,'err')
		e = e.err;
	else
		error('E seems to be a struct, but does not contain an E.err field');
	end
end
% Make e the correct size:
if (size(e,2)~=2)
	e = e';
	if (size(e,2)~=2)
		error('Please make e an Nx2 matrix');
	end
end
if (size(e,1)==1)
	warning('dd_tools:BadROC','I have a very short ROC curve, is it OK?');
end

% First sort the target reject:
[se,I] = sort(e(:,1)); e = e(I,:);

% Extend the e to the bounds if necessary:
% first, is there something smaller than the lower bound?
I = find(e(:,1)<bnd(1));
% extend to low target rejection rates:
if isempty(I)
	e = [bnd(1) 1; min(e(:,1)) 1; e];
else
	% else interpolate:
	if (length(I)==size(e,1))
		e = [bnd(1) 1];
	else
		x1 = e(I(end),1); y1 = e(I(end),2);
		x2 = e(I(end)+1,1); y2 = e(I(end)+1,2);
		y = y1 + (y2-y1)*(bnd(1)-x1)/(x2-x1);
		e(I,:) = [];
		e = [bnd(1) y; e];
	end
end
I = find(e(:,1)>bnd(2));
if isempty(I)   % extend to high target rejection rates
	e = [e; bnd(2) min(e(:,2))];
else                     % interpolate:
	if (length(I)==size(e,1))
		e = [bnd(1) min(e(:,2))];
	else
		x1 = e(I(1)-1,1); y1 = e(I(1)-1,2);
		x2 = e(I(1),1); y2 = e(I(1),2);
		y = y1 + (y2-y1)*(bnd(2)-x1)/(x2-x1);
		e(I,:) = [];
		e = [e; bnd(2) y];
	end
end

% do we have to enforce that the e(:,1) and e(:,2) are strictly
% increasing/decreasing??

%hold on;plot(e(:,1),e(:,2),'g-'); % just checking...
% integrate:
err = 0;
de = diff(e);
for i=1:size(e,1)-1
	err = err + de(i,1)*(e(i+1,2) - de(i,2)/2);
end

% Grumble grumble, the definition of the ROC is a performance, and not
% an error. The maximal performance (area under the curve) is 1, so:
err = 1-err;

return
