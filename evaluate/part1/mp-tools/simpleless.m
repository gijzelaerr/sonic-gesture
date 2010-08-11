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
%
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

function w=lessc(a,C,vars)

if nargin<3
    vars=0;
end

if nargin<2|isempty(C)
    C=1;
end

if nargin < 1 | isempty(a)
    w=mapping(mfilename,{C,vars});
    w=setname(w,'LESS classifier');
    return
end

kernel=1;

if ~ismapping(C)   % train the mapping

    [numObjects,numFeatures,numClasses]=getsize(a);

    if numClasses~=2
        error('Only implemented for 2-class problems');
    end

    nlab=getnlab(a);
    x=+a;
    
    M=zeros(numClasses,numFeatures);
    if vars
        S=zeros(numClasses,numFeatures);
    else
        S=[];
    end

    for c=1:numClasses
        M(c,:)=mean(x(nlab==c,:),1);
        if vars
            S(c,:)=var(x(nlab==c,:),1);
        end
    end

    f=zeros(numFeatures+numObjects,1);
    f(numFeatures+1:end)=1;

    A=zeros(numObjects,numFeatures+numObjects);
    b=zeros(numObjects,1);

    % Set all interclass constraints

    % Put class objects together
    IX=[find(nlab==1);find(nlab==2)];

    d=mapmeans(x(IX,:),M,S);

    % Set class labels properly
    y=[ones(sum(nlab==1),1);-ones(sum(nlab==2),1)];

    A(1:numObjects,1:numFeatures)=d.*repmat(y,1,numFeatures);
    A(1:numObjects,numFeatures+(1:numObjects))=-eye(numObjects);
    b(1:numObjects)=-1;

    Aeq=[];
    beq=[];

    f(1:numFeatures)=1;
    f(numFeatures+1:end)=C;

    % Upper and lower bounds for variables
    lb=zeros(size(f));
    ub=[];

    if (exist('glpkmex')==0)
        LPX_OPT=180;
        param.round=1;
        param.itlim=100000;
        [W,dummy,status]=glpkmex(1,f,A,b,repmat('U',numObjects,1),lb,ub,...
                                 [repmat('C',numFeatures,1);repmat('C',numObjects,1)],param);
        exitflag=(status==LPX_OPT);
    else
        options.Display='off';
        [W,fval,exitflag]=linprog(f,A,b,Aeq,beq,lb,ub,[],options);
    end

    d.beta=W(1:numFeatures);
    d.M=M;
    d.S=S;

    d.nr=sum(d.beta>1.0e-8);

    w=mapping(mfilename,'trained',d,getlabels(a),numFeatures,numClasses);
    w=setname(w,'LESS classifier');
else

    d=+C;
    numClasses=get(C,'size_out');
    numFeatures=get(C,'size_in');

    x=zeros(size(a,1),numClasses);

    z=mapmeans(+a,d.M,d.S)*d.beta;

    x(:,1)=x(:,1)-z;
    x(:,2)=x(:,2)+z;

    w=setdat(a,x);
    w=setfeatlab(w,get(w,'lablist'));
end

return


function b=mapmeans(a,m,s)

    [n,p]=size(a);

    m1=repmat(m(1,:),n,1);
    m2=repmat(m(2,:),n,1);

    if isempty(s)
        b=(a-m1).^2-(a-m2).^2;
    else
        s1=repmat(s(1,:),n,1);
        s2=repmat(s(2,:),n,1);

        ms1=mean(s(1,:),2);
        ms2=mean(s(2,:),2);

        rms1=repmat(ms1,n,p);
        rms2=repmat(ms2,n,p);

        b=(ms1+ms2)*(((a-m1).^2)./(rms1+s1)-((a-m2).^2)./(rms2+s2));
    end

return;
