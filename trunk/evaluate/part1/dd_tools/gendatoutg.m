function z = gendatoutg(a,n,dR)
%GENDATOUTG Generate Gaussian distr. outlier objects
%
%       Z = GENDATOUTG(A,N)
%
% Generate N outlier objects in a Gaussian distr. round dataset A. This
% dataset should be a one-class dataset.
% Note that the original data A is not included in the
% dataset! (To do that, do:  Z = GENDATOC(A,Z); )
%
%       Z = GENDATOUTG(A,N,DR)
%
% The covariance matrix can be enlarged by a certain fraction:
% C' = dR*C_org.
%
% Default: dR = 1.5
%
% See also: make_outliers, gendatoc
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<3)
  dR = 1.5;
end

% what is our target data?
if isocset(a)
	featlab = getfeatlab(a);
	a = +target_class(a);
else
	featlab = [];
	a = +a;
end

[nra,dim] = size(a);

% 'train' the Gaussian model
meana = mean(a);
a = a - repmat(meana,nra,1);
% the C-matrix
C = dR*cov(a);

% generate new data
zdat = gauss(n,meana,C);

%label it as outliers
z = dataset(+zdat,repmat('outlier',n,1), 'featlab',featlab);
z = setname(z,'Artif. Gaussian-distr''d outliers');

return
