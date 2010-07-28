%SETLABELS Reset labels of dataset
%
%   A = SETLABELS(A,LABELS,J)
%
% The labels of the dataset A are reset by LABELS. If supplied, the
% index vector J defines the objects for wich LABELS applies. If in
% LABELS just a single label is given all the objects defined by J
% are given that label. If LABELS is empty ([]) or NaN all the objects
% defined by J are marked as unlabeled.
%
% If A has soft labels (label type is 'soft') or has no labels but
% targets (label type is 'targets'), these soft labels or targets are
% replaced by LABELS, provided it has the right size.
%
% For soft labels and targets LABELS may be a dataset of which the
% data are used for the values of the soft labels or targets and the 
% feature labels are used to set LABLIST of A.  
%
% SEE ALSO MULTI_LABELING
