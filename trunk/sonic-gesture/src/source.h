
#ifndef _SOURCE_H
#define	_SOURCE_H


#include <string.h>
#include "cv.h"
#include "highgui.h"

using namespace cv;

class Source {
public:
    Source();
    Source(const int& device);
    Source(const string& movie);
    ~Source();
    Mat grab();
    Size size;

private:
    Mat frame;
    VideoCapture cap;
    void init();
};

#endif