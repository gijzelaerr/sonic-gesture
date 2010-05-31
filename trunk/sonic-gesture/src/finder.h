#ifndef _FINDER_H
#define	_FINDER_H

#include "cv.h"

#include "bodypart.h"
#include "skinfinder.h"
#include "matcher.h"
#include "combiner.h"
#include "settings.h"

class Finder {
public:
    Finder();
    Finder(const Size& size);
    void load(const cv::Size& size);
    bool step(cv::Mat& big);
    cv::Mat combined;
    
private:
    Settings* settings;
    BodyParts bodyparts;
    SkinFinder skinFinder;
    Combiner combiner;
    Matcher left_matcher;
    Matcher right_matcher;

    cv::Mat big;
    cv::Mat small_, visuals;
    cv::Size big_size, small_size;
    float scale;
    vector<cv::Mat> hands_left, hands_right;
    cv::Mat current_left, current_right, black;

    void draw_fps(int fps);
};


#endif	/* _FINDER_H */

