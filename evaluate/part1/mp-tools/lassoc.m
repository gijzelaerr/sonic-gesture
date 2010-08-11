%LASSO LASSO-Classifier
%
%   W = LASSOC(A,C,mustScale)
% 
% INPUT
%   A       Dataset
%   C       Regularization parameter, C>=0
%           default: C=1
%   MUSTSCALE
%           Boolean variable indicating whether the data must be scaled or
%           not
%           default: mustScale=1
% 
% OUTPUT
%   W       LASSO classifier 

%
%  SEE ALSO
%  MAPPINGS, DATASETS, NMC, NMSC, SVC

% Copyright: Cor J. Veenman, C.J.Veenman@uva.nl
% Computer Science Institute 
% Faculty of Science, University of Amsterdam
% Amsterdam, The Netherlands

function w = lassoc(x,lambda,mustScale)

if nargin<3
    mustScale=1;
end

if (nargin < 2) 
	lambda = 1;
end

if (nargin < 1) | (isempty(x))
	w = mapping(mfilename,{lambda,mustScale});
	w = setname(w,'LASSO classifier');
	return
end

if ~ismapping(lambda)   % train the mapping

    % Unpack the dataset.
    islabtype(x,'crisp');
    %isvaldset(x,1,2); % at least 1 object per class, 2 classes
    [n,k,c] = getsize(x);

    % Is this necessary??
    if mustScale
        %wsc = scalem(x);
        wsc = scalem(x,'variance');
        x.data = x.data*wsc;
    end

    if c == 2  % two-class classifier:

    beta=lasso(+x,3-2*getnlab(x),lambda);

    % now find out how sparse the result is:
    nr = sum(abs(beta)>1.0e-8);

    % and store the results:
    if mustScale
        W.wsc = wsc;
    end

    W.beta = beta;
    W.nr = nr;
    w = mapping(mfilename,'trained',W,getlablist(x),k,c);

    else  % multi-class wrapper
		w = mclassc(x,mapping(mfilename,{lambda,mustScale}));
    end
    
    w = setname(w,'LASSO classifier');

else
    % Evaluate the classifier on new data:
    W=getdata(lambda);

    if mustScale
        x=x*W.wsc;
    end

    out=x*W.beta;

    w=setdat(x,[out -out]);
    w=setfeatlab(w,get(x,'lablist'));
end

return
