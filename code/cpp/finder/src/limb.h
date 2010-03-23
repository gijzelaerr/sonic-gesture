
#ifndef _LIMB_H
#define	_LIMB_H

#include "cv.h"
#include "cvaux.h"

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
    Limb(vector<Point> c, Mat frame);
    void compute_hog();
    Mat get_image();
private:
    Mat sub, frame;
};

bool compare_limbs(const Limb& a, const Limb& b);
bool compare_limbs_xpos(const Limb& a, const Limb& b);

#endif