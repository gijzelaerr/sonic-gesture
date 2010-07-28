%MATCHLAB Compare two labellings and rotate the labels for an optimal match
%
%  LABELS = MATCHLAB(LAB1,LAB2)
%
% INPUT
%   LAB1,LAB2  Label lists of the same objects   
%
% OUTPUT
%   LABELS     A rotated version of LAB2, optimally matched with LAB1
%
% DESCRIPTION
% LAB1 and LAB2 are label lists for the same objects. The returned LABELS 
% constitute a rotated version of LAB2, such that the difference with 
% LAB1 is minimized. This can be used for the alignment of cluster results.
%
% EXAMPLES
% See PREX_MATCHLAB.
%
% SEE ALSO
% DATASETS, HCLUST, MODESEEK, KMEANS, EMCLUST

% $Id: matchlab.m,v 1.2 2006/03/08 22:06:58 duin Exp $


function [lab,L] = matchlab(lab1,lab2)

	prtrace(mfilename);

  [ok1,lab1] = iscolumn(lab1);
  [ok2,lab2] = iscolumn(lab2);
	if (~ok1) | (~ok2)
		prwarning(5,'Label lists should be column lists. LAB1 and LAB2 are made so.');
	end

	% Compute the confusion matrix and renumber the labels.
	C = confmat(lab1,lab2); 			
	[nl1,nl2,lablist] = renumlab(lab1,lab2);

	% N1 and N2 describe the number of distinct labels (classes) in LAB1 and LAB2.
	[n1,n2] = size(C);			

	L = zeros(n2,1);			% Label list for the rotated LAB2
	K = [1:n1]; 					% Class labels of LAB1

	% Find the best match based on the confusion numbers.	
	for i=1:n1
		[NN,r] = min(sum(C(:,K),1) - max(C(:,K),[],1)); 	
		j      = K(r);							% J is the actual class of LAB2 
		[nn,s] = max(C(:,j)); 			% to be assigned as S.
		L(j)   = s;
		C(:,j) = zeros(n1,1); 			% J is already processed, remove it 
		K(r)   = [];								% from further considerations.
	end

	lab = lablist(L(nl2),:);
return;

