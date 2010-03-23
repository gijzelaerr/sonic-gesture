
//#include <iostream>

#include "limb.h"

using namespace cv;
using namespace std;

Limb::Limb() {
    center = Point();
    radius = 0;
    data = false;
};

Limb::Limb(vector<Point> contours, Mat frame) {
    Limb::contour = contours;
    Limb::frame = frame;
    data = true;
    minEnclosingCircle(contour, center, radius);
    sub = frame(boundingRect(contour));
    compute_hog();
};


void Limb::compute_hog() {
    Mat sized;
    resize(sub, sized, Size(64,128));
    cvtColor(sized, bw, CV_BGR2GRAY);
    equalizeHist(bw, bw);
    vector<Point> locations;
    Size winStride = Size(8, 8);
    Size padding = Size(0, 0);
    hog = HOGDescriptor();
    hog.compute(bw, hog_descriptors, winStride, padding, locations);
};

Mat Limb::get_image() {
    assert(sub.data);
    return sub;
}

bool compare_limbs(const Limb& a, const Limb& b) {
    return a.radius > b.radius;
}


bool compare_limbs_xpos(const Limb& a, const Limb& b) {
    return a.center.x < b.center.x;
}