
#ifndef _HISTOGRAM_H
#define	_HISTOGRAM_H

#include "cv.h"

using namespace cv;

class Histogram {
private:
    MatND histogram;
    MatND new_hist;
    MatND old_hist;
    bool first;

public:
    Histogram();
    ~Histogram();
    void update(Mat image);
    Mat backproject(Mat image);
    
};

#endif
