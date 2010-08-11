function b=gstar(a,m,s,t)

    if t==0
        b=+a;
        return
    end
    
    a=+a;
    [n,p]=size(a);

    m1=repmat(m(1,:),n,1);
    m2=repmat(m(2,:),n,1);
    
    if t>1
        s1=repmat(s(1,:),n,1);
        s2=repmat(s(2,:),n,1);

        %ms1=median1(s(1,:),2);
        %ms2=median1(s(2,:),2);

        ms1=mean(s(1,:),2);
        ms2=mean(s(2,:),2);

        rms1=repmat(ms1,n,p);
        rms2=repmat(ms2,n,p);
    end

    switch(t)
    case 1
        b=(a-m1).^2-(a-m2).^2;
    case 2
        b=(ms1+ms2)*(((a-m1).^2)./(rms1+s1)-((a-m2).^2)./(rms2+s2));
    case 3
        b=-(exp(-0.10*((a-m1).^2)./s1)-exp(-0.10*((a-m2).^2)./s2));
        %b(abs(b)<(1.0e-5))=-1;
    case 4
        C=-10;
        b=-((pi/2-atan(-sqrt(s1)+((a-m1).^2)./s1))-(pi/2-atan(-sqrt(s2)+((a-m2).^2)./s2)));
        %scatterd(b);
        %b(abs(b)<(1.0e-5))=-1;
    otherwise
        error('Unknown classifier type');
    end

return;
