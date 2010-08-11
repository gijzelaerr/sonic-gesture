function ll = dd_loglikelihood(x,w)
%DD_LOGLIKELIHOOD
%
%    LL = DD_LOGLIKELIHOOD(X,W)
%
% Compute the loglikelihood LL for a density model W on dataset X. It is
% assumed that you supply a sensible mapping W (gauss_dd, mog_dd,
% parzen_dd ...). If not, you might get interesting outputs out...

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Do it the same as testc:
% When no input arguments are given, we just return an empty mapping:
if nargin==0
	
	% Sometimes Prtools is crazy, but fun!:
	ll = mapping(mfilename,'fixed');
	return

elseif nargin == 1
	% Now we are doing the actual work:
	
	% check if we have a dataset
	if isdataset(x)
		% true labels
		[nin,llin] = getnlab(x);
		% the feature labels
		llout = getfeatlab(x);

		% match both labels:
		m = size(x,1);
		c = size(llout,1); % number of classes in out-labels
		J = zeros(m,c);    % put 1 at the correct label pos.
		for i=1:c          % go over all output labels
			classlab = llout(i,:);
			if ischar(classlab)
				classlab = deblank(classlab);
			end
			k = strmatch(classlab,llin); % find the same objects in llin
			if ~isempty(k)
				I = find(nin==k);
				J(I,i) = 1;
			end
		end

		% now add the outputs:
		if any(+x<0)
			warning('dd_tools:LogNegativeOutputs',
				'It seems the classifier is already log(p(x)), so no log is applied.');
			ll = sum(sum(+x.*J))/m;
		else
			ll = sum(sum(log(+x).*J))/m;
		end
	else
		% we don't have a dataset, so we cannot match the correct output,
		% so now just add the output??
		error('No dataset given, no idea what to do now.');
	end
	
else

	ismapping(w);
	istrained(w);

	if (nargout>1)
		ll = feval(mfilename,x*w);
	else
		ll = feval(mfilename,x*w);
	end

end

return
