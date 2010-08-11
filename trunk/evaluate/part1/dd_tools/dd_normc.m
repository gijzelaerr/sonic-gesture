%DD_NORMC Normalize the output of a oc-classifier
% 
%       B = DD_NORMC(A)
%       B = A*W*DD_NORMC
%       W = DD_NORMC
% 
% Normalize the mapped dataset A to standard 'posterior probability'
% estimates (or something which looks similar to that). It basically
% means that all rows sum to 1. For the output of distance-based
% one-class classifiers (indicated by the definition of the
% featdom-field in the dataset), it also means that the sign is flipped.
% 
% See also datasets, mappings, myproxm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function a = dd_normc(a)

if nargin < 1 | isempty(a) 
	a = mapping(mfilename,'fixed');
	a = setname(a,'Output normalization');
	return
end


[n,p] = size(a);

% We have a normal double matrix, just normalize that the sum of each
% row is 1. This can go wrong when you supply a vector of course:-)
sm = sum(a,2);
a = a./repmat(sm,1,p);

% Check if we can at least expect a one-class classifier:
if isdataset(a)
	featdom = getfeatdom(a);
	if ~isempty(featdom{1}) & ~isempty(featdom{2})
		% we are prob. dealing with a one-class output...:
		if (featdom{1}==[-inf 0]) & (featdom{2}==[-inf 0])
			% we are dealing with a distance-based one-class classif.
			if (p ~= 2)
				error('I am expecting a 2-class output (target and outlier)');
			end
			% change the sign
			a = 1-a;
		end
	end
end

return


