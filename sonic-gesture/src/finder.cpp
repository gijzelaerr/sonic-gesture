
#include <iostream>
#include "settings.h"
#include "tools.h"
#include "bodypart.h"
#include "common.h"
#include "skinfinder.h"
#include "matcher.h"
#include "combiner.h"
#include "loader.h"
#include "finder.h"

Finder::Finder() {};

Finder::Finder(const Size& size) {
    init(size);
}

void Finder::init(const Size& size) {
    skinFinder = new SkinFinder();

    // do size and scale stuff
    big_size = size;
    scale = float(WORKSIZE) / size.height;
    int small_width = int(size.width * scale);
    small_size = Size(small_width, WORKSIZE);
    assert(small_size.width > 0);
    assert(small_size.height > 0);

    // load the examples
    Loader loader = Loader();
    fs::path dataset = fs::path(DATASET);
    assert(exists(dataset));
    loader.load(dataset, small_size);
    hands_left = loader.examples_left;
    hands_right = loader.examples_right;

    // load the actual classifier
    left_matcher = new Matcher(false, loader.labels);
    right_matcher = new Matcher(true, loader.labels);    
    
    // what images to show
    combiner = new Combiner(small_size, XWINDOWS);
    combiner->add_image(skinFinder->frame);
    //combiner.add_image(skinFinder.hsv);
    //combiner.add_image(skinFinder.bw);
    //combiner.add_image(skinFinder.backproj);
    //combiner->add_image(skinFinder->blur);
    //combiner.add_image(skinFinder.thresh);
    combiner->add_image(visuals);
    combiner->add_image(current_left);
    combiner->add_image(current_right);
    //combiner.add_image(skinFinder.mask);

    black = Mat(size, CV_8UC3, Scalar(0, 0, 0));
}

Finder::~Finder() {
    delete left_matcher;
    delete right_matcher;
    delete combiner;
    delete skinFinder;
}

bool Finder::step(Mat& big) {
    double t = (double)getTickCount();

    if (!big.data)
        return false;
    
    this->big = big;

    // INTER_NEAREST is faster, INTER_LINEAR is better
    resize(big, small_, small_size, 0, 0, INTER_LINEAR);
    assert(small_.data);

    // find the bodyparts
    contours skins_small = skinFinder->compute(small_);
    contours skins = scale_contours(skins_small, float(1)/scale);
    Point face_center = Point(skinFinder->face_center.x/scale, skinFinder->face_center.y/scale);
    bodyparts.update(skins, face_center, big);

    int left_index = -1;
    int right_index = -1;
    
    // interpretate the bodyparts
    if (bodyparts.left_hand.state != NOT_VISIBLE)
        left_index = left_matcher->match(bodyparts.left_hand.sized_hog_features);
    if (bodyparts.right_hand.state != NOT_VISIBLE)
        right_index = right_matcher->match(bodyparts.right_hand.sized_hog_features);

    if (left_index > -1) {
        current_left = hands_left.at(left_index);
    } else {
        current_left = black;
    }

    if (right_index > -1) {
        current_right = hands_right.at(right_index);
    } else {
        current_right= black;
    }

    // draw the stuff
    visuals = bodyparts.draw_in_image();
    combined = this->combiner->render();

    t = ((double)getTickCount() - t)*1000/getTickFrequency();
    int wait = MIN(40, MAX(40-(int)t, 4)); // Wait max of 40 ms, min of 4;

    draw_fps(t+wait);
    return true;
}

void Finder::draw_fps(int delay) {
    double fps = 1000.0 / delay;
    std::string s;
    std::stringstream out;
    out.precision(1);
    out << std::fixed << fps << " fps";
    s = out.str();
    putText(combined, s, Point(5, 12), FONT_HERSHEY_SIMPLEX, 0.4, Scalar(255, 255, 255), 1);
}


