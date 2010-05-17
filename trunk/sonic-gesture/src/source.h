
#ifndef _SOURCE_H
#define	_SOURCE_H

#include "cv.h"
#include "highgui.h"

using namespace cv;

class Source {
public:
    Source();
    Source(int device);
    Source(const string& movie);
    ~Source();
    Mat& grab();
    Size size;

private:
    bool mirror;
    Mat frame;
    VideoCapture cap;
    void init();
};

#endif