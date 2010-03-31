
#ifndef _HAND_H
#define	_HAND_H

#include "common.h"

using namespace cv;


struct Hand {
public:
    Mat img, hsv, backproj, cutout;
    HOGDescriptor hog;
    vector<float> descriptors;
    Hand(const string& filename, MatND histogram);
    void load_image(const string& filename);
    void make_hsv();
    void make_backproject(MatND histogram);
    void make_cutout();
	void find_hog();
};

#endif
