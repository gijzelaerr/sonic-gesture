%DD_MEM Size of memory and loops for intermediate results
% 
% 	[loops,rows,last] = dd_mem(m,k)
% 
% The numbers of loops and rows are determined that are needed if in 
% total an intermediate array of m*k is needed such that rows*k < 
% PRMEMORY. The final number of rows for the last loop is returned 
% in last. 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [loops,n,n1] = dd_mem(m,k)
global PRMEMORY;
if isempty(PRMEMORY)
  PRMEMORY = 10000;
end
n = min([floor(PRMEMORY/k),m]);
if n == 0
	error('PRMEMORY too small for given data size, decrease size or change prmem.m');
end
loops = ceil(m/n);   
n1 = m - (loops-1)*n; 
