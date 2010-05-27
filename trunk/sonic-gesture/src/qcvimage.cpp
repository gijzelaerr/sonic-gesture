
#include <qt4/QtGui/qwidget.h>

#include "qcvimage.h"
#include "source.h"
//#include "settings.h"

QCVImage::QCVImage(QWidget *parent) : QWidget(parent) {
};

QCVImage::~QCVImage() {};

void QCVImage::setImage(Mat* bgr) {
    this->bgr = bgr;
    //this->setMinimumSize(bgr->cols, bgr->rows);
}

void QCVImage::paintEvent(QPaintEvent* e) {
    QPainter painter(this);
    this->resize(bgr->cols, bgr->rows);

    //this->setMaximumSize(bgr->cols, bgr->rows);
    cvtColor(*bgr, rgb, CV_BGR2RGB);
    const unsigned char* data = (unsigned char*)(rgb.data);
    qframe = QImage(data, rgb.cols, rgb.rows, QImage::Format_RGB888);
    qframe = qframe.scaled(this->size(), Qt::KeepAspectRatio);
    painter.drawImage(QPoint(0, 0),qframe);
};

