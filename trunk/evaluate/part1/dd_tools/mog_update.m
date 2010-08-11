function w = mog_update(w,x,maxiter)
%MOG_UPDATE Train a MoG
%
%     W = MOG_UPDATE(W,X,MAXITER)
%
% Fit a Mixture of Gaussians model W to data X, for MAXITER number of EM
% steps.
%
% See also: mog_dd, mog_init, mog_P, mog_extend, mogEMupdate

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% unpack it:
dat = w.data;
[xt,xo] = target_class(x);
% update the target class clusters:
[dat.mt,dat.ict,dat.pt] = mogEMupdate(+xt,dat.covtype,...
	dat.mt,dat.ict,dat.pt,maxiter,0,dat.reg);
% update the outlier class clusters:
if isfield(dat,'mo') & ~isempty(xo)
	[dat.mo,dat.ico,dat.po] = mogEMupdate(+xo,dat.covtype,...
		dat.mo,dat.ico,dat.po,maxiter,1,dat.reg);
end
% pack it and return:
w.data = dat;

return
