function [frac_SV2,alf,b,svx] = new_f_svs(sigma,x,labx,frac_error,fracsv,...
                                          thiseps);
% Support function for the training of the SVDD in the optimization
% routine for optimizing sigma.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if (nargin<6)
  thiseps = 1e-4;
end
if (nargin<5)
  fracsv = 0;
end
num_points = size(x,1);
if (nargin<4) | (frac_error<=0)
  frac_error = 1/num_points;
end

% now it is possible:
if length(frac_error)==1
  frac_error(2) = frac_error;
end

if (size(labx,2)>1)
  error('svs: Please make labx a column vector! (containing 1/-1)');
end

% OC support vector, RBF kernel:
%if exist('m_svm')
%	[svx,alf,b]=m_svm(x,labx,2,2,sigma,frac_error(1),thiseps,frac_error(2));
%else
	C = [1 1]./(num_points*frac_error(1));
	[alf,b,Dx,I] = svdd_optrbf(sigma,x,labx,C);
	svx = +x(I,:);
	alf = alf(I);
	b = -b;
%end


if (isempty(alf))
  warning('dd_tools:OptimFailed','No solution for the SVDD could be found!');
  svx = x;
  alf = ones(num_points,1)/num_points;
end

% difference between fraction SV real and desired
I = find(labx>0);
aI = find(alf>0);  % count only the target SVs
diff = fracsv + frac_error(1) - length(aI)/length(I);
frac_SV2 = diff.*diff;

return


