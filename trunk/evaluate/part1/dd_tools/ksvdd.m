%KSVDD Support Vector Data Description on general kernel matrix
% 
%       W = KSVDD(X,FRACERR,WK)
%
% Train an SVDD on the data X, which is first mapped by mapping WK
% (see for possibilities myproxm). The mapping WK should be an
% untrained mapping! A fraction FRACERR of the data is outside the
% description.
% For examples, see dd_ex3.m.
%
% Note that this KSVDD is really slow in evaluation. This is because
% for each evaluation, not only the kernel between the test object
% and the support vectors have to be computed, but also the kernel
% between the test object and itself. This requires the construction
% of a new mapping, which is very expensive. (This is the price to
% pay to have it as general as possible...)
%       
%
%       W = KSVDD(K,FRACERR)
% 
% Train an SVDD directly on the kernel matrix K. Again, FRACERR is the
% fraction of objects outside the boundary. In order to make this
% second version work, during evaluation you have to supply a kernel
% matrix which is extended by one element.  This is because in the
% evaluation of new objects, we do not only need the kernel matrix
% between the training and testing objects, we also need all K(z,z)
% (the diagonal elements of the kernel matrix of the new objects).
% Therefore we require that the kernel matrix for evaluating is one
% wider than the training matrix. This is very annoying, but
% unavoidable, I think!
%
% See also: svdd, myproxm, dd_roc
%
%@article{Tax1999c,
%	author = {Tax, D.M.J. and Duin, R.P.W},
%	title = {Support vector domain description},
%	journal = {Pattern Recognition Letters},
%	year = {1999},
%	volume = {20},
%	number = {11-13},
%	pages = {1191-1199},
%	month = {December}
%}

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
function W = ksvdd(K,fracerr,wK)

if nargin < 3, wK = []; end
if nargin < 2 | isempty(fracerr), fracerr = 0.05; end
if nargin < 1 | isempty(K) % Empty Ksvdd
   W = mapping(mfilename,{fracerr,wK});
   W = setname(W,'k-SVDD');
   return
end

if ~ismapping(fracerr)   % training

   % Introduce outlier label for outlier class if it is not avail.
   n = size(K,1);
   if isocset(K)
      % Make -1/+1 labels from the dataset:
      signlab = getoclab(K);
		if all(signlab<0), error('SVDD needs target objects!'); end
   else
      % Assume everything is target object:
      signlab = ones(n,1);
   end

   % Check the rejection rates
	if (length(fracerr)<2) % if no bound on the outlier error is given, we
								 % do not care
		fracerr(2) = 1;
	end
	if (fracerr(1)>1)
		warning('dd_tools:AllReject',...
			'Fracrej > 1? I cannot reject more than all my target data!');
	end
	% Setup the appropriate C's
	nrtar = length(find(signlab==1));
	nrout = length(find(signlab==-1));
	s = warning('off'); % we could get divide by zero, but that is ok.
		C(1) = 1/(nrtar*fracerr(1));
		C(2) = 1/(nrout*fracerr(2));
	warning(s);

   % Depending on the function arguments, get the kernel matrix:
   if isempty(wK) %no mapping, directly K given:
      D = +K;
      wtr = [];
      dim = size(K,2);
fprintf(['\n! -----  KSVDD:  -----\n',...
'! You directly supplied a kernel matrix. That means that for evaluation\n',...
'! you need to supply one extra last column in the kernel matrix, which\n',...
'! contains the diagonal of the kernel matrix of the test objects!\n\n']);
   else  % compute the K from the mapping:
      if istrained(wK)
         error('K-svdd requires an untrained mapping WK!');
      end
      dim = size(K,2);
      wtr = K*wK;
      D = +(K*wtr);
   end
  
   % Now directly optimize the alpha's (avoid extra .m-file:)
   % Set up the parameters of the QP problem:
   K = +((signlab*signlab').*D);
   f = signlab.*diag(K);
   % check the PD of matrix and warn:
   i = -30;
   while (pd_check(K + (10.0^i)*eye(n)) == 0)
      i = i + 1;
   end
   if (i>-3)
      warning('dd_tools:HugeKernelReg',...
			'distance matrix is heavily regularized (i=%d).',i);
   end
   % i = i+2; K = K + (10.0^i)*eye(n);
   % right now proceed: 
   % equality constraints:
   A = signlab';
   b = 1.0;
   % lower and upper bounds:
   lb = zeros(n,1);
   ub = lb;
   ub(find(signlab==1)) = C(1);
   ub(find(signlab==-1)) = C(2);

   % And here we go:
   % The QP optimization:
   if (exist('qld') == 3)
	   alf = qld(2.0*K, -f, -A, b, lb, ub, rand(n,1), 1);
   else
		opt = optimset; opt.LargeScale='off'; opt.Display='off';
	   alf = quadprog(2.0*K, -f, [], [],A,b,lb,ub,rand(n,1),opt);
   end
   if isempty(alf)
      warning('dd_tools:OptimFailed','Optimization failed');
      alf = ones(n,1)/n;
   end
   %Important: change sign for negative examples:
   alf = signlab.*alf;
   % Find the support vectors:
   I = find(abs(alf)>1e-8);
   % and set small alpha's to zero (may be dangerous??)
   notI = ones(n,1); notI(I) = 0;
   alf(find(notI)) = 0;

   % Find the support vectors on the boundary:
   %J = I(find((abs(alf(I))<C) & (abs(alf(I))>0)));
   J = I(find((alf(I) < ub(I))&(alf(I) > 0)));
   if isempty(J)
	   warning('dd_tools:NoUnboundedSVs','No unbounded support vectors found!');
	   J = I(find(alf(I) > 0));
   end

   % Nice, now find the R2:
   offs = sum(sum( (alf*alf').* D));
   %offs = -0.5 * sum(sum( (alf*alf').* D));
   Dx = diag(+D) -2*sum( repmat(alf',n,1).*D ,2) + offs;
   R2 = mean(Dx(J));

   % ... and store everything:
   W.wK = wK;  % the untrained mapping
   W.wtr = wtr; % the trained mapping
   W.a = alf(I);
   W.threshold = R2;
   W.I = I;
   W.offs = offs;
   W.scale = mean(offs+Dx);

   % Wait, we may have to hack a bit when the mapping wK is not
   % provided!
   if isempty(wK)
   % Because in the evaluation of new objects, we do not only need the
   % kernel matrix between the training and testing objects, we also
   % need all K(z,z) (the diagonal elements). Therefore we require
   % that the kernel matrix for evaluating is one wider than the
   % training matrix.
      W = mapping(mfilename,'trained',W,str2mat('target','outlier'),...
         dim+1,2);
   else
      W = mapping(mfilename,'trained',W,str2mat('target','outlier'),...
         dim,2);
   end
   W = setname(W,'k-SVDD');

else                               %testing

   % Get the data:
   W = getdata(fracerr);  % unpack
   m = size(K,1);
	Korg = K;  % how to do it nicer??
	K = +K;

   % Depending if wK is defined or not:
   if isempty(W.wK)
      % Get the data from the provided kernel matrix:
      Kdiag = +K(:,end);
      D = +K(:,1:(end-1));
   else
      % Compute the diagonal elements of the kernel matrix of the test
      % objects;
      % if it is RBF, avoid this costly exercise:
      wtype = +W.wK;
      if wtype{1}=='r'
         Kdiag = ones(m,1);
      else
         Kdiag = zeros(m,1);
         for i=1:m
            Kdiag(i) = +(K(i,:)*map(K(i,:),W.wK));
   %         Kdiag(i) = +(K(i,:)*(K(i,:)*W.wK));
         end
      end
      % Now the real kernel between training and testing
      D = +(K*W.wtr);
   end
   
   % So, finally we can compute it:
   out = Kdiag - 2*sum( repmat(W.a',m,1).*D(:,W.I) ,2) + W.offs;
   newout = [out repmat(W.threshold,m,1)];

	% Store the distance as output:
	W = setdat(Korg,-newout,fracerr);
	W = setfeatdom(W,{[-inf 0] [-inf 0]});
end
return


