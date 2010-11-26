/*!
 * \brief A self constructed qwidget that displays a opencv image Matrix
 *
 */
#include <QtGui/qwidget.h>
#include <QDesktopWidget>
#include <QApplication>
#include "qcvimage.h"
#include "source.h"
#include "tools.h"

QCVImage::QCVImage(QWidget *parent) : QWidget(parent) {
    this->setAutoFillBackground(false);
};

QCVImage::~QCVImage() {};

void QCVImage::setImage(Mat* bgr) {
    this->bgr = bgr;
    this->setMinimumSize(200, 200);

    // TODO: make this more nice
    QDesktopWidget* desktop = QApplication::desktop();
    const QRect  geom = desktop->screenGeometry();
    this->setMaximumSize(geom.width(), geom.height());
    //this->setMaximumSize(200, 200);
    update();
}

void QCVImage::paintEvent(QPaintEvent* e) {
    QPainter painter(this);
    qframe = mat2qimage(*bgr);
    qframe = qframe.scaled(this->size(), Qt::KeepAspectRatio);
    int wskip = (this->width() - qframe.width())/2;
    int hskip = (this->height() - qframe.height())/2;
    painter.drawImage(QPoint(wskip, hskip),qframe);
};

