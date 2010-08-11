
%% cleanup
clear;
close all;

%%
fprintf('load data\n');
full_dataset = load('../features.txt');
full_labels = load('../labels.txt');
full_sets = importdata('../sets.txt');
groups

%% SETTINGS
%number of symbols in each set
SYMBOLS=28;
% which nameset we want to use
trainVideos = simple_set;
testVideos =  complex_set;
% svm parms
cRange = 2.^(-4:1:4);
nReps = 1;
nFolds = 3;


%%
fprintf('constructing train and test set\n');
trainIndexes = find(ismember(full_sets, trainVideos)==1)';
trainSet = zeros(size(trainIndexes,2)*SYMBOLS, size(full_dataset,2));

for i = 1:size(trainIndexes,2)
    set = trainIndexes(i);
    start = (set-1)*SYMBOLS+1;
    finish = start+SYMBOLS-1;
    range = full_dataset(start:finish, :);

    target_start = (i-1)*SYMBOLS+1;
    target_finish = target_start+SYMBOLS-1;
    trainSet(target_start:target_finish, :) = range;
end

testIndexes = find(ismember(full_sets, testVideos)==1)';
testSet = zeros(size(testIndexes,1)*SYMBOLS, size(full_dataset,2));


for i = 1:size(testIndexes,2)
    set = testIndexes(i);
    start = (set-1)*SYMBOLS+1;
    finish = start+SYMBOLS-1;
    range = full_dataset(start:finish, :);

    target_start = (i-1)*SYMBOLS+1;
    target_finish = target_start+SYMBOLS-1;
    testSet(target_start:target_finish, :) = range;
end

%% construct labels
trainLabels = repmat(eye(28,28),size(trainIndexes,2),1);
testLabels = repmat(eye(28,28),size(testIndexes,2),1);



%%
fprintf('doing PCA\n');
eigenhands = pca(trainSet, 0.95);
fprintf('dimensions after PCA: %d\n', size(eigenhands, 2));
trainSetEigen = trainSet*eigenhands;
testSetEigen = testSet*eigenhands;


%% 
fprintf('constructing kernel\n');
trainDist = ChiSquareDistance(trainSet);
testDist = ChiSquareDistance(testSet, trainSet);


%% 
fprintf('doing classification\n');
[avgPrec clfsOutput] = SvmPKExpOpt(trainDist, testDist, trainLabels, testLabels, cRange, nReps, nFolds, 0);
[c,acc]= svmOutput2Confmat(clfsOutput, testLabels);

%% output
fprintf('full scale accuracy %.2f%%\n', accur(c));
m = major(c);
fprintf('major scale accuracy %.2f%%\n', accur(m));


