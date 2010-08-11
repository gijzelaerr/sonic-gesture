%LESS-MC: MultiClass LESS-Classifier
%
%   W = LESSMC(A,C,VARS,ESTIMATE,COMBINER,COMBINERSTYLE)
%
% INPUT
%   A         Dataset
%   C         Regularization parameter, C>=0
%             default: C=1
%   VARS      Boolean variable indicating whether or not the class variance
%             should be included in data mapping
%             default: VARS=0
%   ESTIMATE  Prototype estimate: 'median' or 'mean'
%             default: ESTIMATE='mean'
%   COMBINER  Integrated class combiner:
%               'single': one vs all (#classes subclassifiers)
%               'multi':  one vs one (#classes*#classes/2 subclassifiers)
%             default: COMBINER='single'
%   COMBINERSTYLE
%             Style for integrating the 2-class problems (see COMBINER):
%               'rigid': same sub-space for each 2-class combiner
%                        (1 subspace)
%               'flex':  optimized sub-space for each 2-class combiner
%                        (#subclassifiers subspaces)
%               'indep': fully indepent 2-class problems through 'mclassc'
%                        (#subclassifiers subspaces)
%             default: COMBINERSTYLE='rigid'
%
% OUTPUT
%   W       LESS classifier 

% REFERENCES
% 1. Veenman, C.J., Tax, D.M.J., A Weighted Nearest Mean Classifier for Sparse Subspaces.
%    Proceedings of the IEEE Computer Society Conference on Computer Vision and Pattern
%    Recognition, San Diego, USA, June 20-25, 2005.
%
% 2. Veenman, C.J., Tax, D.M.J., LESS: a Model-Based Classifier for Sparse Subspaces.
%    IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 27, no. 9,
%    pp. 1496-1500, September 2005.

%
%  SEE ALSO
%  MAPPINGS, DATASETS, NMC, NMSC, SVC

% Copyright: Cor J. Veenman, C.J.Veenman@uva.nl
% Computer Science Institute
% Faculty of Science, University of Amsterdam
% Amsterdam, The Netherlands

function w=lessmcMR(a,C,vars,estimate,combiner,combinerStyle)

if nargin<6|isempty(combinerStyle)
    combinerStyle='flex';
end

if nargin<5|isempty(combiner)
    combiner='single';
end

if nargin<4|isempty(estimate)
    estimate='mean';
end

if nargin<3|isempty(vars)
    vars=0;
end

if nargin<2|isempty(C)
    C=1;
end

if nargin<1
    a=[];
end

w=lessmc(a,C,vars,estimate,combiner,combinerStyle);
