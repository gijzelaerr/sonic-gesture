%SETLABLIST Set names of classes or targets
%
%    A = SETLABLIST(A,LABLIST)
%
% LABLIST should be a column vector of C elements (integers, characters,
% or strings), in which C is the number of classes or targets of A.
% In case of multiple label lists this resets the current label list.
%
%    A = SETLABLIST(A)
%
% Remove entries in the lablist of A to which no objects are assigned,
% i.e. remove empty classes.
%
% SEE ALSO MULTI_LABELING
