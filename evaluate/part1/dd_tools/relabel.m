function b = relabel(a,newlab)
% B = relabel(A,newlab)
%
% Rename the labels in dataset A to newlab. Of course, the length of
% newlab should be equal to the lablist of dataset A. The first class
% from the lablist will get the first label in newlab. 
%
% This function is useful when from a dataset A, several classes are
% to be renamed to 'target' and the rest to outlier class. If just a
% single class should be named 'target' then target_class or oc_set
% should be used.
%
% See also: find_target, gendatoc, target_class, oc_set

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

isdataset(a);
[m,k,c] = getsize(a);

if (c~=size(newlab,1))
  error('Number of new labels should be equal to number of classes');
end

b = set(a,'lablist',newlab);

return
