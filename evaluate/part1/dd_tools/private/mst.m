function [tree,A] = mst(d)
% [tree,A] = mst(d)
% minimum spanning tree
% 
% INPUT
%           d       [m x m] distance matrix
% OUTPUT
%           tree    [m-1 x 2] list of edges
%           A       [m x m] adjecency matrix
%
% See also mst_dd,datasets, mappings

%  Copyright: Piotr Juszczak, p.juszczak@tudelft.nl
%  Information and Communication Theory Group,
%  Faculty of Electrical Engineering, Mathematics and Computer Science,         
%  Delft University of Technology,            
%  The Netherlands

if isdataset(d), d = +d; end

[i,j,dd] = find(+d); %find edges
edges = [i,j];
costs = [dd]; 

% Process (x,y) points, or z points (complex).

if size(edges, 2) == 1
	if nargin == 1
		z = edges;
	elseif nargin == 2
		x = edges;
		y = costs;
		z = x + sart(-1)*y;
	end
	npts = length(z);
	[from, to] = meshgrid(1:npts, 1:npts);
	from = from(:);
	to = to(:);
	f = find(from < to);   % Unique edges only.
	from = from(f);
	to = to(f);
	edges = [from to];
	costs = abs(z(to) - z(from));
end

% Sort the edges by their cost.

[costs, indices] = sort(costs);
edges = edges(indices, :);

from = edges(:, 1);
to = edges(:, 2);

parent = 1:max(max(edges));
rank = zeros(size(parent));
keep = logical(zeros(size(parent)));

% Join sub-trees until no more links to process.

for i = 1:length(from)
	x = sfind(parent, from(i));
	parent(from(i)) = x;   % Acceleration strategy.
	y = sfind(parent, to(i));
	parent(to(i)) = y;   % Acceleration strategy.
	if x ~= y
		[parent, rank] = slink(x, y, parent, rank);
		keep(i) = ~~1;
	end
end

result = edges(keep, :);

% Check for disconnected graph, if desired.
%  For a single connected graph, everyone
%  will have the same root-parent.  Isolated
%  points are not considered part of the
%  graph system.

if (1)
	p = zeros(size(parent));
	for i = 1:length(parent)
		p(i) = sfind(parent, i);
	end
	if ~all(p == p(1))
		count = sum(diff(sort(p)) ~= 0) + 1;
		disp([' ## Not a connected graph.'])
		disp([' ## Contains ' int2str(count) ' independent graphs.'])
	end
end

% Sort indices for ease of reading.

for i = 2:-1:1
	[ignore, indices] = sort(result(:, i));
	result = result(indices, :);
end

if nargout > 0, tree = result; end

A = zeros(size(d));

for k=1:size(tree,1)
	A(tree(k,1),tree(k,2) ) = +d(tree(k,1),tree(k,2));
	A(tree(k,2),tree(k,1) ) = +d(tree(k,1),tree(k,2));
end

	

	
% ---------- sfind ---------- %


function z = sfind(p, x)

% sfind -- Root of a set.
%  sfind(p, x) returns the root parent of the set
%   containing index x, given parent-list p.  The
%   speed is O(lon(n)).

y = x;

while y ~= p(y)
	y = p(y);
end

z = p(y);


% ---------- slink ---------- %


function [p, rank] = slink(x, y, p, rank)

% slink -- Link two sets.
%  [p, rank] = slink(x, y, p, rank) links two sets,
%   whose roots are x and y, using parent array p,
%   and rank(x),  a measure of the depths of the
%   tree from root x.  The speed is O(n).

if rank(x) < rank(y)
	p(x) = y;
else
	if rank(y) < rank(x)
		p(y) = x;
	else
		p(x) = y;
		rank(y) = rank(y) + 1;
	end
end

return;