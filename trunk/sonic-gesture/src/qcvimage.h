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
    void setSource(Source* source);

private:
    Mat bgr, rgb;
    Source* source;
    QImage qframe;
    QTimer* timer;
    void paintEvent(QPaintEvent* e);
    void setProps();

public slots:
    void grab();
};

#endif	/* _QTTEST_H */

