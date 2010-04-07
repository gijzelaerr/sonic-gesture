
#ifndef _FINDER_H
#define	_FINDER_H

#include "common.h"

#include "limb.h"
#include "hand.h"
#include "skin.h"
#include "matcher.h"

using namespace cv;


class Finder {
public:
    Mat big, hsv, bw, backproj, mask;
	Mat small_; // small is reserved keyword in visual studio c++
    Mat facepixels, visuals, combi, temp, blurred, morphed, th, limb_zoom;
    MatND histogram, new_hist, old_hist;
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
    Matcher matcher;
    
    Finder(VideoCapture c);
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
    void mainloop();
};


#endif	/* _FINDER_H */

