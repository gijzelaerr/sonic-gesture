function [e,f] = dd_error(x,w)
%DD_ERROR compute false positive and false negative for oc_classifier
%
%   E = DD_ERROR(X,W)
%   E = DD_ERROR(X*W)
%   E = X*W*DD_ERROR
%
% Compute the fraction of target objects rejected and the fraction of outliers
% accepted:
%    E(1) = target rejected     (error on the target class)
%    E(2) = outlier accepted    (error on the outlier class)
% for dataset X on the trained mapping W.
%
%   [E,F] = DD_ERROR(X,W)
%   [E,F] = DD_ERROR(X*W)
%   [E,F] = X*W*DD_ERROR
%
% When two outputs are requested, the second output F will contain:
%    F(1) = precision
%    F(2) = recall`
%
% See also: dd_roc, gendatoc, plotroc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Do it the same as testc:
% When no input arguments are given, we just return an empty mapping:

if nargin==0
	
	% Sometimes Prtools is crazy, but fun!:
	e = mapping(mfilename,'fixed');
	return

elseif nargin == 1
	% Now we are doing the actual work:

	% true target labels
	[nin,llin] = getnlab(x);
	Ittrue = strmatch('target',llin);
	if isempty(Ittrue), Ittrue = -1; end
	Ittrue = find(nin==Ittrue);
	% true outlier labels
	Iotrue = strmatch('outlier',llin);
	if isempty(Iotrue), Iotrue = -1; end
	Iotrue = find(nin==Iotrue);

	% classification labels:
	% (this is too slow:)
	%lout = labeld(x);
	%[nout,llout] = renumlab(lout);
	llout = getfeatlab(x);
	[mx,nout] = max(+x,[],2);
	% objects labeled target:
	It = strmatch('target',llout);
	if isempty(It), It = -1; end
	It = (nout==It);
	% objects labeled outlier:
	Io = strmatch('outlier',llout);
	if isempty(Io), Io = -1; end
	Io = (nout==Io);

	% Finally the error:
	% Warning can be off, because we like to have NaN's when one of the
	% classes is empty:
	s = warning('off');
	e(1) = sum(It(Ittrue)==0)/length(Ittrue);
	e(2) = sum(Io(Iotrue)==0)/length(Iotrue);
	warning(s);

	% compute the precision and recall when it is requested:
	if (nargout>1)
		s = warning('off');
		f(1) = sum(It(Ittrue)==1)/sum(It);
		f(2) = sum(It(Ittrue)==1)/length(Ittrue);
		warning(s);
	end

else

	ismapping(w);
	istrained(w);

	if (nargout>1)
		[e,f] = feval(mfilename,x*w);
	else
		e = feval(mfilename,x*w);
	end

end

return
