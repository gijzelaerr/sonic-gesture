
%%
knnConfusion = load('knnConfusion');
knnConfusion100 = load('knnConfusion100');
knnConfusion30 = load('knnConfusion30');
svmConfusion = load('svmConfusion');

%%

fprintf('knn accuracy %.2f%%\n', accuracy(knnConfusion) );
fprintf('knn PCA 100 accuracy %.2f%%\n', accuracy(knnConfusion100) );
fprintf('knn PCA 30 accuracy %.2f%%\n', accuracy(knnConfusion30) );
fprintf('svm accuracy %.2f%%\n', accuracy(svmConfusion) );