/****************************************************************************
**
** Copyright (C) Sebojolais
**
** Use of this file is limited according to the terms specified by
** Sebojolais.
**
** Details of those terms are listed in licence.txt included as
** part of the distribution package of this file. This file may not
** be distributed without including the licence.txt file.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/
#include "matwidget.h"

#include <QImage>
#include <QPainter>
#include <QMutexLocker>
#include <QMutex>

struct MatWidgetData
{
    MatWidgetData() : iplImage(NULL), mutex(QMutex::Recursive) {}

    IplImage* iplImage;
    QImage qtImage;
    QMutex mutex;
};

MatWidget::MatWidget(QWidget* parent, Qt::WFlags fl)
: QWidget(parent, fl)
{
    d = new MatWidgetData;
    setAutoFillBackground(true);
}

MatWidget::~MatWidget()
{
    delete d;
}

void MatWidget::initImages(IplImage* image)
{
    try
    {
        QMutexLocker locker(&d->mutex);
        if(d->iplImage)
        {
            cvReleaseImage(&d->iplImage);
            d->iplImage = NULL;
        }
        
        d->iplImage = cvCreateImage(cvSize(image->width, image->height), IPL_DEPTH_8U, 3);
        if(!d->iplImage)
            throw QString("Error : cvCreateImage() return null.\n");

        // feed into QImage  
        uchar *cv = (uchar*) (d->iplImage->imageData);
        d->qtImage = QImage(cv, d->iplImage->width, d->iplImage->height, d->iplImage->widthStep, QImage::Format_RGB888);  

        // Resize the widget
        //resize(d->iplImage->width, d->iplImage->height);
    }
    catch(QString msg)
    {
        qWarning("MatWidget::initImages return error\n");
        return;
    }
    catch(...)
    {
        qWarning("MatWidget::initImages return error\n");
        return;
    }
}
void MatWidget::setIplImage(IplImage* image)
{
    try
    {
    if(!image)
        return;

    d->mutex.lock();

    if(!d->iplImage)
    {
        initImages(image);
    }

    // IF the image size changes
    if(d->iplImage)
        if(image->width != d->iplImage->width || image->height != d->iplImage->height)
        {
            initImages(image);
        }

    // convert image to RGB format  
    switch(image->nChannels)
    {
    case 1: 
        cvCvtColor(image, d->iplImage, CV_GRAY2RGB);
        break;
    case 3: 
        cvCvtColor(image, d->iplImage, CV_BGR2RGB);
        break;
    case 4:
        cvCvtColor(image, d->iplImage, CV_BGRA2RGB);
        break;
    }
    d->mutex.unlock();

    // Post a repaint
    update();

    }
    catch(QString msg)
    {
        d->mutex.unlock();
        qWarning("MatWidget::setIplImage return error\n");
        return;
    }
    catch(...)
    {
        d->mutex.unlock();
        qWarning("MatWidget::setIplImage return error\n");
        return;
    }
}


void MatWidget::setImage(cv::Mat& mat) {
    IplImage i = mat;
    setIplImage(&i);
}

void MatWidget::paintEvent(QPaintEvent*)
{
    QPainter painter(this);

    if (d->qtImage.isNull()) {
        return;
    }
    QImage scaled = d->qtImage.scaled(this->size(), Qt::KeepAspectRatio);
    int wskip = (this->width() - scaled.width())/2;
    int hskip = (this->height() - scaled.height())/2;

    painter.drawImage(QPoint(wskip, hskip), scaled);
}
