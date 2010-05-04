

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
    void update(const Blob& blob, const Mat& image);
    void update(const Mat& image);
    Size size();
    Blob blob;
    vector<float> hog_features;
    Mat hog_image, sized;
    Point pred_center;
    Size pred_size;



private:
    Mat image, mask, binary, cutout;
    int inflate_size;
    void make_cutout();
    void compute_hog();
    void kalman_correct();
    void kalman_predict();
    
    //hog stuff
    HOGDescriptor hog;
    vector<Point> locations;    
    Size winStride;
    Size padding;
    
    //kaman stuff
    KalmanFilter* kalman;
    Mat state, measurement, transition;
};



class BodyParts {
public:
    void update(const vector<vector<Point> > contours, Point face_center, const Mat& image);
    Mat draw_in_image();
    BodyPart head;
    BodyPart left_hand;
    BodyPart right_hand;
private:
    Mat image;
};

#endif
