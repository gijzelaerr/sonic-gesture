
#include <iostream>
#include "videopipe.h"
#include "settings.h"
#include "tools.h"
#include "bodypart.h"


VideoPipe::VideoPipe() {
    source = Source();
    init();
}

VideoPipe::VideoPipe(Source source) {
    this->source = source;
    init();
}

void VideoPipe::init() {
    skinFinder = SkinFinder();
    scale = float(WORKSIZE) / source.size.height;
    int small_width = int(source.size.width * scale);
    small_size = Size(small_width, WORKSIZE);
    assert(small_size.width > 0);
    assert(small_size.height > 0);
}

void VideoPipe::grab() {
    big = source.grab();
    assert(big.data);
    resize(big, small_, Size(), scale, scale);
    assert(small_.data);
}

bool VideoPipe::step() {
    Mat visuals;
    double t = (double)getTickCount();

    grab();
    vector<vector<Point> > skins_small = skinFinder.compute(small_);
    vector<vector<Point> > skins = scale_contours(skins_small, float(1)/scale);
    bodyparts.update(skins, skinFinder.face_center, big);

    // TODO: this shouldn't be done for every step, one time is enough
    combiner = Combiner(small_size, XWINDOWS);
    combiner.add_image(skinFinder.frame);
    //combiner.add_image(skinFinder.hsv);
    //combiner.add_image(skinFinder.bw);
    //combiner.add_image(skinFinder.backproj);
    combiner.add_image(skinFinder.blur);
    combiner.add_image(skinFinder.thresh);
    //combiner.add_image(skinFinder.mask);
    
    visuals = this->combiner.render();
    assert(visuals.data);
    imshow("Sonic Gesture", visuals);

    t = ((double)getTickCount() - t)*1000/getTickFrequency();
    int wait = MIN(40, MAX(40-(int)t, 4)); // Wait max of 40 ms, min of 4;

    if(waitKey(wait) >= 0)
        return false;
    return true;
}

void VideoPipe::run() {
    Mat visuals;
    while (this->step()){};
}




