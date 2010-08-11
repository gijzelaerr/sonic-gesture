function w = svmcPK(D, C, varargin)
% w = svmcPK(D, C, varargin)
%
% Trains a two class svm-classifier with a precomputed kernel.
%
% INPUT:
%
% D:            PR-tools dataset containing a NxM distance matrix, where N
%               is the number of samples.
%               Target labels of this dataset should be 1.
%               Non-target labels of this dataset should be 0 or -1
%               Use an oc_dataset to make sure labels are set correctly.
%               (oc_dataset is part of dd_tools which supplements PR-tools)
% C:            Slack parameter.
% varargin:     Optional parameters. Possible values:
%     'cache-size':           integer[1..1e5] / default: 40 (Memory usage)
%     'eps':                  float<0..0.1] / default: 1e-3 (Convergence
%                             criterion)
%     'weight'<label>:        float[0..1e4] / default: 1
%                             relative weight of slack per class label
%     'probability':          boolean / default: 0 (NOT TESTED!)
%                             enable probability computation
%     'shrinking':            boolean / default: 1 (NOT TESTED!)
%                             enable shrinking
%
% OUTPUT:
% w:            If we are training this becomes a mapping.
% w:            If we are testing this becomes a dataset. The feature
%               values are dummy variables. The second column of labels 
%               corresponds to the support vector responses for the target
%               class: Positive values means positive examples.
%               Note: This has been chosen to enable the use of the avgprec
%               function of the MP-tools.

if nargin < 2
    C = 1; % Set slack parameter to default value
end

if ~isdataset(D)
    warning('D must be a dataset (containing a distance matrix)');
end

% Get labels
if exist('isocset')==2 && isocset(D)
    labels = getoclab(D);
else
    labels = getlabels(D);
end

%%%%%%%%%
% Train the mapping
%%%%%%%%%
if ~ismapping(C) 

    % Correct and check labels for use in rest of function
    labels(labels==0) = -1;
    labelSet = sort(unique(labels));
    if not(length(labelSet) == 2)
        warning('Invalid number of classes: %d. It should be 2', length(labelSet));
        w = [];
        return
    end

    if not(labelSet(1) == -1 && labelSet(2) == 1)
        warning('Labels invalid. Target class must be 1 and non-target class zero or -1');
        w = [];
        return
    end

    [s1 s2 s3] = getsize(D);
    
    % Calculate weights
    [p0 p1] = calcPriors(labels);
    w0 = 1 / p0; % Weights are inverse proportional to the priors
    w1 = 1 / p1;
    
    % With parameter optimization it often happens that the data is
    % ridiculous: All zeros or ones. This function intercepts that.
    if isNonInformative(D)
        fprintf('Warning: Data is non-informative\n');
        m.dummy = 1;
        m.label = 0;
        m.nr = s2;
        w = mapping(mfilename, 'trained', m, m.label, m.nr, 1);
        w = setname(w, 'Dummy Precomputer Kernel Classifier: data non informative');
        return
    end
    
    % Do training
%     m = mexsvmtrain(+D, labels, {'probability' 0 'C' C 'kernel-type' 4 'weight-1' w0 'weight1' w1 varargin{:}});
    % m = mexsvmtrain(+D, labels, {'kernel-type' 4});
    m = svmtrain(labels, [(1:size(+D,1))', +D], sprintf('-t 4 -c %f -b 1 -w-1 %f -w1 %f', C, w0, w1));
    
    % Create mapping construct
%     m.nr = s2;
    w = mapping(mfilename, 'trained', m, labelSet, s2, length(labelSet));
    w = setname(w, 'Precomputed Kernel C-SVM classifier');
    
%%%%%%%%%
% Classify the dataset
%%%%%%%%%
else
    m = getdata(C); % Get mapping data
    
    if isfield(m, 'dummy')
        fprintf('Warning: Dummy mapping. Return random classification\n');
        dummydata = zeros(size(+D,1), 1);
        w = dataset(dummydata, labels);
        v = rand(size(+D,1),1);
        w = setdata(w, [v -v]);
        return
    end
    
    % Get prediction
%     v = mexsvmpredict(+D, m);
    
    
    % Put values in a dataset for easy use in further functions.
    % Feature values in dataset get dummy values.
    dummydata = zeros(size(+D,1), 1);
    w = dataset(dummydata, labels);
    
    [prLab accu probs] = svmpredict(dummydata, [(1:size(+D,1))', +D], m, '-b 1');
    if m.Label(2) == -1
        probs = fliplr(probs);
    end
    w = setdata(w, probs);
end
    

function [p0 p1] = calcPriors(labels)

p1 = sum(labels==1) / length(labels==1);
p0 = 1 - p1;


% Check if data is informative. This prevents from feeding the SVM
% distances which are all the same. Most likely zeros or ones. In such
% cases libsvm gets into an infinite loop.
function bool = isNonInformative(D)
if mean(std(+D)) < 0.02
    bool = 1;
else
    bool = 0;
end