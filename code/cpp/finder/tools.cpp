
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
    r.x = region.x + region.width * 0.3;
    r.y = region.y + region.height * 0.2;
    r.width = region.width * 0.4;
    r.height = region.height * 0.6;
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

