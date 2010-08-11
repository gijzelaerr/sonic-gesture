% Show how several one-class classifiers can be combined.
% To make the classifier outputs comparable, the outputs should be
% normalized using dd_normc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Make some data
x = target_class(gendatb([60 60]),'1');

% Train the three classifiers:
w0 = pca_dd(x,0.1,1)*dd_normc;
w1 = mog_dd(x,0.1,2)*dd_normc;
w2 = kmeans_dd(x,0.1,10)*dd_normc;

% Combine the classifiers:
W0 = [w0 w1 w2]*meanc;
W1 = [w0 w1 w2]*prodc;
W2 = [w0 w1 w2]*minc;

% Show the results:
figure(1); clf;
s = scatterd(x);
axis equal;
h0 = plotc(w0,'k');
hold on;
h1 = plotc(w1,'k');
hold on;
h2 = plotc(w2,'k');
hold on;
H0 = plotc(W0,'g');
hold on;
H0 = plotc(W1,'r');
hold on;
H0 = plotc(W2,'b');

