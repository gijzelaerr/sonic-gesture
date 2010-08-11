function [w cBest] = svmcPKCrossVal(D, labels, cRange, nReps, nFolds)
% w = svmcPKExp(D, params)
%
% Train Support Vector Machine using the Precomputed Kernel
% Uses crossvalidation to optimize the slack parameter of the SVM.
% Optimization is done with respect to the average precision, which
% gives a score to ranked lists.
%
% Precomputer kernel will *not* be exponential:
% 
% This is equal to the RBF kernel if D is the squared euclidean distance.
%
% D:            Dataset containing distances
% labels:       Labels of the distances.
% cRange:       range of slack parameters (e.g. 2.^(-4:1:4))
% nReps:        Number of repetitions for cross validation
% nFolds:       Number of folds

if islogical(labels)
    labels = double(labels);
end

% Get optimal parameters through cross validation
avgPrecCv = zeros(length(cRange), 1);
for i=1:nReps
    % Get random folds
    foldIdx = mod(1:size(D,1), nFolds) + 1;
    foldIdx = foldIdx(randperm(size(D,1)));
    
    for j=1:nFolds
        % trainSet
        trainIdx = (foldIdx ~= j);
        trainSet = dataset(D(trainIdx, trainIdx), labels(trainIdx));
        trainSet = oc_set(trainSet, '1');

        % testSet
        testIdx = (foldIdx == j);
        testSet = dataset(D(testIdx, trainIdx), labels(testIdx));
        testSet = oc_set(testSet, '1');

        % Do classification for each fold for each slack parameter.
        for k = 1:length(cRange)
            w = svmcPK(trainSet, cRange(k));
            classification = testSet * w;
            avgPrecCv(k) = avgPrecCv(k) + avgprec(classification);
        end
    end
end

% Train the final model using the slack with the best cross validation
% score.
[maxAvgPrec cIdx] = max(avgPrecCv);
cBest = cRange(cIdx);

maxAvgPrec = maxAvgPrec / (nFolds * nReps);

% This time the whole dataset is used for learning
trainSet = dataset(D, labels);
trainSet = oc_set(trainSet, '1');

w = svmcPK(trainSet, cBest);