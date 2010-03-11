
//#include <iostream>

#include "limb.h"

using namespace cv;
using namespace std;

Limb::Limb() {
    center = Point();
    radius = 0;
};

Limb::Limb(vector<Point> c) {
    contour = c;
    minEnclosingCircle(contour, center, radius);
    hog = HOGDescriptor();
    vector<Point> locations;
    Size winStride = Size(8, 8);
    Size padding = Size(0, 0);
};

void Limb::compute_hog(Mat image) {
    Mat sized;
    sub = image(boundingRect(contour));
    resize(sub, sized, Size(64,128));
    cvtColor(sized, bw, CV_BGR2GRAY);
    equalizeHist(bw, bw);
    HOGDescriptor hog = HOGDescriptor();
    vector<Point> locations;
    Size winStride = Size(8, 8);
    Size padding = Size(0, 0);
    hog.compute(bw, hog_descriptors, winStride, padding, locations);
};


bool compare_limbs(const Limb& a, const Limb& b) {
    return a.radius > b.radius;
}


bool compare_limbs_xpos(const Limb& a, const Limb& b) {
    return a.center.x < b.center.x;
}