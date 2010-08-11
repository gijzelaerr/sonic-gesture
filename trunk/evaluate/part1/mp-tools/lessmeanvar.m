%LESS LESS-Classifier
%
%   W = LESSC(A,C,VARS)
% 
% INPUT
%   A       Dataset
%   C       Regularization parameter, C>=0
%           default: C=1
%   VARS    Boolean variable indicating whether or not the class variance
%           should be included in data mapping
%           default: VARS=0
% 
% OUTPUT
%   W       LESS classifier 

% REFERENCES
% 1. Veenman, C.J., Tax, D.M.J., A Weighted Nearest Mean Classifier for Sparse Subspaces. 
%    Proceedings of the IEEE Computer Society Conference on Computer Vision and Pattern 
%    Recognition, San Diego, USA, June 20-25, 2005. 
%
% 2. Veenman, C.J., Tax, D.M.J., LESS: a Model-Based Classifier for Sparse Subspaces. 
%    IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 27, no. 9, 
%    pp. 1496-1500, September 2005. 

%
%  SEE ALSO
%  MAPPINGS, DATASETS, NMC, NMSC, SVC

% Copyright: Cor J. Veenman, C.J.Veenman@uva.nl
% Computer Science Institute 
% Faculty of Science, University of Amsterdam
% Amsterdam, The Netherlands

function w=lessmeanvar(a,C,kernel,estimate,normalize,combiner,combinerStyle)

betaTruncateThreshold=1e-8;

NM_Approach=0;

if nargin<7|isempty(combinerStyle)
    combinerStyle='rigid';
end

if nargin<6|isempty(combiner)
    combiner='single';
end

if nargin<5|isempty(normalize)
    normalize=1;
end

if nargin<4|isempty(estimate)
    estimate='mean';
end

if nargin<3|isempty(kernel)
    kernel=2;
end

if nargin<2|isempty(C)
    C=1;
end

if nargin < 1 | isempty(a)
    w=mapping(mfilename,{C,kernel,estimate,combiner,combinerStyle});
    w=setname(w,'LESS-XT(mean,var) classifier');
    return
end

if ~ismapping(C)   % train the mapping

    [numObjects,numFeatures,numClasses]=getsize(a);

    if numClasses==2
        combiner='multi';
    end
    
    [d.beta,d.M,d.S]=less(a,C,kernel,estimate,combiner,combinerStyle);
    d.kernel=kernel;
    d.combiner=combiner;
    d.combinerStyle=combinerStyle;

    switch lower(d.combiner)
    case 'multi'
        numClassifiers=numClasses*(numClasses-1)/2;
    case 'single'
        numClassifiers=numClasses;
    end
    
    if normalize
        x=+a;
        nlab=getnlab(a);
        dimensionsOffset=0;
        count=1;
        
        switch lower(d.combiner)
        case 'multi'
            d.scale=zeros(numClassifiers,1);
            for i=1:numClasses-1
                for j=i+1:numClasses
                    aa=dataset(x(nlab==i|nlab==j,:),nlab(nlab==i|nlab==j));
                    d.scale(count)=computeScale(gstar(aa,d.M([i j],:),d.S([i j],:),d.kernel)*d.beta(dimensionsOffset+(1:numFeatures)),aa);

                    if strcmp(lower(d.combinerStyle),'flexible')
                        dimensionsOffset=dimensionsOffset+numFeatures;
                    end
                    count=count+1;
                end
            end
        case 'single'
            d.scale=zeros(numClassifiers,1);
            for i=1:numClasses
                labs=ones(size(x,1),1);
                labs(nlab~=i)=2;
                aa=dataset(x,labs);
                d.scale(count)=computeScale(gstar(aa,d.M([i numClasses+i],:),d.S([i numClasses+i],:),d.kernel)*d.beta(dimensionsOffset+(1:numFeatures)),aa);

                if strcmp(lower(d.combinerStyle),'flexible')
                    dimensionsOffset=dimensionsOffset+numFeatures;
                end
                count=count+1;
            end
        end
    end

    numSubspaces=1;
    if strcmp(lower(d.combinerStyle),'flexible')
        numSubspaces=numClassifiers;
    end

    % Count (assumed) effective dimensions, taking 'flex' combining style into
    % account
    d.nr=sum(any(reshape(d.beta>betaTruncateThreshold,numFeatures,numSubspaces),2));
    % Remove (assumed) useless dimensions
    d.beta(d.beta<=betaTruncateThreshold)=0;

    w=mapping(mfilename,'trained',d,getlabels(a),numFeatures,numClasses);
    w=setname(w,'LESS-XT(mean,var) classifier');
else

    d=+C;
    numClasses=get(C,'size_out');
    numFeatures=get(C,'size_in');

    if NM_Approach
        % Scale dataset and class means with sqrt(beta)
        a=setdata(a,double(a) .* repmat(sqrt(d.beta)',size(a,1),1));
        d.M(1:numClasses,:)=d.M(1:numClasses,:) .* repmat(sqrt(d.beta)',numClasses,1);

        x=-(+distm(a,d.M));

    else
        dimensionsOffset=0;
        if isfield(d,'scale')
            x=ones(size(a,1),numClasses);
        else
            x=zeros(size(a,1),numClasses);
        end
        
        count=1;

        switch lower(d.combiner)
        case 'multi'
            for i=1:numClasses-1
                for j=i+1:numClasses
                    z=gstar(a,d.M([i j],:),d.S([i j],:),d.kernel)*d.beta(dimensionsOffset+(1:numFeatures));

                    if isfield(d,'scale')
                        z=sigm(z*d.scale(count));
                        x(:,i)=x(:,i).*(1-z);
                        x(:,j)=x(:,j).*z;
                    else
                        x(:,i)=x(:,i)-z;
                        x(:,j)=x(:,j)+z;
                    end

                    if strcmp(lower(d.combinerStyle),'flexible')
                        dimensionsOffset=dimensionsOffset+numFeatures;
                    end
                    count=count+1;
                end
            end
        case 'single'
            for i=1:numClasses
                z=gstar(a,d.M([i numClasses+i],:),d.S([i numClasses+i],:),d.kernel)*d.beta(dimensionsOffset+(1:numFeatures));
                
                if isfield(d,'scale')
                    z=sigm(z*d.scale(count));
                    x(:,i)=1-z;
                else
                    x(:,i)=-z;
                    for j=1:numClasses
                        if j~=i
                            x(:,j)=x(:,j)+z;
                        end
                    end
                end

                if strcmp(lower(d.combinerStyle),'flexible')
                    dimensionsOffset=dimensionsOffset+numFeatures;
                end
                count=count+1;
            end
        end
    end

    w=setdat(a,x);
    w=setfeatlab(w,get(w,'lablist'));
end

return


function scale=computeScale(mapped,a)

	reg     = 1e-7; 		% Regularization, important for non-overlapping classes.
	epsilon = 1e-6;			% Stop when change in likelihood falls below this.

	[m,k,c] = getsize(a); nlab = getnlab(a); p = getprior(a);

	%mapped = double(a*w);								% Calculate mapping outputs.
	if (c == 2) & (size(mapped,2) == 1)		
		mapped = [mapped -mapped];				% Old (perhaps unnecessary) transformation 
																			% for classifiers that give distances.
	end
	mapped = mapped(m*(nlab-1)+[1:m]');	% Select output corresponding to label
																			% (uses 1D matrix addressing).
	% Initialise variables.
	scale = 1e-10; likelihood = -inf; likelihood_new = -realmax;

	% Iteratively update scale to maximize likelihood of outputs.
	while (abs(likelihood_new - likelihood) > epsilon)
		
		% Class A is, for each object, the class the object is classified as;
		% class B stands for all other classes.
		pax = sigm(mapped*scale,1); 			% Estimate of P(class A|x).
		pbx = 1 - pax; 										% Estimate of P(class B|x).
		likelihood = likelihood_new; 
		likelihood_new = mean(p(nlab)'.*log(pax + realmin)) - reg*log(scale+1);

		% Gradient step to maximize likelihood.
		scale = scale + ((p(nlab)'.*pbx)' * mapped - reg*m/(scale+1)) / ...
								    ((p(nlab)'.*mapped.*pax)'*(mapped.*pbx) - ...
											m*reg/((scale+1)*(scale+1)) + realmin);
		%prprogress([],'scale = %8.3f: likelihood gradient = %f\n', scale, likelihood_new);
	end

	% Dirty trick to avoid 0 and inf.
	scale = min(max(scale,0.1/(std(mapped)+1e-16)),1e16);

return