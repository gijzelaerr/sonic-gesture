function w = dissim(a,ttype,p)
%DISSIM Dissimilarity transformations
%
%    W = DISSIM([],TTYPE,PAR)
%
% Define a mapping for a 1-to-1 transformation.
% Possible transformations TTYPE are:
% 
%      TTYPE
%  'identity','i'  out = in;
%  'd2s','s2d'     out = 1-in;                     D->S->D
%  'diag','g'      out_ij = in_ii+in_jj-2in_ij        S->D
%  'sqrt','q'      out = sqrt(1-in)                   D->S
%  'rbf','r'       out = exp(-in*in/(par(1)*par(1)))  D->S
%  'exp','e'       out = exp(-in/par(1))              D->S
%  'mlog','m'      out = -log(in/par(1))
%  'sigm','s'      out = 2/(1+exp(-in/par(1))) - 1    D->D
%  'dsigm','d'     out = 4par(1)/(1+exp(-in/par(1))) - 2par(1)    D->D
%                  ('d' is similar to 's', only a scaled version)
%
%    W = DISSIM(A,TTYPE,PAR)
%
% If a dataset A is supplied, the data is directly mapped (and thus
% no mapping is defined).
%
% Note: I agree that the name is not very fortunate, but I didn't
% have enough inspiration for a good one:-)
%
% See also: myproxm, proxm, sqeucldistm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin < 3, p = []; end
if nargin < 2, ttype = 'd2s'; end
if nargin == 0 | isempty(a)
	w = mapping(mfilename,'fixed',{ttype,p});
	w = setname(w,'Dissimilarity transformation');
	return
end

switch ttype
case {'identity','i'}
	 w = a;
case {'d2s','s2d'}
	 w = 1-a;
case {'sqrt','q'}
	 w = sqrt(1-a);
case {'rbf','r'}
	 w = exp(-a.*a/(p(1)*p(1)));
case {'exp','e'}
	 w = exp(-a/(p(1)*p(1)));
case {'mlog','m'}
	 w = -log(a/p(1));
case {'sigm','s'}
	 w = 2./(1+exp(-a/p(1))) - 1;
case {'dsigm','d'}
	 w = (4*p(1))./(1+exp(-a/p(1))) - 2*p(1);
otherwise
	 error('Transformation is unknown');
end
return

