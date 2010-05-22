
#include "qcvimage.h"
#include "source.h"
#include "settings.h"

QCVImage::QCVImage(QWidget *parent) : QWidget(parent) {
    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(grab()));
    source = new Source();
    grab();
    setProps();
    timer->start(40);
};

QCVImage::~QCVImage() {};

void QCVImage::grab() {
    bool code = source->grab();
    bgr = source->frame;
    this->update();
}

void QCVImage::setProps() {
    this->resize(bgr.cols, bgr.rows);
    this->setMinimumSize(bgr.cols, bgr.rows);
}

void QCVImage::setSource(Source* source) {
    this->source = source;
    grab();
    setProps();
}

void QCVImage::paintEvent(QPaintEvent* e) {
    QPainter painter(this);
    cvtColor(bgr, rgb, CV_BGR2RGB);
    const unsigned char* data = (unsigned char*)(rgb.data);
    //frame.step;
    qframe = QImage(data, rgb.cols, rgb.rows, QImage::Format_RGB888);
    qframe = qframe.scaled(this->size(), Qt::KeepAspectRatio);
    painter.drawImage(QPoint(0, 0),qframe);
};

