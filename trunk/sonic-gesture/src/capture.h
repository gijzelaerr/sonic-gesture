
#ifndef _CAPTURE_H
#define	_CAPTURE_H

#include "cv.h"
#include "bodypart.h"
#include "combiner.h"
#include "settings.h"
#include "skinfinder.h"
#include <QtCore/QDir>


class Capture {
public:
    Capture();
    bool init(const cv::Size& Size);
    bool step(const Mat& big);
    bool saveImage();
    Mat combined;
    QString error;

private:
    BodyParts bodyparts;
    SkinFinder skinFinder;
    Combiner combiner;
    Settings* settings;

    cv::Mat big;
    cv::Mat small_, visuals;
    cv::Size big_size, small_size;
    float scale;
    vector<cv::Mat> examples;
    cv::Mat current, black;
    int counter;

    vector<string> names;
    QDir currentTrainPath;
    QDir originalPath;

    void setError(QString);
    void draw_message();

};

#endif
