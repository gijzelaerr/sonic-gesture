function plotroc_update(w,a)
% PLOTROC_UPDATE(W,A)
%
% Auxiliary function containing the callbacks for the plotroc.m.
%
% See also: plotroc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if isocc(w)
	if ~isocset(a)
		error('setthres: I should have a OC-dataset to set the threshold');
	end

	% Get the ROC data:
	H = gcf;

	% Prepare the figure for interaction:
	% Store the old settings and setup the new ones:
	UD = get(H,'userdata');
	UD.units = get(H,'units');
	set(H,'units','pixels')
	h_ax = get(H,'children');
	UD.ax_units = get(h_ax,'units');
	set(h_ax,'units','pixels')
	UD.sz = get(h_ax,'position');
	UD.pointer = get(H,'pointer');
	set(H,'pointer','crosshair')
	UD.olddown = get(H,'Windowbuttondownfcn');
	set(H,'Windowbuttondownfcn','plotroc_update(''keydown'')');
	UD.oldmove = get(H,'Windowbuttonmotionfcn');
	set(H,'Windowbuttonmotionfcn','plotroc_update(''keymove'')');
	UD.w = w;
	set(H,'userdata',UD);
	% and some speedups?
	set(H,'busyaction','cancel','DoubleBuffer','off');
else
	if ~ischar(w)
		error('I am expecting a string input');
	end
	switch(w)
	case 'fix'
		% Restore to original situation:
		UD = get(gcbf,'userdata');
		set(gcbf,'units',UD.units);
		set(gcbf,'pointer',UD.pointer);
		set(gcbf,'windowbuttondownfcn',UD.olddown);
		set(gcbf,'windowbuttonmotionfcn',UD.oldmove);
		h_ax = get(gcbf,'children');
		set(h_ax,'units',UD.ax_units);

	case 'keydown'
		% When a mouse button is clicked, retrieve the operating point,
		% update the classifier and return the classifier.

		% Get the position of the temporary operating point:
		htmp = findobj('tag','currpoint');
		currx = get(htmp,'xdata');
		curry = get(htmp,'ydata');

		% Set the position of the operating point:
		h = findobj('tag','OP');
		set(h,'xdata',currx);
		set(h,'ydata',curry);

		% Find the position in the coordinate list:
		UD = get(gcbf,'userdata');
		Ix = find(currx==UD.coords(:,1));
		Iy = find(curry==UD.coords(:,2));
		J = intersect(Ix,Iy);
		if isempty(J)
			error('I cannot recover the operating point');
		end
		if length(J)>1
			error('Too many candidates');
		end

		% update the stored classifier:
		W = UD.w; dat = W.data; 
		%DXD this is a hack!! But I don't feel like checking again if this
		%classifier is distance based or density based
		%oldt = dat.threshold 
		%newt = abs(UD.thresholds(J))
		dat.threshold = abs(UD.thresholds(J));
		ww = setdata(W,dat);
		UD.w = ww;
		set(gcbf,'userdata',UD);

		%update the title
		set(UD.h_title,'string','Set classifier to this operating point');

	case 'keymove'
		% When moving the cursor, the temporary operating point should
		% move position:

		% find the possible coordinates for the OP:
		UD = get(gcbf,'userdata');
		roc_x = UD.coords(:,1);
		roc_y = UD.coords(:,2);

		% Now find where the cursor is:
		h = get(0,'PointerWindow');
		pos = get(0,'PointerLocation');
		loc = get(gcbf,'position');
		pos_x = (pos(1)-loc(1)-UD.sz(1))/UD.sz(3);
		pos_y = (pos(2)-loc(2)-UD.sz(2))/UD.sz(4);

		% and find the closest object on the curve (in terms of the
		% x-feature):
		dff = abs(roc_x-pos_x);
		[minD,I] = min(dff);
		J = find(dff==minD);

		% if there are several points with minimum distance, take also the
		% y-coordinate into account):
		if length(J)>1
			dff = abs(roc_y(J)-pos_y);
			[minD,Jy] = min(dff);
			J = J(Jy);
		end
		% Update the operating point:
		h = findobj('tag','currpoint');
		set(h,'visible','off');
		set(h,'xdata',roc_x(J));
		set(h,'ydata',roc_y(J));
		set(h,'visible','on');

		% Update the title
		str = sprintf('(%5.3f, %5.3f)',roc_x(J),roc_y(J));
		if pos_x>=0 & pos_x<=1 & pos_y>=0 & pos_y<=1
			set(UD.h_title,'string',str);
			set(UD.h_title,'color',[1 0 0]);
		else
			set(UD.h_title,'string','');
		end

	otherwise
		error('Unknown type in imroc');
	end
end

return
