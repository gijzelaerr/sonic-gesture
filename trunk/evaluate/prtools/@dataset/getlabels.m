%GETLABELS Get labels or soft labels of a dataset
%
%	  [LABELS,LABLIST] = GETLABELS(A)
%	  [LABELS,LABLIST] = GETLABELS(A,'crisp')
%	  [LABELS,LABLIST] = GETLABELS(A,'soft')
%
% INPUT
%  A      Dataset
%  type   labels type
%
% OUTPUT
%  LABELS
%  LABLIST
%
% DESCRIPTION
% Gets the labels (crisp or soft) of the objects in the dataset A.
% If A has target labels they are converted to soft labels first. 
% See SETLABTYPE for conversion rules.
% LABLIST is the unique set of labels of A and is thereby identical to
% the class names of A.
%
%	[LABELS,LABLIST] = GETLABELS(A,'crisp')
%
% Forces the return of crisp labels in case of a soft labelled dataset.
%
%	[LABELS,LABLIST] = GETLABELS(A,'soft')
%
% Forces the return of soft labels after conversion (if necessary).
% This last command is identical to GETTARGETS(A,'soft').
% Note that soft labels are not names, but memberships to all classes.
% If A has crisp labels or target labels they are converted to soft
% labels first. See SETLABTYPE for conversion rules.
% 
% SEE ALSO
% SETLABTYPE, GETTARGETS, SETLABELS, SETTARGETS, MULTI_LABELING
