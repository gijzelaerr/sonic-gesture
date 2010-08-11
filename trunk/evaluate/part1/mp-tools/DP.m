function x=DP(a,w)

delta=1e-8;
%delta=0;
    if nargin==2
        x=DP(a*w);
    elseif nargin==1
		[m,k,c] = getsize(a); p = getprior(a); 

        if c~=2
            error('Likelihood ratio only defined for 2-class problems');
        end
        
		% Find the labels.
        labout=labeld(a);

		class_errs=zeros(1,c); x = 0;
        labin=getlabels(a);
        
        if any(labin~=0&labin~=1)
            error('Labels should be 0/1');
        end

        if any(labout~=0&labout~=1)
            error('Classifier should labels with 0/1');
        end

        if 0
            x=+a;
            
            [xs,is1]=sort(x(:,1));
            [xs,is2]=sort(-x(:,1));

            TN=cumsum(labout(is1)==0&labin(is1)==0);
            FN=cumsum(labout(is1)==0&labin(is1)==1);

            TP=cumsum(labout(is2)==1&labin(is2)==1);
            FP=cumsum(labout(is2)==1&labin(is2)==0);

            TP=TP(m:-1:1);
            FP=FP(m:-1:1);
            
            DP=((TN+delta).*(TP+delta))./((FN+delta).*(FP+delta));
            x=min(DP);

        else
        TP=sum((labout==1)&(labin==1));
        FP=sum((labout==1)&(labin==0));
        
        TN=sum((labout==0)&(labin==0));
        FN=sum((labout==0)&(labin==1));
        
        x=(TN+delta)*(TP+delta)/((FN+delta)*(FP+delta));
        end
    else
        error('Arguments missing');
    end