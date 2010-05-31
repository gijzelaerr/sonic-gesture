
#ifndef _SKINFINDER_H
#define	_SKINFINDER_H

#include "histogram.h"
#include <QtCore/QString>
#include <QtCore/QDir>

using namespace cv;
using namespace std;

class SkinFinder {
public:
    SkinFinder();
    ~SkinFinder();
    SkinFinder(const QFileInfo& haarfile, int probToBinThresh); // probToBinThresh=30
    vector<vector<Point> > compute(const Mat& frame);
    vector<vector<Point> > contours;

    // required to know which con
    Point face_center;

    // images used in the steps. public so can be used for visualization
    Mat frame, hsv, bw, facepixels, backproj, mask, blur, thresh;

private:
    Mat kernel;
    Histogram histogram;
    CascadeClassifier haar;
    vector<Rect> faces;
    Rect face;
    int frame_counter;
    int probToBinThresh;
    void prepare();
    void find_face();
    void make_histogram();
    void make_backproject();
    void make_mask();
    void find_contours();
    void find_limbs();
    void step();
};


#endif

