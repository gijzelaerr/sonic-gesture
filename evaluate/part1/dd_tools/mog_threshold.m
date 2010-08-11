%MOG_THRESHOLD Set threshold of a MoG
%
%      W = MOG_THRESHOLD(W,X,FRACREJ)
%
% Set the threshold of the Mixture of Gaussians mapping W. The threshold
% is set such that a pre-specified fraction FRACREJ of the target data X
% is rejected.
%
% I still have problems to be sure when the obtained decision boundary
% is closed around the target class...
%
% See also: mog_init, mog_update, mog_P, mogEMupdate, mogEMextend

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function w = mog_threshold(w,x,fracrej)

% setup the basic parameters:
dat = w.data;
x = +target_class(x);
n = size(x,1);

% target class distribution:
Pt = sum(mog_P(x,dat.covtype,dat.mt,dat.ict,dat.pt),2);
f = Pt;

% outlier class distribution
if isfield(dat,'mo')
	Po = mog_P(x,dat.covtype,dat.mo,dat.ico,dat.po) + 10*eps;
	s = warning('off');
		f = f./sum(Po,2);
	warning(s);
end

% see if we only have to adapt the first threshold:
q = dd_threshold(f,fracrej);

if isfield(dat,'mo') & (q<1) & (1==0)
	% then we have a problem, i.e. the decision boundary is not closed
	% around the target class and we have to adapt beta
	warning('dd_tools:OpenBoundary','No closed boundary around the target class.');
%	% base cluster:
	Pb = Po(:,1);
%	% extra specialization outlier clusters
	Pf = sum(Po(:,2:end),2);
%	[f Pt Pb Pf]
	
end

% store the results again:
dat.threshold = q;
w.data = dat;

return





