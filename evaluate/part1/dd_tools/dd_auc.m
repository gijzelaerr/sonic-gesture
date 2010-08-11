function err = dd_auc(e,bnd)
% DD_AUC compute the integrated error under the ROC curve
%
%   ERR = DD_AUC(E,BND)
%
% Compute the integrated error under the ROC curve, given in E (as
% obtained by dd_roc).
% The user can supply a lower and upper bound on the FP (outliers
% accepted) over which the ROC is integrated: BND = [lowerbnd,
% upperbnd], for instance BND = [0.05 0.5].
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
	bnd = [0.0 1.0];
end
% Check if the bounds are sane:
if (bnd(1)>bnd(2))
	error('bnd(1) should be smaller than bnd(2)');
end
if (bnd(1)<0)
	error('bnd(1) is smaller than 0!');
end
if (bnd(2)>1)
	error('bnd(2) is larger than 1!');
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


% For the integration of the ROC curve, we integrate the TP as a
% function of the FP. Because the TP is  TP=1-(target reject),
% we have to correct that in e:
e(:,1) = 1-e(:,1);

% First sort the outlier accept (FP) in increasing order:
if (e(1,2)>e(end,2))
	e = e(end:-1:1,:);
elseif e(1,2)==e(end,2)
	% very degenerated ROC curve; try to sort it to get the TP in
	% increasing order:
	if (e(1,1)>e(end,1))
		e = e(end:-1:1,:);
	end
end
if any(diff(e(:,2))<0)
	error('Please supply E such that E(:,2) is increasing');
end

%hold on;plot(e(:,2),e(:,1),'ro-'); % just checking...

% Extend the e to the bounds if necessary:
% (I) first, is there something smaller than the lower bound?
I = find(e(:,2)<bnd(1));
if isempty(I)
	% nothing lower than the lower bound, so extend to low outlier accept
	% rates:
	e = [0 bnd(1);
	     0 min(e(:,2));
		  e];
else
	% everything is below the lower bound, so we have to fill in some
	% nonsense:
	if (length(I)==size(e,1))
		e = [0 bnd(1)];
	else
		% else interpolate:
		x1 = e(I(end),2);   y1 = e(I(end),1);
		x2 = e(I(end)+1,2); y2 = e(I(end)+1,1);
		y = y1 + (y2-y1)*(bnd(1)-x1)/(x2-x1);
		e(I,:) = [];
		e = [y bnd(1); e];
	end
end
% (II) second, is there something larger than the upper bound?
I = find(e(:,2)>bnd(2));
if isempty(I)
	% nothing larger than the upper bound, extend to high target
	% rejection rates
	e = [e; max(e(:,1)) bnd(2)];
else
	if (length(I)==size(e,1))
		% everything is above the threshold, so e becomes something stupid
		e = [max(e(:,1)) bnd(2)];
	else
		% interpolate:
		x1 = e(I(1)-1,2); y1 = e(I(1)-1,1);
		x2 = e(I(1),2);   y2 = e(I(1),1);
		y = y1 + (y2-y1)*(bnd(2)-x1)/(x2-x1);
		e(I,:) = [];
		e = [e; y bnd(2)];
	end
end

%hold on;plot(e(:,1),e(:,2),'g-'); % just checking...
%hold on;plot(e(:,2),e(:,1),'g-'); % just checking...

% integrate:
err = 0;
de = diff(e);
for i=1:size(e,1)-1
	err = err + de(i,2)*(e(i+1,1) - de(i,1)/2);
end

return
