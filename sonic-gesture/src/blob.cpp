

#include "blob.h"
#include "tools.h"

Blob::Blob() {};

Blob::Blob(const vector<Point>& contour) {
    this->contour = contour;
}

Blob::Blob(const vector<Point>& contour, double inflate_size) {
    this->contour = inflate_contour(this->contour, inflate_size);
};

void Blob::init() {
    minEnclosingCircle(Mat(contour), center, radius);
}


bool compare_blob_size(const Blob& a, const Blob& b) {
    return a.radius > b.radius;
}


bool compare_blob_xpos(const Blob& a, const Blob& b) {
    return a.center.x < b.center.x;
}
