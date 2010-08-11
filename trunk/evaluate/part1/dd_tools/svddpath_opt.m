function [lambda,alf,B,O] = svddpath_opt(K,endLambda,ub)
%SVDDPATH_OPT SVDD path of C
%
%    [LAMBDA,ALF,B,O] = SVDDPATH_OPT(K,ENDLAMBDA)
%
% This is the optimization function for the weights in the SVDD by
% varying the lambda (C) parameter. Lambda is changed from the maximum
% (= the number of training objects) to the minimum, given by the user
% in ENDLAMBDA. The solution for the last Lambda is returned. ALF
% contains all the weights, B and O the indices of the objects that are
% on the boundary (B) or outside (O) the SVDD.
if nargin<3
	ub = [];
end
if nargin<2
	endLambda = 0;
end

% initialize
tol = 1e-9;
m = size(K,1);
if isempty(ub)
	ub = ones(m,1);
else
	ub(ub<=0) = tol;  % stability later...
	ub = m*ub/sum(ub); %normalize
end
% all objects in O:
alf = ub;
lambda = sum(ub);
O = (1:m)';
% the rest is empty:
B = [];
I = [];
lastsituation = 0;
% save for inspection reasons:
ll = lambda;

% GO!
while (lambda>0)
	if isempty(B)
		% No support objects on the boundary, take the first one from O:
		nrO = length(O);
		f_cand = diag(K(O,O)) - 2*K(O,:)*alf/lambda...
			+ sum(sum((alf*alf').*K))/(lambda*lambda);
		[fmin,obj] = min(f_cand);
		% move it in B:
		B = O(obj);
		O(obj) = [];
		%message(3,'EMPTY B, exceptional situation 3: move %d from O to B.\n', obj);
	end
	% Compute the 'sensitivities':
	k = B(1);
	Bmink = B(2:end);
	Y = K - repmat(K(k,:),m,1);
	y = diag(K) - K(k,k);
	Z = eye(m);
	%Z(Bmink,Bmink) = Y(Bmink,Bmink); % wrong!
	Z(B,B) = Y(B,B);
	Z(k,:) = ones(1,m);
	z = zeros(m,1);
	z(Bmink) = y(Bmink);
	z(k) = 2;
	W = zeros(m,m);
	W(Bmink,O) = -Y(Bmink,O);
	W(O,O) = eye(size(O,1));
	% here the expensive part:
	iZ = inv(Z);
	p = iZ*z/2;
	q = iZ*W*ub;

	% consistency check:
	if max(abs(sum(alf)*p+q-alf))>tol
		disp('p and q do not reproduce the orig. solution!');
		keyboard
	end

	% situation 1, B to I, alf becomes 0:
	lambda1 = -q(B)./p(B);
	lambda1(lambda1>lambda) = -inf;
	% okok, check if we are not inversing the last thing we did:
	if (lastsituation==4)
		obj=find(B==lastobj);
		lambda1(obj) = -inf;
	end
	[lambda1,obj1] = max(lambda1);
	% situation 2, B to O, alf becomes upper bounded:
	lambda2 = (ub(B)-q(B))./p(B);
	% we are a bit more strict here: we don't want to move an object from
	% B to O:
	lambda2(lambda2>=lambda) = -inf;
	% okok, check if we are not inversing the last thing we did:
	if (lastsituation==3)
		obj=find(B==lastobj);
		lambda2(obj) = -inf;
	end
	[lambda2,obj2] = max(lambda2);
	% situation 3, O to B, from bounded to unbounded SV:
	if ~isempty(O)
		lambda3 = (2*Y(O,:)*q)./(y(O) - 2*Y(O,:)*p);
		lambda3(lambda3>lambda) = -inf;
		% okok, check if we are not inversing the last thing we did:
		if (lastsituation==2)
			obj=find(O==lastobj);
			lambda3(obj) = -inf;
		end
		[lambda3,obj3] = max(lambda3);
	else
		lambda3 = -inf;
	end
	% situation 4, I to B, from rest to unbounded SV:
	if ~isempty(I)
		lambda4 = (2*Y(I,:)*q)./(y(I) - 2*Y(I,:)*p);
		lambda4(lambda4>lambda) = -inf;
		% okok, check if we are not inversing the last thing we did:
		if (lastsituation==1)
			obj=find(I==lastobj);
			lambda4(obj) = -inf;
		end
		[lambda4,obj4] = max(lambda4);
	else
		lambda4 = -inf;
	end

	% which is the most pressing object?
	%oldlambda = lambda;
	%oldI = I; oldB = B; oldO = O; oldalf = alf;
	[lambda,situation] = max([lambda1 lambda2 lambda3 lambda4]);
	%message(3,'situation %d\n',situation);
	% maybe we already obtained lambda=0?
	if lambda<=endLambda
		%disp('End!');
		break;
	end
	ll = [ll;lambda];
	% update the weights:
	alf = lambda*p + q;
	if any(alf<-tol)
		disp('Some alphas became <0.');
		keyboard;
	end
	if any(alf>ub+tol)
		disp('Some alphas became > upper bound.');
		keyboard;
	end

	% and move the object:
	switch situation
	case 1
		lastsituation = 1; lastobj = B(obj1);
		I = [I; B(obj1)];
		B(obj1) = [];
	case 2
		lastsituation = 2; lastobj = B(obj2);
		O = [O; B(obj2)];
		B(obj2) = [];
	case 3
		lastsituation = 3; lastobj = O(obj3);
		B = [B; O(obj3)];
		O(obj3) = [];
	case 4
		lastsituation = 4; lastobj = I(obj4);
		B = [B; I(obj4)];
		I(obj4) = [];
	end

	% what about 'cleaning' the weights, to avoid numerical
	% instabilities?
	%sum1=sum(alf);
	if ~isempty(O)
		alf(O) = ub(O);
	end
	if ~isempty(I)
		alf(I) = 0;
	end
	lambda = sum(alf);
	%message(4,'Cleaning weights, change=%e\n',abs(lambda-sum1));

end

lambda = ll;

return

