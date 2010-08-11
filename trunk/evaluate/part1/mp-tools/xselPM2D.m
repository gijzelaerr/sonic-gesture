function [pars,minErrors]=xselPM2D(a,pm,minmax,clfs,ranges1,ranges2,sfolds,sreps)

    if length(ranges1)~=length(ranges2)
        error('Should have same number of ranges per dimension');
    end

    maxRangeLen=0;

    col={'r','b','g','k','m','y','c','r--','b--','g--','k--','m--','y--','c--'};

    e=cell(1,length(clfs));
    pars=ones(length(clfs),2);
    minErrors=ones(1,length(clfs));

    for i=1:length(clfs)
        if length(ranges1{i})>maxRangeLen
            maxRangeLen=length(ranges1{i});
        end
        if length(ranges2{i})>maxRangeLen
            maxRangeLen=length(ranges2{i});
        end
    end

    if maxRangeLen==1
        return
    end

    for i=1:length(clfs)
        e{i}=zeros(max(1,length(ranges1{i})),max(1,length(ranges2{i})));
    end

    sign=1;
    if sfolds<0
        sign=-1;
    end

    sfolds=abs(sfolds);

    for i=1:sreps
        sets = nfoldsubsets(size(a,1),get(a,'nlab'),sfolds);
        for j=1:sfolds
            [trainSet, testSet] = nfoldselect(sets, sign*j);
            for m=1:length(clfs)
str=sprintf('[%3d] %s:',(i-1)*sfolds+j,clfs{m});
fprintf(str);
                if isempty(ranges1{m})
                    w=feval(clfs{m},a(trainSet,:));
                    e{m}(1)=e{m}(1)+feval(pm,a(testSet,:)*w);
                else
                    for k=1:length(ranges1{m})
                        for p=1:length(ranges2{m})
fprintf('.');
pause(0);
                            w=feval(clfs{m},a(trainSet,:),[ranges1{m}(k) ranges2{m}(p)]);
                            e{m}(k,p)=e{m}(k,p)+feval(pm,a(testSet,:)*w);
                        end
                    end
                end
                backspaces=length(str)+length(ranges1{m})*length(ranges2{m});
fprintf('%s%s%s',8*ones(1,backspaces),32*ones(1,backspaces),8*ones(1,backspaces));
            end

            % BEGIN - DISPLAY STATUS
            for m=1:length(clfs)
                if isempty(ranges1{m})
                    plot(1,e{m}(1)/((i-1)*sfolds+j),[col{m} 'o']);
                else
                    surf(ranges2{m},ranges1{m},e{m}/((i-1)*sfolds+j)); %,col{m});
                    set(gca,'xscale','log');
                    set(gca,'yscale','log');
                end
                hold on;
            end
            legend(clfs,4);
            hold off

            xlabel(sprintf('repeat: %d fold: %d',i,j));
            title(['DATASET: ' getname(a)]);
            drawnow;
            pause(0);

            % END - DISPLAY STATUS

        end

        xlabel(sprintf('repeat: %d fold: %d',i,j));
        drawnow;
        pause(0);

    end

    for i=1:length(clfs)
        minErrors(i)=feval(minmax,feval(minmax,e{i}));
        [k,p]=find(e{i}==minErrors(i));
        k=k(ceil(length(k)/2));
        p=p(ceil(length(p)/2));
        if isempty(ranges1{i})
            pars(i,:)=[NaN NaN];
        else
            pars(i,:)=[ranges1{i}(k) ranges2{i}(p)];
        end
    end

return
