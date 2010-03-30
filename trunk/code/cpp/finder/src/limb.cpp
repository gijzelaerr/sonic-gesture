
#include "limb.h"
#include "tools.h"

using namespace cv;
using namespace std;


Limb::Limb() {
    center_big = center_small = Point();
    radius_big = radius_small = 0;
    data = false;
};

// scale is ratio between big and small
// We keep both
Limb::Limb(vector<Point> contours, float scale, Mat frame) {
    Limb::contour_small = contours;
    Limb::contour_big = scale_contour(contours, 1.0/scale);
    Limb::frame = frame;
    data = true;
    minEnclosingCircle(contour_small, center_small, radius_small);
    minEnclosingCircle(contour_big, center_big, radius_big);
    cutout = frame(boundingRect(contour_big));
    compute_hog();
};


// compute hog of sub
void Limb::compute_hog() {
    Mat sized;
    resize(cutout, sized, Size(64,128));
    cvtColor(sized, bw, CV_BGR2GRAY);
    equalizeHist(bw, bw);
    vector<Point> locations;
    Size winStride = Size(8, 8);
    Size padding = Size(0, 0);
    hog = HOGDescriptor();
    hog.compute(bw, hog_descriptors, winStride, padding, locations);
};


Mat Limb::get_limb_image() {
    assert(cutout.data);
    return cutout;
}


bool compare_limbs(const Limb& a, const Limb& b) {
    return a.radius_small > b.radius_small;
}


bool compare_limbs_xpos(const Limb& a, const Limb& b) {
    return a.center_small.x < b.center_small.x;
}