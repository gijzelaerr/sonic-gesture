
#include <iostream>
#include "settings.h"
#include "tools.h"
#include "bodypart.h"
#include "common.h"
#include "source.h"
#include "skinfinder.h"
#include "matcher.h"
#include "combiner.h"


class Finder {
public:
    Finder(const Source& source);
    void run();

private:
    BodyParts bodyparts;
    SkinFinder* skinFinder;
    Combiner* combiner;
    Matcher* left_matcher;
    Matcher* right_matcher;

    Source source;
    Mat big;
    Mat small_, visuals, combined;
    Size big_size, small_size;
    float scale;
    vector<Mat> hands_left, hands_right;
    Mat current_left, current_right, black;

    void init();
    void grab();
    bool step();
    void draw_fps(int fps);
};

Finder::Finder(const Source& source) {
    this->source = source;
    init();
}

void Finder::init() {
    skinFinder = new SkinFinder();
    left_matcher = new Matcher();
    right_matcher = new Matcher(true);

    hands_left = load_example_hands(source.size, false);
    hands_right = load_example_hands(source.size, true);

    // do size and scale stuff
    scale = float(WORKSIZE) / source.size.height;
    int small_width = int(source.size.width * scale);
    small_size = Size(small_width, WORKSIZE);
    assert(small_size.width > 0);
    assert(small_size.height > 0);

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

    black = Mat(source.size, CV_8UC3, Scalar(0, 0, 0));
}

void Finder::grab() {
    big = source.grab();
    assert(big.data);
    // INTER_NEAREST is faster, INTER_LINEAR is better
    resize(big, small_, small_size, 0, 0, INTER_LINEAR);
    assert(small_.data);
}

bool Finder::step() {
    double t = (double)getTickCount(); 
    
    grab();

    // find the bodyparts
    contours skins_small = skinFinder->compute(small_);
    contours skins = scale_contours(skins_small, float(1)/scale);
    bodyparts.update(skins, skinFinder->face_center, big);
 
    // interpretate the bodyparts
    int left_index = left_matcher->match(bodyparts.left_hand.hog_features);
    int right_index = right_matcher->match(bodyparts.right_hand.hog_features);

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
    imshow("Sonic Gesture", combined);

    if(waitKey(wait) >= 0)
        return false;
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

void Finder::run() {
    //while (this->step()){};

    for(int i=0; i < 10; i++) {
        this->step();
    }
}

int main(int, char**) {
    Source source = Source(DEVICE);
    Finder finder = Finder(source);
    finder.run();
    return EXIT_SUCCESS;

}
