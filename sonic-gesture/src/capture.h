
#ifndef _CAPTURE_H
#define	_CAPTURE_H

#include <vector>
#include <string>
#include "cv.h"
#include "bodypart.h"
#include "combiner.h"

#include "boost/filesystem.hpp"
#include "boost/date_time/gregorian/gregorian.hpp"
#include "boost/date_time/posix_time/posix_time.hpp"

using namespace boost::posix_time;
using namespace boost::gregorian;
namespace fs = boost::filesystem;

class Capture {
public:
    Capture();
    Capture(const cv::Size& Size);
    bool step(const Mat& big);
    Mat combined;

private:
    BodyParts bodyparts;
    SkinFinder* skinFinder;
    Combiner* combiner;

    cv::Mat big;
    cv::Mat small_, visuals;
    cv::Size big_size, small_size;
    float scale;
    vector<cv::Mat> examples;
    cv::Mat current, black;
    int counter;

    vector<string> names;
    fs::path current_train_path;
    fs::path original_path;

};

#endif