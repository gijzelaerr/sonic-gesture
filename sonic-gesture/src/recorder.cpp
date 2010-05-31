#include "recorder.h"

Recorder::Recorder() {
    // TODO: disable writer
};

Recorder::Recorder(const QString& filename, double fps, cv::Size frameSize) {
    open(filename, fps, frameSize);
};

bool Recorder::open(const QString& filename, double fps, cv::Size frameSize) {
    return writer.open(filename.toStdString(), CV_FOURCC('M','J','P','G'), fps, frameSize, true);
};

bool Recorder::isOpened() {
    return writer.isOpened();
};

void Recorder::putFrame(const cv::Mat& frame) {
    if (isOpened())
        writer << frame;
};

