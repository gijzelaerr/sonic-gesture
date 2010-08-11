%LIKNON LIKNON-Classifier
%
%   W = LIKNONC(A,C)
% 
% INPUT
%   A       Dataset
%   C       Regularization parameter, C>=0
%           default: C=1
% 
% OUTPUT
%   W       LIKNON classifier 

%
%  SEE ALSO
%  MAPPINGS, DATASETS, NMC, NMSC, SVC

% Copyright: Cor J. Veenman, C.J.Veenman@uva.nl
% Computer Science Institute 
% Faculty of Science, University of Amsterdam
% Amsterdam, The Netherlands

function w = liknonc(x, C)

if (nargin < 2)
	C = 1; 
end

if (nargin < 1) | (isempty(x))
	w = mapping(mfilename,{C});
	w = setname(w,'LIKNON classifier');
	return
end

if ~ismapping(C)   % train the mapping

	% Unpack the dataset.
	islabtype(x,'crisp');
	%isvaldset(x,1,2); % at least 1 object per class, 2 classes
	[n,k,c] = getsize(x); 

	% Is this necessary??
	%wsc = scalem(x,'variance');
	%x = x*wsc;

	X = +x;

	if c == 2  % two-class classifier:

		% first create the target values:
		y = 2*getnlab(x)-3;

		%---create f
		%f = [ones(2*k + n,1); zeros(2,1)];
        f=[ones(2*k,1); C*ones(n,1); zeros(2,1)];

        %---create A
  		A = -[(y*ones(1,k)).*X, -(y*ones(1,k)).*X, speye(n), -y, y];

        %---generate b
		b = -ones(n,1);

		%---solve linear program
        if n>2*k+3&&n>1000||exist('glpkmex')~=3
            options=optimset('Display','off','LargeScale','on','Diagnostics','off');
            z = linprog(f,A,b,[],[],zeros(size(f)),[],[],options);
        else
            LPX_OPT=180;
            param.round=1;
            param.itlim=100000;
			[z,dummy,status]=glpkmex(1,f,A,b,repmat('U',n,1),zeros(size(f)),[],repmat('C',size(f,1),1),param);
            exitflag=(status==LPX_OPT);
		end

		%---extract parameters
		u = z(1:k); u = u(:);
		v = z(k+1:2*k); v = v(:);
		zeta = z(2*k+1:2*k+n); zeta = zeta(:);
		bp = z(end-1);
		bm = z(end);

        W.beta=u-v;
	
        W.b=bp-bm;
	
        W.nr = sum(abs(W.beta)>1e-8);
    
    	w = mapping(mfilename,'trained',W,getlablist(x),size(x,2),c);

	else  % multi-class wrapper
		w = mclassc(x,mapping(mfilename,{C}));
    end

	w = setname(w,'LIKNON classifier');

else
	% Evaluate the classifier on new data:
	W = getdata(C);
	n = size(x,1);

	% linear classifier:
	out = (+x)*W.beta - W.b;

	% and put it nicely in a prtools dataset:
	w = setdat(x,sigm([-out out]),C);

end

return
