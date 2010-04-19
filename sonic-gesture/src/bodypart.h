

#ifndef _BODYPARTS_H
#define	_BODYPARTS_H

#include "cv.h"
#include "cvaux.h"
#include "blob.h"


using namespace cv;

class BodyPart {
public:
    BodyPart();
    ~BodyPart();
    void update(Blob blob, const Mat& image);
    void update(const Mat& image);
    const Mat get_hog_image();
    
    
private:
    Blob blob;
    Mat image, hog_image, mask, binary, sized, cutout;
    int inflate_size;
    vector<float> hog_features;
    void make_cutout();
    void compute_hog();
    
    //hog stuff
    HOGDescriptor hog;
    vector<Point> locations;    
    Size winStride;
    Size padding;
};



class BodyParts {
public:
    BodyParts();
    ~BodyParts();
    void update(const vector<vector<Point> >& contours, Point face_center, const Mat& image);
private:
    BodyPart head, left_hand, right_hand;
};

#endif
