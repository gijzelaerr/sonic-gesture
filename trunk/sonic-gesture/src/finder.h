#ifndef _FINDER_H
#define	_FINDER_H

#include "cv.h"

#include "bodypart.h"
#include "skinfinder.h"
#include "matcher.h"
#include "combiner.h"

class Finder {
public:
    Finder();
    Finder(const cv::Size& size);
    ~Finder();

    void init(const cv::Size& size);
    bool step(cv::Mat& big);
    cv::Mat combined;
    
private:
    BodyParts bodyparts;
    SkinFinder* skinFinder;
    Combiner* combiner;
    Matcher* left_matcher;
    Matcher* right_matcher;

    cv::Mat big;
    cv::Mat small_, visuals;
    cv::Size big_size, small_size;
    float scale;
    vector<cv::Mat> hands_left, hands_right;
    cv::Mat current_left, current_right, black;

    void init();
    void draw_fps(int fps);
};


#endif	/* _FINDER_H */

