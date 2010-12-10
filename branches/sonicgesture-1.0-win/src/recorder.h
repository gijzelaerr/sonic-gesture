#ifndef _RECORDER_H
#define	_RECORDER_H

#include "opencv/cv.h"
#include "opencv/highgui.h"

#include <QtCore/QString>

class Recorder {
public:
    Recorder();
    Recorder(const QString& filename, double fps, cv::Size frameSize);
    void putFrame(const cv::Mat& frame);
    bool open(const QString& filename, double fps, cv::Size frameSize);
    bool isOpened();

private:
    cv::VideoWriter writer;

};

#endif	/* _RECORDER_H */

