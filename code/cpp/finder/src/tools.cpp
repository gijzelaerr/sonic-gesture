
#include <iostream>

#include "tools.h"

#include "cv.h"

using namespace cv;
using namespace std;


float sum(const vector<float>& x) {
    float total = 0.0;
    for (unsigned int i=0; i<x.size(); i++)
        total = total + x[i]; 
    return total;
}

Rect sub_region(Rect region) {
    Rect r;
    float xbor = 0.3;
    float ybor = 0.16;
    r.x = region.x + region.width * xbor;
    r.y = region.y + region.height * ybor;
    r.width = region.width * (1.0-(2*xbor));
    r.height = region.height * (1.0-(2*ybor));
    return r;
}

void show_mat(Mat M) {
    for (int y=0; y < M.rows; y++) {
        for (int x=0; x < M.cols; x++) {
            float val = M.at<float>(y, x);
            cout << val << " ";
        }
        cout << endl;
    }
}

Mat round_kernel(int dia) {
    Mat kernel = Mat(dia, dia, CV_8U, Scalar(0));
    circle(kernel, Point(dia/2, dia/2), dia/2, Scalar(1), -1);
    return kernel;
}

vector<vector<Point> > scale_contours(vector<vector<Point> > contours, float scale) {
    vector<vector<Point> > scaled_contours;
    vector<Point> contour;

    for(unsigned int i=0; i < contours.size(); i++) {
        contour = contours.at(i);
        scaled_contours.push_back(scale_contour(contour, scale));
    }
    return scaled_contours;
}

vector<Point> scale_contour(vector<Point> contour,float scale) {
    vector<Point> scaled_contour;
    vector<Point>::iterator contour_iterator;
    Point temp_point;

    contour_iterator = contour.begin();
    while( contour_iterator != contour.end() ) {
        temp_point = Point((int)(contour_iterator->x * scale), (int)(contour_iterator->y * scale));
        scaled_contour.push_back(temp_point);
        ++contour_iterator;
    }
    return scaled_contour;
}

