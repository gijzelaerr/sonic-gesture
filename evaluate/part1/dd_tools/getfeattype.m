function [feattype,featrange] = getfeattype(x)
%GETFEATTYPE Return the feature type (cont. or nominal)
%
%   [FEATTYPE,FEATRANGE] = GETFEATTYPE(X)
%
% Get the feature types (continuous or nominal) of dataset X, and
% their ranges when the feature type is continuous. The range is
% extracted from the dataset, but when it is not defined, it will be
% taken as max(x)-min(x). These is used in the computation of the
% Gower similarities.
%
% See also: gower, myproxm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

%DXD Should this not be a function implemented in normal Prtools?
[n,k] = getsize(x);
feattype = zeros(1,k);
featrange = zeros(1,k);

f = getfeatdom(x);
for i=1:k
	% check if the feature is nominal
	if isa(f{i},'char')
		feattype(i) = 1;
	else
		% and not, then we have to find the range of the feature:
		if isempty(f{i})
			featrange(i) = max(x(:,i))-min(x(:,i));
		else
			featrange(i) = f{i}(1,2)-f{i}(1,1);
		end
	end
end

return
