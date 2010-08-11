% DD_EX5
%
% Show the use of the distance mappings, the dissimilarity
% transformation, and the dlpdd.
%
% The function lpdd transforms the normal feature data to distance
% data using the proximity mapping myproxm. In some cases the user
% might have home-made distance data, and wants to apply the classifier
% directly on this distance data. In that case he/she should use the
% function dlpdd.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% First, see how the explicit construction of distances work:
% Generate some interesting data:
x = target_class(gendatb([40 20]),'1');

% Define the distance (squared Euclidean to dataset x):
wd = myproxm(x,'d',2);
% Define a nonlinear transformation of these distances:
ws = dissim([],'d',5);
% and finally train a real one-class classifier:
w = dlpdd(x*wd*ws,0.1);

% Now in Prtools you can nicely combine it to a new mapping:
W = wd*ws*w;

% So finally plot this mapping:
figure(1);
scatterd(x);
plotc(W);

% Compare this result which the lpdd where the distances are computed
% using the build-in  myproxm
% Of course, this should be the same as above...
w1 = lpdd(x,0.1,5,'d',2); % LPDD on squared Eucl. distances.
figure(2);
scatterd(x);
plotc(w1,'r');

% To make a solution similar to the Bennett paper:
% (in this paper the data is mapped using an RBF kernel, and a linear
% separation plane is fitted which separates the data as well as 
% possible from the origin. This can be simulated by the LPDD by
% transforming the RBF 'similarities' to dissimilarities using the 
% 'd2s' (see dissim))
wr = myproxm(x,'r',5);    % RBF similarity
wmin = dissim([],'d2s');  % make dissimilarity
w = dlpdd(x*wr*wmin,0.1); % train the LPDD on this
W2 = wr*wmin*w;           % combine it to one big mapping

% And show the results:
figure(3); scatterd(x);   
plotc(W2);                % and plot the mapping



