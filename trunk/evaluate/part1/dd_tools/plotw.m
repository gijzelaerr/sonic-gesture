function h = plotw(w,nrc)
%PLOTW Plot the classifier w.
%
%    h = plotw(w,nrc)
%
% Please use plotc instead.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

if nargin<2
  nrc = 10;
end

% first determine the grid:
V = axis;
[grid,x,y] = makegriddat(V(1),V(2),V(3),V(4));
% determine the size
lx = length(x);
ly = length(y);

% make the output
z = grid*w;

% see if z has the right size
if (size(z,2)>2)
  error('Data z does not have appropriate size');
end
if (size(z,2)==2)
  z = z(:,1) - z(:,2);
  if (nrc==1)
    contour(x,y,reshape(+z,ly,lx),[0 0],'k');
  else
    [c,h] = contourf(x,y,reshape(+z,ly,lx),nrc);
    hold on;
    [c2,h2] = contour(x,y,reshape(+z,ly,lx),[0 0]);
    set(h2,'linewidth',2,'edgecolor','w');
  end
else
  hold on;
  if (nrc==1)
    [c,h] = contour(x,y,reshape(+z,ly,lx),[0 0],'k');
  else
    [c,h] = contourf(x,y,reshape(+z,ly,lx),nrc);
  end
end


return
