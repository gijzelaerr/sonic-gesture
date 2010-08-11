% Show the difference between the supervised Mixture of Gaussians (as
% implemented in Prtools), the unsupervised mog_dd and the
% 'semi-supervised' outmog_dd where one cluster is fixed to model the
% uniform outlier distribution.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Make some data
xt = target_class(gendatb([60 60]),'1');
xo = 1.6*randn(40,2);
x = gendatoc(xt,xo);

% Train the three classifiers:
w0 = mogc(x,5);
w1 = mog_dd(x,0.1,5);
w2 = mog_dd(x,0.1,[5 2]);

% Show the results:
figure(1);
s = scatterd(x);
axis equal;
h0 = plotc(w0);
hold on;
h1 = plotc(w1,'g');
hold on;
h2 = plotc(w2,'r');
v = ver('matlab');
if str2num(v.Version)>7.0
	h0 = get(h0,'children');
	h1 = get(h1,'children');
	h2 = get(h2,'children');
end
legend([s(2) s(1) h0(1) h1(1) h2(1)],...
  'target','outlier','supervised','unsupervised','unsuperv. + outliers',0);

