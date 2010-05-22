#ifndef _QCVIMAGE_H
#define	_QCVIMAGE_H

#include <QtGui/QWidget>
#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtCore/QPoint>
#include <QtCore/QTimer>

#include "cv.h"
#include "highgui.h"

#include "source.h"

using namespace cv;

class QCVImage: public QWidget
{
Q_OBJECT

public:
    QCVImage(QWidget* parent = 0);
    ~QCVImage();
    void setImage(Mat* bgr);
    
private:
    Mat* bgr;
    Mat rgb;
    Source* source;
    QImage qframe;

    void paintEvent(QPaintEvent* e);
};

#endif	/* _QTTEST_H */

