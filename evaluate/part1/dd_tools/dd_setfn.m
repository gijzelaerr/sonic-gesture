function w = dd_setfn(w,a,thr)
%DD_SETFN Set the threshold to a specific FN rate
%
%     W2 = DD_SETFN(W,A,THR)
%
% The data of classifier W is copied to classifier W2, only the
% threshold value is changed to achieve the False Negative rate THR
% on dataset A.
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if ~isocc(w)
	error('dd_setfn: I need a one-class classifier to set the threshold');
end
if ~isocset(a)
	error('dd_setfn: I should have a OC-dataset to set the threshold');
end
if thr<0 | thr>1
	error('dd_setfn: the threshold should be between 0 and 1.');
end
% find the threshold on the target data:
a = target_class(a);
if isempty(a)
	error('dd_setfn: I cannot find target data in the dataset.');
end

% Get the output data:
out = a*w;

% Check if we have distance based output:
featdom = getfeatdom(out);
if (featdom{1}==[-inf 0]) & (featdom{2}==[-inf 0])
	thr = dd_threshold(out(:,1),thr);
	thr = -thr;
else
	thr = dd_threshold(out(:,1),thr);
end

% Change the threshold:
UD = w.data;
UD.threshold = thr;
w = setdata(w,UD);

return
