function [D,path] = dijk(A,s,t)
%DIJK Shortest paths from nodes 's' to nodes 't' using Dijkstra algorithm.
% D = dijk(A,s,t)
%
% INPUT 
%   A  n x n node-node weighted adjacency matrix of arc lengths
%         (Note: A(i,j) = 0   => Arc (i,j) does not exist;
%   s FROM node indices = [] (default), paths from all nodes
%   t TO node indices   = [] (default), paths to all nodes
%
% OUTPUT
%     D = |s| x |t| matrix of shortest path distances from 's' to 't'
%       = [D(i,j)], where D(i,j) = distance from node 'i' to node 'j' 
%
%		path minimum path
%
%
%  (Based on Fig. 4.6 in Ahuja, Magnanti, and Orlin, Network Flows,
%   Prentice-Hall, 1993, p. 109.)
% 
% See also mst_dd,datasets, mappings

%  Copyright: Piotr Juszczak, p.juszczak@tudelft.nl
%  Information and Communication Theory Group,
%  Faculty of Electrical Engineering, Mathematics and Computer Science,         
%  Delft University of Technology,            
%  The Netherlands


%============================ Input Error Checking =============================================
error(nargchk(1,3,nargin));

[n,cA] = size(A);

if nargin < 2 | isempty(s), s = (1:n)'; else s = s(:); end
if nargin < 3 | isempty(t), t = (1:n)'; else t = t(:); end

if n ~= cA
   error('A must be a square matrix');
elseif any(any(A < 0))
   error('A must be non-negative');
elseif any(s < 1 | s > n)
   error(['''s'' must be an integer between 1 and ',num2str(n)]);
elseif any(t < 1 | t > n)
   error(['''t'' must be an integer between 1 and ',num2str(n)]);
end
%============================  End (Input Error Checking)=======================================

D = zeros(length(s),length(t));
%P = zeros(length(s),n);
path = [];

for i = 1:length(s)
   j = s(i);
   
   Di = Inf*ones(n,1); Di(j) = 0;
   
   isLab = logical(zeros(length(t),1));
   nLab = 0;
   UnLab = 1:n;
   isUnLab = logical(ones(n,1));
   
   while nLab < n & ~all(isLab)
       [Dj,jj] = min(Di(isUnLab));
       j = UnLab(jj);
       UnLab(jj) = [];
       isUnLab(j) = 0;      
       
       nLab = nLab + 1;
       
       if length(t) < n, isLab = isLab | (j == t); end
       
       [jA,kA,Aj] = find(A(:,j));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		 
       Aj(isnan(Aj)) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		 
       if isempty(Aj), Dk = Inf; else Dk = Dj + Aj; end
%			 P(i,jA(Dk < Di(jA))) = j;
				Di(jA) = min(Di(jA),Dk); 
				
				if(nargout > 1 )
					path = [path j];
				end
	 end
  D(i,:) = Di(t)';
end

if(nargout > 1)		
	
	tmp = path;
	col = 1:size(A,2);
	
	while(sum(sum((A(tmp,col)~=0),2)==1) > 2)
		tmp2 = sum((A(tmp,col)~=0),2);
		
		ind = find(tmp2==1);
		
		ind = setdiff(ind,[1;size(tmp2,1)]);
		col = setdiff( col , tmp(ind) );
		tmp = tmp(setdiff(1:size(tmp,2),ind));
				
	end
	
	path = tmp;
	
end

return;