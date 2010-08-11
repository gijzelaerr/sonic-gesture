function W = Wremove(W,c)
%WREMOVE Remove an object from the incsvdd
%
%        W = WREMOVE(W,W.C)
%
% Remove object W.C from structure W (see Wstartup). W.C should be an index
% to the object defined in the global matrix X_incremental. An updated
% version of W is returned.
%
% See also: incsvdd, inckernel, Wstartup, Wadd

% we assume we have a valid SVDD solution. That means, we have:
%  X_incremental, W.y
%  W.kernel, W.kpar.type, kpar.s
%  W.C
%  W.alf, W.b
%  W.setS, W.Ks,
%  W.setE, W.Ke,
%  W.setR, W.Kr,
%  W.R, W.grad.
%
% Of course, from X_incremental,W.y,W.alf,W.b and W.C, be can derive the rest. But because
% we will switch from adding and removing objects, I assume all the
% rest is also available.

% Check for the dataset:
global X_incremental;
if isempty(X_incremental)
	error('I am expecting a global variable X_incremental');
end
if length(c)>1
	error('Please remove just a single object.');
end

% so, here we go then
setD = (1:size(X_incremental,1))';

%fprintf('Removing object number %d\n',c);
if ~any(W.setR==c)
  % not so easy, c is a support vector or error vector...
  
  % so, remove it from W.setS or W.setE:
  if ~isempty(W.setE) & any(W.setE==c)  % object from W.setE
    %fprintf('Object %d will be removed from E\n',c);
    nrE = find(W.setE==c);
    W.Ke(nrE,:) = [];
    W.setE(nrE) = [];
  else            % object from W.setS
    %fprintf('Object %d will be removed from S\n',c);
    nrS = find(W.setS==c);
    if isempty(nrS)
      warning('Object cannot be found in S, E or W.R!');
    end
    % W.Ks has 1 extra row and column, be careful with this extra 1
    W.Ks(nrS+1,:) = [];  % remove the row
    W.setS(nrS) = [];
    W.Ks(:,nrS+1) = [];  % W.Ks is never empty: always the W.y row/column
    if ~isempty(W.setE), W.Ke(:,nrS) = []; end
    if ~isempty(W.setR), W.Kr(:,nrS) = []; end
    % don't forget the W.R:
    W.R = change_R(W.R,-nrS,0,0);
  end
  
  done = 0; % to check if stable solution is found.
  while ~done

    % compute the kernel matrix entry for the object,
    % this is necessary for computing beta and gamma, and after that
    % for updating the gradients for all objects.
    K = feval(W.kernel,W.kpar,c,setD);
    Kc = 2*(W.y(c)*W.y(setD)').*K;

    % compute beta, (this excludes c)
    beta = zeros(length(W.setS)+1,1);
    beta = -W.R*[W.y(c); Kc(W.setS)'];
    % compute gamma, (this includes c, although it is not stricly
    % necessary, I think...)
    gamma = Kc';
    % again, special cares for an possible empty W.setS:
    if isempty(W.setS) 
      gamma = W.y(c)*W.y(setD);
      %duptonow = W.y(c)*W.b;
      duptonow = 0; % im not sure...
    else % the more or less normal case
      if ~isempty(W.setE)
        gamma(W.setE) = gamma(W.setE) + [W.y(W.setE) W.Ke]*beta;
      end
      if ~isempty(W.setR)
        gamma(W.setR) = gamma(W.setR) + [W.y(W.setR) W.Kr]*beta;
      end
      gamma(c) = gamma(c) + [W.y(c) Kc(W.setS)]*beta;
      gamma(W.setS) = 0;
      %duptonow = W.alf(c);
      duptonow = 0; % so, I don't know...
    end

    % I'm not interested in the gradient of c, the only stopping
    % criterion is, that \alpha_c = 0.
    % (1) check the own lower bound:
    if isempty(W.setS)
      deltaAcis0 = -inf;
    else
      deltaAcis0 = -W.alf(c);
    end
    % (2) check upper bounds of the SVs:
    deltaupperC = -inf;
    if ~isempty(W.setS)
      s = warning('off');
			deltaupperC = -duptonow + (W.C-W.alf(W.setS))./beta(2:end);
		warning(s);	
      % positive changes do not count:
      deltaupperC(deltaupperC>duptonow) = -inf;
      deltaupperC(beta(2:end)>=0) = -inf;
      [deltaupperC,nrS_up] = max(deltaupperC);
    end
    % (3) check lower bounds of the SVs:
    deltalowerC = -inf;
    if ~isempty(W.setS)
      s = warning('off');
         deltalowerC = -duptonow -W.alf(W.setS)./beta(2:end);
		warning(s);	
      % positive changes do not count:
      deltalowerC(deltalowerC>duptonow) = -inf;
      deltalowerC(beta(2:end)<=0) = -inf;
      [deltalowerC,nrS_low] = max(deltalowerC);
    end
    % (4) check E gradients to become 0:
    deltaGeis0 = -inf;
    if ~isempty(W.setE)
      warning off;
      deltaGeis0 = -duptonow -W.grad(W.setE)./gamma(W.setE);
      warning on;
      deltaGeis0(deltaGeis0>=-duptonow) = -inf; %DXD break symmetry
      deltaGeis0(gamma(W.setE)>=0) = -inf;
      [deltaGeis0,nrE_0] = max(deltaGeis0);
    end
    % (5) check W.R gradients to become 0:
    deltaGris0 = -inf;
    if ~isempty(W.setR)
      warning off;
      deltaGris0 = -duptonow -W.grad(W.setR)./gamma(W.setR);
      warning on;
      deltaGris0(deltaGris0>=duptonow) = -inf;
      deltaGris0(gamma(W.setR)<=0) = -inf;
      [deltaGris0,nrG_0] = max(deltaGris0);
    end

    %alfbefore = W.alf;
    %gradbefore = W.grad;
    % which one should be considered first?
    deltas = [deltaAcis0; deltaupperC; deltalowerC;deltaGeis0;...
      deltaGris0];
    [maxdelta,situation] = max(deltas);
    %fprintf(' Maxdelta = %e, so situation %d\n',maxdelta,situation);

    % update the parameters
    if isempty(W.setS) % then we only change W.b:
      %disp('Empty set in remove_obj');
      W.b = W.b + W.y(c)*maxdelta;
    else
      W.alf(c) = W.alf(c) + maxdelta;
      W.alf(W.setS) = W.alf(W.setS) + (maxdelta+duptonow)*beta(2:end);
      W.b = W.b + (maxdelta+duptonow)*beta(1);
    end
    W.grad = W.grad + (maxdelta+duptonow)*gamma;

    %update the sets
    switch situation
      case 1   % the new object goes to W.setR
        %fprintf('(1) New object %d goes -> W.R\n',c);
        W.alf(c) = 0; % just to be sure...
        if size(W.Kr,1)==0, W.Kr = []; end % make it really empty
        W.Kr = [W.Kr; Kc(W.setS)];
        W.setR = [W.setR; c];
        done = 1;
      case 2  % a support object hits upper bound
        j = W.setS(nrS_up);             % number of the object
        %fprintf('(2) Object %d goes from S -> E\n',j);
        W.alf(j) = W.C;                   % just to be sure
        if size(W.Ke,1)==0, W.Ke=[]; end  % make it really really empty
        W.Ke = [W.Ke; W.Ks(nrS_up+1,2:end)];  % update W.Ke
        W.setE = [W.setE;j];              % add to W.setE
        W.Ks(nrS_up+1,:) = [];            % update all K's
        W.Ks(:,nrS_up+1) = [];
        W.Ke(:,nrS_up) = [];
        if ~isempty(W.Kr), W.Kr(:,nrS_up) = []; end
        W.setS(nrS_up) = [];            % remove from W.setS
        W.R = change_R(W.R,-nrS_up,beta,gamma(j));
      case 3  % a support object hits lower bound
        j = W.setS(nrS_low);             % number of the object
        %fprintf('(3) Object %d goes from S -> W.R\n',j);
        W.alf(j) = 0;                    % just to be sure
        if size(W.Kr,1)==0, W.Kr = []; end % make really empty
        W.Kr = [W.Kr; W.Ks(nrS_low+1,2:end)];  % update W.Kr
        W.setR = [W.setR;j];               % add to W.setE
        W.Ks(nrS_low+1,:) = [];            % update all K's
        W.Ks(:,nrS_low+1) = [];
        if ~isempty(W.Ke), W.Ke(:,nrS_low) = []; end;
        if ~isempty(W.Kr), W.Kr(:,nrS_low) = []; end;
        W.setS(nrS_low) = [];            % remove from W.setS
        W.R = change_R(W.R,-nrS_low,beta,gamma(j));
      case 4  % an error becomes a support object
        j = W.setE(nrE_0);              % number of the object
        %fprintf('(4) Object %d goes from E -> S\n',j);
        % adding to W.setS, means that all kernels have to be computed:
        K = feval(W.kernel,W.kpar,j,setD);
        Kj = 2*(W.y(j)*W.y(setD)').*K;
        % to update W.R, we have to have the beta of object j:
        betaj = zeros(length(W.setS)+1,1);
        betaj = -W.R*[W.y(j); Kj(W.setS)'];
        W.Ks = [W.Ks; W.y(j) Kj(W.setS)];     % add row to W.Ks
        W.Kr = [W.Kr Kj(W.setR)'];          % update W.Kr
        W.Ke = [W.Ke Kj(W.setE)'];          % update W.Ke
        W.Ke(nrE_0,:) = [];
        W.setE(nrE_0) = [];             % update W.setE
        W.setS = [W.setS;j];              % add to W.setS
        W.Ks = [W.Ks [W.y(j); Kj(W.setS)']];   % and the extra column for W.Ks
        if length(betaj)==1 % compute it directly (to avoid the inf's)...
          W.R = [-Kj(j) W.y(j); W.y(j) 0];
        else
          % to update W.R, we also have to have the gamma of object j:
          gammaj = W.Ks(end,:)*[betaj;1] ;
          W.R = change_R(W.R,+j,betaj,gammaj);
        end
      case 5  % an other object becomes a support object
        j = W.setR(nrG_0);              % number of the object
        %fprintf('(5) Object %d goes from W.R -> S\n',j);
        % adding to W.setS, means that all kernels have to be computed:
        K = feval(W.kernel,W.kpar,j,setD);
        Kj = 2*(W.y(j)*W.y(setD)').*K;
        % to update W.R, we have to have the beta of object j:
        betaj = zeros(length(W.setS)+1,1);
        betaj = -W.R*[W.y(j); Kj(W.setS)'];
        W.Ks = [W.Ks; W.y(j) Kj(W.setS)];     % add row to W.Ks
        W.Ks = [W.Ks [W.y(j); Kj([W.setS;j])']]; % and the extra column for W.Ks
        W.Ke = [W.Ke Kj(W.setE)'];          % update W.Ke
        W.Kr = [W.Kr Kj(W.setR)'];          % update W.Kr
        W.Kr(nrG_0,:) = [];
        W.setS = [W.setS;j];              % add to W.setS
        W.setR(nrG_0) = [];             % update W.setR
        if length(betaj)==1 % compute it directly (to avoid the inf's)...
          W.R = [-Kj(j) W.y(j); W.y(j) 0];
        else
          % to update W.R, we also have to have the gamma of object j:
          gammaj = W.Ks(end,:)*[betaj;1] ;
          W.R = change_R(W.R,+j,betaj,gammaj);
        end
    end  %of the switch statement.

    %W.alf
    %keyboard

  end   % end-done
  
end

% the object is now in W.R, so it is easy:  
nrR = find(W.setR==c);
W.Kr(nrR,:) = [];
W.setR(nrR) = [];
% now you probably also want to remove X_incremental,W.y, and thus move all
% indices:
X_incremental(c,:) = [];
W.y(c) = [];
if ~isempty(W.setS)
  I = (W.setS>c); W.setS(I) = W.setS(I)-1;
end
if ~isempty(W.setE)
  I = (W.setE>c); W.setE(I) = W.setE(I)-1;
end
if ~isempty(W.setR)
  I = (W.setR>c); W.setR(I) = W.setR(I)-1;
end
W.alf(c) = [];
W.grad(c) = [];



