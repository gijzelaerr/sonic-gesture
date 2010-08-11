function h = plotcostc(c,varargin)
%PLOTCOSTC Draw the cost curve
%
%      H = PLOTCOSTC(W,A)
%      H = PLOTCOSTC(E)
%
% Plot the cost curve of E.
%
% See also dd_costc, dd_roc, plotroc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% default settings:
mrk = 'b-';
fs = 16;
lw = 2;

% First check if we have the 'W,A' input or the 'E' input:
w = [];
if (nargin>1) & isa(c,'mapping')
	% get the second input argument...
	a = varargin{1};
	% and check if it is a dataset:
	if ~isocset(a) % it might be that W and A are reversed...
		if ~isocc(a)
			error('Plotcostc is expecting a W,A.');
		end
		% then reverse a  and w
		tmp = a;
		a = c;
		c = tmp;
	end
	if isocset(a)
		w = c;
		% then the first argument should be a classifier:
		if ~isocc(w)
			error('Now the first argument should be a OC classifier');
		end
		c = a*w*dd_roc;
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
if isdataset(c) & (nargin<2)
	error('Please compute the cost curve first by dd_costc(a*w).');
end

% Get the marker out:
if ~isempty(varargin)
	mrk = varargin{1};
	varargin(1) = [];
end

% Check the structure itself:
if ~isfield(c,'pcf') | ~isfield(c,'cost')
	error('The function plotcostc expects a structure with .pcf and .cost (i.e. use dd_costc).');
end

% finally we can plot:
h = plot(c.pcf,c.cost,mrk);
set(h,'linewidth',lw);
axis([0 1 0 0.5]);
hold on;
plot([0 1],[0 1],'k--');
plot([0 1],[1 0],'k--');
xlabel('Probability cost function','fontsize',fs);
ylabel('Normalized expected cost','fontsize',fs);

% if the operating point exist:
if isfield(c,'op')
	plot([0 1],[c.op(2) c.op(1)],'b:');
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

