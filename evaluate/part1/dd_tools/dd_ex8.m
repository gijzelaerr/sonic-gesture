% Show the interactive capabilities of the plotroc command.
%
% Generate some simple data, train a one-class classifier, make a
% scatterplot with the classifier and plot an ROC curve. Now it is
% possible to move the operating point over the ROC curve (using the
% mouse).
%
% When the operating point is defined, a new classifier can be retrieved
% and plotted in the scatterplot.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


% Generating some OC dataset:
a = oc_set(gendatb([30 30],1.9),'1');
% Train a incremental SVDD
w = incsvdd(a,0.1,'r',6);

% Make a scatterplot of the data
close all;
figure(1); h1 = scatterd(a);
plotc(w);

% Make a new plot with the ROC curve:
figure(2); h2 = plotroc(w,a);

% Give some hint what to do next:
fprintf('\n\n');
disp('Move the operating point over the ROC curve, and click when you');
disp('find a satisfactory solution. Then type: ');
disp('>> w=getrocw(h2);figure(1);plotc(w)   ');
fprintf('\n');
