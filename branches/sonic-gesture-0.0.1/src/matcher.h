#ifndef _MATCHER_H
#define	_MATCHER_H

#include "settings.h"

#include "ml.h"
#include "cvaux.h"

using namespace std;
using namespace cv;

#define STATE_MAX 10
#define STATE_MIN 0
#define STATE_THRESH 8

class Stabilizer {
public:
    Stabilizer();
    Stabilizer(int state_num);
    ~Stabilizer();
    int update(int state);
    int get_state();
    void set_callback();
    bool is_active();

private:
    void trigger(bool active, int state);
    bool active;
    vector<int> states;
};

class Matcher {
public:
    Matcher();
    ~Matcher();
    Matcher(bool mirror, vector<int> labels);
    int match(const vector<float>& descriptors);

private:
    KNearest knn_matcher;
    Size winStride, padding;
    HOGDescriptor hog;
    vector<Point> locations;
    vector<float> descriptors;
    vector<float> labels;
    Mat handimg;
    Mat train;
    Mat labels_mat;
    Stabilizer stabilizer;
    Settings* settings;
};




#endif

