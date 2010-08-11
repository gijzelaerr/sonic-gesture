%LPDD Linear programming distance data description
%
%         W = LPDD(X,NU,S,DTYPE,P)
% 
% One-class classifier put into a linear programming framework. From
% the data X the distance matrix is computed (using distance DTYPE,
% see myproxm for the possibilities). The distances are then
% transformed using a sigmoidal transformation (with parameter S,
% see the function dissim) and on this the linear machine is
% trained. The parameter NU gives the possible error on the target
% class.
%
% This function is basically a wrapper around dlpdd. See dd_ex2 to
% see how it works.
%
% See also: myproxm, dissim, dlpdd, dd_ex2
%
%@inproceedings{Pekalska2002,
%	author = {Pekalska, E. and Tax, D.M.J. and Duin, R.P.W.},
%	title = {One-class {LP} classifier for dissimilarity representations},
%	booktitle = {Advances in Neural Information Processing Systems},
%	year = {2003},
%	pages = {},
%  editor =       {S.~Becker and S.~Thrun and K.~Obermayer},
%  volume =       {15},
%  publisher = {MIT Press: Cambridge, MA}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = lpdd(x,nu,s,dtype,par)

% first set up the parameters
if nargin < 5 | isempty(par), par = 2; end
if nargin < 4 | isempty(dtype), dtype = 'd'; end
if nargin < 3 | isempty(s), s = 1; end
if nargin < 2 | isempty(nu), nu = 0.05; end
if nargin < 1 | isempty(x) % empty
	W = mapping(mfilename,{nu,s,dtype,par});
	W = setname(W,'Linear Programming Distance-data description');
	return
end

% training
if ~ismapping(nu)

	% Use all different methods:
	% First define the distance mapping:
	wd = myproxm(x,dtype,par);
	% Second the distance transformation:
	ws = dissim([],'d',s);
	% And finally do the real work in dlpdd:
	w = dlpdd(x*wd*ws,nu);

	% store the results
	W.wd = wd;
	W.ws = ws;
	W.w = w;
  	% Also set the s explicitly, useful for inspection purposes:
	ww = +ws;
	W.s = +ww{2};
	% Because I promised that all the OCCs have a threshold, it
	% should be given here:
	ww = +w;
	W.threshold = ww.threshold; 

	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),size(x,2),2);
	W = setname(W,'Linear Programming Distance-dd');
else                               %testing

	W = getdata(nu);  % unpack
	% and here we go:
	newout = x*W.wd*W.ws*W.w;

	% Copy the output of the dlpdd:
	W = setdat(x,newout,nu);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return



