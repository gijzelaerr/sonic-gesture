%GETDATA Get data of dataset
%
%    [DATA,NLAB,IDENT] = GETDATA(A,CLASSES)
%
% Returns the data as stored in A.DATA. If the index vector CLASSES is
% given just the data of the objects (rows of A.DATA) that belong to the
% corresponding classes are returned. CLASSES are the class numbers of the
% classes defined in the current LABLIST. 
%
% By default all data is returned. In NLAB the class numbers of the
% selected objects are given, these are the indices to the label 
% list that can be retrieved by LABLIST = GETLABLIST(A).
%
% IDENT returns the vector or cell array with the corresponding object
% identifiers.
