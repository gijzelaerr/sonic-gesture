function [c,acc] = svmOutput2Confmat(svmo, truth)

    maxSvmo = repmat(max(svmo,[],2),1,size(svmo,2));
    [c, acc] = binlab2confmat(maxSvmo==svmo, truth, 1);

end