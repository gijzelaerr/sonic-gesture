
#include <iostream>

#include "cv.h"
#include "highgui.h"

#include "tools.h"
//#include "settings.h"

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
    double xbor = 0.3;
    double ybor = 0.16;
    r.x = int(region.x + region.width * xbor);
    r.y = int(region.y + region.height * ybor);
    r.width = int(region.width * (1.0-(2*xbor)));
    r.height = int(region.height * (1.0-(2*ybor)));
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

vector<vector<Point> > scale_contours(const vector<vector<Point> > contours, float scale) {
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

// increase the size of a contour. Window_size is required to know max size
// Doing many findContours is quite slow. hm.
vector<Point> dilate_contour(const vector<Point>& contour, Size window_size) {
    int dia = window_size.height/10 + 1;
    vector<vector<Point> > contours;
    vector<vector<Point> > contours_new;
    Mat binary(window_size, CV_8U, Scalar(0));
    Mat kernel = round_kernel(dia);
    
    contours.push_back(contour);
    drawContours( binary, contours, -1, Scalar(255), CV_FILLED);

    dilate(binary, binary, kernel, Point(int(ceil(dia/2.0)), int(ceil(dia/2.0))));
    findContours( binary, contours_new, RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE );
    assert(contours.size() > 0);
    return contours_new.at(0);
}

vector<Point> inflate_contour(vector<Point> contour, float scale) {
    assert(contour.size() >0);
    
    Point2f center;
    float radius;
    vector<Point> new_contour;
    vector<Point>::iterator iterator;
    int x, y;

    minEnclosingCircle(Mat(contour), center, radius);
    
    iterator = contour.begin();
    while( iterator != contour.end() ) {
        if(iterator->x > center.x)
            x = int((iterator->x - center.x) * scale + center.x);
        else
            x = int(center.x - (center.x - iterator->x) * scale);

        if(iterator->y > center.y)
            y = int((iterator->y - center.y) * scale + center.y);
        else
            y = int(center.y - (center.y - iterator->y) * scale);
        
        new_contour.push_back(Point(x, y));
        ++iterator;
    }
    return new_contour;
}

bool is_number(const string& str) {
    for (unsigned int i = 0; i < str.length(); i++) {
        if (!isdigit(str[i]))
            return false;
    }
    return true;
}

Rect rect_in_mat(Rect rectange, const Mat& matrix) {
    // return maximum size of rectangle inside the borders of matrix
    int x,y,w,h;

    x = max(0, rectange.x);
    x = min(x, matrix.cols);

    y = max(0, rectange.y);
    y = min(y, matrix.rows);

    w = rectange.width;
    if (x+w >= matrix.cols)
        w = matrix.cols - x;

    h = rectange.height;
    if (y+h >= matrix.rows)
        h = matrix.rows - y;

    w = max(0, w);
    h = max(0, h);

    assert(0 <= x);
    assert(0 <= w);
    assert(x + w <= matrix.cols);
    assert(0 <= y);
    assert(0 <= h);
    assert(y + h <= matrix.rows);

    return Rect(x, y, w, h);
}

void print_mat(Mat matrix) {
    vector<Mat> planes;
    split(matrix, planes);
    Size s = matrix.size();
    int cns = matrix.channels();

    cout << "channels: " << cns;
    cout << " type: " << matrix.type() << endl;
    Mat c;
    float e;

    for (int cn = 0; cn < cns; cn++) {
        c = planes.at(cn);
        if (cns > 1) {
            cout << "channel " << cns << endl;
        }
        for (int x = 0; x < s.width; x++) {
            for (int y = 0; y < s.height; y++) {
                e = matrix.at<float>(x, y);
                cout << e << "\t";
            };
            cout << endl;
        };
    };
};

string int2string(int integer) {
    std::stringstream str;
    str << integer;
    std::string result;
    str >> result;
    return result;
};

Mat qimage2mat(const QImage& qimage) {
    cv::Mat mat = cv::Mat(qimage.height(), qimage.width(), CV_8UC4, (uchar*)qimage.bits(), qimage.bytesPerLine());
    cv::Mat mat2 = cv::Mat(mat.rows, mat.cols, CV_8UC3 );
    int from_to[] = { 0,0,  1,1,  2,2 };
    cv::mixChannels( &mat, 1, &mat2, 1, from_to, 3 );
    return mat2;
};

QImage mat2qimage(const Mat& mat) {
    Mat rgb;
    cvtColor(mat, rgb, CV_BGR2RGB);
    return QImage((const unsigned char*)(rgb.data), rgb.cols, rgb.rows, rgb.step, QImage::Format_RGB888);
};
