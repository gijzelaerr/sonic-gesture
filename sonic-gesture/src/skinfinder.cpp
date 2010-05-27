

#include "skinfinder.h"
#include "tools.h"
#include <iostream>

SkinFinder::SkinFinder(const QFileInfo& haarfile, int probToBinThresh) {
    // load haar wavelet face finder
    assert(haarfile.exists());
    haar = CascadeClassifier(haarfile.filePath().toStdString());
    this->probToBinThresh = probToBinThresh;
    histogram = Histogram();
    frame_counter = 0;
}

vector<vector<Point> > SkinFinder::compute(const Mat& frame) {
    this->frame = frame;
    step();
    return contours;
}

void SkinFinder::prepare() {
    cvtColor(frame, hsv, CV_BGR2HSV);
    cvtColor(frame, bw, CV_BGR2GRAY);
}

void SkinFinder::find_face() {
    if ((frame_counter % 10) != 0)
        return;
        
    frame_counter = 0;
    assert(frame.data);
    haar.detectMultiScale(frame, faces, 1.3, 3, CV_HAAR_DO_CANNY_PRUNING +
        CV_HAAR_FIND_BIGGEST_OBJECT, Size(frame.rows/10, frame.rows/10) );

    if (faces.size() > 0) {
        face = faces.at(0);
        face = sub_region(face);
        face_center = Point(face.x+face.width/2, face.y+face.height/2);
    } else {
        face = Rect();
        //face_center = Point(); // don't reset, of we are lucky it is still correct. no biggy if it is not
    }
}

void SkinFinder::make_histogram() {
    assert(hsv.data);
    if (!(face == Rect())) {
        facepixels = hsv(face);
        histogram.update(facepixels);
    }
}

void SkinFinder::make_backproject() {
    assert(hsv.data);
    backproj = histogram.backproject(hsv);
}

void SkinFinder::make_mask() {
    assert(backproj.data);
    normalize(backproj, backproj, 0, 255, NORM_MINMAX);
    GaussianBlur( backproj, blur, Size(31, 31), 0);
    threshold(blur, thresh, probToBinThresh, 255, THRESH_BINARY);
    morphologyEx(thresh, mask, MORPH_CLOSE, Mat());
}

void SkinFinder::find_contours() {
    assert(mask.data);
    findContours( mask, contours, RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE );
}

// perform all actions required to find contours
void SkinFinder::step() {
    prepare();
    find_face();
    make_histogram();
    make_backproject();
    make_mask();
    find_contours();
    frame_counter++;
}
