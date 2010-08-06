%TESTR MSE for regression
%
%      E = TESTR(X,W)
%      E = TESTR(X*W)
%      E = X*W*TESTR
%
% INPUT
%   X    Regression dataset
%   W    Regression mapping
%
% OUTPUT
%   E    Mean squared error
%
% DESCRIPTION
% Compute the the mean squared error of regression W on dataset X.
%
% SEE ALSO
%  RSQUARED, TESTC

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function e = testr(x,w)

if nargin==0

	e = mapping(mfilename,'fixed');
	return

elseif nargin==1

	e = mean((+x(:,1) - gettargets(x)).^2);

	if nargout==0
		%display results on the screen:
		fprintf('Mean squared error on %d objects: %f.\n',...
			size(x,1), e);
		clear e;
	end

else

	ismapping(w);
	istrained(w);

	e = feval(mfilename, x*w);

end
