%CLEVAL Classifier evaluation (learning curve)
%
%   E = CLEVAL(A,CLASSF,TRAINSIZES,NREPS,T,TESTFUN)
%
% INPUT
%   A          Training dataset
%   CLASSF     Classifier to evaluate
%   TRAINSIZE  Vector of class sizes, used to generate subsets of A
%              (default [2,3,5,7,10,15,20,30,50,70,100])
%   NREPS      Number of repetitions (default 1)
%   T          Tuning dataset (default [], use remaining samples in A)
%   TESTFUN    Mapping,evaluation function (default classification error)
%
% OUTPUT
%   E          Error structure (see PLOTE) containing training and test
%              errors
%
% DESCRIPTION
% Generates at random, for all class sizes defined in TRAINSIZES, training
% sets out of the dataset A and uses these for training the untrained
% classifier CLASSF. CLASSF may also be a cell array of untrained
% classifiers; in this case the routine will be run for all of them. The
% resulting trained classifiers are tested on the training objects and
% on the left-over test objects. This procedure is then repeated NREPS
% times. The default test routine is classification error estimation by
% TESTC([],'crisp'). 
%
% Training set generation is done "with replacement" and such that for each
% run the larger training sets include the smaller ones and that for all
% classifiers the same training sets are used.
%
% If CLASSF is fully deterministic, this function uses the RAND random
% generator and thereby reproduces if its seed is reset (see RAND).
% If CLASSF uses RANDN, its seed may have to be set as well.
%
% Per default both the true error (error on the test set) and the
% apparent error (error on the training set) are computed. They will be
% visible when the curves are plotted using PLOTE.
%
% SEE ALSO
% MAPPINGS, DATASETS, CLEVALB, TESTC, PLOTE
% Examples in PREX_CLEVAL

% Copyright: D.M.J. Tax, R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function e = cleval(a,classf,learnsizes,nreps,t,testfun)

	prtrace(mfilename);

  if (nargin < 6) | isempty(testfun)
    testfun = testc([],'crisp');
  end;
  if (nargin < 5) | isempty(t)
    prwarning(2,'no tuning set T supplied, using remaining samples in A');
    t = [];
  end;
  if (nargin < 4) | isempty(nreps);
    prwarning(2,'number of repetitions not specified, assuming NREPS = 1');
    nreps = 1;
  end;
  if (nargin < 3) | isempty(learnsizes);
    prwarning(2,'vector of training set class sizes not specified, assuming [2,3,5,7,10,15,20,30,50,70,100]');
    learnsizes = [2,3,5,7,10,15,20,30,50,70,100];
  end;

  % Correct for old argument order.

  if (isdataset(classf)) & (ismapping(a))
    tmp = a; a = classf; classf = {tmp};
  end
  if (isdataset(classf)) & (iscell(a)) & (ismapping(a{1}))
    tmp = a; a = classf; classf = tmp;
  end
  if ~iscell(classf), classf = {classf}; end

  % Assert that all is right.
  isdataset(a); ismapping(classf{1}); if (~isempty(t)), isdataset(t); end

  % Remove requested class sizes that are larger than the size of the
  % smallest class.

  mc = classsizes(a); [m,k,c] = getsize(a);
  toolarge = find(learnsizes >= min(mc));
  if (~isempty(toolarge))
    prwarning(2,['training set class sizes ' num2str(learnsizes(toolarge)) ...
                 ' larger than the minimal class size in A; removed them']);
    learnsizes(toolarge) = [];
  end
  learnsizes = learnsizes(:)';

  % Fill the error structure.

  nw = length(classf(:));
  datname = getname(a);

  e.n       = nreps;
  e.error   = zeros(nw,length(learnsizes));
  e.std     = zeros(nw,length(learnsizes));
  e.apperror   = zeros(nw,length(learnsizes));
  e.appstd     = zeros(nw,length(learnsizes));
  e.xvalues = learnsizes(:)';
  e.names   = [];
  if (nreps > 1)
    e.ylabel= ['Averaged error (' num2str(nreps) ' experiments)'];
  elseif (nreps == 1)
    e.ylabel = 'Error';
  else
    error('Number of repetitions NREPS should be >= 1.');
  end;
  if (~isempty(datname))
    e.title = ['Learning curve on ' datname];
  end
  if (learnsizes(end)/learnsizes(1) > 20)
    e.plot = 'semilogx';        % If range too large, use a log-plot for X.
  end

  % Report progress.
	
	s1 = sprintf('cleval: %i classifiers: ',nw);
	prwaitbar(nw,s1);

  % Store the seed, to reset the random generator later for different
  % classifiers.

	seed = rand('state');

  % Loop over all classifiers (with index WI).

  for wi = 1:nw
		
    if (~isuntrained(classf{wi}))
      error('Classifiers should be untrained.')
    end
    name = getname(classf{wi});
    e.names = char(e.names,name);
    prwaitbar(nw,wi,[s1 name]);

    % E1 will contain the error estimates.

    e1 = zeros(nreps,length(learnsizes));
    e0 = zeros(nreps,length(learnsizes));

    % Take care that classifiers use same training set.

    rand('state',seed); seed2 = seed;

		% For NREPS repetitions...
		
		s2 = sprintf('cleval: %i repetitions: ',nreps);
		prwaitbar(nreps,s2);

		for i = 1:nreps
	
			prwaitbar(nreps,i,[s2 int2str(i)]);
      % Store the randomly permuted indices of samples of class CI to use in
      % this training set in JR(CI,:).

			JR = zeros(c,max(learnsizes));
			
			for ci = 1:c

				JC = findnlab(a,ci);

        % Necessary for reproducable training sets: set the seed and store
        % it after generation, so that next time we will use the previous one.
				rand('state',seed2);

				JD = JC(randperm(mc(ci)));
				JR(ci,:) = JD(1:max(learnsizes))';
				seed2 = rand('state'); 
			end

			li = 0;										% Index of training set.
			
			nlearns = length(learnsizes);
			s3 = sprintf('cleval: %i sizes: ',nlearns);
			prwaitbar(nreps,s3);
			
			for j = 1:nlearns 
				
				nj = learnsizes(j);
				
				prwaitbar(nlearns,j,[s3 int2str(j) ' (' int2str(nj) ')']);
				li = li + 1;

        % J will contain the indices for this training set.

        J = [];
        for ci = 1:c
          J = [J;JR(ci,1:nj)'];
        end;

				w = a(J,:)*classf{wi}; 					% Use right classifier.
				e0(i,li) = a(J,:)*w*testfun;
				if (isempty(t))
  				Jt = ones(m,1);
					Jt(J) = zeros(size(J));
					Jt = find(Jt); 								% Don't use training set for testing.
					e1(i,li) = a(Jt,:)*w*testfun;
				else
					e1(i,li) = t*w*testfun;
				end

			end
			prwaitbar(0);

		end
		prwaitbar(0);

    % Calculate average error and standard deviation for this classifier
    % (or set the latter to zero if there's been just 1 repetition).

		e.error(wi,:) = mean(e1,1);
		e.apperror(wi,:) = mean(e0,1);
		if (nreps == 1)
			e.std(wi,:) = zeros(1,size(e.std,2));
			e.appstd(wi,:) = zeros(1,size(e.appstd,2));
		else
			e.std(wi,:) = std(e1)/sqrt(nreps);
			e.appstd(wi,:) = std(e0)/sqrt(nreps);
		end
	end
	prwaitbar(0);

	% The first element is the empty string [], remove it.
	e.names(1,:) = [];

return

