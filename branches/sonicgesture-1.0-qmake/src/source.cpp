/*!
 * \brief used for reading from movie or camera
 *
 */

#include <iostream>
#include <QtGui/QImage>
#include <QtCore/qfileinfo.h>
#include <QtDebug>
#include "opencv/highgui.h"
#include "source.h"
#include "tools.h"


Source::Source() {
    qimage_storage = QImage(":images/startscreen");
    loop = true;
}

Source::~Source() {
    //cap.release();
}

void Source::startScreen() {
     open(qimage_storage);
}

bool Source::open(int device) {
    cap = cv::VideoCapture(device);
    sourceMode = DEVICE;
    movieLocation = QFileInfo();
	

    cap.set(CV_CAP_PROP_FRAME_WIDTH, 320);
    cap.set(CV_CAP_PROP_FRAME_HEIGHT, 280);
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
    return loadImage(qimage2mat(qimage));
}


bool Source::loadImage(const cv::Mat& mat) {
    frame = mat;
    sourceMode = IMAGE;
    movieLocation = QFileInfo();
    size = frame.size();
    return true;
};

bool Source::loadImage(const QFileInfo& file) {
    frame = cv::imread(file.filePath().toStdString());
    sourceMode = IMAGE;
    movieLocation = QFileInfo();
    size = frame.size();
    return true;
};

bool Source::loadMovie(const QFileInfo& file) {
    try {
        cap = cv::VideoCapture(file.filePath().toStdString());
    } catch (cv::Exception) {
        setError("An exception has accurred");
        return false;
    }

    sourceMode = MOVIE;
    movieLocation = file;
    return init();
}

bool Source::setPos(double position) {
    cap.set(CV_CAP_PROP_POS_FRAMES, position * cap.get(CV_CAP_PROP_FRAME_COUNT));
    return true;
}

double Source::getPos() {
    return cap.get(CV_CAP_PROP_POS_AVI_RATIO);
}

double Source::getAbsolutePos() {
    return cap.get(CV_CAP_PROP_POS_FRAMES);
}

bool Source::init() {
    try {
        if(!cap.isOpened()) {
            setError("The device or movie is not openable");
            return false;
        };
    } catch (cv::Exception) {
        setError("An exception has accurred");
        return false;
    };


    try {
        cap >> frame;
    } catch (cv::Exception) {
        setError("An exception has accurred");
        return false;
    };

    if ((frame.data == NULL)) {
        setError("can't grab from capture device");
        return false;
    };
    
    int width = frame.cols;
    int height = frame.rows;
    
    assert(width > 0);
    assert(height > 0);
    size = cv::Size(width, height);
    return true;
};

void Source::setLoop(bool loop) {
    this->loop = loop;
};

bool Source::grab() {
    if (sourceMode == MOVIE) {
        // loop it at end
        if (cap.get(CV_CAP_PROP_POS_FRAMES) == (cap.get(CV_CAP_PROP_FRAME_COUNT)-1)) {
            if (this->loop)
                setPos(0);
            else
                return false;
        };
    };

    if (sourceMode != IMAGE) {
        try {
            cap >> frame;
        } catch (cv::Exception& e) {
            const char* err_msg = e.what();
            setError("can't grab frame" + QString(err_msg));
            return false;
        };
    };

    if (!frame.data) {
        setError("can't grab frame");
        return false;
    }



    if(sourceMode == DEVICE)
        cv::flip(frame, frame, 1);

    return true;
}

void Source::close() {
    cap.release();
};

void Source::setError(QString str) {
    this->error = str;
}
