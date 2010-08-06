function b = NormalizeRows(a)
% Normalizes the rows of a. Makes sure there is no division by zero: b will
% not contain any NaN entries.
%
% a:            data with row vectors
% 
% b:            normalized data with row vecors. All rows sum to one except
%               the ones that are zero in the first place: these remain
%               zero.

% Get sums
sumA = sum(a,2);

% Make sure there is no division by zero
sumA(sumA == 0) = 1;

% Do the normalization
b = a ./ repmat(sumA, 1, size(a,2));