#include <iostream>
#include <QtGui/QImage>
#include <QtCore/qfileinfo.h>
#include <QtDebug>
#include "highgui.h"
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

void Source::setLoop(bool loop) {
    this->loop = loop;
};

bool Source::grab() {
    if (sourceMode != IMAGE) {
        // loop video
        if (this->loop) {
            if (cap.get(CV_CAP_PROP_POS_FRAMES) == (cap.get(CV_CAP_PROP_FRAME_COUNT)-2))
                setPos(0);
        };

        try {
            cap >> frame;
        } catch (cv::Exception) {
            setError("can't grab frame");
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

