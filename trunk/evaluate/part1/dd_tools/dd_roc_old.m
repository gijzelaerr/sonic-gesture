function [e,thr] = dd_roc_old(w,a,b,frac_rej)
% e = dd_roc_old(W,A,B,frac_rej)
%
% Find for a (data description) method W (trained with A) the
% Receiver Operating Characteristic curve over dataset B. The user can
% supply a vector of target rejection rates for which the ROC curve
% can be computed. These target rejection rates are then obtained for
% the training set A, and applied to the testing set B.
%
% The results are returned in e.  The first column gives the fraction
% of target objects rejected, the second column the fraction of
% outlier objects accepted.
%
% NOTE: people typically use this ROC definition: false positive FP
% (outlier accepted) on the x-axis, and true positive TP (target
% accepted) on the y-axis. You can retrieve that by using:
%   newe = [e(:,2) 1-e(:,1)]
% I choose to define my ROC curve consistent, i.e. both numbers
% indicates 'errors', so that the AUC is also easy to calculate.
%
% e = dd_roc_old(W,A)
%
% When no seperate training and testing set are given, the threshold
% is just varied over A, and the target rejection and outlier
% acceptance rates are calculated.
%
% see also dd_roc, dd_auc, dd_error.

% Copyright: D.M.J. Tax, R.P.W. Duin, davidt@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

if (nargin<4)
  frac_rej = [0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.5];
end
if (nargin==3) & (~isa(b,'dataset'))
  frac_rej = b;
  b = a;
end
if (nargin<3)
  b = a;
  frac_rej = 50;
end


% if frac_rej>1 then we just want to change the threshold, and we do
% not require a specific target rejection rate:
if max(length(frac_rej))==1 & frac_rej>1
  nrfrac = frac_rej;
  frac_rej = [];
else
  nrfrac = length(frac_rej);
end
e = zeros(nrfrac,2);

% all checks
if isa(w,'dataset')
  error('Please make W a mapping');
end

% map the labels of a and b to faster numerical labels:
%[nlaba,nlabb,lablist] = renumlab(getlab(a),getlab(b));
%a = dataset(+a,nlaba);
%b = dataset(+b,nlabb);

W = getdata(w);

if ~istrained(w)  % the mapping is untrained
    w = a*w;
end

% w should be a trained mapping, now compute the thresholds:
%if strcmp(getmapping_file(w),'nndd')
%  % Another exception, use leave-one-out from NNDD
%  W = getdata(w);
%  d =  dist2dens(log(W.fit),log(W.scale))
%else
  d = a*w;               %map the training set
%end

% check if we have sane results:
if ~all(isfinite(+d))
  error('Some strange classifier outputs: can you check your classifier?');
end

% first find out where the output for the target objects are stored:
tcolumn = strmatch('target ',getlab(w));
if tcolumn~=1
  % then we are probably using 'normal' prtools classifiers, and in
  % that case, the outputs should be normalized
  % I introduced this because I want to be sure that the classifier
  % outlier is indeed something like a 'target-class resemblance'.
  if abs(sum(sum(+d)) - size(d,1)) > 1e-9
    error('Are the classifier outputs normalized?');
  end
end
% and now extract the required 'resemblance to target set':
d = sort(+d(:,tcolumn));

% check if we have to use a logarithmic scale for the thresholds on
% the outputs, necessary for a smooth curve in for instance gauss_dd
% (it's exp(-.) result in very small values, so now and then).
if (d(end)>0 & d(end)<1e-10)
  dolog = 1;
else
  if d(end) - d(1) > 1e10
    dolog = 1;
  else
    dolog=0;
  end
end
if dolog>0
  % remove the zero entries (deadly for the log(.)):
  I = find(d==0);
  if length(I)>0
    d(I) = realmin;
  end
  d = log(d);
end
% now, do we want specific target rejection rates, or just change the
% threshold?
if isempty(frac_rej)
%  thr = linspace(d(1),d(end),nrfrac);
  N = size(a,1);
%  I = 1:(N-1)/nrfrac:N;
	I = linspace(1,N,nrfac+1);
  thr = d(round(I));
else
  frac = round(frac_rej*length(d));
  thr = zeros(nrfrac,1);  % computation thresholds:
  % take care for the extrema:
  for i=1:nrfrac
    if (frac(i)==0)
      thr(i) = d(1);
    else
      if (frac(i)==length(d))
        thr(i) = d(end);
      else
        thr(i) = (d(frac(i)) + d(frac(i)+1))/2;
      end
    end
  end
end

% use the threshold to test on set b:
[I1,I2] = find_target(b);
if isempty(I2)
  error([mfilename,': Cannot find outlier objects!']); 
end
d = b*w;
% check if we have sane results:
if ~all(isfinite(+d))
  error('Some strange classifier outputs: can you check your classifier?');
end

if dolog
  % remove the zero entries (deadly for the log(.)):
  I = find(d==0);
  if length(I)>0
    d(I) = realmin;
  end
  d = log(d);
end
for i=1:nrfrac
  e(i,1) = sum(d(I1,tcolumn)<thr(i));    % target objects rejected
  e(i,2) = sum(d(I2,tcolumn)>=thr(i));   % outlier objects accepted
end
e(:,1) = e(:,1)/length(I1);
e(:,2) = e(:,2)/length(I2);

return
