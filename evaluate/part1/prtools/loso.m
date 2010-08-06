%LOSO  Leave_One_Set_Out crossvalidation
%
%		[E,C,D] = LOSO(A,CLASSF,LABLISTNAME)
%		[E,C,D] = LOSO(A,CLASSF,SETLABELS)
%		[E,C,D] = LOSO(A,CLASSF,SETLABELS,SETLABLIST)
%
% INPUT
%   A            Dataset
%   CLASSF       Untrained classifier
%   LABLISTNAME  Name of label list incase of multiple labeling
%   SETLABELS    Set labels for objects in A
%   SETLABLIST   Order and selection of labels in SETLABELS
%
% OUTPUT
%   E            Classification error
%   C            Array with numbers of erroneaously clasified objects
%                per label (vertically) and per class (horizontally)
%   D            Classification matrix of classified objects
%                (order may be different from A)
%
% DESCRIPTION
% In crossvalidation it may be desired that sets of corresponding objects
% (e.g. pixels from the same image) are all together in the training set or
% in the test set. This might be enabled by adding an additional labeling to
% the dataset A (see ADDLABELS) corresponding to the sets and running LOSO
% with the corresponding LABLISTNAME.
% Alternatively, the set labels may be supplied in the call. In SETLABLIST
% a ranking of the used labels can be supplied that will be used in C.
% In case SETLABLIST does not contain all set labels used in SETLABELS LOSO
% will only test the set labels given in SETLABLIST and thereby perform a
% reduced crosvalidation.
%
% The reported error E identical to E = sum(C)./classsizes(D)*getprior(A)';
% By confmat(D) a confusion matrix can be visualised.
%
% SEE ALSO
% DATASETS, MAPPINGS, TESTC, CONFMAT

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [e,err,d] = loso(a,classf,setlab,setlablist)

if nargin < 4, testfun = testc; end

if nargin == 3 & size(setlab,1) == 1
	lablistname = setlab;
	b = changelablist(a,lablistname);
elseif nargin == 3
	b = addlabels(a,setlab); 
else
	b = addlablist(a,setlablist);
	b = setnlab(b,renumlab(setlab,setlablist));
end

nset = getsize(b,3);  
S = [1:nset 0];
c = getsize(a,3);
s = sprintf('Testing %i sets: ',nset);
prwaitbar(nset,s);
err = zeros(nset,c);
d = [];
N = 0;
for j=1:nset
	prwaitbar(nset,j,[s int2str(j)]);
	T = S;
	T(j) = [];
	x = changelablist(seldat(b,T),1);
	y = changelablist(seldat(b,j),1); 
	N = N+size(y,1);
	if ~isempty(y)
		dd = y*(x*classf);
		dd = dataset(dd);
		[ee,err(j,:)] = testc(dd);
		d = [d;dd];
	end
end
prwaitbar(0);
e = sum(err)./classsizes(d);
e = e*getprior(a)';
	