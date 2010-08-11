% DD_EX3
%
% Show the use of the ksvdd: the support vector data description using
% several different kernels.
%
% To be honest, the SVDD is the most useful using the RBF kernel. In 
% most cases therefore svdd.m will suffice. But if you are interested
% how other kernels look like, this might be interesting.
%
% Note, that the evaluation of KSVDD can be pretty slow, because for each
% evaluation of an object z, it is required to compute K(z,z). This 
% requires the construction of a myproxm-mapping to object z, which is
% very expensive.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Make some data:
a = target_class(gendatb([40 40]),'1');
% Make a scatterplot of the data:
figure(1); clf; hold on;
scatterd(a);

% Basic SVDD:
w1 = svdd(a,0.1,3);     % Implicit RBF kernel with sigma=3
plotc(w1);              % Plot the result in the scatterplot

% Giving the kernel mapping by:
wk = myproxm([],'r',3); % Explicit RBF kernel with sigma=3
w2 = ksvdd(a,0.1,wk);   % Train the classifier
plotc(w2,'r');          % Plot the results, should be equal to the
                        % previous plot!

wk = myproxm([],'p',2); % Explicit Polynomial kernel with d=2
w3 = ksvdd(a,0.1,wk);   % Train the classifier
plotc(w3,'g');          % Plot the results

wk = myproxm([],'p',3); % Explicit Polynomial kernel with d=3
w4 = ksvdd(a,0.1,wk);   % Train the classifier
plotc(w4,'b');          % Plot the results


% Finally, define the kernel externally:
x = +a;                 % Get the data, without dataset definition
K = (x*x'+1).^4;        % Polynomial kernel degree 4.
grid = gendatgrid;      % The kernel of the feature space grid:
Kgrid = (grid*x'+1).^4; % Polynomial kernel degree 4.
% Unfortunately, we also have to find the K(z_i,z_i) of the
% gridpoints themselves:
n = length(grid);
diagK = zeros(n,1);
for i=1:n
	diagK(i) = (grid(i,:)*grid(i,:)'+1).^4;
end
Kgrid = [Kgrid diagK];  % So the complete kernel is constructed.
w6 = ksvdd(K,0.1);      % Train the classifier
h = plotg(grid,Kgrid*w6,'k'); % Plot the results




