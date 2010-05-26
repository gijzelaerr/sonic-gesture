#include "recorder.h"

Recorder::Recorder(const std::string& filename, double fps, cv::Size frameSize) {
    open(filename, fps, frameSize);
};

bool Recorder::open(const std::string& filename, double fps, cv::Size frameSize) {
    return writer.open(filename, CV_FOURCC('M','J','P','G'), fps, frameSize, true);
};

bool Recorder::isOpened() {
    return writer.isOpened();
};

void Recorder::putFrame(const cv::Mat& frame) {
    writer << frame;
};

