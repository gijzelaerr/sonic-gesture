function x = gendatoc(x_t,x_o)
%GENDATOC Generate a one-class dataset
%
%    X = GENDATOC(X_T,X_O)
%
% Generate a one-class dataset from the two datasets X_T and X_O. Dataset
% X_T will be labelled 'target', and X_O will be labelled 'outlier'. It is
% possible to have X_T or X_O an empty dataset [], but not both at the same
% time, of course.
%
% Thus, X = GENDATOC([],X) will make X a dataset with only outlier objects.
%
% Note that  X = GENDATOC(X) does the same as  X = TARGET_CLASS(X) when X is
% a data matrix.
%
% See also: relabel, find_target, target_class

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin < 2, x_o = []; end

[n_t,d1] = size(x_t);
[n_o,d2] = size(x_o);

% Because x_t or x_o can be empty, things become slightly complicated.
% Furthermore, take care for the feature labels...
if isempty(x_t) % we should get featlab from x_o
	if isempty(x_o)
		error('I need data to make a OC dataset');
	end
	if isdataset(x_o)
		featlab = getfeatlab(x_o);
	else
		featlab = (1:d2)';
	end
else  % get the featlab from x_t, and check the dims.
	if (~isempty(x_o)) & (d1 ~= d2)
		error('Dimensionality of x_t and x_o do not match.');
	end
	if isdataset(x_t)
		featlab = getfeatlab(x_t);
	else
		featlab = (1:d1)';
	end
end

% Create the labels and finally the dataset itself
lab = [ones(n_t,1); repmat(2,n_o,1)];
lablist = ['target ';'outlier'];
x = dataset([+x_t;+x_o],lablist(lab,:),'featlab',featlab);

%DXD A thing still to consider is: what name should be given to the
%dataset?

return
