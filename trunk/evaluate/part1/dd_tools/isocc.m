%ISOCC True for one-class classifiers
%
% isocc(w) returns true if the classifier w is a one-class classifier,
% outputting only classes 'target' and/or 'outlier' and having a
% structure with threshold stored.
%
% Only problem is when you have an empty oc-classifier, this will
% return false. I cannot help it:-(

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = isocc(w)

% First check if it is a mapping:
if ~isa(w,'mapping')
	out = 0;
	return
end

% Check if the labels are correct:
lablist = getlabels(w);
switch size(lablist,1)
case 1
	out = strcmp(lablist,'target')|...
			strcmp(lablist,'target ')|...
			strcmp(lablist,'outlier');
case 2
	out = strcmp(lablist,['outlier';'target ']) | ...
			strcmp(lablist,['target ';'outlier']);
otherwise
	out = 0;
end

if out
	% now check if it contains also a threshold field:
	d = getdata(w);
	if isstruct(d)
		fn = fieldnames(d);
		out = out & sum(strcmp(fn,'threshold'));
	end
	if ~out
		warning('dd_tools:NoThresholdInOCC',...
			'Missing threshold field in OC classifier.');
	end
end

return
