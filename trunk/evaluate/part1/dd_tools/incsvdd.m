function W = incsvdd(a,fracerr,ktype,par,kfunction)
%INCSVDD Incremental Support Vector Classifier
%
%     W = INCSVDD(A,FRACERR,KTYPE,PAR)
%
% Use the incremental version of the SVDD. The kernel is defined by
% KTYPE, with the free parameter PAR. See inckernel.m for more
% information on the available kernels and the parameters to choose.
% FRACERR defines the error on the target data.
%
%     W = INCSVDD(A,FRACERR,PAR,KTYPE)
% 
% To be consistent with the procedure consistent_occ, it is also
% possible to swap the KTYPE and the PAR. This will happen when the
% forth parameter appears to be a string type.
%
% Default: FRACERR = 0.1, KTYPE = 'p', PAR = 1
%
% See also: svdd, inckernel, Wstartup, Wadd, Wremove, Wstore
%

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin < 5 kfunction = 'inckernel'; end
if nargin < 4 par = 1; end
if nargin < 3 ktype = 'p'; end  
if nargin < 2 fracerr = 0.1; end
if nargin < 1 | isempty(a) 
  W = mapping(mfilename,{fracerr,ktype,par,kfunction});
  W = setname(W,'Increm. SVDD');
  return
end

% Alarm!: to be consistent with consistent_occ, we should be able to
% provide the complexity parameter as the third input parameter. That
% means that the kernel type should move to parameter 4. In that case we
% have to swap parameters 3 and 4, to make it standard again.
if ischar(par)
	tmp = par; par = ktype; ktype = tmp;
end

if ~ismapping(fracerr)           %training

	isdataset(a);              %train on training set
	% remove the double objects?
	[B,I] = unique(+a,'rows');
	a = a(I,:);
	% put the data in standard format:
	[n,d] = size(a);
	[nlab,llist] = getnlab(a);
	% setup the C variable:
	It = find_target(a);    % find the target objects
	if fracerr<0  % tricky trick!
		C = -fracerr;
	else
		nrtar = length(It);
		C = 1/(nrtar*fracerr);
	end
	% be sure that there are enough target objects in the beginning:
	N = floor(1/C)+1;       % this is what we need
	if (length(It)<N)
		error('Not enough target objects available to initialize the incsvdd!');
	end
	It = It(1:N);       % extract the first N objects
	astartup = a(It,:); % and use that in the startup
	a(It,:) = [];       % and remove them from the rest of the data
	a = [astartup; a];  % and glue it in front
  
	% set the labels:
	y = -ones(n,1); It = find_target(a); y(It) = +1;

	% set up the kernel:
	kpar.type = ktype;
	kpar.s = par;
	% Here the optimization comes:
	V = Wstartup(+a,y,C,kfunction,kpar);
	% store it:
	W = Wstore(V);

else                               %testing

	W = getdata(fracerr);  % unpack
	[n,d] = size(a);
	laba = getlab(a);
	orga = a;      % not very efficient, isn't it?
	a = +a;
	% this is a bit expensive, but I decide to process the dataset
	% object by object:
	global X_incremental;
	tmp_X = X_incremental;
	% the static matrix with support vectors and one new object:
	% glue one extra entry for the object to evaluate...
	X_incremental = [W.sv; zeros(1,d)];
	nra = size(W.sv,1)+1; I = 1:nra;
	out = repmat(W.offs,n,1);
	for i=1:n
		X_incremental(nra,:) = a(i,:);  % replace the last object by object from a
		wa = feval(W.K,W.par,nra,I);
		out(i) = out(i) -2*wa(1:end-1)*W.alf + wa(nra);
	end
	X_incremental = tmp_X;
	newout = [out repmat(W.threshold,n,1)];

	% Store the distance as output:
	W = setdat(orga,-newout,fracerr);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return
