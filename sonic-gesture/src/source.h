
#ifndef _SOURCE_H
#define	_SOURCE_H

#include "cv.h"
#include "highgui.h"

//#include "Qt/QtCore"
#include <QtCore>

using namespace cv;

class Source {
public:
    Source();
    Source(int device);
    Source(const string& file);
    Source(const QString &file);
    ~Source();
    Mat& grab();
    Size size;

private:
    bool mirror, image;
    Mat frame;
    VideoCapture cap;
    void init();
    void loadCam(int device);
    void loadMovie(const QString& file);
    void loadImage(const QString& file);
};

#endif