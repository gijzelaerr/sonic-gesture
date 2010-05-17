#ifndef _QTTEST_H
#define	_QTTEST_H

#include <QtGui/QApplication>
#include <QtGui/QWidget>
#include <QtGui/QImage>
#include <QtGui/QPushButton>
#include <QtGui/QPainter>
#include <QtCore/QPoint>
#include <QtCore/QTimer>

#include "cv.h"
#include "highgui.h"

#include "source.h"

using namespace cv;

class QtTestor: public QWidget
{
Q_OBJECT

public:
    QtTestor(QWidget *parent = 0);
    ~QtTestor();


private:
    Mat bgr, rgb;
    QPushButton* button;
    Source* source;
    QImage qframe;
    QPainter* painter;
    QTimer* timer;
    void paintEvent(QPaintEvent* e);

public slots:
    void queryFrame();
};

#endif	/* _QTTEST_H */

