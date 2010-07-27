
%% load features
features = load('features.txt');

%% load labels
labels = load('labels.txt');

%% load set labels
sets = importdata('sets.txt');

%% eigen faces
eigen_faces = eigen(features);

%% svd
[U,S,V] = svd(features);