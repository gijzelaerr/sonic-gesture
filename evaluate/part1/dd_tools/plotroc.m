function h = plotroc(e,varargin)
%PLOTROC Draw an ROC curve
%
%     H = PLOTROC(W,A)
%     H = PLOTROC(E)
%
% Plot the roc curve of E according to the 'traditional' way: on the x
% axis we put the false positive (outliers accepted) and on the y axis
% we put the true positive (targets accepted).
%
% By supplying W and A explicitly, you get some added functionality, in
% the sense that you can change the operating point and retrieve the new
% classifier. You can retrieve the classifier using GETROCW:
%
%   a = oc_set(gendatb,'1');
%   w = gauss_dd(a,0.1);
%   h = plotroc(w,a);
%   % Move the operating point over the ROC curve and click on the
%   % desired position. Then type:
%   w2 = getrocw(h);
%
% The mapping w2 now contains the same classifier w, only with a changed
% operating point.
%
%     H = PLOTROC(W,A,LINESTYLE)
%     H = PLOTROC(E,LINESTYLE)
%
% When required, a third (second) argument can be given, indicating the
% color, LINESTYLE and markers of the plot. See 'plot' for the
% possibilities.
%
% See also dd_error, dd_roc, dd_auc, getrocw

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% default settings:
mrk = 'b-';
fs = 16;
lw = 2;

% First check if we have the 'W,A' input or the 'E' input:
w = [];
if (nargin>1) & isa(e,'mapping')
	% get the second input argument...
	a = varargin{1};
	% and check if it is a dataset:
	if ~isocset(a) % it might be that W and A are reversed...
		if ~isocc(a)
			error('Plotroc is expecting a W,A.');
		end
		% then reverse a  and w
		tmp = a;
		a = e;
		e = tmp;
	end
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
	end
end
% avoid plotting just a*w
if isdataset(e) & (nargin<2)
	error('Please compute the ROC curve first by dd_roc(a*w).');
end

% Get the marker out:
if ~isempty(varargin)
	mrk = varargin{1};
	varargin(1) = [];
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
	threshold = [];
	op = [];
end

% transpose e if required:
if size(e,1)==2
	e = e';
end

% and here we plot:
%h = loglog(e(:,2), 1-e(:,1),mrk);
h = plot(e(:,2), 1-e(:,1),mrk);
set(h,'tag','curve');
xlabel('outliers accepted (FPr)','fontsize',fs);
ylabel('targets accepted (TPr)','fontsize',fs);
% and the extra feature: plot the operating point!
if ~isempty(op)
	hold on; h_op=plot(op(2),1-op(1),'.');
	set(h_op,'tag','OP');
	sz = get(h_op,'markersize');
	set(h_op,'color',get(h,'color'),'markersize',3*sz);

	hold on; h_op=plot(op(2),1-op(1),'o');
	set(h_op,'tag','currpoint');
	set(h_op,'color',get(h,'color'),'markersize',round(1.5*sz));
	coords = [coords(:,2) 1-coords(:,1)];
end
set(h,'linewidth',lw);
UD.h_title = title('');

% Want this in most cases:
axis([0 1 0 1]);
hold on;

% Store the thresholds and positions in the userfield (when requested)
if ~isempty(w)
	UD.thresholds = thresholds;
	UD.coords = coords;
	set(gcf,'UserData',UD);
	plotroc_update(w,a);
end

% process the other options like linewidth etc
if ~isempty(varargin)
	while(length(varargin)>1)
		set(h,varargin{1},varargin{2});
		varargin(1:2) = [];
	end
end

% If no handles are requested, remove them:
if nargout==0
  clear h;
end

return
