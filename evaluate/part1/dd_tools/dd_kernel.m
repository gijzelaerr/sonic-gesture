function K = dd_kernel(A,B,ktype,kpar);
%DD_KERNEL Kernel definition
%
%              K = DD_KERNEL(A,B,KTYPE,KPAR);
%
% Computation of the kernel function. The datasets A and B are expected
% to be standard Matlab matrices (NOT datasets).
%
% The kernel is defined by the kernel type KTYPE, and its parameter KPAR.
%        KTYPE   defines the kernel type
%       'linear'       | 'l': A*B'
%       'polynomial'   | 'p': sign(A*B'+1).*(A*B'+1).^KPAR
%       'exponential'  | 'e': exp(-(||A-B||)/KPAR)
%       'radial_basis' | 'r': exp(-(||A-B||.^2)/(KPAR*KPAR))
%       'sigmoid'      | 's': sigm((sign(A*B').*(A*B'))/KPAR)
%       'distance'     | 'd': ||A-B||.^KPAR
%             when more than 1 free parameter is required, then par.s
%             can be a vector of length 2 or more.
%
% See also: inckernel, svddpath, myproxm, svddpath_opt

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
% See also: incsvdd, proxm, Wstartup, Wadd

switch ktype
case {'linear' 'l'}
	K = A*B'; 
case {'polynomial' 'p'}
	K = A*B'; 
	if kpar ~= 1
		[n,d] = size(A);
		[m,d] = size(B);
		if kpar ~= round(kpar)
			K = K + ones(n,m);
			K = sign(K).*abs(K).^kpar;
		else
			K = K + ones(n,m);
			K = K.^kpar;
		end
	end
case {'sigmoid' 's'}
	K = A*B'; 
	if length(kpar)>1
		K = sigm(K/kpar(1) + kpar(2));   %DXD: I need this sometimes
	else
		K = sigm(K/kpar);
	end
case {'exponential' 'e'}
	K = sqeucldistm(A,B);
	J = find(K<0);
	K(J) = zeros(size(J));
	K = exp(-sqrt(K)/kpar);
case {'radial_basis' 'r'}
	K = sqeucldistm(A,B);
	J = find(K<0);
	K(J) = zeros(size(J));
	K = exp(-K/(kpar*kpar));
case {'inv_radial_basis' 'i'}
	K = sqeucldistm(A,B);
	J = find(K<0);
	K(J) = zeros(size(J));
	K = exp(sqrt(K)/kpar);
case {'distance' 'd'}
	K = sqeucldistm(A,B);
	J = find(K<0);
	K(J) = zeros(size(J));
	if kpar ~= 2
		K = K.^(kpar/2);
	end
otherwise
	error(sprintf('Unknown proximity type: %s',ktype))
end

return
