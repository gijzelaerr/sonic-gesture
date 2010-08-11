function [w,zeta] = bamc(x, C, rtype, par, unitnorm)
% w = bamc(x, C, rtype, par, unitnorm)
%
% Optimize AUC on dataset X and reg. param. C. The AUC constraints can
% be sampled in different ways:
%  rtype     par
% 'full',     -   use all constraints
% 'subs',     N   subsample just N constraints
%  'knn'      k   use only the k nearest neighbors
%  'xval'     N   subsample just N constraints and use the rest to
%                 optimize C
% Finally, per default the difference vectors are normalized to unit
% length.

prtrace(mfilename);

if (nargin < 5)
	unitnorm = 0;
end
if (nargin < 4)
	par = 1000;
end
if (nargin < 3)
	rtype = 'subs';
end
if (nargin < 2)
	prwarning(3,'C set to one');
	C = 1; 
end
if (nargin < 1) | (isempty(x))
	w=mapping(mfilename,{C,rtype,par,unitnorm});
	w=setname(w,'BAMC');
	return
end

if ~ismapping(C)   % train the mapping

	% Unpack the dataset.
	islabtype(x,'crisp');
	isvaldset(x,1,2); % at least 1 object per class, 2 classes
	[n,k,c]=getsize(x);

	% makes the mapping much faster:
	X=+x;

	if c==2  % two-class classifier:

		% first create the target values:
		y = 2*getnlab(x)-3;

		%---create A for bamc
        Nxi=par;

        if strcmp(rtype,'full') | Nxi>=(sum(y==-1)*sum(y==1))
            A=makeOrderData(X,y);
            Nxi=size(A,1);
        else
            A=makeOrderData(X,y,Nxi);
        end

        if unitnorm
			% normalize the length of A:
			lA = sqrt(sum(A.*A,2));
			A = A./repmat(lA,1,size(A,2));
		end
		% negative should be present for the constraints:
		A = [A -A];

        % take also care of the xi:
		A = [A -speye(Nxi)];

        %---create f
		f = [ones(2*k,1); repmat(C,Nxi,1)];
    
		%--- generate b
		b = -ones(Nxi,1);

		%---lower bound constraints
		lb = zeros(size(f));

        %---solve linear program
		if (0&exist('glpkmex')==3)
            %'glpk'
			%message(5,'Use glpkmex');
            LPX_OPT=180;
            param.round=1;
            param.itlim=100000;
			[z,fmin,status]=glpkmex(1,f,A,b,repmat('U',Nxi,1),lb,[],repmat('C',size(f,1),1));
		else
            %'linprog'
            options=optimset('Display','off','LargeScale','on','Diagnostics','off');
			z = linprog(f,A,b,[],[],lb,[],[],options);
		end

		%---extract parameters
		u = z(1:k); u = u(:);
		v = z(k+1:2*k); v = v(:);
		zeta = z(2*k+1:2*k+Nxi); zeta = zeta(:);

	else
		error('Only a two-class classifier is implemented');
	end
	% now find out how sparse the result is:
    W.beta=u-v;
    W.nr = sum(abs(W.beta)>1e-6);
	w = mapping(mfilename,'trained',W,getlablist(x),size(x,2),c);
	w = setname(w,sprintf('BAMC %s',rtype));
	
else
	% Evaluate the classifier on new data:
	W = getdata(C);
	n = size(x,1);

	% linear classifier:
	out = x*(W.beta);

	% and put it nicely in a prtools dataset:
	w = setdat(x,[out -out],C);
	%w = setdat(x,sigm([-out out]),C);

end
		
return

function Z=makeOrderData(X,Y,n)

    if nargin<3
        n=Inf;
    end
    
    Ineg = find(Y==-1);
    Ipos = find(Y==+1);
    
    Nneg = length(Ineg);
    Npos = length(Ipos);

    if Nneg==0|Npos==0
        error('Dataset not properly labeled; should be: -1|+1');
    end
    
    k=size(X,2);

    if nargin>2

	    Nxi = min(n,Npos*Nneg);

        if 0
            Z=repmat(X(Ipos,:),Nneg,1)-reshape(repmat(X(Ineg,:),1,Npos)',k,Npos*Nneg)';
            p=randperm(Npos*Nneg);
            p=p(1:Nxi);
            Z=Z(p,:);
        else

        if 0
            % correct
            Ip=repmat((1:Npos)',Nneg,1);
            In=reshape(repmat((1:Nneg)',1,Npos)',1,Npos*Nneg)';
            p=randperm(Npos*Nneg);
            p=p(1:Nxi);
            Z=X(Ipos(Ip(p)),:) - X(Ineg(In(p)),:);
        else
            % approximate: less memory consuming
            Z=X(Ipos(ceil(Npos*rand(Nxi,1))),:) - X(Ineg(ceil(Nneg*rand(Nxi,1))),:);
        end

        end
    else
        Z=repmat(X(Ipos,:),Nneg,1)-reshape(repmat(X(Ineg,:),1,Npos)',k,Npos*Nneg)';
    end

return
