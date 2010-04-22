

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
    //minEnclosingCircle(m, center, radius);
    //RotatedRect s = minAreaRect(m);
    position = boundingRect(m);
    area = position.area();
    center = Point(position.x + (position.width/2), position.y + (position.height/2));
}


bool compare_blob_size(const Blob& a, const Blob& b) {
    return a.area > b.area;
}


bool compare_blob_xpos(const Blob& a, const Blob& b) {
    return a.center.x < b.center.x;
}
