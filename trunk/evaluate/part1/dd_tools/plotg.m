function h = plotg(grid,z,nrc)
%PLOTG Plot the function values z on a 2D grid
%
%    h = plotg(grid,z)
%
% Plot the function values given in z on the 2D grid. The grid is a
% 2xN dataset, where N is nxn. Vector z has therefore also length N.
%
%    h = plotg(grid,z,clrs)
%
% By setting clrs the number of colors can be changed (default
% clrs=10).
%
% In case you are only interested in the decision boundary, use
%
%    h = plotg(grid,z,1)
%
% see also: makegriddat, gendatgrid, plotw

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<3
	nrc = 10;
end

% I want to be able to handle datasets
if isdataset(grid)
	grid = +grid;
end
if isdataset(z)
	z = +z;
end

% first determine the sizes of the grid:
lx = length(find(grid(:,2)==grid(1,2)));
ly = size(grid,1)/lx;
% and extract the exact x and y positions:
x = grid(1:ly:end,1);
y = grid(1:ly,2)';

% see if z has the right size
if (size(z,2)>2)
	error('Data z should not have more that two features (sorry).');
end

% If we have two outputs, then we have to use the difference:
if (size(z,2)==2)
	z = z(:,1) - z(:,2);
end

% Special case if we just want the decision boundary:
hold on;
if (nrc==1) | ischar(nrc)
	if nrc==1, nrc = 'k'; end
	[c,h] = contour(x,y,reshape(+z,ly,lx),[0 0],nrc);
else
	[c,h] = contourf(x,y,reshape(+z,ly,lx),nrc);
end

% When we have two outputs, we know we have a decisioun boundary:
%if (size(z,2)==2) | (nrc>1)
%	hold on;
%	[c2,h2] = contour(x,y,reshape(+z,ly,lx),[0 0]);
%	set(h2,'linewidth',2,'edgecolor','y','linestyle','-');
%end

% to avoid annoying outputs:
if nargout==0
	clear h;
end

return
