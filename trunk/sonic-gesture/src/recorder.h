#ifndef _RECORDER_H
#define	_RECORDER_H

#include "cv.h"
#include "highgui.h"



class Recorder {
public:
    Recorder(const std::string& filename, double fps, cv::Size frameSize);
    void putFrame(const cv::Mat& frame);
    bool open(const std::string& filename, double fps, cv::Size frameSize);
    bool isOpened();

private:
    cv::VideoWriter writer;

};

#endif	/* _RECORDER_H */

