
%% cleanup
clear;
close all;

%% settings
%number of symbols in each set
SYMBOLS=28;

%% load features
full_dataset = load('features.txt');

%% load labels
full_labels = load('labels.txt');

%% load set labels
full_sets = importdata('sets.txt');

%% import all video groups
groups

%% SETTINGS
% which nameset we want to use
trainVideos = simple_set;
testVideos =  complex_set;
knn = 5;

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

% construct labels
testLabels = repmat((1:SYMBOLS)', size(testIndexes,2), 1);
trainLabels = repmat((1:SYMBOLS)', size(trainIndexes,2), 1);


% % do normal KNN
% predicted = knnclassify(testSet, trainSet, trainLabels, knn);
% confusion = confusionmat(testLabels, predicted);



% construct PCA
eigenhands = pca(trainSet, 0.95);
fprintf('dimensions after PCA: %d\n', size(eigenhands, 2));
trainSetEigen = trainSet*eigenhands;
testSetEigen = testSet*eigenhands;

% % do KNN PCA classification
% predicted = knnclassify(testSetEigen.data, trainSetEigen.data, trainLabels, 3);
% confusion = confusionmat(testLabels, predicted);


% DO SVM classification
model = svmtrain(trainLabels, trainSetEigen.data, '-c 8192, -g 0.031250');
[svmPredict, accuracy, decision_values] = svmpredict(rand(size(testSetEigen.data, 1), 1), testSetEigen.data, model);
confusion = confusionmat(testLabels, svmPredict);
a = accur(confusion);
fprintf('c: %f, g: %f, accuracy: %.2f%%\n', c, g, a);


%
fprintf('full scale accuracy %.2f%%\n', accur(confusion));
m = major(confusion);
fprintf('major scale accuracy %.2f%%\n', accur(m));


