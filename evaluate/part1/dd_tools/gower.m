function s = gower(x,y,feattype,featrange)
%GOWER Gower dissimilarity
%
%    s = GOWER(X,Y,FEATTYPE,FEATRANGE)
%
% Compute the gower general similarity between two objects X and Y.
% It should work for continuous and nominal features. For easy
% application, please use the function myproxm.m.
%
% The vector FEATTYPE should indicate if the corresponding feature
% is:
%   0 : continuous
%   1 : nominal values.
% Obviously, the feattype index vector should have length d (the
% dimensionality of the feature space). To find out which features
% are continuous or nominal, use the function getfeattype.m
%
% For the continuous features, the featrange of these features should be
% specified. This can be a problem, when we have just a very few
% objects...
%
% See also: myproxm, getfeattype, dissim
%
%@article{Gower1971,
%	author = {Gower, J.C.},
%	title = {A general coefficient of similarity and some of its properties},
%	journal = {Biometrics},
%	year = {1971},
%	volume = {27},
%	pages = {857-872}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% First the checks:
[m,dim] = size(x);
[n,dim2] = size(y);
if m>1
	error('I only can handle vector x');
end
if dim~=dim2
	error('Vectors in x and y should have equal length');
end

% So now we can go:
s = zeros(n,1);
lens = zeros(n,1);
% The continuous features:
Ic = find(feattype==0);
if length(Ic)>0
	d = 1 - abs( repmat(x(1,Ic),n,1)-y(:,Ic) )./repmat(featrange(Ic),n,1);
	s = s + sum(d,2);
	lens = length(Ic);
end

% The nominal features:
In = find(feattype==1);
if length(In)>0
	z = (repmat(x(1,In),n,1)==y(:,In));
	% Kick out elements for which both x and y have 0 value.
	Iz = (repmat(x(1,In),n,1)==0)&(y(:,In)==0);
	z(Iz) = 0;
	w = dim - sum(Iz,2);
	s = s + sum(z,2);
	lens = lens + w;
end

% Finally, normalize the similarity:
s = s./lens;

return
