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
    bool init(const cv::Size& size);
    bool step(cv::Mat& big);
    cv::Mat combined;
    QString error;
    
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
    void setError(QString);
};


#endif	/* _FINDER_H */

