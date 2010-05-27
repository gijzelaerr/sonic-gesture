#include <iostream>
#include <QtGui/QImage>
#include <qt4/QtCore/qfileinfo.h>
#include "highgui.h"
#include "source.h"


Source::Source() {
    qimage_storage = QImage(":images/startscreen");
    open(qimage_storage);
}

Source::~Source() {
}

bool Source::open(int device) {
    cap = cv::VideoCapture(device);
    mirror = true;
    image = false;
    return init();
}

bool Source::open(const QFileInfo& fileinfo) {
    if (!fileinfo.exists()) {
        setError("file doesn't exists");
        return false;
    }

    if (fileinfo.fileName().endsWith("png", Qt::CaseInsensitive) ||
            fileinfo.fileName().endsWith("jpg", Qt::CaseInsensitive))
        return loadImage(fileinfo);
    else
        return loadMovie(fileinfo);
};

bool Source::open(const QImage& qimage) {
    assert(qimage.height() > 0);
    cv::Mat mat = cv::Mat(qimage.height(), qimage.width(), CV_8UC3, cv::Scalar(0, 0 ,0));
    mat.data = (uchar*)qimage.bits();
    //cv::cvtColor(mat, mat, CV_RGB2BGR);
    return loadImage(mat);
}


bool Source::loadImage(const cv::Mat& mat) {
    frame = mat;
    image = true;
    mirror = false;
    size = frame.size();
    return true;
};

bool Source::loadImage(const QFileInfo& file) {
    frame = cv::imread(file.filePath().toStdString());
    image = true;
    mirror = false;
    size = frame.size();
    return true;
};

bool Source::loadMovie(const QFileInfo& file) {
    cap = cv::VideoCapture(file.filePath().toStdString());
    image = false;
    mirror = false;
    return init();
}

bool Source::setPos(double position) {
    //cap.set(CV_CAP_PROP_POS_AVI_RATIO, position);
    //return (getPos() == position);

    cap.set(CV_CAP_PROP_POS_FRAMES, position * CV_CAP_PROP_FRAME_COUNT);
    return true;
}

double Source::getPos() {
    return cap.get(CV_CAP_PROP_POS_AVI_RATIO);
}

bool Source::init() {
    if(!cap.isOpened()) {
        setError("can't open the capture device");
        return false;
    }

    cap >> frame;
    if ((frame.data == NULL)) {
        setError("can't grab from capture device");
        return false;
    };
    
    // doesn't work for webcam somehow
    //int width = cap.get(CV_CAP_PROP_FRAME_WIDTH);
    //int height = cap.get(CV_CAP_PROP_FRAME_HEIGHT);
    //CV_CAP_PROP_POS_MSEC - Film current position in milliseconds or video capture timestamp
    //CV_CAP_PROP_POS_FRAMES - 0-based index of the frame to be decoded/captured next
    //CV_CAP_PROP_POS_AVI_RATIO - Relative position of the video file (0 - start of the film, 1 - end of the film)
    //CV_CAP_PROP_FRAME_WIDTH - Width of the frames in the video stream
    //CV_CAP_PROP_FRAME_HEIGHT - Height of the frames in the video stream
    //CV_CAP_PROP_FPS - Frame rate
    //CV_CAP_PROP_FOURCC - 4-character code of codec
    //CV_CAP_PROP_FRAME_COUNT - Number of frames in the video file
    //CV_CAP_PROP_BRIGHTNESS - Brightness of the image (only for cameras)
    //CV_CAP_PROP_CONTRAST - Contrast of the image (only for cameras)
    //CV_CAP_PROP_SATURATION - Saturation of the image (only for cameras)
    //CV_CAP_PROP_HUE - Hue of the image (only for cameras)
    int width = frame.cols;
    int height = frame.rows;
    
    assert(width > 0);
    assert(height > 0);
    size = cv::Size(width, height);
    return true;
};

bool Source::grab() {
    if(!image)
        cap >> frame;

    if (!frame.data)
        return false;

    if(mirror)
        cv::flip(frame, frame, 1);

    return true;
}

void Source::setError(QString str) {
    this->error = str;
}