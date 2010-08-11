%   DD_EX2
%
% Show the performance of a whole list of classifiers on a simple
% artificial one-class problem.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Generate data:
nrx = 50;
X = gendatb([nrx nrx]);
% Give names to the features:
X = set(X,'featlab',['height';'width ']);
% Use now class 2 as target class:
X = oc_set(X,'2');

% Split the data in training and test data:
trnr = 15;
[x,z] = gendat(X,[trnr trnr]);
% Only use target data for training,
x = target_class(x);
% and both classes for testing:
z = [z;gendatout(x,100)];

% Here we go
clf;

% Train several classifiers and plot the ROC curve:
w = parzen_dd(x,0.2);
h = plotroc(dd_roc(z*w),'b');
H(1) = h(1);

w = svdd(x,0.2,5);
h = plotroc(dd_roc(z*w),'r');
H(2) = h(1);

w = lpdd(x,0.2,5,'d',2);
h = plotroc(dd_roc(z*w),'g');
H(3) = h(1);

w = nndd(x,0.2);
h = plotroc(dd_roc(z*w),'y');
H(4) = h(1);

w = kmeans_dd(x,0.2);
h = plotroc(dd_roc(z*w),'m');
H(5) = h(1);

w = knndd(x,0.2,5);
h = plotroc(dd_roc(z*w),'k');
H(6) = h(1);

legend(H,'parzen','svdd','lpdd','nndd','kmeans','knndd')
