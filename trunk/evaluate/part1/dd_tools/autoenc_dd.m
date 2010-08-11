%AUTOENC_DD Auto-Encoder data description.
% 
%       W = AUTOENC_DD(A,FRACREJ,N)
% 
% Train an Auto-Encoder network with N hidden units. The network should
% recover the original data A at its output. The difference between the
% network output and the original pattern (in MSE sense) is used as a
% charaterization of the class. The threshold on this measure is optimized
% such that FRACREJ of the training objects are rejected.
% 
% Default: N=5
%
% See also datasets, mappings, dd_roc
%
%@phdthesis{Tax2001a,
%	author = {Tax, D.M.J.},
%	title = {One-class classification},
%	school = {Delft University of Technology},
%	year = {2001},
%	address = {http://www.ph.tn.tudelft.nl/\~{}davidt/thesis.pdf},
%	month = {June}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function W = autoenc_nn(a,fracrej,N)

if nargin < 3 | isempty(N), N = 5; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) % empty nndd
	W = mapping(mfilename,{fracrej,N});
	W = setname(W,'Auto-encoder neural network');
	return
end

if ~ismapping(fracrej)           %training

	a = +target_class(a);     % make sure a is an OC dataset
	[nrx,dim] = size(a);

	% set up the parameters for the network:
	minmax = [min(a)' max(a)'];
	net = newff(minmax,[N dim],{'tansig','purelin'},'trainlm');
	net = init(net);
	net.trainParam.show = inf;
	net.trainParam.lr = 0.01;
	net.trainParam.goal = 1e-5;
	net = train(net,a',a');

	% obtain the threshold:
	aout = sim(net,a');
	d = sum((a-aout').^2,2);
	W.threshold = dd_threshold(d,1-fracrej);

	%and save all useful data:
	W.net = net;
	W.scale = mean(d);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),dim,2);
	W = setname(W,'Auto-encoder neural network');

else                               %testing

	W = getdata(fracrej);  % unpack
	m = size(a,1);

	%compute distance:
	out = sim(W.net,+a')';
	out = [sum((a-out).^2,2) repmat(W.threshold,m,1)];

	%store the distance as output:
	W = setdat(a,-out,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
	
end
return


