
#ifndef _TOOLS_H
#define	_TOOLS_H

#include "common.h"

using namespace cv;

float sum(const vector<float>& x);

Rect sub_region(Rect region);
void show_mat(Mat M);
Mat round_kernel(int dia);
vector<vector<Point> > scale_contours(vector<vector<Point> > contours, float scale);
vector<Point> scale_contour(vector<Point> contour, float scale);
vector<Point> dilate_contour(vector<Point> contour, Size window_size);
vector<Point> inflate_contour(vector<Point> contour, float scale);
bool is_number(const string& s);
vector<Mat> load_example_hands(const Size& target_size, bool mirror);
#
#endif
