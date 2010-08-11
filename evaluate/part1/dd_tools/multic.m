%MULTIC Make a multi-class classifier
%
%    W = MULTIC(A,V)
%
% Train the (untrained!) one-class classifier V on each of the classes
% in A, and combine it to a multi-class classifier W. If an object is
% rejected by all one-class classifiers, it will be classified
% 'outlier'. If it is accepted by more than one one-class classifier, it
% will be assigned to the class with the highest class posterior.
%
% Frustratingly, it can happen that the class labels are numbers. In
% that case the outlier class label will be 0.
%
% Furthermore, in the current version the OCC's are only given the
% target data, and do not use any example outlier data. This may change
% in the future.
%
%    W = MULTIC(A,{V1 V2 ... VK})
% 
% The trained one-class classifiers V1...VK are combined to a multiclass
% classifier W.
%
%    W = MULTIC(A,W,EMPTYV)
% 
%
% See also dd_normc, myproxm

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
  
function w = multic_dd(a,v,newv)

if nargin<3
	newv = [];
end
if nargin<2
	v{1} = gauss_dd([],0.1);
end
if nargin<1 | isempty(a)
	if ~isa(v,'cell')
		tmp = v; v = {}; v{1} = tmp;
	end
	w = mapping(mfilename,{v});
	% full name:
	fname = ['Multiclass ',getname(v{1})];
	w = setname(w,fname);
	return
end

if ~ismapping(v) | ~istrained(v)  % first training of the multic
	[n,k,c] = getsize(a);
	if ~isa(v,'cell') %check if we have a cell-array of mappings
		%warning('Input v should be a (%dx1) cell array of mappings.',c);
		tmp{1} = v;
		v = tmp;
	end
	if length(v)~=c % check if the size of the cellarray is good enough.
		if length(v)==1
			v = repmat(v,c,1);
		else
			error('Input v should be a (%dx1) cell array of mappings.',c);
		end
	end
	for i=1:c % check if we really have untrained mappings
		if ~ismapping(v{i}) | istrained(v{i})
			error('The supplied V''s should be untrained OC mappings.');
		end
	end
	% train the individual OCCs
	for i=1:c
		W{i} = target_class(a,i)*v{i};
		if ~is_occ(W{i})  % this test can only be applied to trained
			               % mappings
			error('Multic can only combine one-class classifiers.');
		end
		% find the average output on the training set and use that for the
		% 'natural' scaling of the output
		out = target_class(a,i)*W{i};
		out = (+out(:,'target')) - double(out(1,'outlier'));
%		Iin = find(out>0); sc(i) = mean(out(Iin));
		sc(i) = mean(out);
		%sc(i) = 1;
	end
	% construct the lablist for the final mapping
	labl = getlablist(a);
	if ~isa(labl,'char')
		warning('Labels are integers. Outlier class will be labeled 0.');
		L = [labl; 0];
	else
		L = strvcat(labl,'outlier');
	end
	% store and pack
	W.w = W;
	W.sc = sc;
	w = mapping(mfilename,'trained',W,L,k,size(L,1));
	fname = ['Multiclass ',getname(W.w{1})];
	w = setname(w,fname);

elseif ismapping(v) & istrained(v) & ~isempty(newv) % add an extra OCC

	if isempty(newv)
		error('An untrained OC mapping should be supplied for the new class.');
	end
	if ~ismapping(newv) | istrained(newv)
		error('An untrained OC mapping should be supplied for the new class.');
	end
	% now we have to check the class label
	if ~isdataset(a)
		error('Please supply a dataset A with one class.');
	end
	c = getsize(a,3);
	if length(c)>1
		error('Only a single class should be supplied.');
	end
	% are we really updating a multic?
	if ~strcmp(getmapping_file(v),mfilename)
		error('Only a Multic classifier can be updated.');
	end
	% check if this class already exist, if not, add it, otherwise
	% complain.
	newlab = getlablist(a);
	oldll = getlabels(v);
	if ~strcmp(class(newlab),class(oldll))
		error('The labels in the old and new datasets are not of the same type.');
	end
	%     (comparing labels is different for character and numeric
	%     labels)
	if isa(newlab,'double')
		if any(oldll==newlab)
			error('Label %d already exist.',newlab);
		end
		newll = [oldll(1:end-1); newlab; oldll(end)];
	else
		if ~isempty(strmatch(newlab,oldll))
			error('Label %s already exist.',newlab);
		end
		newll = strvcat(oldll(1:end-1,:), newlab, oldll(end,:));
	end
	% Finally, train the new OCC and extend our multic:
	W = v.data;
	W.w{end+1} = target_class(+a)*newv;
	if ~is_occ(W.w{end})  % this test can only be applied to trained
			               % mappings
		error('Multic can only add a one-class classifier.');
	end
	% find the average output on the training set and use that for the
	% 'natural' scaling of the output
	out = target_class(+a)*W.w{end};
	out = (+out(:,'target')) - double(out(1,'outlier'));
	Iin = find(out>0);
	W.sc(end+1) = mean(+out(Iin));
	% store the mapping and update labels/sizes:
	w = setdata(v,W);
	w = setlabels(w,newll);
	w = setsize_out(w,getsize_out(w)+1);

else
	% evaluation!
	W = getdata(v);
	[m,k] = size(a);

	% apply all mappings sequentially:
	% (the first mapping is a special case)
	out = a*W.w{1};
	% fix the outputs such that all the threshold is always at 0:
	out = +(out(:,'target')-out(:,'outlier'));
	% and such that the output was always 1:
	out = out/W.sc(1);
	for i=2:length(W.w)
		newout = a*W.w{i};
		newout = +(newout(:,'target')-newout(:,'outlier'));
		out = [out newout/W.sc(i)];
	end
	% add the 'outlier'-class output as the last column and return
	w = setdat(a,[out zeros(m,1)],v);
end


return
