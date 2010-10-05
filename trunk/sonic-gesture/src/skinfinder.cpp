

#include "skinfinder.h"
#include "tools.h"
#include <iostream>
#include <QtDebug>
#include "highgui.h"

SkinFinder::SkinFinder() {
    settings = Settings::getInstance();
    histogram = Histogram();
    frame_counter = 0;
};

bool SkinFinder::init() {
    if (!settings->haarFile.exists()) {
        setError(QString("%1 doesn't exists").arg(settings->haarFile.path()));
        return false;
    };

    haar = CascadeClassifier(settings->haarFile.filePath().toStdString());
    if (haar.empty()) {
        setError("haar file is empty");
        return false;
    };

    return true;
}

bool SkinFinder::compute(const Mat& frame) {
    this->frame = frame;
    return step();
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
    haar.detectMultiScale(frame, faces, 1.3, 3, CV_HAAR_DO_CANNY_PRUNING + CV_HAAR_FIND_BIGGEST_OBJECT, Size(frame.rows/10, frame.rows/10) );
    //haar.detectMultiScale(frame, faces, 1.1, 1, NULL, Size(frame.rows/10, frame.rows/10) );

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
    if ((frame_counter % 10) != 0)
        return;
    assert(hsv.data);
    if (!(face == Rect())) {
        facepixels = hsv(face);
        histogram.update(facepixels);

        //Mat gijs = frame(face);
        //Mat gijs2;
        //resize(gijs, gijs2, Size(), 5, 5);
        //imshow("gijs", gijs2);
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
    threshold(blur, thresh, settings->probToBinThresh, 255, THRESH_BINARY);
    morphologyEx(thresh, mask, MORPH_CLOSE, Mat());
}

void SkinFinder::find_contours() {
    assert(mask.data);
    findContours( mask, contours, RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE );
}

// perform all actions required to find contours
bool SkinFinder::step() {
    prepare();
    find_face();
    make_histogram();
    make_backproject();
    make_mask();
    find_contours();
    frame_counter++;
    return true;
}

void SkinFinder::setError(QString error) {
    this->error = error;
    qDebug() << error;
}
