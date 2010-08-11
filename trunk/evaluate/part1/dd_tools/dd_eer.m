%EER Equal error rate
%
%    E = DD_EER(R)
%    E = A*W*DD_EER
%
% Compute the Equal error rate for ROC-curve R, or from the roc-curve
% derived from dataset A applied to (one-class) classifier W. Output E
% returns two values, the FPr and the FNr. In the case the ROC curve is
% sampled very well, these two values should be equal. In the case the
% ROC curve is very poorly sampled, both values may be much different.
% In these cases you probably want to use the average of the two, i.e.
% mean(e).
%
% See also: dd_roc, dd_error, dd_auc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function e = dd_eer(a,w)

if nargin==0
	e = mapping(mfilename,'fixed');

elseif nargin==1

	if isocset(a)
		a = a*dd_roc;
	end
	if ~isa(a,'struct')
		error('I expect a roc curve structure.');
	end
	if ~isfield(a,'err')
		error('I expect a roc curve.');
	end
	err = abs(a.err(:,1)-a.err(:,2));
	[minerr,I] = min(err);
	e = a.err(I,:);

else
	ismapping(w);
	istrained(w);

	e = feval(mfilename,a*w);
end

return
