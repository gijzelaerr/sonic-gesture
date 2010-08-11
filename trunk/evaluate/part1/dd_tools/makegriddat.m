function [griddat,x,y] = makegriddat(minx,maxx,miny,maxy,nrstepx,nrstepy)
%MAKEGRIDDAT Make uniform 2D grid.
%
% [GRIDDAT,X,Y] = MAKEGRIDDAT(MINX,MAXX,MINY,MAXY,NRSTEPX,NRSTEPY)
%
% Make a uniform 2D grid of objects and store it in a 2xN array. This
% array is not directly a PRTools dataset, but can be used for making
% a 2D plot of a user function:
%
%   grid = makegriddat(0,10,0,10);
%   out = f(grid);  % any method can be applied here.
%   plotg(grid,out);
%
% This method uses GRIDSIZE when nrstepx and nrstepy are not supplied.
%
% See also: gendatgrid, plotg

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


global GRIDSIZE;
% when GRIDSIZE is needed, but it is not defined, we have to set it
% ourselves:
if nargin<6
	if isempty(GRIDSIZE)
		nrstepy = 30;
	else
		nrstepy = GRIDSIZE;
	end
end
if nargin<5
	if isempty(GRIDSIZE)
		nrstepx = 10;
	else
		nrstepx = GRIDSIZE;
	end
end

% Now the ranges over x and y can be defined:
stepx = (maxx-minx)/(nrstepx-1);
stepy = (maxy-miny)/(nrstepy-1);

x = minx:stepx:maxx;
y = miny:stepy:maxy;

% To make the grid, we rely on a Matlab function:
[gx,gy] = meshgrid(x,y);
griddat=[reshape(gx,nrstepx*nrstepy,1), reshape(gy,nrstepx*nrstepy,1)];

return
