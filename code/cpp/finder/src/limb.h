
#ifndef _LIMB_H
#define	_LIMB_H

#include "cv.h"
#include "cvaux.h"

using namespace cv;
using namespace std;

struct Limb {
public:
    vector<Point> contour_big, contour_small;
    float radius_big, radius_small;
    Point2f center_big, center_small;
    HOGDescriptor hog;
    vector<float> hog_descriptors;
    Mat bw;
    bool data;
    
    Limb();
    Limb(vector<Point> c, float scale, Mat frame);
    void compute_hog();
    Mat get_limb_image();
private:
    Mat cutout, frame;
};

bool compare_limbs(const Limb& a, const Limb& b);
bool compare_limbs_xpos(const Limb& a, const Limb& b);

#endif
