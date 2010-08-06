%ISCOLUMN Checks whether the argument is a column array
%
%   [OK,Y] = ISCOLUMN(X)
% 
% INPUT
% 	X   Array: an array of entities such as numbers, strings or cells
%
% OUTPUT
% 	OK  1 if X is a column array and 0, otherwise
%   Y   X or X' to ensure that Y is a column array
%
% DESCRIPTION
% Returns 1 if X is a column array and 0, otherwise. Y is the column
% version of X. If X is a matrix, an error is returned.
%
% Important: note that an array of one entity only is considered as 
% a column array. So, X = 'Apple', X = {'Apple'} or X = 1 are column
% arrays.
%

function [ok,x] = iscolumn(x)  
	s = size(x);	
  if (isstr(x)) 	% Char array
    ok = 1;
	else								% Vector of numbers
		ok = (s(1) > 1 & s(2) == 1) | all(s == 1);
		if all(s > 1)
			error('X is a matrix. A vector is expected.');
		end
	end
  if (~ok), x = x'; end
return;
