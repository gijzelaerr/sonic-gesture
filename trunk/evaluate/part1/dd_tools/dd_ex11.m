% DD_EX11
%
% Example of the training of a multi-class classifiers, constructed from
% class-wise one-class classifiers. As a comparison, also the individual
% one-class classifiers are explicitly constructed.

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Generate the two-class data:
a = gendatb;
a = setlablist(a,{'apple' 'banana'});
% and a new/unseen class
b = gauss(30,[6,-10]);
b = setlablist(b,'pear')

% Create an OCC per class:
w1 = gauss_dd(target_class(a,1),0.1);
w2 = gauss_dd(target_class(a,2),0.1);
w3 = gauss_dd(target_class(b,1),0.1);
% Create the multiclass on the first two classes
w = multic(a,{gauss_dd([],0.1)});

% the results:
confmat(getlab(a),a*w*labeld)

% show the results:
figure(1); clf; scatterd([a;b],'legend');
plotc(w1,'b'); plotc(w2,'r');
plotc(w,'k--');

% Now update the multic by including dataset b in training:
wplus = multic(b,w,gauss_dd);
plotc(wplus,'m:',2);

% the results:
confmat(getlab([a; b]),[a; b]*wplus*labeld)

