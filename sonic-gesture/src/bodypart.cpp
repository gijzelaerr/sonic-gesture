
#include "bodypart.h"
#include "blob.h"
#include "common.h"
#include "tools.h"

#include <iostream>
using namespace std;


const int stateparms = 6;
const int measureparms = 4;

BodyPart::BodyPart() {
    state = NOT_VISIBLE;
    
    // hog stuff
    winStride = Size(8, 8);
    padding = Size(0, 0);
    hog = HOGDescriptor();

    kalman = new KalmanFilter();
    // kalman stuff

    float f[stateparms][stateparms] = {
        {1, 0, 0, 0, 0.1, 0},
        {0, 1, 0, 0, 0, 0.1},
        {0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0},
        {0, 0, 0, 0, 1, 0},
        {0, 0, 0, 0, 0, 1},
    };

    kalman->init(stateparms, measureparms);
    Mat transmat = Mat(stateparms, stateparms, CV_32FC1, f);
    transmat.copyTo(kalman->transitionMatrix);
    setIdentity(kalman->measurementMatrix, Scalar(1));
    setIdentity(kalman->processNoiseCov, Scalar(1));
    setIdentity(kalman->measurementNoiseCov, Scalar(5));
    setIdentity(kalman->errorCovPost, Scalar(3));
    setIdentity(kalman->gain, Scalar(0e-15));
    randu(kalman->statePost, Scalar(1), Scalar(100));
};


BodyPart::~BodyPart() {
    delete kalman;
};


void BodyPart::update(const Blob& blob, const Mat& image) {
    state = FOUND_COLOR;
    this->image = image;
    this->blob = blob;
    this->position = blob.position;
    kalman_predict();
    make_cutout();
    compute_hog();
    kalman_correct(position);
    last_good_cutout = cutout;
};

void BodyPart::update(const Mat& image) {
    // we can't do anything if we don't have some previous knowledge
    if (state == NOT_VISIBLE)
        return;

    state = FOUND_TEMPLATE;
    this->image = image;
    kalman_predict();
    make_cutout();
    compute_hog();
    locate();
    kalman_correct(position);
};


void BodyPart::kalman_predict() {
    kalman->predict();
    int x = kalman->statePre.at<float>(0, 0);
    int y = kalman->statePre.at<float>(0, 1);
    int w = kalman->statePre.at<float>(0, 2);
    int h = kalman->statePre.at<float>(0, 3);
    prediction = Rect(x, y, w, h);
    prediction = rect_in_mat(prediction, image);
};

void BodyPart::kalman_correct(Rect measurement) {
    float m[1][measureparms] = {{measurement.x, measurement.y,
            measurement.width, measurement.height}};
    Mat measurementMatrix = Mat(1, measureparms, CV_32FC1, m).t();
    kalman->correct(measurementMatrix);
};

void BodyPart::make_cutout() {
    mask = blob.mask(image);
    binary = Mat(image.size(), image.type(), Scalar(0));
    image.copyTo(binary, mask);
    Rect cut = rect_in_mat(blob.position, binary);
    cutout = binary(cut);
    cvtColor(cutout, hog_image, CV_BGR2GRAY);
};

void BodyPart::compute_hog() {
    resize(hog_image, sized_hog_image, Size(64,128), 0, 0, INTER_NEAREST);
    equalizeHist(sized_hog_image, sized_hog_image);
    equalizeHist(hog_image, hog_image);
    hog.compute(sized_hog_image, sized_hog_features);

    //HOGDescriptor h = HOGDescriptor()
    //hog.compute(hog_image, hog_features, hog_image.size(), Size());

};

void BodyPart::locate() {
    Rect search_rect = Rect(prediction.x - prediction.width/20,
                            prediction.y - prediction.height/20,
                            prediction.width + prediction.width/10,
                            prediction.height + prediction.height/10);

    search_rect = rect_in_mat(search_rect, image);
    Mat search = image(search_rect);

    // if going to search outside of image
    if (last_good_cutout.cols > search.cols || last_good_cutout.rows > search.rows ) {
        state = NOT_VISIBLE;
        return;
    };

    matchTemplate(search, last_good_cutout, locate_result, CV_TM_SQDIFF_NORMED);
    double min;
    double max;
    Point minloc;
    Point maxloc;
    minMaxLoc(locate_result, &min, &max, &minloc, &maxloc);
    Rect new_pos = Rect(minloc.x + search_rect.x,
                        minloc.y + search_rect.y,
                        prediction.width, prediction.height);

    if (min > 0.7) {
        state = NOT_VISIBLE;
        return;
    }
    
    this->position = new_pos;
    //cout << fixed << min << endl;
};


Size BodyPart::size() {
    return cutout.size();
};

BodyParts::BodyParts() {
    settings = Settings::getInstance();
}

BodyParts::~BodyParts() {
}

void BodyParts::update(contours contours_, Point face_center, const Mat& image) {
    vector<Blob> blobs, tmp_blobs;
    this->image = image;
    this->face_center = face_center;
    Blob blob;
    int head_pos = -1;
    int left_pos = -1;
    int right_pos = -1;

    // first make blobs
    for (unsigned int i = 0; i < contours_.size(); i++) {
        contour contour_ = contours_.at(i);
        if (contour_.size() > 0) {
            assert(contour_.size() > 0);
            blob = Blob(contour_, settings->limbInflationRatio);
            // A filter to remove noice, (small objects)

            if (blob.area > settings->minBlobSize) {
                blobs.push_back(blob);
            }
        }
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

    if (head.state == FOUND_COLOR)
        contours.push_back(head.blob.contour);
    if (left_hand.state == FOUND_COLOR)
    contours.push_back(left_hand.blob.contour);
    if (right_hand.state == FOUND_COLOR)
    contours.push_back(right_hand.blob.contour);

    mask = Mat(image.size(), CV_8U, Scalar(0));
    drawContours( mask, contours, -1, Scalar(255), CV_FILLED);
    
    this->image.copyTo(visuals);
    convertScaleAbs(visuals, visuals, 0.2);
    this->image.copyTo(visuals, mask);
    
    if (head.state == FOUND_COLOR) {
        vector<vector<Point> > cs;
        cs.push_back(head.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 80, 80, 255 ));
    }

    if (left_hand.state == FOUND_COLOR) {
        vector<vector<Point> > cs;
        cs.push_back(left_hand.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 255, 80, 80 ));
    }

    if (right_hand.state == FOUND_COLOR) {
        vector<vector<Point> > cs;
        cs.push_back(right_hand.blob.contour);
        drawContours( visuals, cs, -1, Scalar( 80, 255, 80 ));
    }

    if (left_hand.state != NOT_VISIBLE) {
        rectangle(visuals, left_hand.prediction, Scalar(255, 0, 0));
    }
    if (right_hand.state != NOT_VISIBLE) {
        rectangle(visuals, right_hand.prediction, Scalar(0, 255, 0));
    }
    if (head.state != NOT_VISIBLE) {
        rectangle(visuals, head.prediction, Scalar(0, 0, 255));
    }
    circle(visuals, face_center, 10, CV_RGB(255, 255, 255));
    return visuals;
};