
#ifndef _TOOLS_H
#define	_TOOLS_H

#include "opencv/cv.h"

using namespace cv;

float sum(const vector<float>& x);

Rect sub_region(Rect region);
void show_mat(Mat M);
#endif
