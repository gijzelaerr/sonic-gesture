function [W,out,J] = newsvdd(a,fracrej,fracerr,param2)
% [W,out,J] = newsvdd(a,fracrej,fracerr,param2)
%
% This is another SVDD, which uses an optimized mex function to solve
% the quadratic optimization problem (libsvm). The advantage is that
% it is very fast and that very large datasets can be attacked (the
% problem is decomposed in subproblems). The drawback is that it is
% not a 'pure' SVDD. It is based on the nu-SVC and therefore tries to
% seperate the data with maximal margin from the origin. Therefore
% only for RBF-kernels the same results as in the original SVDD are
% found.
%
% This has also influence on the classifier output. Because it
% is impossible to compute the distance to the center of the (hyper)
% sphere (only a distance to the decision boundary), there is no clear
% way to transform this distance to a probability. Combining the
% outputs of this method with other outputs is therefore still
% impossible.
%
% Finally, it is also possible to give sigma directly:
% [W,out,J] = newsvdd(a,[],sigma);

% Copyright: D. Tax, R.P.W. Duin, davidt@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

sigma=[];
if nargin >= 3 & isempty(fracrej)
	sigma = fracerr;
	if nargin < 4
		fracerr = 0.0;
	else
		fracerr = param2;
	end
end
if nargin < 3 | isempty(fracerr), fracerr = 0.0; end
if nargin < 2 | isempty(fracrej), fracrej = 0.05; end
if nargin < 1 | isempty(a) % empty svdd
	W = mapping(mfilename,{fracrej,fracerr});
	W = setname(W,'New Support Vector Data Description');
	return
end

if ~ismapping(fracrej)   % training

	if (fracrej>1)
		warning('dd_tools:AllReject',...
			'Fracrej > 1? I cannot reject more than all my data!');
	end

	% be sure to have correct input:
	isdataset(a);
	[m,k,c] = getsize(a);

	% introduce outlier label for outlier class if it is not avail.
	signlab = -ones(m,1);
	I = find_target(a);
	signlab(I) = 1;

	% other parameters checking:
	if length(fracerr)>1
		error('This newsvdd cannot use different fracerr''s for target&outliers!');
	end
	if (fracerr<=0), fracerr=1/m; end
	thiseps = 1e-4;
	% correction necessary when outlier objects are in training:
	fracerr = length(I)*fracerr/m;

	if isempty(sigma)       % the user did not supply a sigma
		D = distm(a);
		maxsigma = sqrt(max(max(D)));
		minsigma = sqrt(min(min(D+maxsigma*eye(size(D,1)))));
		clear D;
		options = optimset('Display','off','TolX',0.01);
		sigma = fminbnd('new_f_svs',minsigma,maxsigma,options,...
			+a,signlab,fracerr,fracrej,thiseps);
	end
	% OC support vector, RBF kernel:
	if exist('m_svm') % my own optimizer...
		[svx,alf,b]=m_svm(+a,signlab,2,2,sigma,fracerr,thiseps);
		b = b*2; % this scaling was ignored in the m_svm optimizer,
		         % but to be consistent with the rest of the code...
	else
		% use the standard optimizer as used in svdd.m
		C = [1 1]./(m*fracerr(1));
		[alf,b,Dx,I] = svdd_optrbf(sigma,+a,signlab,C);
		% put the results in correct format:
		svx = +a(I,:);
		alf = alf(I);
		b = -b;
	end
	% how is the training set mapped?
	K = exp(-distm(+a,svx)/(sigma*sigma));
	Dx = 2*sum(K.*(ones(m,1)*alf'),2);

	% store all results
	W.s = sigma;
	W.sv = svx;
	W.a = alf;
	W.threshold = b;
	W.scale = mean(Dx);
	W = mapping(mfilename,'trained',W,str2mat('target','outlier'),k,2);
	W = setname(W,'New Support Vector Data Description');

	% supply other data if it is requested:
	if nargout>1
		out = Dx;
	end
	if nargout>2
		[dummy,J,Jb] = intersect(+a,svx,'rows');
		J = {J, alf, sigma, b, Jb};
	end
else                               %testing

	% unpack
	W = getdata(fracrej);
	[m,k,c] = getsize(a);

	% and here we go:
	K = exp(-distm(+a,W.sv)/(W.s*W.s));
	out = [2*sum(K.*repmat(W.a',m,1),2) repmat(W.threshold,m,1)];

	% here we have the mapping of the data onto the normal of the
	% decision boundary, the larger the mapping, the more it fits onto
	% the target class. It is not obvious how to map it to probability:
	newout = out;

	% Store it although it is not a density:
	W = setdat(a,newout,fracrej);
	W = setfeatdom(W,{[0 inf] [0 inf]});
end
return


