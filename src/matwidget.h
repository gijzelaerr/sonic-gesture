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
#ifndef IPLIMAGE_WIDGET
#define IPLIMAGE_WIDGET

#include <QWidget>
#include "opencv/cv.h"

struct MatWidgetData;
class MatWidget : public QWidget
{
    Q_OBJECT
public:
    MatWidget(QWidget* parent = 0, Qt::WFlags fl = 0 );
    ~MatWidget();

    void setIplImage(IplImage*);
    void setImage(cv::Mat&);

protected:
    void paintEvent(QPaintEvent*);
    void initImages(IplImage*);

private:
    MatWidgetData* d;
};

#endif
