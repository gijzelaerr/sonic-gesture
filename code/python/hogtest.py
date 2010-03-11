

import cv

capture = cv.CaptureFromCAM(-1)
m = cv.CreateMemStorage()

while True:
    frame = cv.QueryFrame(capture)
    cv.ShowImage('', frame )
    hog = cv.HOGDetectMultiScale(frame, m)
    # HOGDetectMultiScale(image, storage [, svm_classifier [, win_stride
    # [, hit_threshold [, scale [, group_threshold [, padding [, win_size
    # [, block_size [, block_stride [, cell_size [, nbins [,
    # gammaCorrection]]]]]]]]]]]]) -> CvSeq*
    print hog
    print len(hog)
    print dir(hog)
    print hog.h_next()
    print hog.h_prev()
    print hog.v_next()
    print hog.v_prev()
    cv.WaitKey(2)

