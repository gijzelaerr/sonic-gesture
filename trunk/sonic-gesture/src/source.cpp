
#include <Qt/QtCore>
#include <qt4/QtGui/qimage.h>
#include "highgui.h"
#include "source.h"
#include "settings.h"

Source::Source() {
    open(STARTSCREEN);
}

Source::~Source() {
}

bool Source::open(int device) {
    cap = cv::VideoCapture(device);
    mirror = true;
    image = false;
    return init();
}

bool Source::open(const std::string& file) {
    QString qstr = QString(file.c_str());
    return open(qstr);
};

bool Source::open(const QString& file) {
    QFile* qfile = new QFile(file);

    if (!qfile->exists()) {
        setError(qfile->errorString());
        return false;
    }
        

    if (file.endsWith("png", Qt::CaseInsensitive)  || file.endsWith("jpg", Qt::CaseInsensitive))
        return loadImage(file);
    else
        return loadMovie(file);
};

bool Source::open(const QImage& qimage) {
    cv::Mat mat = cv::Mat(qimage.height(), qimage.width(), CV_8UC3, cv::Scalar(0, 0 ,0));
    const uchar* blaat = (const uchar*)qimage.bits();
    mat.data = (uchar*)blaat;
    cv::cvtColor(mat, mat, CV_RGB2BGR);
    return loadImage(mat);
}


bool Source::loadImage(const cv::Mat& mat) {
    frame = mat;
    image = true;
    mirror = false;
    size = frame.size();
    return true;
};

bool Source::loadImage(const QString& file) {
    frame = cv::imread(file.toStdString());
    image = true;
    mirror = false;
    size = frame.size();
    return true;
};

bool Source::loadMovie(const QString& file) {
    cap = cv::VideoCapture(file.toStdString());
    image = false;
    mirror = false;
    return init();
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
    int width = cap.get(CV_CAP_PROP_FRAME_WIDTH);
    int height = cap.get(CV_CAP_PROP_FRAME_HEIGHT);
    //int width = frame.cols;
    //int height = frame.rows;
    
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