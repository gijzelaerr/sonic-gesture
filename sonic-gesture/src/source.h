
#ifndef _SOURCE_H
#define	_SOURCE_H

#include "cv.h"
#include "highgui.h"
#include <string>
#include <Qt/QtCore>

class Source {
public:
    Source();
    ~Source();
    bool open(int device);
    bool open(const std::string& file);
    bool open(const QImage& qimage);
    bool open(const QString& file);
    bool open(const cv::Mat& image);

    bool grab();
    QString lastError();

    cv::Size size;
    cv::Mat frame;
    
private:

    bool init();
    bool loadCam(int device);
    bool loadMovie(const QString& file);
    bool loadImage(const QString& file);
    bool loadImage(const cv::Mat& file);
    void setError(QString error);

    bool mirror, image;
    cv::VideoCapture cap;
    QString error;

};

#endif