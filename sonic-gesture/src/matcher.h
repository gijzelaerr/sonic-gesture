#ifndef _MATCHER_H
#define	_MATCHER_H

#define STATE_MAX 10
#define STATE_MIN 0
#define STATE_THRESH 8

#include "common.h"

using namespace std;

class Stabilizer {
public:
    Stabilizer(int state_num=1);
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
    KNearest knn_matcher;
    Size winStride, padding;
    HOGDescriptor hog;
    vector<Point> locations;
    vector<float> descriptors;
    vector<float> labels;
    Mat handimg;
    Mat train;
    Mat labels_mat;
    Stabilizer* stabilizer;

public:
    Matcher(bool mirror, vector<int> labels);
    ~Matcher();
    int match(const vector<float>& descriptors);
};




#endif

