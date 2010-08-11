function [thr,frac] = dd_threshold(d,fracrej)
%DD_THRESHOLD Find percentile value for dataset
%
% thr = dd_threshold(d,frac)
%
% Find the threshold for the data d. The lowest  frac*100%  of the
% data is rejected. This method is therefore first aimed at thresholds
% for density estimates. When the highest  frac*100%  of the data
% should be rejected, you have to use:   thr = -threshold(-d,frac).
% (prctile in the statistics toolbox can also be used)

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

[nr,dim] = size(d);
if (dim>1)
	error('dd_threshold is expecting a 1D array');
end
if ((fracrej<0)|(fracrej>1))
	error('fracrej in threshold should be between 0 and 1');
end
d = sort(d);
frac = round(fracrej*nr);
if (frac==0)
	frac = 1;
	thr = d(frac);
else
	if (frac==nr)
		thr = d(frac);
	else
		thr = (d(frac) + d(frac+1))/2;
	end
end

return
