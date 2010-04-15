
#ifndef _VIDEOPIPE_H
#define	_VIDEOPIPE_H

#include "cv.h"
#include "source.h"
#include "skinfinder.h"
#include "combiner.h"

using namespace cv;

class VideoPipe {
public:
    VideoPipe();
    VideoPipe(Source source);
    void run();
    
private:
    Source source;
    Mat big, small_;
    Size big_size, small_size;
    float scale;
    SkinFinder skinFinder;
    Combiner combiner;
    void init();
    void grab();
    bool step();
};

#endif
