
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

    int hbins;
    int sbins;
    float* hranges;
    float* sranges;
    const float** ranges;
    int* histSize;
    int* channels;


public:
    Histogram();
    ~Histogram();
    void update(const Mat& image);
    Mat backproject(const Mat& image);
    
};

#endif
