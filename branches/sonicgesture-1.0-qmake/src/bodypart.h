

#ifndef _BODYPARTS_H
#define	_BODYPARTS_H

#include "opencv/cv.h"
#include "opencv/cvaux.h"
#include "common.h"
#include "blob.h"
#include "settings.h"

enum State {NOT_VISIBLE, FOUND_COLOR, FOUND_TEMPLATE};

using namespace cv;

class BodyPart {
public:
    BodyPart();
    ~BodyPart();
    void update(const Blob& blob, const Mat& image);
    void update(const Mat& image);
    Size size();
    Blob blob;
    vector<float> sized_hog_features, hog_features;
    Mat sized_hog_image, hog_image;
    Rect position, prediction;
    Mat locate_result, last_good_cutout;
    State state;


private:
    Mat image, mask, binary, cutout;
    int inflate_size;
   
    //hog stuff
    HOGDescriptor hog;
    vector<Point> locations;    
    Size winStride;
    Size padding;
    
    //kaman stuff
    KalmanFilter kalman;

    void make_cutout();
    void compute_hog();
    void kalman_correct(Rect measurement);
    void kalman_predict();
    void locate();
};



class BodyParts {
public:
    BodyParts();
    ~BodyParts();
    void update(contours contours_, Point face_center, const Mat& image);
    Mat draw_in_image();
    BodyPart head;
    BodyPart left_hand;
    BodyPart right_hand;
private:
    Settings* settings;
    Mat image;
    Point face_center;
};

#endif
