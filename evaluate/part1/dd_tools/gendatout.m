function [z,R,meana] = gendatout(a,n,dR,dontusequadprog)
%GENDATOUT Generate outlier objects
%
%       Z = GENDATOUT(A,N)
%
% Generate N outlier objects in a hypersphere round dataset A. This
% dataset should be a one-class dataset. The hypersphere is calculated
% from SVDD. Note that the original data A is not included in the
% dataset! (To do that, do:  Z = GENDATOC(A,Z); )
%
%       [Z,R] = GENDATOUT(A,N,DR)
%
% The radius can be enlarge by a certain fraction:  r' = dR*r_org.
% The resulting radius is also returned.
%
% Default: dR = 1.1
%
% See also: randsph, make_outliers, gendatoc
%
%@article{Tax2001,
%	author = {Tax, D.M.J. and Duin, R.P.W.},
%	title = {Uniform object generation for optimizing one-class classifiers},
%	journal = {Journal for Machine Learning Research},
%	year = {2001},
%	pages = {155-173}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<4)
	dontusequadprog = 0;
end
if (nargin<3)
  dR = 1.1;
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

if ~dontusequadprog
	% Compute SVDD with very big s:
	s_max = sqrt(max(max(sqeucldistm(a,a))));
	w = svdd(gendatoc(a),1/nra,s_max);
	% Get the support vectors and their weights:`
	w = +w;
	svx = w.sv;
	alf = w.a;
	nrsv = size(svx,1);
end

% Compute from SVDD the mean and radius
if (dontusequadprog) | (nrsv<=1) % no support vectors found...
	%warning('dd_tools:NoSVs','Something wrong with calculating the center in gendatout');
	meana = mean(a);
	D = sqeucldistm(a,meana);
	R = sqrt(max(D));
else % do it as it is supposed to work:
	% note that the sum_i alf_i is not always normalized:
	meana = sum(svx.*repmat(alf,1,dim))/sum(alf);
	R = sqrt(mean(sum((svx-repmat(meana,nrsv,1)).^2,2)));
end
% extend the radius if requested:
R = dR*R;
% generate new data
zdat = repmat(meana,n,1) + randsph(n,dim)*R;
%label it as outliers
z = dataset(zdat,repmat('outlier',n,1), 'featlab',featlab);
% hm, patch...?
%z.ident = num2cell(z.ident);
z = setname(z,'Artif. spherical-distr''d outliers');

return
