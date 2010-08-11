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