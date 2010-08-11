%SVDDPATH SVDD for different lambda/C
%
%     W = SVDDPATH(A,FRACREJ,KTYPE,KPAR)
%
% Optimize the SVDD over the complete regularization path by changing C
% (or lambda). The SVDD is defined by the kernel KTYPE with parameter
% KPAR. For the definition of the kernel, see dd_kernel.m.
%
% To get the path, please have a look at svddpath_opt.m.
%
%     W = SVDDPATH(A,FRACREJ,KTYPE,KPAR,UB)
%
% Finally, you can introduce upper bounds on the weights per object by
% defining the vector UB (UB_i>0).
% bound on 
%See also: svdd, incsvdd, dd_kernel, svddpath_opt

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function W = svddpath(a,fracrej,ktype,kpar,UB)

% First set up the parameters
if nargin < 5 
	UB = [];
end
if nargin < 4 
	kpar = 1;
end
if nargin < 3 
	ktype = 'p';
end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) % empty svdd
	W = mapping(mfilename,{fracrej,ktype,kpar,UB});
	W = setname(W,'Support vector dd-path');
	return
end

if ~ismapping(fracrej) % training

	% introduce outlier label for outlier class if it is available.
	if isocset(a)
		signlab = getoclab(a);
		if any(signlab<0), error('No outliers here please.'); end
	else
		%error('SVDD needs a one-class dataset.');
      % Noo, be nice, everything is target:
      signlab = ones(size(a,1),1);
		%a = target_class(+a);
	end
	% check the rejection rates
	if (fracrej(1)>1)
		warning('dd_tools:AllReject',...
			'Fracrej > 1? I cannot reject more than all my target data!');
	end
	% Setup the appropriate C's
	nrtar = size(a,1);
	% Setup the kernel matrix
	K = dd_kernel(+a,+a,ktype,kpar);

	% Find the alpha's
	[lambda,alf,B,O] = svddpath_opt(K,nrtar*fracrej,UB);
	% get rid of this lambda:
	alf = alf/lambda(end);

	% and the offset:
	offs = sum(sum((alf*alf').*K));
	% and threshold:
	thr = diag(K(B,B)) - 2*K(B,:)*alf;
	thr = mean(thr);

	% store the results
	SV = [B; O];
	W.ktype = ktype;
	W.kpar = kpar;
	W.a = alf(SV);
	W.threshold = offs+thr;
	W.sv = +a(SV,:);
	W.offs = offs;
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),size(a,2),2);
	W = setname(W,'Support vector data description');
else                               %testing

	W = getdata(fracrej);
	m = size(a,1);
	out = zeros(m,1);

	% check if alpha's are OK
	if isempty(W.a)
		warning('dd_tools:OptimFailed','The SVDD is empty or not well defined');
	end

	% and here we go:
	K = dd_kernel(+a,W.sv,W.ktype,W.kpar);
	for i=1:m
		ai = +a(i,:);
		Kaa = dd_kernel(ai,ai,W.ktype,W.kpar);
		out(i) = W.offs + Kaa - 2*K(i,:)*W.a;
	end
	newout = [out repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(a,-newout,fracrej);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return


