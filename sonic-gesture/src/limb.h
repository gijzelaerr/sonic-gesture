
#ifndef _LIMB_H
#define	_LIMB_H

#include "common.h"

using namespace cv;
using namespace std;

struct Limb {
public:
    vector<Point> contour;
    float radius;
    Point2f center;
    HOGDescriptor hog;
    vector<float> hog_descriptors;
    Mat bw;
    bool data;
    
    Limb();
    Limb(vector<Point> c, const Mat& frame);
    void compute_hog();
    Mat get_limb_image();
private:
    Mat cutout;
};

class Limbs {
public:
    Limb head, left, right;
    Limbs(Limb head, Limb left, Limb right);
};

bool compare_limbs(const Limb& a, const Limb& b);
bool compare_limbs_xpos(const Limb& a, const Limb& b);
Limbs make_limbs(vector<vector<Point> > contours, Point face_center, Mat image);

#endif
