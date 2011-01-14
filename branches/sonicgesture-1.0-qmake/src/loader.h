
#ifndef _LOADER_H
#define	_LOADER_H

#include "opencv/cv.h"
#include "opencv/highgui.h"
#include <QtCore/QDir>

class Loader {
public:
    bool load(QDir location, cv::Size size);
    std::vector<cv::Mat> examples_left, examples_right;
    std::vector<int> labels;
    QString error;
    
private:
    bool load_examples(QDir examples, cv::Size size);
    bool load_labels(QFileInfo labels);
    void setError(QString error);
    QDir location;
};

#endif
