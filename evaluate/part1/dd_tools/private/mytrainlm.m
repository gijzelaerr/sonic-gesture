function [net,tr,v3,v4,v5,v6,v7,v8] = ...
  trainlm(net,Pd,Tl,Ai,Q,TS,VV,TV,v9,v10,v11,v12)
%TRAINLM Levenberg-Marquardt backpropagation.
%
%	Syntax
%	
%	  [net,tr] = trainlm(net,Pd,Tl,Ai,Q,TS,VV)
%	  info = trainlm(code)
%
%	Description
%
%	  TRAINLM is a network training function that updates weight and
%	  bias values according to Levenberg-Marquardt optimization.
%
%	  TRAINLM(NET,Pd,Tl,Ai,Q,TS,VV) takes these inputs,
%	    NET - Neural network.
%	    Pd  - Delayed input vectors.
%	    Tl  - Layer target vectors.
%	    Ai  - Initial input delay conditions.
%	    Q   - Batch size.
%	    TS  - Time steps.
%	    VV  - Either empty matrix [] or structure of validation vectors.
%	  and returns,
%	    NET - Trained network.
%	    TR  - Training record of various values over each epoch:
%	          TR.epoch - Epoch number.
%	          TR.perf  - Training performance.
%	          TR.vperf - Validation performance.
%	          TR.tperf - Test performance.
%	          TR.mu    - Adaptive mu value.
%
%	  Training occurs according to the TRAINLM's training parameters
%	  shown here with their default values:
%	    net.trainParam.epochs      10  Maximum number of epochs to train
%	    net.trainParam.goal         0  Performance goal
%	    net.trainParam.lr        0.01  Learning rate
%	    net.trainParam.max_fail     5  Maximum validation failures
%	    net.trainParam.mem_reduc    1  Factor to use for memory/speed trade off.
%	    net.trainParam.min_grad 1e-10  Minimum performance gradient
%	    net.trainParam.show        25  Epochs between showing progress
%	    net.trainParam.time       inf  Maximum time to train in seconds
%
%	  Dimensions for these variables are:
%	    Pd - NoxNixTS cell array, each element P{i,j,ts} is a DijxQ matrix.
%	    Tl - NlxTS cell array, each element P{i,ts} is a VixQ matrix.
%		Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%	  Where
%	    Ni = net.numInputs
%		Nl = net.numLayers
%		LD = net.numLayerDelays
%	    Ri = net.inputs{i}.size
%	    Si = net.layers{i}.size
%	    Vi = net.targets{i}.size
%	    Dij = Ri * length(net.inputWeights{i,j}.delays)
%
%	  If VV is not [], it must be a structure of validation vectors,
%	    VV.PD - Validation delayed inputs.
%	    VV.Tl - Validation layer targets.
%	    VV.Ai - Validation initial input conditions.
%	    VV.Q  - Validation batch size.
%	    VV.TS - Validation time steps.
%	  which is used to stop training early if the network performance
%	  on the validation vectors fails to improve or remains the same
%	  for MAX_FAIL epochs in a row.
%
%	  TRAINLM(CODE) return useful information for each CODE string:
%	    'pnames'    - Names of training parameters.
%	    'pdefaults' - Default training parameters.
%
%	Network Use
%
%	  You can create a standard network that uses TRAINLM with
%	  NEWFF, NEWCF, or NEWELM.
%
%	  To prepare a custom network to be trained with TRAINLM:
%	  1) Set NET.trainFcn to 'trainlm'.
%	     This will set NET.trainParam to TRAINLM's default parameters.
%	  2) Set NET.trainParam properties to desired values.
%
%	  In either case, calling TRAIN with the resulting network will
%	  train the network with TRAINLM.
%
%	  See NEWFF, NEWCF, and NEWELM for examples.
%
%	Algorithm
%
%	  TRAINLM can train any network as long as its weight, net input,
%	  and transfer functions have derivative functions.
%
%	  Backpropagation is used to calculate the Jacobian jX of performance
%	  PERF with respect to the weight and bias variables X.  Each
%	  variable is adjusted according to Levenberg-Marquardt,
%
%	    jj = jX * jX
%	    je = jX * E
%	    dX = -(jj+I*mu) \ je
%
%	  where E is all errors and I is the identity matrix.
%
%	  The adaptive value MU is increased by MU_INC until the change above
%	  results in a reduced performance value.  The change is then made to
%	  the network and mu is decreased by MU_DEC.
%
%	  The parameter MEM_REDUC indicates how to use memory and speed to
%	  calculate the Jacobian jX.  If MEM_REDUC is 1, then TRAINLM runs
%	  the fastest, but can require a lot of memory. Increasing MEM_REDUC
%	  to 2, cuts some of the memory required by a factor of two, but
%	  slows TRAINLM somewhat.  Higher values continue to decrease the
%	  amount of memory needed and increase training times.
%
%	  Training stops when any of these conditions occurs:
%	  1) The maximum number of EPOCHS (repetitions) is reached.
%	  2) The maximum amount of TIME has been exceeded.
%	  3) Performance has been minimized to the GOAL.
%	  4) The performance gradient falls below MINGRAD.
%	  5) MU exceeds MU_MAX.
%	  6) Validation performance has increased more than MAX_FAIL times
%	     since the last time it decreased (when using validation).
%
%	See also NEWFF, NEWCF, TRAINGD, TRAINGDM, TRAINGDA, TRAINGDX.

% Mark Beale, 11-31-97
% Copyright (c) 1992-1998 by The MathWorks, Inc.
% $Revision: 1.1.1.1 $

% **[ NNT2 Support ]**
if ~isa(net,'struct') & ~isa(net,'char')
  nntobsu('trainlm','Use NNT2FF and TRAIN to update and train your network.')
  switch(nargin)
  case 5, [net,tr,v3,v4] = tlm1(net,Pd,Tl,Ai,Q); return
  case 6, [net,tr,v3,v4] = tlm1(net,Pd,Tl,Ai,Q,TS); return
  case 8, [net,tr,v3,v4,v5,v6] = tlm2(net,Pd,Tl,Ai,Q,TS,VV,TV); return
  case 9, [net,tr,v3,v4,v5,v6] = tlm2(net,Pd,Tl,Ai,Q,TS,VV,TV,v9); return
  case 11, [net,tr,v3,v4,v5,v6,v7,v8] = tlm3(net,Pd,Tl,Ai,Q,TS,VV,TV,v9,v10,v11); return
  case 12, [net,tr,v3,v4,v5,v6,v7,v8] = tlm3(net,Pd,Tl,Ai,Q,TS,VV,TV,v9,v10,v11,v12); return
  end
end

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
	  net = fieldnames(trainlm('pdefaults'));
    case 'pdefaults',
	  trainParam.epochs = 100;
	  trainParam.goal = 0;
	  trainParam.max_fail = 5;
	  trainParam.mem_reduc = 1;
	  trainParam.min_grad = 1e-10;
	  trainParam.mu = 0.001;
	  trainParam.mu_dec = 0.1;
	  trainParam.mu_inc = 10;
	  trainParam.mu_max = 1e10;
	  trainParam.show = 25;
	  trainParam.time = inf;
	  net = trainParam;
    otherwise,
	  error('Unrecognized code.')
  end
  return
end

% CALCULATION
% ===========

% Constants
this = 'TRAINLM';
epochs = net.trainParam.epochs;
goal = net.trainParam.goal;
max_fail = net.trainParam.max_fail;
mem_reduc = net.trainParam.mem_reduc;
min_grad = net.trainParam.min_grad;
mu = net.trainParam.mu;
mu_inc = net.trainParam.mu_inc;
mu_dec = net.trainParam.mu_dec;
mu_max = net.trainParam.mu_max;
show = net.trainParam.show;
time = net.trainParam.time;
doValidation = ~isempty(VV);
doTest = ~isempty(TV);

% Initialize
stop = '';
startTime = clock;
X = getx(net);
numParameters = length(X);
ii = sparse(1:numParameters,1:numParameters,ones(1,numParameters));
[perf,E,Ac,N,Zb,Zi,Zl] = calcperf(net,X,Pd,Tl,Ai,Q,TS);
if (doValidation)
  VV.net = net;
  VV.perf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
  vperf=VV.perf;
  VV.numFail = 0;
end
tr = newtr(epochs,'perf','vperf','tperf','mu');

% Train
for epoch=0:epochs

  % Jacobian
  [je,jj,normgX]=calcjejj(net,Pd,Zb,Zi,Zl,N,Ac,E,Q,TS,mem_reduc);
  
  % Training Record
  epochPlus1 = epoch+1;
  tr.perf(epoch+1) = perf;
  tr.mu(epoch+1) = mu;
  if (doValidation)
    tr.vperf(epochPlus1) = vperf;
  end
  if (doTest)
    tr.tperf(epochPlus1) = calcperf(net,X,TV.Pd,TV.Tl,TV.Ai,TV.Q,TV.TS);
  end
  
  % Stopping Criteria
  currentTime = etime(clock,startTime);
  if (perf <= goal)
    stop = 'Performance goal met.';
  elseif (epoch == epochs)
    stop = 'Maximum epoch reached, performance goal was not met.';
  elseif (currentTime > time)
    stop = 'Maximum time elapsed, performance goal was not met.';
  elseif (normgX < min_grad)
    stop = 'Minimum gradient reached, performance goal was not met.';
  elseif (mu > mu_max)
    stop = 'Maximum MU reached, performance goal was not met.';
  elseif (doValidation) & (VV.numFail > max_fail)
    stop = 'Validation stop.';
	net = VV.net;
  end
  
% DXD : comment out all these plots and information stuff.
%
%  % Progress
%  if ~rem(epoch,show) | length(stop)
%    fprintf(this);
%	if isfinite(epochs) fprintf(', Epoch %g/%g',epoch, epochs); end
%	if isfinite(time) fprintf(', Time %4.1f%%',currentTime/time*100); end
%	if isfinite(goal) fprintf(', %s %g/%g',upper(net.performFcn),perf,goal); end
%	if isfinite(min_grad) fprintf(', Gradient %g/%g',normgX,min_grad); end
%	fprintf('\n')
%	plotperf(tr,goal,this,epoch)
%    if length(stop) fprintf('%s, %s\n\n',this,stop); break; end
%  end
  
  % Levenberg Marquardt
  while (mu <= mu_max)
    dX = -(jj+ii*mu) \ je;
	X2 = X + dX;
	net2 = setx(net,X2);
 	[perf2,E2,Ac2,N2,Zb2,Zi2,Zl2] = calcperf(net2,X2,Pd,Tl,Ai,Q,TS);
	if (perf2 < perf)
	  X = X2; net = net2; Zb = Zb2; Zi = Zi2; Zl = Zl2;
	  N = N2; Ac = Ac2; E = E2; perf = perf2;
      mu = mu * mu_dec;
	  break
	end
	mu = mu * mu_inc;
  end
  
  % Validation
  if (doValidation)
    vperf = calcperf(net,X,VV.Pd,VV.Tl,VV.Ai,VV.Q,VV.TS);
	if (vperf < VV.perf)
	  VV.perf = vperf; VV.net = net; VV.numFail = 0;
	elseif (vperf > VV.perf)
      VV.numFail = VV.numFail + 1;
	end
  end
end

% Finish
tr = cliptr(tr,epoch);
