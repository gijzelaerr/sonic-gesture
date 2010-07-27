function [eigen_faces] = eigen(features)

%% eigenvalue/vector decomposition
psi = mean(features);
diff = features - repmat(psi, size(features, 1), 1);
[small_vecs,vals] = eig(diff*diff');
big_vecs = diff'*small_vecs;
vals = diag(vals);

%% Sort the eigenvectors and values
[vals indexes] = sort(vals,'descend');
big_vecs = big_vecs(:,indexes);

%% eigenface construction
eigen_faces = zeros(size(big_vecs));
for i = 1:size(big_vecs,2)
    eigen_faces(:,i) = big_vecs(:,i)/norm(big_vecs(:,i));
end

