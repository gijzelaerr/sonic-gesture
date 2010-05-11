
#ifndef _LOADER_H
#define	_LOADER_H

#include "cv.h"
#include "highgui.h"
#include "boost/filesystem.hpp"
#include <vector>

using namespace boost::filesystem;
using namespace cv;

class Loader {
public:
    void load(path location, Size size);
    vector<Mat> examples_left, examples_right;
    vector<int> labels;
    
private:
    void load_examples(path examples, Size size);
    void load_labels(path labels);
    path location;
};

#endif