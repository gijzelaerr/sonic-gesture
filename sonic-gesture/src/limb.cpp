
#include "common.h"
#include "limb.h"
#include "tools.h"


Limb::Limb() {
    center_big = center_small = Point();
    radius_big = radius_small = 0;
    data = false;
};

// scale is ratio between big and small
// We keep both
// frame is original image
Limb::Limb(vector<Point> contour_small, float scale, const Mat& frame) {
    Mat binary;
    Limb::contour_small = contour_small;
    contour_big = scale_contour(contour_small, float(1.0/scale));
    contour_big = inflate_contour(contour_big, INFLATE_SIZE);
    
    Limb::frame = frame;
    data = true;
    minEnclosingCircle(Mat(contour_small), center_small, radius_small);
    minEnclosingCircle(Mat(contour_big), center_big, radius_big);
    
    Mat mask = Mat(frame.size(), CV_8U, Scalar(0));
    binary.zeros(frame.size(), CV_8U);
   
    vector<vector<Point> > contours_big;
    contours_big.push_back(contour_big);
    drawContours( mask, contours_big, -1, Scalar(255), CV_FILLED);
    

    frame.copyTo(binary, mask);

    Rect cutout_border = boundingRect(Mat(contour_big));
    
    // make sure the cutout_border is inside the borders of image
    int x = max(0, cutout_border.x);
    int y = max(0, cutout_border.y);
    int width, height;
    if (cutout_border.width+cutout_border.x > binary.cols) {
        width = binary.cols - x;
    } else {
        width = cutout_border.width;
    }
    if (cutout_border.height + cutout_border.y > binary.rows) {
        height = binary.rows - y;
    } else {
        height = cutout_border.height;
    }
    cutout_border = Rect(x, y, width, height);
    
    cutout = binary(cutout_border); 
  
    Mat sized;
    resize(cutout, sized, Size(64,128));
    cvtColor(sized, bw, CV_BGR2GRAY);
    equalizeHist(bw, bw);

    compute_hog();
};


// compute hog of sub
void Limb::compute_hog() {
    
    vector<Point> locations;
    Size winStride = Size(8, 8);
    Size padding = Size(0, 0);
    hog = HOGDescriptor();
    hog.compute(bw, hog_descriptors, winStride, padding, locations);
};


Mat Limb::get_limb_image() {
    assert(bw.data);
    return bw;
}


bool compare_limbs(const Limb& a, const Limb& b) {
    return a.radius_small > b.radius_small;
}


bool compare_limbs_xpos(const Limb& a, const Limb& b) {
    return a.center_small.x < b.center_small.x;
}