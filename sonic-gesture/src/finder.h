
#ifndef _FINDER_H
#define	_FINDER_H

#include "common.h"

#include "limb.h"
#include "matcher.h"
#include "histogram.h"

using namespace cv;


class Finder {
protected:
    Mat big, hsv, bw, backproj, mask;
	Mat small_; // small is reserved keyword in visual studio c++
    Mat facepixels, visuals, combi, temp, blurred, morphed, th, limb_zoom;
    //MatND histogram, new_hist, old_hist;
    VideoCapture cap;
    CascadeClassifier haar;
    Size big_size;
    Size small_size;
    float scale;
    vector<Rect> faces;
    Rect face;
    vector<vector<Point> > contours;
    vector<Point> face_contour;
    Limb left_hand, right_hand, head;
    KNearest hand_matcher;
    vector<Mat> presentation;
    Matcher* left_matcher;
    Matcher* right_matcher;
    vector<Mat> example_right_hands, example_left_hands;
    Histogram* histogram;


    bool grab_frame();
    void find_face();
    void make_histogram();
    void make_backproject();
    void make_mask();
    void visualize();
    void find_contours();
    void find_limbs();
    void match_hands();
    void init_hands();
    bool step();
    void init();
    void prepare_frame();

public:
    Finder(int device=0);
    Finder(string movie);
    ~Finder();
    void run();
};


#endif	/* _FINDER_H */

