% addpath prtools
% addpath mp-tools
% addpath libsvm-mat-2.89-3
% addpath dd_tools



D = load('../features.txt');

%%
trainSet = D(1:30*28,:);
testSet = D(30*28+1:end,:);
trainLabels = repmat(eye(28,28),30,1);
testLabels = repmat(eye(28,28),74-30,1);

%%
cRange = 2.^(-4:1:4);
nReps = 1;
nFolds = 3;

%% Calculate distance matrices
fprintf('Calculating training distance...')
trainDist = ChiSquareDistance(trainSet);
fprintf('done\nCalculating test distance...');
testDist = ChiSquareDistance(testSet, trainSet);
fprintf('done\nDoing classification')

%%
[avgPrec clfsOutput] = SvmPKExpOpt(trainDist, testDist, trainLabels, testLabels, cRange, nReps, nFolds, 0);

%%
[c,acc]= svmOutput2Confmat(clfsOutput, testLabels);


