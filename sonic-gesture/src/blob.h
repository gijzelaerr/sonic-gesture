
#ifndef _BLOB_H
#define	_BLOB_H

#include "cv.h"

using namespace cv;

class Blob {
public:
    Blob();
    Blob(const vector<Point>& contour);
    Blob(const vector<Point>& contour, int inflate_size);
    Point2f center;
    float radius;
    vector<Point> contour;
    
private:
    void init();
};


bool compare_blob_size(const Blob& a, const Blob& b);
bool compare_blob_xpos(const Blob& a, const Blob& b);

#endif

