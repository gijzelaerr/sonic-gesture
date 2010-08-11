function x=phi(a,w)

    if nargin==2
        x=phi(a*w);
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
            error('Classifier should have labels 0/1');
        end

        TP=sum((labout==1)&(labin==1));
        FP=sum((labout==1)&(labin==0));
        
        TN=sum((labout==0)&(labin==0));
        FN=sum((labout==0)&(labin==1));
        
        x=(TP*TN - FP*FN)./sqrt(1+(TP+FN)*(TN+FP)*(TP+FP)*(TN+FN));
    else
        error('Arguments missing');
    end