

#include "blob.h"
#include "tools.h"

#include "highgui.h"

Blob::Blob() {};

Blob::Blob(const vector<Point>& contour) {
    assert(contour.size() > 0);
    this->contour = contour;
    init();
}

Blob::Blob(const vector<Point>& contour, double inflate_size) {
    assert(contour.size() > 0);
    this->contour = contour;
    this->contour = inflate_contour(this->contour, inflate_size);
    init();
};

void Blob::init() {
    Mat m = Mat(contour);
    position = boundingRect(m);
    center = Point(position.x + (position.width/2), position.y + (position.height/2));
}

// returns a binary mask for contour, mask size is of image size
Mat Blob::mask(const Mat& image) {
    vector <vector<Point> > contours_tmp;
    Mat maskmat = Mat(image.size(), CV_8U, Scalar(0));
    if (contour.size() > 0) {
        contours_tmp.push_back(contour);
        drawContours( maskmat, contours_tmp, -1, Scalar(255), CV_FILLED);
    };
    return maskmat;
}


bool compare_blob_size(const Blob& a, const Blob& b) {
    return a.area > b.area;
}


bool compare_blob_xpos(const Blob& a, const Blob& b) {
    return a.center.x < b.center.x;
}
