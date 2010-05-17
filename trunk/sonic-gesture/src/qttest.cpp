
#include "qttest.h"
#include "source.h"


QtTestor::QtTestor(QWidget *parent) : QWidget(parent) {
    source = new Source(0);
    queryFrame();
    this->resize(bgr.cols, bgr.rows);
    timer = new QTimer();
    timer = new QTimer(this);
    connect(timer,SIGNAL(timeout()),this,SLOT(queryFrame()));
    timer->start(1);
};

QtTestor::~QtTestor() {};

void QtTestor::queryFrame() {
    bgr = source->grab();
    this->update();
}

void QtTestor::paintEvent(QPaintEvent* e) {
    painter = new QPainter(this);
    cvtColor(bgr, rgb, CV_BGR2RGB);
    const unsigned char * data = (unsigned char *)(rgb.data);
    //frame.step;
    qframe = QImage(data, rgb.cols, rgb.rows, QImage::Format_RGB888);
    painter->drawImage(QPoint(0, 0),qframe);
};

int main(int argc, char *argv[]) {
    QApplication* app = new QApplication(argc, argv);
    QtTestor* qtTestor = new QtTestor();
    qtTestor->show();
    return app->exec();
}