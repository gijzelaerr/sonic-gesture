#ifndef _FINDER_H
#define	_FINDER_H

#include "opencv/cv.h"

#include "bodypart.h"
#include "skinfinder.h"
#include "matcher.h"
#include "combiner.h"
#include "settings.h"
#include "audio.h"

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
    Audio audio;

    cv::Mat big;
    cv::Mat small_, visuals;
    cv::Size big_size, small_size;
    float scale;
    vector<cv::Mat> hands_left, hands_right;
    cv::Mat current_left, current_right, black;
    bool ready;

    void setError(QString);
    void audioOut(int left, int right, float leftPos, float rightPos, float leftSize, float rightSize);
};


#endif	/* _FINDER_H */

