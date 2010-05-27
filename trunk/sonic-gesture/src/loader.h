
#ifndef _LOADER_H
#define	_LOADER_H

#include "cv.h"
#include "highgui.h"
#include <QtCore/QDir>

class Loader {
public:
    void load(QDir location, cv::Size size);
    std::vector<cv::Mat> examples_left, examples_right;
    std::vector<int> labels;
    
private:
    void load_examples(QDir examples, cv::Size size);
    void load_labels(QFileInfo labels);
    QDir location;
};

#endif