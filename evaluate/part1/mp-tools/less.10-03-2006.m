function [W,M,S,Slack]=less(a,par,kernel,estimate,combiner,combinerStyle)

    if nargin<6
        combinerStyle='rigid';
    end

    if nargin<5
        combiner='single';
    end

    if nargin<4
        estimate='mean';
    end

    if nargin<3
        kernel=1;
    end

    if nargin<2
        error('Error in arguments');
    end

    if isempty(strmatch(lower(combiner),strvcat('single','multi'),'exact'))
        error('Unknown class combiner');
    end

    if isempty(strmatch(lower(combinerStyle),strvcat('rigid','flex'),'exact'))
        error('Unknown combiner style');
    end

    [numObjects,numFeatures,numClasses]=getsize(a);

    if numClasses==2
        combiner='multi';
    end

    mkSparse=numClasses==2&&numObjects>2*numFeatures+3&&numObjects>1000;
    %mkSparse=numClasses==2&&numObjects>2*numFeatures+3;    

    labs=get(a,'nlab');
    a=+a;

    M=zeros(numClasses,numFeatures);
    S=zeros(numClasses,numFeatures);

    if strcmp(lower(combiner),'single')
        M=[M;zeros(numClasses,numFeatures)];
        S=[S;zeros(numClasses,numFeatures)];
    end

    switch lower(estimate)
    case 'median'
        for c=1:numClasses
            [M(c,:),S(c,:)]=median1(a(labs==c,:),1);
        end
    case 'mean'
        for c=1:numClasses
            M(c,:)=mean(a(labs==c,:),1);
            S(c,:)=var(a(labs==c,:),1);
        end
        if strcmp(lower(combiner),'single')
            for c=1:numClasses
                M(numClasses+c,:)=mean(a(labs~=c,:),1);
                S(numClasses+c,:)=var(a(labs~=c,:),1);
            end
        end
    case 'mean2'
        MM=mean(a,1);
        for c=1:numClasses
            M(c,:)=mean(a(labs==c,:),1)-MM;
            S(c,:)=var(a(labs==c,:),1);
        end
    otherwise
        error('Unknown model estimate type');
    end

    classObjects=zeros(1,numClasses);

    for c=1:numClasses
        classObjects(c)=sum(labs==c);
    end

    numDimensions=numFeatures;

    switch lower(combiner)
    case 'multi'
        numObjectConstraints=0;
        if strcmp(lower(combinerStyle),'flex')
            numDimensions=0;
        end
        for i=1:numClasses-1
            for j=i+1:numClasses
                numObjectConstraints=numObjectConstraints+classObjects(i)+classObjects(j);
                if strcmp(lower(combinerStyle),'flex')
                    numDimensions=numDimensions+numFeatures;
                end
            end
        end
    case 'single'
        numObjectConstraints=numClasses*numObjects;
        if strcmp(lower(combinerStyle),'flex')
            numDimensions=numFeatures*numClasses;
        end
    otherwise
        error('Unknown class combiner rule');
    end

    f=zeros(numDimensions+numObjectConstraints,1);
    f(numDimensions+1:end)=1;
    %b=zeros(numObjectConstraints,1);

    b=-ones(numObjectConstraints,1); %%% ????

    if ~isempty(par)
        f(1:numDimensions)=1;
        f(numDimensions+1:end)=par;
    end
    
    if mkSparse
        IX=[find(labs==1);find(labs==2)];
        d=gstar(a(IX,:),M([1 2],:),S([1 2],:),kernel);
        y=[ones(classObjects(1),1);-ones(classObjects(2),1)];        
        A=[d.*repmat(y,1,numFeatures), -speye(numObjectConstraints)];
        f(numFeatures+(1:numObjects))=par*[(classObjects(2)/numObjects)*ones(1,classObjects(1)),(classObjects(1)/numObjects)*ones(1,classObjects(2))];
    else        
        A=zeros(numObjectConstraints,numDimensions+numObjectConstraints);

        % Set all interclass constraints

        switch lower(combiner)
        case 'multi'
            constraintsOffset=0;
            dimensionsOffset=0;
            for i=1:numClasses-1
                for j=i+1:numClasses
                    IX=[find(labs==i);find(labs==j)];

                    d=gstar(a(IX,:),M([i j],:),S([i j],:),kernel);

                    num=classObjects(i)+classObjects(j);

                    y=[ones(classObjects(i),1);-ones(classObjects(j),1)];

                    A(constraintsOffset+(1:num),dimensionsOffset+(1:numFeatures))=d.*repmat(y,1,numFeatures);

                    A(constraintsOffset+(1:num),numDimensions+constraintsOffset+(1:num))=-eye(num); 

                    %f(numDimensions+constraintsOffset+(1:num))=par*[(classObjects(j)/num)*ones(1,classObjects(i)),(classObjects(i)/num)*ones(1,classObjects(j))];
                    %b(constraintsOffset+(1:num))=-1;

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

                d=gstar(a([IX1;IX2],:),M([i numClasses+i],:),S([i numClasses+i],:),kernel);

                y=[ones(classObjects(i),1);-ones(numObjects-classObjects(i),1)];

                A(constraintsOffset+(1:numObjects),dimensionsOffset+(1:numFeatures))=d.*repmat(y,1,numFeatures);
            
                A(constraintsOffset+(1:numObjects),numDimensions+constraintsOffset+(1:numObjects))=-eye(numObjects);
                %b(constraintsOffset+(1:numObjects))=-1;

                %f(numDimensions+constraintsOffset+(1:numObjects))=par*[((numObjects-classObjects(i))/numObjects)*ones(1,classObjects(i)),((classObjects(i))/numObjects)*ones(1,numObjects-classObjects(i))];

                constraintsOffset=constraintsOffset+numObjects;
                if strcmp(lower(combinerStyle),'flex')
                    dimensionsOffset=dimensionsOffset+numFeatures;
                end
            end
        end
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
        Slack=W(numDimensions+1:end);
        W=W(1:numDimensions);
    else
        error('LP solver failed (%d)',exitflag);
    end

return

