
#include <iostream>

#include "cv.h"
#include "highgui.h"

#include "tools.h"
#include "settings.h"

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

vector<vector<Point> > scale_contours(const vector<vector<Point> >& contours, float scale) {
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
    int dia = WORKSIZE/10 + 1;
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

vector<Point> inflate_contour( vector<Point> contour, float scale) {
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

vector<Mat> load_example_hands(const Size& target_size, const bool mirror) {
    // the file names of example and train
    string expstr[] = SOLFEGE_FILES;
    vector<string> examples(expstr, expstr + sizeof (expstr)/sizeof (*expstr));
    vector<Mat> examples_mat;

    fs::path examples_path(EXAMPLES_PATH );
    assert(fs::exists(examples_path));

    for(unsigned int i =0; i < examples.size(); i++) {
        string image_file = examples.at(i);
        fs::path image_path = examples_path / image_file;
        assert(fs::exists(image_path));
        Mat example_mat = imread(image_path.string(), 1);
        if(mirror) flip(example_mat, example_mat, 1);
        Mat temp;
        resize(example_mat, temp, target_size);
        examples_mat.push_back(temp);
    }
    return examples_mat;
}
