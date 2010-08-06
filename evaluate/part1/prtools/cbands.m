%CBANDS 12000 objects with 30 features in 24 classes
%
%	A = CBANDS
%	A = CBANDS(M,N)
%
% Load the dataset in A, select the objects and features according to the
% index vectors M and N.
%
% See also DATASETS, PRDATASETS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: cbands.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function a = cbands(M,N);
		prtrace(mfilename);
if nargin < 2, N = []; end
if nargin < 1, M = []; end
a = prdataset('cbands',M,N);
a = setname(a,'Chromosome Bands');
