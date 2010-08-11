%LESS LESS-Classifier
%
%  LESS with distance to class means optimised per class. This in contrast
%  to LESS with variance scaling, where the optimal scaling is estimated
%  through the variance per class.
%
%   W = LESSQDC(A,C)
%
% INPUT
%   A       Dataset
%   C       Regularization parameter, C>=0
%           default: C=1
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

function w=lessqdc(a,C)

if nargin<2|isempty(C)
    C=1;
end

if nargin < 1 | isempty(a)
    w=mapping(mfilename,{C});
    w=setname(w,'LESS classifier');
    return
end

if ~ismapping(C)   % train the mapping

    [numObjects,numFeatures,numClasses]=getsize(a);

    if numClasses==2

        nlab=getnlab(a);
        x=+a;
    
        M=zeros(numClasses,numFeatures);
        D=zeros(numObjects,numFeatures,numClasses);
        
        for c=1:numClasses
            M(c,:)=mean(x(nlab==c,:),1);
        end

        % Set variable weights
        f=[ones(numFeatures*numClasses,1); repmat(C,numObjects,1)];
    
        % Put class objects together
        IX=[find(nlab==1);find(nlab==2)];

        for c=1:numClasses
            D(:,:,c)=mapmean(x(IX,:),M(c,:));
        end

        % Set class labels properly
        y=[ones(sum(nlab==1),1);-ones(sum(nlab==2),1)];

        % Set all interclass constraints
        A=[D(:,:,1).*repmat(y,1,numFeatures), -D(:,:,2).*repmat(y,1,numFeatures), -speye(numObjects)];
        b=-ones(numObjects,1);

        if numObjects>2*numFeatures+3&&numObjects>1000||exist('glpkmex')~=3
            options=optimset('Display','off','LargeScale','on','Diagnostics','off');
            [W,fval,exitflag]=linprog(f,A,b,[],[],zeros(size(f)),[],[],options);
        else
            LPX_OPT=180;
            param.round=1;
            param.itlim=100000;
            [W,dummy,status]=glpkmex(1,f,A,b,repmat('U',numObjects,1),zeros(size(f)),[],...
                                     [repmat('C',numClasses*numFeatures,1);repmat('C',numObjects,1)],param);
            exitflag=(status==LPX_OPT);
        end

        
        e=1e-8;

        d.beta=[W(1:numFeatures),W(numFeatures+1:2*numFeatures)];
        d.nr=sum(sum(d.beta,2)>e);
        d.M=M;

        w=mapping(mfilename,'trained',d,getlabels(a),numFeatures,numClasses);
    else    % multi-class classifier
		w=mclassc(x,mapping(mfilename,{C}));
    end
    w=setname(w,'LESS classifier');
else
    d=+C;
    z=mapmean(+a,d.M(1,:))*d.beta(:,1)-mapmean(+a,d.M(2,:))*d.beta(:,2);
    w=setdat(a,[-z z]);
    w=setfeatlab(w,get(w,'lablist'));
end

return


function b=mapmean(a,m)
    b=(a-repmat(m,size(a,1),1)).^2;
return;
