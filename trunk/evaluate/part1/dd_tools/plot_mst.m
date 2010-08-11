function plot_mst(a,tree,c,lwidth)
%PLOT_MST Plot minimum spanning tree
%
%    PLOT_MST(A,TREE,STR,LWIDTH)
% 
% Plots the edges of a minimum spanning tree, defined by the nodes A and
% TREE
% 
% INPUT
%      A        dataset
%      TREE     list of edges
%      STR      color e.g. 'k','m' or [0.9 0.1 0.7]
%      LWIDTH   linewidth
%
% See also: mst_dd, datasets, mappings

%  Copyright: Piotr Juszczak, p.juszczak@tudelft.nl
%  Information and Communication Theory Group,
%  Faculty of Electrical Engineering, Mathematics and Computer Science,         
%  Delft University of Technology,            
%  The Netherlands

if (nargin<2), error('At least 2 inputs expected');end
if (nargin==2),lwidth=1;c='k';end
[m,k] = size(a);
mt = size(tree);
if ((m-1)~=mt), error('The size of dataset does not much number of edges.'); end

i=0;
if ~ishold, hold on; i=1; end

for k=1:size(tree,1)
    plot([+a(tree(k,1),1),+a(tree(k,2),1)],[+a(tree(k,1),2),+a(tree(k,2),2)],...
        'linestyle','-','linewidth',lwidth,'color',c);
end

if i==1, hold off; end

return;
