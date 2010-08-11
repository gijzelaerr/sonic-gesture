function w = lessr(x,C,k)

betaTruncateThreshold=1e-8;

if (nargin<3)
    k=3;
end

if (nargin<2) 
	C = 1;
end

if (nargin < 1) | (isempty(x))
	w = mapping(mfilename,{C});
	w = setname(w,'LESS regressor');
	return
end

if ~ismapping(C)   % train the mapping

    size(x)
    x=+x;
    y=x(:,1);
    x=x(:,2:end);
    numSubspaces=1;
    
    [numObjects, numFeatures]=size(x);
    dm=repmat(y,1,numObjects)-repmat(y',numObjects,1);
    dm=dm.*dm;
    
    dm(eye(numObjects)==1)=NaN;
    
    [z,I]=sort(dm,2);
    
    I=I(:,1:k);
    
    numObjectConstraints=numObjects*numObjects;
    
    f=ones(numFeatures+numObjectConstraints,1);
    f(numFeatures+1:end)=C;
    
    A=[];
    b=[];
    A=repmat(
    for i=1:numObjects
        for j=1:numObjects
            dx=(x(i,:)-x(j,:)).^2;
            A=[A; -dx];
            b=[b; -(y(i)-y(j)).^2];
        end
    end

    A=[A, -speye(numObjectConstraints)];

    Aeq=[];
    beq=[];

    % Upper and lower bounds for variables
    lb=zeros(size(f));
    ub=[];

    options=optimset('Display','off','LargeScale','on','Diagnostics','off');
    [W,fval,exitflag]=linprog(f,A,b,Aeq,beq,lb,ub,[],options);
exitflag
    if ~isempty(W)
        Slack=W(numFeatures+1:end);
        W=W(1:numFeatures);
        Slack
    else
        error('LP solver failed (%d)',exitflag);
    end
W
    d.beta=W;
    % Count (assumed) effective dimensions, taking 'flex' combining style into
    % account
    d.nr=sum(any(reshape(d.beta>betaTruncateThreshold,numFeatures,numSubspaces),2));
    % Remove (assumed) useless dimensions
    d.beta(d.beta<=betaTruncateThreshold)=0;
    
    w=mapping(mfilename,'trained',d,[],numFeatures,0);
    w=setname(w,'LESS Regressor');
else
end
