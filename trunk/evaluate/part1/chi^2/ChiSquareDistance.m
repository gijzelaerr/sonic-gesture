function distances = ChiSquareDistance(a, b, isSparse)
% distances = ChiSquareDistance(a, b)
% distances = ChiSquareDistance(a)
%
% Results in a distance matrix between a and b, based on the Chi Square
% measure which is defined as:
%
%       1/(2*|i|)  *  Sum_i D(a_i, b_i),
%
% where
%
%       D(a_i,b_i) = (a-b)^2 / (a + b))
%
%
% Input:
% a:            NxT matrix of N feature vectors of size T
% b:            MxT matrix of M feature vectors of size T
%
% Output:
% distances     NxM matrix of the distances between the rows of a and b.
%
% Note: For speed, make sure that a >= b.
% Note: Works only for positive numbers
% Note: I use the mean instead of the sum to be able to compare the Chi^2
%       distance between features of different dimensionality (more or
%       less).

if nargin < 2
    b = a;
end

if nargin < 3
    isSparse = 1;
end

if min(min(a)) < 0 || min(min(b)) < 0
    warning('Some features are smaller than zero.');
end

if isdataset(a)
    if ~isdataset(b)
        warning('If A is a dataset, B should be one too');
    end
    alabs = getlabels(a);
    distances = mexChiSquareDistance(+a, +b, isSparse);
    distances = dataset(distances, alabs);
else
    distances = mexChiSquareDistance(a,b, isSparse);
end

%%% Matlab implementation is too slow:
% sizeA = size(a,1);
% distances = zeros(sizeA, size(b,1));
% 
% for i=1:size(b,1)
%     bRow = repmat(b(i,:),sizeA, 1); 
%     denominator = a + bRow;
%     
%     % Make sure that there are no zero values. Notice that where there is a
%     % zero value, the total Chi Square distance of that bin will be zero
%     % because the numerator will still be zero.
%     denominator(denominator == 0 ) = 1;
%     diff = a - bRow;
%     distances(:,i) = mean((diff .* diff) ./ denominator,2) / 2;
% end
