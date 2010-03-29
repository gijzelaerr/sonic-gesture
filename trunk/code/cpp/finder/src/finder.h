
#ifndef _FINDER_H
#define	_FINDER_H

#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "opencv/ml.h"

#include "limb.h"
#include "hand.h"
#include "skin.h"

using namespace cv;


struct Finder {
public:
    Mat frame, small, hsv, bw, backproj, mask;
    Mat facepixels, visuals, combi, temp, blurred, morphed, th, limb_zoom;
    MatND histogram, new_hist, old_hist;
    VideoCapture cap;
    CascadeClassifier haar;
    Size frame_size;
    Size small_size;
    float scale;
    vector<Rect> faces;
    Rect face;
    vector<vector<Point> > contours;
    vector<Point> face_contour;
    Limb left_hand, right_hand, head;
    vector<Hand> hands;
    KNearest hand_matcher;
    vector<Mat> presentation;
    
    Finder(VideoCapture c);
    void grab_frame();
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

