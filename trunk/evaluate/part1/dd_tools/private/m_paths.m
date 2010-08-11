function [l,p] = m_paths(A,n)
% [l,p] = m_paths(A,n)
%
% n paths, with maximum length, in a graph which is 
% described by an adjacency matrix A
%
% INPUT
%	A			weighted adjacency matrix 
%
% OUTPUTS
%	l   		lenght of paths	
%	p   		nods in the path 
% See also mst_dd,datasets, mappings

%  Copyright: Piotr Juszczak, p.juszczak@tudelft.nl
%  Information and Communication Theory Group,
%  Faculty of Electrical Engineering, Mathematics and Computer Science,         
%  Delft University of Technology,            
%  The Netherlands

if nargin < 2 | isempty(n), n = maxreal; end

l = zeros(floor(size(A,1)/2),1);
p = cell(floor(size(A,1)/2),1);
k = 1;

while( any(any(A)) & k <= n )
	
	D = dijk(A);
	D(isinf(D)) = 0;
	[m,i] = max(D,[],1);
	[mm,j] = max(m);
	[DD,path] = dijk(A,i(j),j);
	
	l(k,1) = DD;
	p{k,1} = path;
	
	k = k+1;
	
	for i=1:size(path,2)-1		
		A(path(i),path(i+1)) = 0;
		A(path(i+1),path(i)) = 0;
	end
	
	A(path(end),path(end-1)) = 0;
	A(path(end-1),path(end)) = 0;

end

p = p(1:k-1,1);
l = l(1:k-1,1);

return;