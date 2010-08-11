function askerplot(e,varargin)
%ASKERPLOT Plot FP and FN
%
%    ASKERPLOT(E)
%    ASKERPLOT(W,A)
%
% Plot the false positive and false negative rate as function of the
% thresholds. Input parameter E is typically obtained using:
%    E = A*W*DD_ROC
%
% See also plotroc, dd_error, dd_roc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% default settings:
mrk = 'b-';
fs = 16;
lw = 2;

% First check if we have the 'W,A' input or the 'E' input:
w = [];
if nargin>1
	% get the second input argument...
	a = varargin{1};
	% and check if it is a dataset:
	if isdataset(a) & ismapping(e)
		if isocset(a)
			w = e;
			% then the first argument should be a classifier:
			if ~isocc(w)
				error('Now the first argument should be a OC classifier');
			end
			e = a*w*dd_roc;
			% remove the second argument:
			N = length(varargin);
			if N<=2
				varargin = {};
			else
				varargin = varargin(3:N);
			end
		else
			error('I am expecting a one-class dataset');
		end
	end
else
	error('I am expecting ASKERPLOT(W,A)');
end

% Get the marker out:
if ~isempty(varargin)
	mrk = varargin{1};
end

% Check if we got the new error structure containing an error and
% threshold field:
if isfield(e,'err')
	if ~isfield(e,'thresholds')
		error('The structure E should have an "err" and "thresholds" field.');
	end
	thresholds = e.thresholds;
	coords = e.thrcoords;
	op = e.op;
	e = e.err;
else
	thresholds = [];
	op = [];
end

% transpose e if required:
if size(e,1)==2
	e = e';
end

% and here we plot:
if isempty(thresholds)
	h = semilogy(e(:,1),'r-');
	set(h,'linewidth',lw);
	hold on;
	h = semilogy(e(:,2),'b-');
	set(h,'linewidth',lw);
else
	thresholds=thresholds(2:end);
	h = semilogy(thresholds,e(:,1),'r-');
	set(h,'linewidth',lw);
	hold on;
	h = semilogy(thresholds,e(:,2),'b-');
	set(h,'linewidth',lw);
end
xlabel('Thresholds','fontsize',fs);
ylabel('FP (blue) and FN (red)','fontsize',fs);
grid on;


