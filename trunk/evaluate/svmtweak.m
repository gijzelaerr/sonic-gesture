
%% init cluster
%matlabpool;


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
profile on;
full_sets = importdata('sets.txt');
profile viewer;

%% import all video groups
groups

%% which group do we want to use
nameset = simple_names;

%% do it
for c= 2.^(1:2:15)
    for g = 2.^(-15:2:3)
        % iterate
        confusion = zeros(SYMBOLS, SYMBOLS);

        % find users
        for name = nameset'
            indx =  ~cellfun('isempty', cellfun(@(foenk) foenk(foenk==1), strfind(full_set, name{1}), 'UniformOutput',false));
            if sum(indx) == 0
                fprintf('skipping %s\n', name{1});
                continue;
            end;
            fprintf('.');
            trainnames = full_set(~indx);
            testnames = full_set(indx);

            trainindexes = find(ismember(full_sets, trainnames)==1)';
            trainSet = zeros(size(trainindexes,2)*SYMBOLS, size(full_dataset,2));

            for i = 1:size(trainindexes,2)
                set = trainindexes(i);
                start = (set-1)*SYMBOLS+1;
                finish = start+SYMBOLS-1;
                range = full_dataset(start:finish, :);

                target_start = (i-1)*SYMBOLS+1;
                target_finish = target_start+SYMBOLS-1;
                trainSet(target_start:target_finish, :) = range;
            end

            testindexes = find(ismember(full_sets, testnames)==1)';
            testSet = zeros(size(testindexes,1)*SYMBOLS, size(full_dataset,2));


            for i = 1:size(testindexes,2)
                set = testindexes(i);
                start = (set-1)*SYMBOLS+1;
                finish = start+SYMBOLS-1;
                range = full_dataset(start:finish, :);

                target_start = (i-1)*SYMBOLS+1;
                target_finish = target_start+SYMBOLS-1;
                testSet(target_start:target_finish, :) = range;
            end

            % construct labels
            testLabels = repmat((1:SYMBOLS)', size(testindexes,2), 1);
            trainLabels = repmat((1:SYMBOLS)', size(trainindexes,2), 1);

            % construct PCA
            eigenhands = pca(trainSet, 0.95);
            trainSetEigen = trainSet*eigenhands;
            testSetEigen = testSet*eigenhands;


            % DO SVM classification
            model = svmtrain(trainLabels, trainSetEigen.data);
            [svmPredict, accuracy, decision_values] = svmpredict(rand(size(testSetEigen, 1), 1), testSetEigen.data, model);
            C = confusionmat(testLabels, svmPredict);
            confusion = confusion + C;
        end
        a = accur(confusion);
        fprintf('\nc: %f, g: %f, accuracy: %.2f%%\n', c, g, a);
    end
end