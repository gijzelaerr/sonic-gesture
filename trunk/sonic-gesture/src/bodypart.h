

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
    Size size();
    Blob blob;
    vector<float> hog_features;
    Mat hog_image;
    
private:
    Mat image, mask, binary, sized, cutout;
    int inflate_size;
    vector<vector<Point> > contours_tmp;
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
    void update(const vector<vector<Point> > contours, Point face_center, const Mat& image);
    Mat draw_in_image();
    BodyPart head;
    BodyPart left_hand;
    BodyPart right_hand;
private:

    Mat image;
};

#endif
