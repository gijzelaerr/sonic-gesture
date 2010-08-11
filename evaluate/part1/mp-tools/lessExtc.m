function w=lessExtc(a,C,kernel,estimate,combiner,combinerStyle)

NM_Approach=0;

if nargin<6|isempty(combinerStyle)
    combinerStyle='flexible';
end

if nargin<5|isempty(combiner)
    combiner='single';
end

if nargin<4|isempty(estimate)
    estimate='mean';
end

if nargin<3|isempty(kernel)
    kernel=1;
end

if nargin<2|isempty(C)
    C=1;
end

if nargin < 1 | isempty(a)
    w=mapping(mfilename,{C,kernel,estimate,combiner,combinerStyle});
    w=setname(w,'LESS-XT classifier');
    return
end

if ~ismapping(C)   % train the mapping

    [numObjects,numFeatures,numClasses]=getsize(a);

    if numClasses==2
        combiner='multiple';
    end
    
    [d.beta,d.M,d.S]=lessExt(a,C,kernel,estimate,combiner,combinerStyle);
    d.kernel=kernel;
    d.combiner=combiner;
    d.combinerStyle=combinerStyle;

    d.nr=sum(d.beta>1.0e-8);    % Not correct for flexible combination;
                                % must intersect dimensions

    w=mapping(mfilename,'trained',d,getlabels(a),numFeatures,numClasses);
    w=cnormc(w,a);  % Proper Posteriors ???? 
    w=setname(w,'LESS-XT classifier');

else

    d=+C;
    numClasses=get(C,'size_out');
    numFeatures=get(C,'size_in');

    if NM_Approach
        % Scale dataset and class means with sqrt(beta)
        a=setdata(a,double(a) .* repmat(sqrt(d.beta)',size(a,1),1));
        d.M=d.M .* repmat(sqrt(d.beta)',numClasses,1);

        x=-(+distm(a,d.M));

    else
        dimensionsOffset=0;
        x=zeros(size(a,1),numClasses);

        switch lower(d.combiner)
        case 'multiple'
            for i=1:numClasses-1
                for j=i+1:numClasses
                    z=gstar(a,d.M([i j],:),d.S([i j],:),d.kernel)*d.beta(dimensionsOffset+(1:numFeatures));
                    x(:,i)=x(:,i)-z;
                    x(:,j)=x(:,j)+z;

                    if strcmp(lower(d.combinerStyle),'flexible')
                        dimensionsOffset=dimensionsOffset+numFeatures;
                    end
                end
            end
        case 'single'
            for i=1:numClasses
                z=gstar(a,d.M([i numClasses+i],:),d.S([i numClasses+i],:),d.kernel)*d.beta(dimensionsOffset+(1:numFeatures));
                x(:,i)=x(:,i)-z;
                for j=1:numClasses
                    if j~=i
                        x(:,j)=x(:,j)+z;
                    end
                end

                if strcmp(lower(d.combinerStyle),'flexible')
                    dimensionsOffset=dimensionsOffset+numFeatures;
                end
            end
        end
    end

    w=setdat(a,x);
    w=setfeatlab(w,get(w,'lablist'));
end

return

