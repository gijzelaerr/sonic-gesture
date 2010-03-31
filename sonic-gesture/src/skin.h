
#ifndef _SKIN_H
#define	_SKIN_H

#include "common.h"

using namespace cv;

struct Skin {
public:
    Mat img, hsv, bw, facepixels;
    MatND histogram;
    vector<Rect> faces;
    CascadeClassifier haarzoeker;
    Rect face_rect, sub_rect;
    Skin(const string& facefile, const string& haarfile);
    void load_image(const string& filename);
    void load_haar(const string& filename);
    void find_face();
    void make_histogram();
    Rect face_region(Rect face);
};

#endif
