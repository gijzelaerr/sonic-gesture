
#include <Qt/QtCore>

#include <highgui.h>
#include "source.h"

#include <iostream>
using namespace std;

Source::Source() {
    loadImage(QString("/home/gijs/Work/sonic-gesture/sonic-gesture/data/resources/background.jpg"));
}

Source::Source(int device) {
    loadCam(device);
}

Source::Source(const QString& file) {
    QFile* qfile = new QFile(file);

    if (!qfile->exists()) {
        // TODO: use a QT signal or something
        exit(EXIT_FAILURE);
    }

    if (file.endsWith("png", Qt::CaseInsensitive)  || file.endsWith("jpg", Qt::CaseInsensitive)) {
        loadImage(file);
    } else {
        loadMovie(file);
    };
};

void Source::loadCam(int device) {
    cap = cv::VideoCapture(device);
    mirror = true;
    init();
}

void Source::loadImage(const QString& file) {
    cout << file.toStdString() << endl;
    frame = cv::imread(file.toStdString());
    image = true;
    mirror = false;
    size = frame.size();
};

void Source::loadMovie(const QString& file) {
    cap = VideoCapture(file.toStdString());
    image = false;
    mirror = false;
    init();
}

Source::~Source() {
};

void Source::init() {
    if(!cap.isOpened()) {
        // TODO: raise qt exception or something
        exit(EXIT_FAILURE);
    }

    cap >> frame;
    assert(frame.data);
    
    // doesn't work for webcam somehow
    //int width = cap.get(CV_CAP_PROP_FRAME_WIDTH);
    //int height = cap.get(CV_CAP_PROP_FRAME_HEIGHT);
    int width = frame.cols;
    int height = frame.rows;
    
    assert(width > 0);
    assert(height > 0);
    size = Size(width, height);
};

Mat& Source::grab() {
    if(!image)
        cap >> frame;

    // TODO: end of movie, use QT signal or soemthing
    if (!frame.data)
        exit(EXIT_SUCCESS);

    if(mirror)
        flip(frame, frame, 1);

    return frame;
}