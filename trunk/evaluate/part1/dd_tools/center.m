function K = center(Ktst,Ktrn)
%CENTER Center the kernel matrix
%
%   K = CENTER(KTST,KTRN)
%
% Center the kernel matrix KTST in the kernelspace defined by KTRN.
%
%@article{Scholkopf1998,
%	author = {Bernhard Scholkopf and Alex J. Smola and Klaus-Robert
%    M{\" u}ller},
%	title = {Nonlinear Component Analysis as a Kernel Eigenvalue Problem},
%	journal = {Neural Computation},
%	year = {1998},
%	volume = {10},
%	number = {5},
%	pages = {1299-1319}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

n = size(Ktrn,1);
I = repmat(1/n,n,n);
m = size(Ktst,1);
I1 = repmat(1/n,m,n);

K = Ktst - I1*Ktrn - Ktst*I + I1*Ktrn*I;

return
