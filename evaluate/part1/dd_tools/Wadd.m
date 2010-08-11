function W = Wadd(W,newx,newy,alreadyadded)
%WADD Add an object to the incsvdd
%
%        W = WADD(W,NEWX,NEWY)
%
% Given a structure W (see Wstartup), a new object NEWX with label NEWY
% is added to the solution. An updated W is returned.
%
%        W = WADD(W,NEWX,NEWY,ALREADYADDED)
%
% In some rare cases, the global matrix X_incremental already contains
% the new object (it should then be the last object in the matrix). In
% that case the object is not added again, but just directly used. This
% should not be done by the user.
%
% See also: incsvdd, inckernel, Wstartup

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<4
	alreadyadded = 0;
end

% Make the dataset ready with the new object:
global X_incremental;
if isempty(X_incremental)
	error('I am expecting a global variable X_incremental');
end
if size(newx,1)>1 | length(newy)>1
	error('Please add just a single object.');
end
% An exception when we have a strange starting set:
if alreadyadded

	c = size(X_incremental,1);
	newsetD = (1:c)';

	% compute the kernel matrix entry for the new object:
	% (let us assume this is a row vector)
	K = feval(W.kernel,W.kpar,c,newsetD);
	Kc = 2*(W.y(c)*W.y(newsetD)').*K;

else

	% add the object:
	X_incremental = [X_incremental; newx];
	W.y = [W.y; newy];
	W.alf = [W.alf; 0];

	c = size(X_incremental,1);

	% currently seen objects plus new object
	newsetD = (1:c)';
	  
	% compute the kernel matrix entry for the new object:
	% (let us assume this is a row vector)
	K = feval(W.kernel,W.kpar,c,newsetD);
	Kc = 2*(W.y(c)*W.y(newsetD)').*K;
	% note the factor 2, which we included here to facilitate
	% computation in the rest of the story. Only in the computation of
	% the gradient, this factor should be cancelled for the term Kcc.

	% Compute the gradient for the new object:
	W.grad(c,1) = W.y(c)*W.b - W.y(c)*Kc(c)/2;
	if ~isempty(W.setS)
		W.grad(c,1) = W.grad(c,1) + Kc(W.setS)*W.alf(W.setS);
	end
	if ~isempty(W.setE)
		W.grad(c,1) = W.grad(c,1) + Kc(W.setE)*W.alf(W.setE);
	end

end

% Right, here we go, can be add object c?:
if W.grad(c)>0 % it is already classified ok,
	W.setR = [W.setR;c];   % put in the 'rest' set
	W.Kr = [W.Kr; Kc(W.setS)];  % update Kr

else         % we have to work

	done = 0;  % to check if we are done
	nrloops = 0;
	while ~done

		% compute beta, not for the new object:
		beta = zeros(length(W.setS)+1,1);
		beta = -W.R*[W.y(c); Kc(W.setS)'];

		% compute gamma, also for the new object:
		gamma = Kc';
		if isempty(W.setS)
			% here something fishy is going on, when there is just a single
			% object added. Then we cannot freely move alf, and we can only
			% move b. In this case, b is moved until alf(c) enters setS
			% (that means, the gradient becomes 0).
			gamma = W.y(c)*W.y(newsetD);
			duptonow = W.y(c)*W.b;
		else
			if ~isempty(W.setE)
				gamma(W.setE) = gamma(W.setE) + [W.y(W.setE) W.Ke]*beta;
			end
			if ~isempty(W.setR)
				gamma(W.setR) = gamma(W.setR) + [W.y(W.setR) W.Kr]*beta;
			end
			gamma(c) = gamma(c) + [W.y(c) Kc(W.setS)]*beta;
			gamma(W.setS) = 0;
			duptonow = W.alf(c);
		end

		% now we have to see how large deltaAc can become...
		% (1) check the own upper bound:
		if isempty(W.setS)
			deltaAcisC = inf; %because we're moving b, and not alf!
		else
			deltaAcisC = W.C;
		end
		% (2) check if own gradient becomes zero:
		s = warning('off');
		deltaGcis0 = duptonow-W.grad(c)./gamma(c);
		warning(s);
		% object moves the wrong way:
		deltaGcis0(deltaGcis0<duptonow) = inf;
		% (3) check upper bounds of the SVs:
		deltaupperC = inf;
		if ~isempty(W.setS)
			deltaupperC = duptonow + (W.C-W.alf(W.setS))./beta(2:end);
			% negative changes do not count:
			deltaupperC(deltaupperC<duptonow) = inf;
			% object moves the wrong way (or not at all):
			deltaupperC(beta(2:end)<=0) = inf;
			[deltaupperC,nrS_up] = min(deltaupperC);
		end
		% (4) check lower bounds of the SVs:
		deltalowerC = inf;
		if ~isempty(W.setS)
			deltalowerC = duptonow + -W.alf(W.setS)./beta(2:end);
			% negative changes do not count:
			deltalowerC(deltalowerC<duptonow) = inf;
			% object moves the wrong way (or not at all)
			deltalowerC(beta(2:end)>-eps) = inf; %DXD break the symmetry with (6)
			[deltalowerC,nrS_low] = min(deltalowerC);
		end
		% (5) check E gradients to become 0:
		deltaGeis0 = inf;
		if ~isempty(W.setE)
			s = warning('off'); % divide by 0 is taken care of later...
				deltaGeis0 = duptonow -W.grad(W.setE)./gamma(W.setE);
			warning(s);
			deltaGeis0(deltaGeis0<=duptonow) = inf;
			deltaGeis0(gamma(W.setE)<=0) = inf;
			[deltaGeis0,nrE_0] = min(deltaGeis0);
		end
		% (6) check R gradients to become 0:
		deltaGris0 = inf;
		if ~isempty(W.setR)
			s = warning('off'); % divide by 0 is taken care of later...
				deltaGris0 = duptonow -W.grad(W.setR)./gamma(W.setR);
			warning(s);
			deltaGris0(deltaGris0<duptonow) = inf;
			deltaGris0(gamma(W.setR)>=0) = inf;
			[deltaGris0,nrG_0] = min(deltaGris0);
		end

		% which one is the most urgent one?
		deltas = [deltaAcisC; deltaGcis0; deltaupperC; deltalowerC;...
		          deltaGeis0; deltaGris0];
		[maxdelta,situation] = min(deltas);
%fprintf('Situation %d (max_delta=%f)\n',situation,maxdelta);
%keyboard

		% update the parameters
		if isempty(W.setS) % then we only change b:
		%disp('setS is empty!');
			W.b = W.y(c)*maxdelta;
		else
			W.alf(c) = maxdelta;
			W.alf(W.setS) = W.alf(W.setS) + (maxdelta-duptonow)*beta(2:end);
			W.b = W.b + (maxdelta-duptonow)*beta(1);
		end
		W.grad = W.grad + (maxdelta-duptonow)*gamma;
      
		% do consistency check:
		I = find(W.alf<0);
		if ~isempty(I)
			J = find(W.alf(I)<-W.tol);
			if ~isempty(J)
				disp('one of the alpha''s became < 0!');
				%keyboard;
			else
				W.alf(I) = 0;
			end
		end

		% update the sets:
		%fprintf('situation %d\n',situation);
		switch situation
		case 1   % object c goes to setE
			W.alf(c) = W.C; % just to be sure...
			if size(W.Ke,1)==0, W.Ke = []; end % make it really empty
			W.Ke = [W.Ke; Kc(W.setS)];
			W.setE = [W.setE; c];
			done = 1;
		case 2   % object c goes to setS
			W.Ks = [W.Ks [W.y(c); Kc(W.setS)'];
			        W.y(c) Kc([W.setS; c])];
			W.Ke = [W.Ke Kc(W.setE)'];
			W.Kr = [W.Kr Kc(W.setR)'];
			% update R 
			if isempty(W.setS) % compute it directly (to avoid the inf's)...
				W.R = [-Kc(c) W.y(c); W.y(c) 0];
			else
				W.R = change_R(W.R,+c,beta,gamma(c));
			end
			W.setS = [W.setS;c];
			done = 1;
		case 3  % a support object hits upper bound
			j = W.setS(nrS_up);             % number of the object
			W.alf(j) = W.C;                   % just to be sure
			if size(W.Ke,1)==0, W.Ke=[]; end  % make it really really empty
			W.Ke = [W.Ke; W.Ks(nrS_up+1,2:end)];  % update Ke
			W.setE = [W.setE;j];              % add to setE
			W.Ks(nrS_up+1,:) = [];            % update all K's
			W.Ks(:,nrS_up+1) = [];
			W.Ke(:,nrS_up) = [];
			if ~isempty(W.Kr), W.Kr(:,nrS_up) = []; end
			W.setS(nrS_up) = [];            % remove from setS
			W.R = change_R(W.R,-nrS_up,beta,gamma(j));
		case 4  % a support object hits lower bound
			j = W.setS(nrS_low);             % number of the object
%fprintf('object %d becomes rest\n',j);
			W.alf(j) = 0;                    % just to be sure
			if size(W.Kr,1)==0, W.Kr = []; end % make really empty
			W.Kr = [W.Kr; W.Ks(nrS_low+1,2:end)];  % update Kr
			W.setR = [W.setR;j];               % add to setE
			W.Ks(nrS_low+1,:) = [];            % update all K's
			W.Ks(:,nrS_low+1) = [];
			if ~isempty(W.Ke), W.Ke(:,nrS_low) = []; end;
			if ~isempty(W.Kr), W.Kr(:,nrS_low) = []; end;
			W.setS(nrS_low) = [];            % remove from setS
			W.R = change_R(W.R,-nrS_low,beta,gamma(j));
		case 5  % an error becomes a support object
			j = W.setE(nrE_0);              % number of the object
			% adding to setS, means that all kernels have to be computed:
			K = feval(W.kernel,W.kpar,j,newsetD);
			Kj = 2*(W.y(j)*W.y(newsetD)').*K;
			% to update R, we have to have the beta of object j:
			betaj = zeros(length(W.setS)+1,1);
			betaj = -W.R*[W.y(j); Kj(W.setS)'];
			W.Ks = [W.Ks; W.y(j) Kj(W.setS)];   % add row to Ks
			W.Kr = [W.Kr Kj(W.setR)'];          % update Kr
			W.Ke = [W.Ke Kj(W.setE)'];          % update Ke
			W.Ke(nrE_0,:) = [];
			if isempty(W.Ke), W.Ke = []; end
			W.setE(nrE_0) = [];             % update setE
			if isempty(W.setE), W.setE = []; end
			W.setS = [W.setS;j];              % add to setS
			W.Ks = [W.Ks [W.y(j); Kj(W.setS)']];  % and the extra column for Ks
			if length(betaj)==1 % compute it directly (to avoid the inf's)...
				W.R = [-Kj(j) W.y(j); W.y(j) 0];
			else
				% to update R, we also have to have the gamma of object j:
				gammaj = W.Ks(end,:)*[betaj;1] ;
				W.R = change_R(W.R,+j,betaj,gammaj);
			end
		case 6  % an other object becomes a support object
			j = W.setR(nrG_0);              % number of the object
%fprintf('object %d becomes SV\n',j);
			% adding to setS, means that all kernels have to be computed:
			K = feval(W.kernel,W.kpar,j,newsetD);
			Kj = 2*(W.y(j)*W.y(newsetD)').*K;
			% to update R, we have to have the beta of object j:
			betaj = zeros(length(W.setS)+1,1);
			betaj = -W.R*[W.y(j); Kj(W.setS)'];
			W.Ks = [W.Ks; W.y(j) Kj(W.setS)];     % add row to Ks
			W.Ks = [W.Ks [W.y(j); Kj([W.setS;j])']]; % and the extra column for Ks
			W.Ke = [W.Ke Kj(W.setE)'];          % update Ke
			W.Kr = [W.Kr Kj(W.setR)'];          % update Kr
			W.Kr(nrG_0,:) = [];
			W.setS = [W.setS;j];              % add to setS
			W.setR(nrG_0) = [];             % update setR
			if length(betaj)==1 % compute it directly (to avoid the inf's)...
				W.R = [-Kj(j) W.y(j); W.y(j) 0];
			else
				% to update R, we also have to have the gamma of object j:
				gammaj = W.Ks(end,:)*[betaj;1] ;
				W.R = change_R(W.R,+j,betaj,gammaj);
			end
		end

      %disp('end situation');
		nrloops = nrloops+1;
		%if nrloops>500, done=1; disp('NRLOOPS=500'), end
      %keyboard
	end % changing alfa's till stable solution is found
end % check for gradient<=0


% now we can also compute the R, compute the output for the x(setS):
% But fortunately, this value is
%   R^2 = offset + b;
% If we ignore the offset, we just have to use b!


