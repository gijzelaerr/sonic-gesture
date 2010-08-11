function [a,b] = target_class(a,clnr)
% TARGET_CLASS  extracts the target class from an one-class dataset
%
%    A = TARGET_CLASS(A,CLNR)
%
% Extract the target class from an one-class dataset. When the label
% CLNR is given, the class indicated by this label is taken.
%
%    [A,B] = TARGET_CLASS(A,CLNR)
%
% When a second output argument B is requested, the remaining data is
% stored in B.
%
% Default: CLNR='target';
%
% See also: oc_set, gendatoc, find_target, relabel

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<2)
  clnr = 'target';
end

% Be sure we are working with an OC set:
[a,I] = oc_set(a,clnr);

% Extract just the target objects:
It = find(I==1);
if isempty(It) & (nargout==1)
	error('Cannot find target class objects!');
end

% On request, also return the outlier objects:
% (do this before the construction of the target-class dataset, because
% in that construction the outlier data is removed)
if nargout>1
	Io = find(I==2);
	b = a(Io,:);
	%DXD  Now the question becomes, should we reduce the lablist to just
	% 'outlier'??
	b = setnlab(b,ones(length(Io),1));
	b = setlablist(b); % remove empty classes.
	b = setlablist(b,'outlier');
end

% and what it was all about:
a = a(It,:);
%DXD  Now the question becomes, should we reduce the lablist to just
% 'target'??
a = setlablist(a); % remove empty classes from the lablist
a = setnlab(a,ones(length(It),1));
a = setlablist(a,'target');

return


