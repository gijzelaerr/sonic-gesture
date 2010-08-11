%LESS-MC: MultiClass LESS-Classifier
%
%   W = LESSMC(A,C,VARS,ESTIMATE,COMBINER,COMBINERSTYLE)
%
% INPUT
%   A         Dataset
%   C         Regularization parameter, C>=0
%             default: C=1
%   VARS      Boolean variable indicating whether or not the class variance
%             should be included in data mapping
%             default: VARS=0
%   ESTIMATE  Prototype estimate: 'median' or 'mean'
%             default: ESTIMATE='mean'
%   COMBINER  Integrated class combiner:
%               'single': one vs all (#classes subclassifiers)
%               'multi':  one vs one (#classes*#classes/2 subclassifiers)
%             default: COMBINER='single'
%   COMBINERSTYLE
%             Style for integrating the 2-class problems (see COMBINER):
%               'rigid': same sub-space for each 2-class combiner
%                        (1 subspace)
%               'flex':  optimized sub-space for each 2-class combiner
%                        (#subclassifiers subspaces)
%               'indep': fully indepent 2-class problems through 'mclassc'
%                        (#subclassifiers subspaces)
%             default: COMBINERSTYLE='rigid'
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

function w=lessmc(a,C,vars,estimate,combiner,combinerStyle)

betaTruncateThreshold=1e-8;

if nargin<6|isempty(combinerStyle)
    combinerStyle='rigid';
%    combinerStyle='flex';
end

if nargin<5|isempty(combiner)
    combiner='single';
%    combiner='multi';
end

if nargin<4|isempty(estimate)
    estimate='mean';
end

if nargin<3|isempty(vars)
    vars=0;
end

if nargin<2|isempty(C)
    C=1;
end

if nargin < 1 | isempty(a)
    w=mapping(mfilename,{C,vars,estimate,combiner,combinerStyle});
    w=setname(w,'LESS-MC classifier');
    return
end

if ~ismapping(C)   % train the mapping

    % Check function parameters
    if isempty(strmatch(lower(combiner),strvcat('single','multi'),'exact'))
        error('Unknown class combiner');
    end

    if isempty(strmatch(lower(combinerStyle),strvcat('rigid','flex','indep'),'exact'))
        error('Unknown combiner style');
    end

    [numObjects,numFeatures,numClasses]=getsize(a);

    if numClasses>2 && strcmp(lower(combinerStyle),'indep')
        w=mclassc(a,mapping(mfilename,{C,vars,estimate}),combiner);
        return;
    end

    if numClasses==2
        combiner='multi';
    end

    labs=get(a,'nlab');
    x=+a;

    M=zeros(numClasses,numFeatures);
    S=zeros(numClasses,numFeatures);

    if strcmp(lower(combiner),'single')
        M=[M;zeros(numClasses,numFeatures)];
        S=[S;zeros(numClasses,numFeatures)];
    end

    switch lower(estimate)
    case 'median'
        for c=1:numClasses
            [M(c,:),S(c,:)]=mymedian(x(labs==c,:),1);
        end
    case 'mean'
        for c=1:numClasses
            M(c,:)=mean(x(labs==c,:),1);
            if vars
                S(c,:)=var(x(labs==c,:),1);
            end
        end
        if strcmp(lower(combiner),'single')
            for c=1:numClasses
                M(numClasses+c,:)=mean(x(labs~=c,:),1);
                if vars
                    S(numClasses+c,:)=var(x(labs~=c,:),1);
                end
            end
        end
    otherwise
        error('Unknown model estimate type');
    end

    classObjects=zeros(1,numClasses);

    for c=1:numClasses
        classObjects(c)=sum(labs==c);
    end

    numDimensions=numFeatures;

    Cvector=[];
    
    C=C(:);
    if length(C)==1
        C=repmat(C,numClasses,1);
    elseif length(C)~=numClasses
        error('C should be a scalar or a vector with length equal to the number of classes');
    end
    
    switch lower(combiner)
    case 'multi'
        numObjectConstraints=0;
        if strcmp(lower(combinerStyle),'flex')
            numDimensions=0;
        end
        for i=1:numClasses-1
            for j=i+1:numClasses
                numObjectConstraints=numObjectConstraints+classObjects(i)+classObjects(j);
                Cvector=[Cvector; repmat(C(i),classObjects(i),1); repmat(C(j),classObjects(j),1)];
                if strcmp(lower(combinerStyle),'flex')
                    numDimensions=numDimensions+numFeatures;
                end
            end
        end
    case 'single'
        numObjectConstraints=numClasses*numObjects;
        for i=1:numClasses
            Cvector=[Cvector; ...
                     repmat(C(i),classObjects(i),1); ...
                     repmat(sum(C((1:numClasses)~=i)),sum(classObjects((1:numClasses)~=i)),1)];
        end
        if strcmp(lower(combinerStyle),'flex')
            numDimensions=numFeatures*numClasses;
        end
    otherwise
        error('Unknown class combiner rule');
    end

    f=zeros(numDimensions+numObjectConstraints,1);
    f(numDimensions+1:end)=1;

    b=-ones(numObjectConstraints,1);

    if ~isempty(C)
        f(1:numDimensions)=1;
        %f(numDimensions+1:end)=C;
        f(numDimensions+1:end)=Cvector;
    end

    mkSparse=numObjectConstraints>2*numDimensions+3&&numObjectConstraints>1000;

    if 0&mkSparse&numClasses==2
        IX=[find(labs==1);find(labs==2)];
        d=mapmeans(x(IX,:),M([1 2],:),S([1 2],:),vars);
        y=[ones(classObjects(1),1);-ones(classObjects(2),1)];
        A=[d.*repmat(y,1,numFeatures), -speye(numObjectConstraints)];
        f(numFeatures+(1:numObjects))=C*[(classObjects(2)/numObjects)*ones(1,classObjects(1)),...
                                         (classObjects(1)/numObjects)*ones(1,classObjects(2))];
    else
        A=zeros(numObjectConstraints,numDimensions);

        % Set all interclass constraints

        switch lower(combiner)
        case 'multi'
            constraintsOffset=0;
            dimensionsOffset=0;
            
            for i=1:numClasses-1
                for j=i+1:numClasses
                    
                    IX=[find(labs==i);find(labs==j)];

                    d=mapmeans(x(IX,:),M([i j],:),S([i j],:),vars);
        
                    num=classObjects(i)+classObjects(j);

                    y=[ones(classObjects(i),1);-ones(classObjects(j),1)];

                    %scatterd(dataset(d,y));
                    %pause;

                    A(constraintsOffset+(1:num),dimensionsOffset+(1:numFeatures))=d.*repmat(y,1,numFeatures);

                    constraintsOffset=constraintsOffset+num;
                    if strcmp(lower(combinerStyle),'flex')
                        dimensionsOffset=dimensionsOffset+numFeatures;
                    end
                end
            end
        case 'single'
            constraintsOffset=0;
            dimensionsOffset=0;
            for i=1:numClasses
                IX1=find(labs==i);
                IX2=find(labs~=i);

                d=mapmeans(x([IX1;IX2],:),M([i numClasses+i],:),S([i numClasses+i],:),vars);

                y=[ones(classObjects(i),1);-ones(numObjects-classObjects(i),1)];
                
                %scatterd(dataset(d,y));
                %pause;
                
                A(constraintsOffset+(1:numObjects),dimensionsOffset+(1:numFeatures))=d.*repmat(y,1,numFeatures);

                constraintsOffset=constraintsOffset+numObjects;
                if strcmp(lower(combinerStyle),'flex')
                    dimensionsOffset=dimensionsOffset+numFeatures;
                end
            end
        end
        A=[A -speye(numObjectConstraints)];
    end

    Aeq=[];
    beq=[];

    % Upper and lower bounds for variables
    lb=zeros(size(f));
    ub=[];

    if (~mkSparse && exist('glpkmex')==3)
        LPX_OPT=180;
        param.round=1;
        param.itlim=100000;
        [W,dummy,status]=glpkmex(1,f,A,b,repmat('U',numObjectConstraints,1),lb,ub,...
                                 [repmat('C',numDimensions,1);repmat('C',numObjectConstraints,1)],param);
        exitflag=(status==LPX_OPT);
    else
        options=optimset('Display','off','LargeScale','on','Diagnostics','off');
        [W,fval,exitflag]=linprog(f,A,b,Aeq,beq,lb,ub,[],options);
    end

    if ~isempty(W)
        W=W(1:numDimensions);
    else
        error('LP solver failed (%d)',exitflag);
    end

    d.beta=W;
    d.M=M;
    d.S=S;
    d.vars=vars;
    d.combiner=combiner;
    d.combinerStyle=combinerStyle;

    switch lower(d.combiner)
    case 'multi'
        numClassifiers=numClasses*(numClasses-1)/2;
    case 'single'
        numClassifiers=numClasses;
    end

    d.numSubspaces=1;
    if strcmp(lower(d.combinerStyle),'flex')
        d.numSubspaces=numClassifiers;
    end

    % Count (assumed) effective dimensions, taking 'flex' combining style into
    % account
    d.nr=sum(any(reshape(d.beta>betaTruncateThreshold,numFeatures,d.numSubspaces),2));
    % Remove (assumed) useless dimensions
    d.beta(d.beta<=betaTruncateThreshold)=0;

    w=mapping(mfilename,'trained',d,getlabels(a),numFeatures,numClasses);
    w=setname(w,'LESS-MC classifier');
else

    d=+C;
    numClasses=get(C,'size_out');
    numFeatures=get(C,'size_in');

    x=+a;

    dimensionsOffset=0;
    y=zeros(size(a,1),numClasses);

    count=1;

    switch lower(d.combiner)
    case 'multi'
        for i=1:numClasses-1
            for j=i+1:numClasses
                vec=d.beta(dimensionsOffset+(1:numFeatures));
                z=mapmeans(x,d.M([i j],:),d.S([i j],:),d.vars)*vec;

                len=sqrt(vec'*vec);
                if len>0
                    z=z./len;
                end

                y(:,i)=y(:,i)-z;
                y(:,j)=y(:,j)+z;

                if strcmp(lower(d.combinerStyle),'flex')
                    dimensionsOffset=dimensionsOffset+numFeatures;
                end
                count=count+1;
            end
        end
    case 'single'
        for i=1:numClasses
            vec=d.beta(dimensionsOffset+(1:numFeatures));
            z=mapmeans(x,d.M([i numClasses+i],:),d.S([i numClasses+i],:),d.vars)*vec;

            len=sqrt(vec'*vec);
            if len>0
                z=z./len;
            end

            y(:,i)=-z;

            for j=1:numClasses
                if j~=i
                %   y(:,j)=y(:,j)+z;
                end
            end

            if strcmp(lower(d.combinerStyle),'flex')
                dimensionsOffset=dimensionsOffset+numFeatures;
            end
            count=count+1;
        end
    end

    w=setdat(a,y);
    w=setfeatlab(w,get(w,'lablist'));
end

return


function b=mapmeans(a,m,s,vars)

    [n,p]=size(a);

    m1=repmat(m(1,:),n,1);
    m2=repmat(m(2,:),n,1);

    if vars
        s1=repmat(s(1,:),n,1);
        s2=repmat(s(2,:),n,1);

        %ms1=mymedian(s(1,:),2);
        %ms2=mymedian(s(2,:),2);

        ms1=mean(s(1,:),2);
        ms2=mean(s(2,:),2);

        rms1=repmat(ms1,n,p);
        rms2=repmat(ms2,n,p);
        b=(ms1+ms2)*(((a-m1).^2)./(rms1+s1)-((a-m2).^2)./(rms2+s2));
    else
        b=(a-m1).^2-(a-m2).^2;
    end

return;


function [y,s]=mymedian(x,dim)

    if nargin<2
        dim=1;
    end

    y=sort(x,dim);

    if dim==1
        y=y(floor(size(y,dim)/2)+1,:);
        s=sort((x-repmat(y,size(x,dim),1)).^2);
        s=s(floor(size(s,dim)/2)+1,:);
    else
        y=y(:,floor(size(y,dim)/2)+1);
        s=sort((x-repmat(y,1,size(x,dim))).^2);
        s=s(:,floor(size(s,dim)/2)+1);
    end


return


