%RANDOM_DD Random one-class classifier
% 
%       W = RANDOM_DD(A,FRACREJ)
% 
% This is the trivial one-class classifier, randomly assigning labels
% and rejecting FRACREJ of the data objects. This procedure is just to
% show the basic setup of a Prtools classifier, and what is required
% to define a one-class classifier for dd_tools.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


function W = random_dd(a,fracrej)

% Take care of empty/not-defined arguments:
if nargin < 2 fracrej = 0.05; end
if nargin < 1 | isempty(a) 
	% When no inputs are given, we are expected to return an empty
	% mapping:
	W = mapping(mfilename,{fracrej});
	% And give a suitable name:
	W = setname(W,'Random one-class classifier');
	return
end

if ~ismapping(fracrej)           %training

	a = target_class(a);     % only use the target class
	[m,k] = size(a);

	% train it:
	% This trivial classifier cannot be trained. For each object we will
	% output a random value between 0 and 1, indicating the probability
	% that an object belongs to class 'target'
	% If you would like to train something, you should do it here.

	%and save all useful data in a structure:
	W.threshold = fracrej;  % a threshold should *always* be defined
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'Random one-class classifier');

else                               %testing

	% Unpack the mapping and dataset:
	W = getdata(fracrej);
	[m,k] = size(a); 

	% This classifier only contains the threshold, nothing more.

	% Output should consist of two numbers: the first indicating the
	% 'probability' that it belongs to the target, the second indicating
	% the 'probability' that it belongs to the outlier class. The latter
	% is often the constant threshold. Note that the object will be
	% classified to the class with the highest output. In the definition
	% above, the first column was for the target, the second column for
	% the outlier class:
	newout = [rand(m,1) repmat(W.threshold,m,1)];

	% Fill in the data, keeping all other fields in the dataset intact:
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[0 inf] [0 inf]});
end
return


