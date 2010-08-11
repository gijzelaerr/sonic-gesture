function [avgPrec clfsOutput w]= SvmPKOpt(trainDist, testDist, trainLabels, testLabels, cRange, nReps, nFolds, verbose)
% [avgPrec clfsOutput] = SvmPKExpOpt(trainDist, testDist, 
%                         trainLabels, testLabels, cRange, nReps, nFolds)
%
% Does crossvalidation on the training distance and applies to test
% distance. The output is in average precision per class
% Distance matrix will be taken as is.
%
% trainDist:        M x M distance matrix of train set.
% testDist:         N x M distance matrix of test and train set
% trainLabels:      M x c logical label matrix of c classes.
% testLabels:       N x c logical matrix with labels of c classes
% cRange:           range for slack parameter in crossvalidation
% nReps:            Number of repetitions in crossvalidation
% nFolds:           Number of folds in crossvalidation
% verbose(optional):Put to 1 to see progress          
%
% avgPrec:          Average Precision measure per class
% clfsOutput:       Output of the classifier

if islogical(trainLabels)
    trainLabels = double(trainLabels);
end

if islogical(testLabels)
    testLabels = double(testLabels);
end

if ~exist('verbose')
    verbose = 0;
end


avgPrec = zeros(size(trainLabels,2), 1);
clfsOutput = zeros(size(testDist,1), size(trainLabels,2));
% Loop over all classes
for i=1:size(trainLabels,2)
    

    if verbose == 1
        fprintf('%g  ', i);
    end
    
    % Get Labels for current class
    trainL = trainLabels(:,i);
    w{i} = svmcPKCrossVal(trainDist, trainL, cRange, nReps, nFolds);
    
    % Testset
    testSet = dataset(testDist, testLabels(:,i));
    testSet = oc_set(testSet,'1');
        
    classification = testSet * w{i};
    avgPrec(i,1) = avgprec(classification);
    clfsOutput(:,i) = +classification(:,2);
end

if verbose == 1
    fprintf('\n');
end
    