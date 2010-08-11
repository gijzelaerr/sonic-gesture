function [b,blck] = make_outliers(a,n,scale)
% MAKE_OUTLIERS
%
%   [B,BLCK] = MAKE_OUTLIERS(A,N,SCALE)
%
% Add an uniform block-shaped outlier distribution to the given OC
% dataset A and create a new dataset B. Dataset should contain a target
% class (with the label 'target').  All other data will be deleted. The
% N new outliers will be drawn from a block defined around dataset A.
% The size of the box can be adjusted by scale (default 2, which means
% the edge of the box is twice the maximum distance in the respective
% feature direction).
%
% When N=0 is given, no outliers are created, but the dataset with
% only the first class is created and the box is computed.
%
%   [B,BLCK] = MAKE_OUTLIERS(A,N,BLCK)
% 
% The user now defines the block where the data should be created. The
% format of the block is   BLCK=[minx max; miny maxy ] 
%
%   [B,BLCK] = MAKE_OUTLIERS(A)
%
% Now the same number of target objects and outlier objects are
% created.
%
% In the case of 2D data is also possible to use a grid of objects. In
% that case N should be <0.
%
% See also: gendatoc, gendatgrid
%
%@article{Tax2001,
%	author = {Tax, D.M.J. and Duin, R.P.W.},
%	title = {Uniform object generation for optimizing one-class classifiers},
%	journal = {Journal for Machine Learning Research},
%	year = {2001},
%	pages = {155-173}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<3)
  scale = 2.0;
end
if (nargin<2)  % if no required number is given, copy from a:
  n = size(a,1);
end

% Well, find the target class:
a = target_class(a);
[m,k] = size(a);

% Create the outlier box:
if (max(size(scale))>1)         % the block is known
	blck = scale;
else
	blck = [min(a)' max(a)'];     % the block has to be defined
	df = diff(blck,1,2);
	meanval = mean(blck,2);
	newscale = scale/2;
	blck = [meanval-newscale*df, meanval+newscale*df];
end

%DXD this can be made more efficient using gendatoc, I think...

% Combine it to a dataset:
if (n>0)  % we randomly draw uniform data:
	b = [+a; (ones(n,1)*blck(:,1)') + ...
	     (ones(n,1)*diff(blck,1,2)').*rand(n,k)];
else      % we make a nice 2D grid:
	if k==2
		grid = gendatgrid([],[30 30],blck(:,1),blck(:,2));
		b = [+a; grid];
		n = size(grid,1);
	else
		error('Data should be 2D');
	end
end

% Now create the new dataset:
lablist = str2mat('target','outlier');
labb = [ones(m,1); 2*ones(n,1)];
b = dataset(b,lablist(labb,:));
b = setfeatlab(b,getfeatlab(a));
b = setname(b, 'Data with artificial box-distr. outliers');

return
