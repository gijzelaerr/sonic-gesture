function w = svmcPKExp(D, params)
% w = svmcPKExp(D, params)
%
% Wrapper around svmcPK creating an exponential precomputed kernel
% function:
%
%       exp(-gamma*+D)
%
%
% D:            Dataset containing distances
% params:       Parameters
%       params(1):  C parameter (Slack)
%       params(2):  gamma parameter (default: 1 / mean(mean(+D)))


if ismapping(params) % Classification
    C = params;
    gamma = getfield(params, 'user');
else                 % Training
    C = params(1);
    if length(params) == 2
        gamma = params(2);
    else
        gamma = 1 / mean(mean(D));
    end
end

dataSet = exp(-gamma * +D);
if exist('isocset') == 2 && isocset(D)
    dataSet = dataset(dataSet, getoclab(D));
    dataSet = oc_set(dataSet, '1');
else
    dataSet = dataset(dataSet, getlabels(D));
    dataSet = oc_set(dataSet, '1');
end

w = svmcPK(dataSet, C);

% Make an Exp mapping which includes the gamma parameter
if ismapping(w)
    m = getdata(w);
    clear w;
    
    w = mapping(mfilename, 'trained', m, m.Label, size(D,2), length(m.Label));
    w = setname(w, 'exp(-gamma* Precomputed Kernel) C-SVM classifier');
    w = setfield(w, 'user', gamma);
end
