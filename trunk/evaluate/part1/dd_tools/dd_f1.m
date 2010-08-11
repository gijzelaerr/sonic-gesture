function e = dd_F1(x,w)
%DD_F1 compute the F1 score 
%
%   E = DD_F1(X,W)
%   E = DD_F1(X*W)
%   E = X*W*DD_F1
%
% Compute the F1 score of a dataset, defined as:
%           2*precision*recall
%     F1 =  ------------------
%           precision + recall
%
% See also: dd_error, dd_roc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Do it the same as testc:
% When no input arguments are given, we just return an empty mapping:
if nargin==0
	
	e = mapping(mfilename,'fixed');
	return

elseif nargin == 1
	% Now we are doing the actual work, our input is a mapped dataset:

	% get the precision and recall:
	[dummy,f] = dd_error(x);

	% do some checks:
	if ~isfinite(f(1))
		warning('dd_tools:NonfiniteOutputs',...
			'The precision is not finite (all data is classified outlier)');
		e = nan;
		return;
	end
	if ~isfinite(f(2))
		warning('dd_tools:NonfiniteOutputs',...
			'The recall is not finite (no target data present?)');
		e = nan;
		return
	end
	% and compute F1:
	e = (2*f(1)*f(2))/(f(1)+f(2));

else

	ismapping(w);
	istrained(w);

	e = feval(mfilename,x*w);

end

return

