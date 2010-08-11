function [a,I] = oc_set(a,clnr)
% OC_SET  makes an one-class dataset
%
%     A = OC_SET(A,CLNR)
%
% Change a normal dataset A into an one-class dataset: the class
% indicated by the classnr (CLNR) is made target class and all other
% data becomes outliers class. The labels are changed to 'target' and
% 'outlier'.
%
% It is also possible to use a class label:
%
%    A = OC_SET(A,LABEL)
%
% but then the type of the label should be a char (else you cannot
% distinguish it from a class number, can you?:-))
%
%    [A,I] = OC_SET(A,LABEL)
%
% As a second output argument an index vector I is returned, indicating
% which objects are target (I=1) or outlier (I=2).
%
%
% See also: target_class, find_target, gendatoc, isocset

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
if (nargin<2)
	clnr = 1;
end

% I have to check Prtools somewhere...:
% checkprversion;

% First check if there is more than one label indicating the target
% class, then we will recursively call oc_set.
if ~ischar(clnr) & size(clnr,2)>1,
	clnr = clnr';
end
if size(clnr,1)>1 % we have more than 1 label
	I = [];
	% go along each class and extract the indices of the objects
	% belonging
	for i=1:size(clnr,1)
		[tmpx,tmpI] = oc_set(a,clnr(i,:));
		I = [I; find(tmpI==1)];
	end
	nlab = repmat(2,size(a,1),1);
	nlab(I) = 1;
	%a = dataset(a,nlab,'lablist',['target ';'outlier']);
	a = dataset(a,nlab);
	a = setlablist(a);
	a = set(a,'lablist',['target ';'outlier']);
	% and fix the new dataset name:
	clname = sprintf('%d classes as target',size(clnr,1));
	a = setname(a,[getname(a),' (',clname,')']);
	%a = setprior(a,[]);
	return
end

% If a is just a Matlab array, everything becomes target data:
if ~isdataset(a)
	m = size(a,1);
	a = dataset(a,ones(m,1),'lablist','target');
	a = setprior(a,1);
	I = ones(m,1);
	return;
else
	% first unpack the clnr, if it was just a single entry in a
	% cell-array:
	if isa(clnr,'cell')
		clnr = clnr{1};
	end

	if is_ocset(a)
		
		% If we are given an one-class dataset, the only possibility is
		% that we have to switch the target-outlier labels.
		if (isa(clnr,'char') & strcmp(clnr,'outlier')) | ...
			(isa(clnr,'double') & clnr<0)
		% That is the case, we swap the classes. We just swap
		% the labels by changing nlab so we can later search for 'target'
		% instead of 'outlier':

			% Now we check if we are not dealing with strange situations
			% that all data is of one of the classes:
			if getsize(a,3)==2
				% Ok, swap the labels
				a = set(a,'nlab',3-getnlab(a));
			else
				% we only have one class
				if strcmp(getlablist(a),'outlier')
					% and this class is indeed outlier
					a = setlablist(a,'target');
				else
					% we only have target data in the dataset, but we are
					% requesting outliers: problem! Return an empty dataset:
					a = setlablist(a,'outlier');
				end
			end
		end
		%else we have already a correct oneclass dataset
		I = repmat(2,size(a,1),1);
		I(find_target(a)) = 1;
		return;
	end

	% Now we have to work, detect the label in the dataset:
	[nlab,lablist] = getnlab(a);
	if isempty(lablist)
		warning('dd_tools:UnlabeledDataset',...
			'This dataset is unlabeled: all data is considered target.');
		[a,I] = oc_set(+a);
		return
	end
	
	[m,k,c] = getsize(a,1);

	% This is a hack:
	% If the lablist contains characters, but all character values are
	% smaller than 32 (smaller ASCI value), than something went probabily
	% wrong, and then we assume it were just doubles. This happens for
	% instance in the NIST dataset:-(
	if isa(lablist,'char')
		if length(find(lablist<32))==size(lablist,1)
			a = set(a,'lablist',double(lablist));
		end
	end

	% Depending on the type of label, we have to do other things:
	if isa(clnr,'char')

		% We have to string-match with the lablist
		if isa(lablist,'double')
			% If the lablist is a number, we'd better change the clnr also
			% to a number
			clnr = str2num(clnr);
			if ~isempty(clnr)
				clnr = find(lablist==clnr);
			%else the clnr was a label-string and not a number, so it will
			%not match anyway
			end
		else % Lablist is character
			% Ok, we get a bit inconsistent behaviour here. It might be
			% that when the dataset contains just target objects, the label
			% becomes 'target' without trailing ' '. Then the strmatch has
			% to be switched. When also outliers are present, there will be
			% always this trailing ' ', so then we don't have a problem.
			% (Thanks Piotr!:-)
			if (c==1)
				clnr = strmatch(lablist,clnr);
			else
				clnr = strmatch(clnr,lablist);
			end
		end
	end

	% Make the new labels, target objects get 1, outlier objects get 2:
	if isempty(clnr)
		% everything becomes outlier
		I = repmat(2,m,1);
	else
		% Otherwise apply the hard fought for clnr:
		I = 2-(nlab==clnr);
	end
	
	% Now construct the dataset:
	labelnames = str2mat('target', 'outlier');
	a = set(a,'labels',labelnames(I,:));
	% and fix the new dataset name:
	if (clnr<=size(lablist,1))
		clname = lablist(clnr,:);
	else
		clname = clnr;
	end
	if isa(clname,'double')
		clname = num2str(clname);
	end
	if ~isempty(clname)
		a = setname(a,[getname(a),' (targetcl. ',deblank(clname),')']);
	end
	a = setprior(a,getprior(a,0));% hmmm, is this the right thing to do??

	% Maybe we should give some message?
	if isempty(clname)
		fprintf('No target class found.\n');
	else
		% fprintf('Class %s is used as target class.\n',deblank(clname));
	end
	
end

return
