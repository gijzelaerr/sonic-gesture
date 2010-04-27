
#include "bodypart.h"
#include "blob.h"
#include "settings.h"
#include "tools.h"

#include <iostream>
using std::cout;
using std::endl;

BodyPart::BodyPart() {    
    // hog stuff
    winStride = Size(8, 8);
    padding = Size(0, 0);
    hog = HOGDescriptor();

    // kalman stuff
    const int stateparms = 6; // x, y, vx, vy, w, h
    const int measureparms = 4; // x, y, w, h
    const float dt = 1.0; // time between frames, constant for movie
 
    float f[stateparms][stateparms] = {
        {1, 0, dt, 0, 0, 0},
        {0, 1, 0, dt, 0, 0},
        {0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0},
        {0, 0, 0, 0, 1, 0},
        {0, 0, 0, 0, 0, 1}
    };
    transition = Mat(stateparms, stateparms, CV_32FC1, f);
    

    kalman.init(stateparms, measureparms); 
    kalman.transitionMatrix = transition;
    
    // initialization, taken from example
    //setIdentity(kalman.measurementMatrix, Scalar(1.0));
    //setIdentity(kalman.processNoiseCov, Scalar(1e-5));
    //setIdentity(kalman.measurementNoiseCov, Scalar(1e-1));
    //setIdentity(kalman.errorCovPost, Scalar(1));
    //randu(kalman.statePost, Scalar(0), Scalar(0.1));
    
    //randu(kalman.statePre, Scalar(0), Scalar(0.1));
    //setIdentity(kalman.errorCovPre, Scalar(1));
    //setIdentity(kalman.gain, Scalar(1));
};


BodyPart::~BodyPart() {};


void BodyPart::update(const Blob& blob, const Mat& image) {
    this->blob = blob;
    this->update(image);
};

void BodyPart::update(const Mat& image) {
    this->image = image;
    kalman_correct();
    make_cutout();
    compute_hog();
};

void BodyPart::kalman_correct() {
    //const int stateparms = 6; // x, y, vx, vy, w, h
    const int measureparms = 4; // x, y, w, h    
    int x = blob.center.x;
    int y = blob.center.y;
    int w = blob.position.width;
    int h = blob.position.height;
    float m[1][measureparms] = {{x, y, w, h}};
    measurement = Mat(1, measureparms, CV_32FC1, m).t();
    kalman.correct(measurement);
    kalman_predict();
};

void BodyPart::kalman_predict() {    
    Mat y_k = kalman.predict();   
    Point predicted_center = Point(y_k.at<float>(0, 0), y_k.at<float>(0, 1));
    Size predicted_size = Size(y_k.at<float>(0, 4), y_k.at<float>(0, 5));
    cout << predicted_center.x << endl;
    cout << predicted_size.width << endl;
};
    
void BodyPart::make_cutout() {
    vector <vector<Point> > contours_tmp;
    mask = Mat(image.size(), CV_8U, Scalar(0));
    binary = Mat(image.size(), CV_8U, Scalar(0));
    contours_tmp.push_back(blob.contour);
    drawContours( mask, contours_tmp, -1, Scalar(255), CV_FILLED);
    image.copyTo(binary, mask);
    Rect cut = rect_in_mat(blob.position, binary); // make sure we cut inside binary
    cutout = binary(cut);
    cvtColor(cutout, hog_image, CV_BGR2GRAY);
};

void BodyPart::compute_hog() {
    resize(hog_image, sized, Size(64,128), 0, 0, INTER_NEAREST);
    //hog.compute(sized, hog_features, winStride, padding, locations);
    equalizeHist(sized, sized);
    hog.compute(sized, hog_features);
};


Size BodyPart::size() {
    return cutout.size();
};

void BodyParts::update(const vector<vector<Point> > contours, Point face_center, const Mat& image) {
    vector<Blob> blobs, tmp_blobs;
    this->image = image;
    Blob blob;
    int head_pos = -1;
    int left_pos = -1;
    int right_pos = -1;

    // first make blobs
    for (unsigned int i = 0; i < contours.size(); i++) {
        blobs.push_back(Blob(contours.at(i), INFLATE_SIZE));
    }    

    // sort the limbs on size
    sort(blobs.begin(), blobs.end(), compare_blob_size);

    // take only the 3 biggest blobs
    int s = MIN((int)blobs.size(), 3);
    for(int i=0; i < s; i++)
        tmp_blobs.push_back(blobs.at(i));
    blobs = tmp_blobs;

    // then sort the blobs for x pos, left to right
    sort(blobs.begin(), blobs.end(), compare_blob_xpos);
    
    for (unsigned int i = 0; i < blobs.size(); i++) {
        if (pointPolygonTest(Mat(blobs.at(i).contour), face_center, false) > 0) {
            head_pos = i;
            break;
        }
    }
    
    switch(blobs.size()) {
        case 3:
            switch (head_pos) {
                case 0:
                    left_pos = 1;
                    right_pos = 2;
                    break;
                case 1:
                    left_pos = 0;
                    right_pos = 2;
                    break;
                case 2:
                    left_pos = 0;
                    right_pos = 1;
                    break;
                default:
                    left_pos = 0;
                    head_pos = 1;
                    right_pos = 2;
                    break;
            }
            break;
        case 2:
            switch (head_pos) {
                case 0:
                    right_pos = 1;
                    break;
                case 1:
                    left_pos = 0;
                    break;
                default:
                    left_pos = 0;
                    right_pos = 1;
                    break;
            }
            break;
        case 1:
            head_pos = 0;
            break;
        default:
            head_pos = right_pos = left_pos = -1;
            break;
    }
    
    if (head_pos > -1)
        head.update(blobs.at(head_pos), image);
    else
        head.update(image);

    if (left_pos > -1)
        left_hand.update(blobs.at(left_pos), image);
    else
        left_hand.update(image);
    
    if (right_pos > -1)
        right_hand.update(blobs.at(right_pos), image);
    else
        right_hand.update(image);
};

Mat BodyParts::draw_in_image() {
    Mat visuals, mask;
    vector<vector<Point> > contours;
    
    contours.push_back(head.blob.contour);
    contours.push_back(left_hand.blob.contour);
    contours.push_back(right_hand.blob.contour);

    mask = Mat(image.size(), CV_8U, Scalar(0));
    drawContours( mask, contours, -1, Scalar(255), CV_FILLED);
    
    this->image.copyTo(visuals);
    convertScaleAbs(visuals, visuals, 0.2);
    this->image.copyTo(visuals, mask);
    
    if (head.blob.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(head.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 0, 0, 255 ));
    }
    
    if (left_hand.blob.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(left_hand.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 0, 255, 0 ));
    }
    
    if (right_hand.blob.contour.size() > 0) {
        vector<vector<Point> > cs;
        cs.push_back(right_hand.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 255, 0, 0 ));
    }
    return visuals;
};