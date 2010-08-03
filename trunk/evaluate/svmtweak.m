
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
group = simple_set;

% find positions of sets in full_dataset
runset = find(ismember(full_sets, group)==1)';

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


%% do it
for c= 2.^(-3:2:15)
    for g = 2.^(-15:2:3)
        % iterate
        confusion = zeros(SYMBOLS, SYMBOLS);

        for setNum = 1:size(runset,2)
            setName = group(setNum);

            % construct test features
            testStart = (setNum-1)*SYMBOLS+1;
            testEnd = testStart+SYMBOLS-1;
            testSet = dataset(testStart:testEnd, :);

            % construct train features
            testPre = dataset(1:testStart-1, :);
            testPost = dataset(testEnd+1:end, :);
            trainSet = [testPre; testPost];

            % construct PCA
            eigenhands = pca(trainSet, 0.95);
            trainSetEigen = trainSet*eigenhands;
            testSetEigen = testSet*eigenhands;
            
            % normalize data
            low = max(max([trainSetEigen.data; testSetEigen.data]));
            high = min(min([trainSetEigen.data; testSetEigen.data]));
            scale = max(abs(low), abs(high));
            trainNormalized = trainSetEigen.data / scale;
            testNormalized = testSetEigen.data / scale;
            
            model = svmtrain(trainLabels, trainNormalized, ['-c ' num2str(c) ' -g ' num2str(g)]);
            [svmPredict, accuracy, decision_values] = svmpredict(rand(size(testNormalized, 1), 1), testNormalized, model);
            conf1 = confusionmat(testLabels, svmPredict);
            confusion = confusion +1;
        end
        a = accur(confusion);
        fprintf('c: %f, g: %f, accuracy: %.2f%%\n', c, g, a);
    end
end
