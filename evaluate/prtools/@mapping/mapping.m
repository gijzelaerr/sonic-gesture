%MAPPING Mapping class constructor
%
%	W = MAPPING(MAPPING_FILE, MAPPING_TYPE, DATA, LABELS, SIZE_IN, SIZE_OUT)
%
% A map/classifier object is constructed. It may be used to map a dataset A
% on another dataset B by B = mapd(A,W) or by training a mapping using an
% untrained mapping W and a dataset A: V = mapd(A,W) or by modifying,
% (or combining) a mapping W with another mapping V: Wnew = mapd(V,W);
% These operations may also be written as B = A*W, V = A*W or Wnew = V*W.
%
% Note that mappings are usually not defined by PRTools users, but just by
% PRTools programmers that like to add new tools for training or data
% manupulation. See FISHERC or LDC for simple examples of a MAPPING construct.
%
% MAPPING_FILE       name of the routine used for learning or executing the
%                    mapping. This routine (e.g. 'mapfile') should accept and
%                    execute the following types of calls, depending on the
%                    value of MAPPING_TYPE:
%
%    MAPPING_TYPE = 'untrained': V = mapfile(A,W) 
%                    for training the untrained mapping W by a dataset A,
%                    resulting in a trained mapping V. This may be called as 
%                    V = A*W.
%    MAPPING_TYPE = 'trained':   D = mapfile(B,W)
%                    for mapping a dataset B by the mapping W resulting in a
%                    dataset D. This may be called as D = B*W. W is the result
%                    of training an untrained mapping V by a dataset A: 
%                    W = A*V. Consequently D = B*(A*V).
%    MAPPING_TYPE = 'combiner: V2 = mapfile(V1,W), such that 
%                    D = B*V2 is consistent with D = B*V1*W and thereby 
%                    also with D = mapfile(B*V1,W).
%    MAPPING_TYPE = 'fixed': D = mapfile(A,W) or D = A*W.
%                    In practice there is not much difference between a
%                    trained and a fixed mapping. The first is found from
%                    data, the latter is defined directly by its parameters.
%                   
% MAPPING_TYPE       string defining the type of mapping:
%                   'untrained', 'trained', "combiner' or 'fixed', see above.
%                    Default is 'untrained'. MAPPING(MAPPING_FILE,DATA) is
%                    equivalent to MAPPING(MAPPING_FILE,'untrained',DATA)
%
% DATA               Data, structure or cell array necessary for defining the
%                    mapping, e.g. the weights of a neural network. DATA is
%                    just used in the MAPPING_FILE for executing the mapping.
%                    For fixed and untrained mappings DATA can only be a
%                    cell array.
% LABELS             Array with labels to be used as feature labels for the
%                    dataset resulting by executing the mapping. So at least
%                    as many labels as defined by SIZE_OUT has to be supplied.
% SIZE_IN            Input dimensionality or size vector describing its shape,
%                    e.g. in case the input space is derived from an image.
%                    For a classifier SIZE_IN is the feature size.
% SIZE_OUT           Output dimensionality or size vector describing its
%                    shape, e.g. in case the output space should represent an
%                    image. For a classifier SIZE_OUT is the number of
%                    classes. Default is the number of labels in LABELS.
%                    SIZE_IN and SIZE_OUT are just used for error checking.
%                    If SIZE_IN is not supplied they are both set to 0 and 
%                    checking is skipped.
%
% Other parameter fields may be set to define the mapping further by
%
%	W = MAPPING(MAPPING_FILE, MAPPING_TYPE, DATA, LABELS, ...
%                                             'field1',V1,'field2',V2, ...)
% or by
%
%	W = MAPPING(MAPPING_FILE, MAPPING_TYPE, DATA, LABELS, SIZE_IN, ...
%                                      SIZE_OUT,'field1',V1,'field2',V2, ...)
%
% The following fields are possible (if not set defaults are supplied):
%
% SCALE               Output multiplication factor. If SCALE is a scalar all
%                     multiplied by it. SCALE may also be a vector with size
%                     as defined by SIZE_OUT to set separate scalings for each
%                     output.
% OUT_CONV            0,1,2,3 for defining the desired output conversion:
%                     0 - no(default), 1: SIGM, 2: NORMM or 3: SIGM and NORMM.
%                     These values are set by cnormc in case of 2-class
%                     discriminants (OUTCONV = 1) and by CLASSC
%                     (OUT_CONV = OUT_CONV+2) to convert densities and
%                     sigmoidal outputs to normalised posterior probabilities.
% COST                Classification costs in case the mapping defines a
%                     classifier. See SETCOST.
% NAME                String with mapping name
% USER                User definable variable
%
% All parameters are stored in fields corresponding to the above names.
% Parameter fields of a given mapping may also be changed by:
%
%	W = SET(W,'field1',V1,'field2',V2, ...)
%
% They may also be set by the routines SETMAPPING_FILE, SETMAPPING_TYPE, 
% SETDATA, SETLABELS, SETSIZE_IN, SETSIZE_OUT, SETSIZE, SETSCALE, SETOUT_CONV,
% SETCOST, SETNAME and SETUSER. Fields may be retrieved by
%
%	VARARGOUT = GET(W,'field1','field2', ...)
%
% or by the routines GETMAPPING_FILE, GETMAPPING_TYPE, GETDATA, GETSIZE_IN,
% GETSIZE_OUT, GETSCALE, GETOUTCONV, GETCOST, GETNAME and GETUSER. 
%
% See also DATASETS, MAPPINGS
