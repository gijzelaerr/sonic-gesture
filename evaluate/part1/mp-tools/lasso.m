% LASSO
%
% function w=lasso(x,y,C)
%
% input variables:
%
%   x:  dataset in double format; a row per object
%   y:  response variables; -1/+1 in 2-class classifiaction case
%
% output variables
%
%   w:  weight vector
%

%
% Ported to Matlab by Cor J. Veenman. Original C-code by Berwin A Turlach
% after the following publication:
%
% Osborne, M.R., Presnell, B. and Turlach, B.A., On the LASSO and its dual, 
% Journal of Computational and Graphical Statistics, 9(2): 319-337, 2000.
%
% Copyright: Cor J. Veenman, C.J.Veenman@uva.nl
% Computer Science Institute 
% Faculty of Science, University of Amsterdam
% Amsterdam, The Netherlands
%
