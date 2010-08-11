function w = Wstore(W)
%WSTORE Store structure W in a mapping
%
%        W = WSTORE(W)
%
% Store the structure W as it is obtained from Wstartup, Wadd and
% Wremove into a incsvdd mapping.
%
% See also: incsvdd, inckernel, Wstartup, Wadd, Wremove

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% find the dataset:
global X_incremental;
dim = size(X_incremental,2);

% store it in the correct fields:
setSV = [W.setS; W.setE];
dat.K = W.kernel;
dat.par = W.kpar;
dat.alf = W.y(setSV).*W.alf(setSV);
dat.sv = X_incremental(setSV,:);
% compute the offset for the 'real' radius computation:
K = feval(W.kernel,W.kpar,setSV,setSV);
dat.offs = sum(sum((dat.alf*dat.alf').*K));
dat.threshold = dat.offs + W.b;  % a threshold should always be defined

% finally, make the 'incvsdd' mapping:
w = mapping('incsvdd','trained',dat,str2mat('target','outlier'),dim,2);

return
