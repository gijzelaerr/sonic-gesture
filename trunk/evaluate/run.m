
%% settings
%number of symbols in each set
SYMBOLS=28;

%% load features
features = load('features.txt');

%% load labels
labels = load('labels.txt');

%% load set labels
sets = importdata('sets.txt');

%% iterate
knnConfusion = zeros(SYMBOLS, SYMBOLS);
knnConfusion30 = zeros(SYMBOLS, SYMBOLS);
knnConfusion100 = zeros(SYMBOLS, SYMBOLS);
svmConfusion = zeros(SYMBOLS, SYMBOLS);

for setNum = 1:size(sets,1)
%for setNum = 1:1
    setName = sets(setNum);
    
    % where are we now
    fprintf('%s %d/%d\n', setName{1}, setNum, size(sets,1));

    % construct test features
    testStart = (setNum-1)*SYMBOLS+1;
    testEnd = testStart+SYMBOLS-1;
    testFeatures = features(testStart:testEnd, :);
   
    % construct train features
    testPre = features(1:testStart-1, :);
    testPost = features(testEnd+1:end, :);
    trainFeatures = [testPre; testPost];

    %% do PCA
    eigenhands = pca(trainFeatures, 0.95);
    trainFeaturesEigen = trainFeatures*eigenhands;
    testFeaturesEigen = testFeatures*eigenhands;
    
%     % construct data for 100 eigenfaces
%     eigenFaces = eigen(trainFeatures);
%     eigen100 = eigenFaces(:, 1:100);
%     trainFeatures100 = trainFeatures*eigen100;
%     testFeatures100 = testFeatures*eigen100;
%     % construct data for 30 eigenfaces
%     eigen30 = eigenFaces(:, 1:30);
%     trainFeatures30 = trainFeatures*eigen30;
%     testFeatures30 = testFeatures*eigen30;
%     
%    

    % construct labels
    testLabels = (1:SYMBOLS)';
    trainLabels = repmat((1:SYMBOLS)', size(sets,1)-1, 1);
    
%     % do KNN classification
%     knnPredict = knnclassify(testFeatures, trainFeatures, trainLabels, 3);
%     C = confusionmat(testLabels, knnPredict);
%     knnConfusion = knnConfusion + C;
% 
%     % do KNN PCA100 classification
%     knnPredict100 = knnclassify(testFeatures100, trainFeatures100, trainLabels, 3);
%     C = confusionmat(testLabels, knnPredict100);
%     knnConfusion100 = knnConfusion100 + C;
% 
%     % do KNN PCA30 classification
%     knnPredict30 = knnclassify(testFeatures30, trainFeatures30, trainLabels, 3);
%     C = confusionmat(testLabels, knnPredict30);
%     knnConfusion30 = knnConfusion30 + C;

    
%     % DO SVM classification
%     model = svmtrain(trainLabels, trainFeatures);
%     [svmPredict, accuracy, decision_values] = svmpredict(rand(SYMBOLS, 1), testFeatures, model);
%     C = confusionmat(testLabels, svmPredict);
%     svmConfusion = svmConfusion + C;

    knnPredict = knnclassify(testFeaturesEigen, trainFeaturesEigen, trainLabels, 3);
    C = confusionmat(testLabels, knnPredict);
    knnConfusion = knnConfusion + C;
end

knnConfusion

good = sum(sum(eye(SYMBOLS).*knnConfusion));
bad = sum(sum((ones(SYMBOLS)-eye(SYMBOLS)) .* knnConfusion));
total = sum(sum(knnConfusion));
accuracy = 100/total * good;
fprintf('accuracy %.2f%%\n', accuracy');