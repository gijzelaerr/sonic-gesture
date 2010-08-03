
#ifndef _SOURCE_H
#define	_SOURCE_H

#include "cv.h"
#include "highgui.h"
#include <string>
#include <QtCore/QFileInfo>
#include <QtGui/QImage>

enum SourceModeType { MOVIE, DEVICE, IMAGE };

class Source {
public:
    Source();
    ~Source();
    bool open(int device);
    bool open(const QImage& qimage);
    bool open(const QFileInfo& file);
    bool open(const cv::Mat& image);
    bool grab();
    bool setPos(double position);
    double getPos();
    double getAbsolutePos();
    void close();
    void startScreen();
    void setLoop(bool loop);

    cv::Size size;
    cv::Mat frame;
    QString error;
    SourceModeType sourceMode;
    QFileInfo movieLocation;

private:

    bool init();
    bool loadCam(int device);
    bool loadMovie(const QFileInfo& file);
    bool loadImage(const QFileInfo& file);
    bool loadImage(const cv::Mat& file);
    void setError(QString error);


    bool loop;
    cv::VideoCapture cap;
    QImage qimage_storage;

};

#endif
