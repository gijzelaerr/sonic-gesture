
%% cleanup
clear;
close all;

% settings
%number of symbols in each set
SYMBOLS=28;
knn = 5;
% svm parms
cRange = 2.^(-4:1:4);
nReps = 1;
nFolds = 3;

% load features
full_dataset = load('features.txt');

% load labels
full_labels = load('labels.txt');

% load set labels
full_sets = importdata('sets.txt');

% import all video groups
groups
nameset = full_names;

%% prepare rundata
rundata = cell(size(nameset,1), 2);
for index = 1:size(nameset)
    name = nameset(index);
    indx =  ~cellfun('isempty', cellfun(@(f) f(f==1), strfind(full_set, name{1}), 'UniformOutput',false));
    if sum(indx) == 0
        fprintf('name %s not in dataset\n', name{1});
        break;
    end;

    trainnames = full_set(~indx);
    testnames = full_set(indx);
    trainindexes = find(ismember(full_sets, trainnames)==1)';
    testindexes = find(ismember(full_sets, testnames)==1)';

    rundata(index, 1) = {trainindexes};
    rundata(index, 2) = {testindexes};
end;


%% DO IT
confusion = zeros(SYMBOLS, SYMBOLS);
%for index = 1:size(rundata,1)
for index = 1:1
    name = nameset(index);
    fprintf('running test with: %s\n', name{1});
    data = rundata(index, :);
    trainIndexes = data{1};
    testIndexes = data{2};

    trainSet = zeros(size(trainIndexes,2)*SYMBOLS, size(full_dataset,2));
    testSet = zeros(size(testIndexes,2)*SYMBOLS, size(full_dataset,2));
    
    for i = 1:size(trainIndexes,2)
        set = trainIndexes(i);
        start = (set-1)*SYMBOLS+1;
        finish = start+SYMBOLS-1;
        range = full_dataset(start:finish, :);

        target_start = (i-1)*SYMBOLS+1;
        target_finish = target_start+SYMBOLS-1;
        trainSet(target_start:target_finish, :) = range;
    end
 
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
    
    fprintf('doing PCA\n');
    eigenhands = pca(trainSet, 0.95);
    trainSetEigen = trainSet*eigenhands;
    testSetEigen = testSet*eigenhands;

    trainData = trainSetEigen.data;
    testData = testSetEigen.data;
    trainMin = min(trainData);
    shift = trainMin .* ((trainMin < 0)*-1);
    trainShift = repmat(shift, size(trainData, 1), 1);
    testShift = repmat(shift, size(testSet, 1), 1);
    trainData = trainData + trainShift;
    testData = testData + testShift;
    testData(testData<0) = 0;


    fprintf('constructing kernel\n');
    trainDist = ChiSquareDistance(trainData);
    testDist = ChiSquareDistance(testData, trainData);

    fprintf('doing classification\n');
    [avgPrec clfsOutput] = SvmPKExpOpt(trainDist, testDist, trainLabels, testLabels, cRange, nReps, nFolds, 0);
    [c,acc]= svmOutput2Confmat(clfsOutput, testLabels);
    confusion = confusion + c;
    
end;
    

%%
fprintf('full scale accuracy %.2f%%\n', accur(confusion));
m = major(confusion);
fprintf('major scale accuracy %.2f%%\n', accur(m));
confusion;

