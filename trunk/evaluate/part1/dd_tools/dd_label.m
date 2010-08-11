function z = dd_label(x,w,realoutput)
%DD_LABEL classify the dataset and put labels in the dataset
%
%   Z = DD_LABEL(X,W)
%
% Compute the output labels of objects X by mapping through mapping W
% and store these labels as normal labels in Z.
%
% See also: dd_error

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<3
	realoutput = 0;
end
if nargin<2
	error('I need a dataset and mapping as input');
end

ismapping(w);
istrained(w);

% Now we are doing the actual work:
if realoutput   % we want to have the real-valued classifier output
	out = x*w;
	out = +out(:,1) - (+out(:,2));
	z = setlabtype(x,'targets');
	z = dataset(z,out);
else            % we only want to have the labels:
	lab = x*w*labeld;
	z = dataset(x,lab);
end

return
