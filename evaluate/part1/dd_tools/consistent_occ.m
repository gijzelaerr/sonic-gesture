function [w1,optval] = consistent_occ(x,w,fracrej,range,nrbags,varargin)
%CONSISTENT_OCC
%
%     W = CONSISTENT_OCC(X,W,FRACREJ,RANGE,NRBAGS)
%
% Optimize the hyperparameters of method W. W should contain the
% (string) name of a one-class classifier. Using crossvalidation on
% dataset X (containing just target objects!), this classifier is
% trained using the target rejection rate FRACREJ and the values of
% the hyperparameter given in RANGE. The hyperparameters in RANGE
% should be ordered such that the most simple classifier comes
% first. New hyperparameters (for more complex classifiers) are used
% until the classifier becomes inconsistent. Per default
% NRBAGS-crossvalidation is used.
%
% An example for kmeans_dd, where k is optimized:
%    w = consistent_occ(x,'kmeans_dd',0.1, 1:20)
%    w = consistent_occ(x,'svdd',0.1, scale_range(x))
%
%     W = CONSISTENT_OCC(X,W,FRACREJ,RANGE,NRBAGS,P1,P2,...)
%
% Finally, some classifiers require additional parameters, they
% should be given in P1,P2,... at the end.
%
% Default: NRBAGS=5
%
% See also: scale_range, dd_crossval

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<5 | isempty(nrbags)
	nrbags = 5;
end

% Check some things:
if ~isa(w,'char')
	error('Expecting the name (string!) of the classifier');
end
if length(fracrej)>1
	error('Fracrej should be a scalar');
end
nrrange = length(range);
if nrrange<2
	error('Expecting a range of param. values (from simple to complex classifier)');
end

sigma_thr = 2;
if length(nrbags)>1  %aiaiaiaiaiaai
   sigma_thr = nrbags(2);
   nrbags = nrbags(1);
end

% Setup the consistency threshold, say the three sigma bound:
%DXD still a magic parameter!
nrx = size(x,1);
err_thr = fracrej + sigma_thr*sqrt(fracrej*(1-fracrej)/nrx);
% AI!---------------^

% Train the most simple classifier:
k = 1;
I = nrbags;
for i=1:nrbags
	% Compute the target error on the leave-out bags
	[xtr,xte,I] = dd_crossval(x,I);
	w1 = feval(w,xtr,fracrej,range(k),varargin{:});
	res = dd_error(xte,w1);
	err(i) = res(1);
end

% This one should at least satisfy the bound, else the model is already
% too complex?!
if (mean(err)>err_thr)
	warning('dd_tools:AllOCCsInconsistent',...
		'The most simple classifier is already inconsistent!');
	w1 = [];
	optval = [];
	return;
end
fracout(1) = mean(err);

% Go through the other parameter settings until it becomes inconsistent:
while (k<nrrange) & (fracout(k)<err_thr)
	k = k+1;
	I = nrbags;
	for i=1:nrbags
		% Compute the target error on the leave-out bags
		[xtr,xte,I] = dd_crossval(x,I);
		w1 = feval(w,xtr,fracrej,range(k),varargin{:});
		res = dd_error(xte,w1);
		err(i) = res(1);
	end
	fracout(k) = mean(err);
end

%% So, the final classifier becomes:
%if (fracout(k)<err_thr)
%	% The method was still consistent:
%	w1 = feval(w,x,fracrej,range(end),varargin{:});
%else
%	% This is not consistent, so take the previous solution:
%	w1 = feval(w,x,fracrej,range(k-1),varargin{:});
%end

w1 = feval(w,x,fracrej,range(k),varargin{:});

optval = range(k);

return


