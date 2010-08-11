%DD_EX10
%
% This example shows the use of the incremental SVDD. On the banana set
% an initial SVDD is fitted using Wstartup. When 

% create initial dataset:
a = target_class(gendatb([10 10]),1);
figure(1); clf; h0 = scatterd(a); axis equal;

% setup the parameters for the Wstartup:
C = 1;
kpar.type = 'r';
kpar.s = 4;
[n,dim] = size(a);
x = +a;
y = getoclab(a);

% Here the incsvdd is made:
W = Wstartup(x,y,C,'inckernel',kpar);
w0 = Wstore(W);
% And show it:
h0w = plotc(w0);

% Now one point is added:
b = target_class(gendatb([1 1]),1);
hold on; h1 = scatterd(b,'g+');

% Add this to the structure:
W = Wadd(W,+b,+1);
w1 = Wstore(W);
% And show it:
h1w = plotc(w1,'g');

% And now the first object is removed:
hold on; h2 = scatterd(a(1,:),'r*');
W = Wremove(W,1);
w2 = Wstore(W);
% And show it:
h2w = plotc(w2,'r');

legend([h0(1) h0w(1) h1(1) h1w(1) h2(1) h2w(1)]',...
       'original data','original SVDD (black)',...
       'added object','extended SVDD (green)',...
       'removed object','shrunken SVDD (red)',...
		 'location','bestoutside');
