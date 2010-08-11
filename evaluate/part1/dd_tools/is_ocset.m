%IS_OCSET True for one-class datasets
%
% is_ocset(a) returns true if the dataset a is a one-class dataset,
% containing only classes 'target' and/or 'outlier'.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function out = is_ocset(a)

if ~isdataset(a)
  out = 0;
  return;
end
[l,lablist] = getnlab(a);
switch size(lablist,1)
case 1
   out = strcmp(lablist,'target')|...
         strcmp(lablist,'target ')|...
         strcmp(lablist,'outlier');
case 2
   out = strcmp(lablist,['outlier';'target ']);
otherwise
   out = 0;
end
