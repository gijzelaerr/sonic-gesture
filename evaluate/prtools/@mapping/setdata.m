%SETDATA Set data field in mapping
%
% 	W = SETDATA(W,DATA,FIELD)
% 	W = SETDATA(W,DATA,N)
%
% INPUT
%   W     Mapping
%   DATA  Data to be put in data field.
%   FIELD String, name of natafield to be used for DATA
%   N     Index of cell array to be used for DATA
%
% OUTPUT
%   W     Mapping
%
% DESCRIPTION
% The datafield of a mapping consists of a matrix, cell array or a structure. 
% In case FIELD nor N are given the entire datafield is replaced by DATA.
% In case the datafield is a structure DATA is assigned to field FIELD.
% In case the datafield is a cell array, DATA is assigned to cell N.
% DATA cannot be a structure in case of untrained or fixed mappings.
