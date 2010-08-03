
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

%% which group do we want to use
group = full_set;

% find positions of sets in full_dataset
runset = find(ismember(full_sets, group)==1)';


%% find users
nameset = zeros(size(group));
for name = names'
    %nameset = nameset | ~cellfun('isempty', strfind(full_sets, name{1}));
    nameset =  nameset | ~cellfun('isempty', cellfun(@(foenk) foenk(foenk==1), strfind(group, name{1}), 'UniformOutput',false));
end

%% construct dataset we want
dataset = zeros(size(runset,1)*SYMBOLS, size(full_dataset,2));
for i = 1:size(runset,2)
    set = runset(i);
    start = (set-1)*SYMBOLS+1;
    finish = start+SYMBOLS-1;
    range = full_dataset(start:finish, :);
    
    target_start = (i-1)*SYMBOLS+1;
    target_finish = target_start+SYMBOLS-1;
    dataset(target_start:target_finish, :) = range;
end

%% construct labels
testLabels = (1:SYMBOLS)';
trainLabels = repmat((1:SYMBOLS)', size(runset,2)-1, 1);

%% iterate
confusion = zeros(SYMBOLS, SYMBOLS);

for setNum = 1:size(runset,2)
    setName = group(setNum);
    
    % where are we now
    fprintf('%s %d/%d\n', setName{1}, setNum, size(runset,2));

    % construct test features
    testStart = (setNum-1)*SYMBOLS+1;
    testEnd = testStart+SYMBOLS-1;
    testSet = dataset(testStart:testEnd, :);
   
    % construct train features
    testPre = dataset(1:testStart-1, :);
    testPost = dataset(testEnd+1:end, :);
    trainSet = [testPre; testPost];

    % do normal KNN
    predicted = knnclassify(testSet, trainSet, trainLabels, 2);
    C = confusionmat(testLabels, predicted);
    confusion = confusion + C;
    
%     % construct PCA
%     eigenhands = pca(trainSet, 0.95);
%     trainSetEigen = trainSet*eigenhands;
%     testSetEigen = testSet*eigenhands;

%     % do KNN PCA classification
%     predicted = knnclassify(testSetEigen.data, trainSetEigen.data, trainLabels, 3);
%     C = confusionmat(testLabels, predicted);
%     confusion = confusion + C; 
    
%     % construct data for 100 eigenfaces
%     eigenFaces = eigen(trainFeatures);
%     eigen100 = eigenFaces(:, 1:100);
%     trainFeatures100 = trainFeatures*eigen100;
%     testFeatures100 = testFeatures*eigen100;
%     % do KNN PCA100 classification
%     knnPredict100 = knnclassify(testFeatures100, trainFeatures100, trainLabels, 3);
%     C = confusionmat(testLabels, knnPredict100);
%     knnConfusion100 = knnConfusion100 + C;
 
%     % DO SVM classification
%     model = svmtrain(trainLabels, trainSetEigen.data);
%     [svmPredict, accuracy, decision_values] = svmpredict(rand(SYMBOLS, 1), testSetEigen.data, model);
%     C = confusionmat(testLabels, svmPredict);
%     confusion = confusion + C;
end


fprintf('accuracy %.2f%%\n', accuracy(confusion));

m = major(confusion);
fprintf('accuracy %.2f%%\n', accuracy(m));
