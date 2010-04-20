

#include "blob.h"
#include "tools.h"

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
    minEnclosingCircle(Mat(contour), center, radius);
}


bool compare_blob_size(const Blob& a, const Blob& b) {
    return a.radius > b.radius;
}


bool compare_blob_xpos(const Blob& a, const Blob& b) {
    return a.center.x < b.center.x;
}
