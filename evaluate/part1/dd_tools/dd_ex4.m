% DD_EX4
%
% This should show the use of consistent_occ, for the optimization
% of complexity parameters of one-class classifiers. This function
% can be applied to all one-class classifiers in the toolbox, for
% instance:
%  function   range
%  knndd      1:10
%  svdd       scale_range
%  lpdd       scale_range
%  parzen_dd  scale_range  (here the automatic optimization works
%                           also quite satisfactory)

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Generate some data:
nrx = 100;
x = target_class(gendatb([nrx nrx]),'1');

% Define the error on the target class
fracrej = 0.2;

% The knndd:
% Define a useful range of scales:
range = 1:10;
% Optimize the k in the knndd using the consistency:
w_knndd = consistent_occ(x,'knndd',fracrej,range);

% The LPDD:
% Define a useful range of scales:
range = scale_range(x);
% Optimize the scale in the LPDD using the consistency:
w_lpdd = consistent_occ(x,'lpdd',fracrej,range);

% Plot the results:
figure(1); clf;
scatterd(x);
plotc(w_knndd);
plotc(w_lpdd,'r');

