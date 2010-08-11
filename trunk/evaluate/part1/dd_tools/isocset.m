%ISOCSET True for one-class datasets
%
% isocset(a) returns true if the dataset a is a one-class dataset,
% containing only classes 'target' and/or 'outlier'.
%
% See also: is_occ, gendatoc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = isocset(a)

if ~isa(a,'dataset')
	out = 0;
	return;
end
lablist = getlablist(a);
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
