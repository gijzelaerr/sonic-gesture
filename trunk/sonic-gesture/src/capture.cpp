
#include "common.h"
#include "source.h"
#include "bodypart.h"
#include "skinfinder.h"
#include "combiner.h"

#include "boost/filesystem.hpp"
#include "boost/date_time/gregorian/gregorian.hpp"
#include "boost/date_time/posix_time/posix_time.hpp"

using namespace boost::posix_time;
using namespace boost::gregorian;
namespace fs = boost::filesystem;


class Capture {
public:
    Capture(const Source& source);
    void run();
    
private:
    BodyParts bodyparts;
    SkinFinder* skinFinder;
    Combiner* combiner;

    Source source;
    Mat big;
    Mat small_, visuals, combined;
    Size big_size, small_size;
    float scale;
    vector<Mat> examples;
    Mat current, black;

    vector<string> names;
    fs::path current_train_path;
    fs::path original_path;
    
    void init();
    void grab();
    bool step(string image_name);
};

Capture::Capture(const Source& source) {
    this->source = source;
    init();
}

void Capture::init() {
    skinFinder = new SkinFinder();
    examples = load_example_hands(source.size, false);
    black = Mat(source.size, CV_8UC3, Scalar(0, 0, 0));
    
    // do size and scale stuff
    scale = float(WORKSIZE) / source.size.height;
    int small_width = int(source.size.width * scale);
    small_size = Size(small_width, WORKSIZE);
    assert(small_size.width > 0);
    assert(small_size.height > 0);

    // what images to show
    combiner = new Combiner(small_size, XWINDOWS);
    combiner->add_image(skinFinder->frame);
    combiner->add_image(visuals);
    combiner->add_image(current);
    
    string expstr[] = SOLFEGE_FILES;
    names = vector<string>(expstr, expstr + sizeof(expstr)/sizeof(*expstr));
    
    fs::path train_path(NEWTRAIN_PATH );
    assert(fs::exists(train_path));
    
    ptime now = second_clock::local_time();
    date today = now.date();
    current_train_path = train_path / to_simple_string(now);
    original_path = current_train_path / "original/";
    
    // make sure this directory _doens't_ exists, so we don't overwrite
    assert(!fs::exists(current_train_path));
    
    assert(create_directory(current_train_path));
    assert(create_directory(original_path));
};

void Capture::grab() {
    big = source.grab();
    assert(big.data);
    resize(big, small_, Size(), scale, scale);
    assert(small_.data);
}

bool Capture::step(string image_name) {
    double t = (double)getTickCount();
    grab();

    // find the bodyparts
    contours skins_small = skinFinder->compute(small_);
    contours skins = scale_contours(skins_small, float(1)/scale);
    bodyparts.update(skins, skinFinder->face_center, big);

    // draw the stuff
    visuals = bodyparts.draw_in_image();
    combined = this->combiner->render();
    imshow("Sonic Gesture Capturing train data", combined);

    t = ((double)getTickCount() - t)*1000/getTickFrequency();
    int wait = MIN(40, MAX(40-(int)t, 4)); // Wait max of 40 ms, min of 4;

   int inpoet = waitKey(wait);
    if (inpoet == 27) // escape
        exit(EXIT_FAILURE);
    else if (inpoet == 32) { //space
        fs::path hand_file =  current_train_path / image_name;
        fs::path orig_file = original_path / image_name;
        cout << "saving " << hand_file.string() << endl;
        cout << "saving " << orig_file.string() << endl;
        assert(imwrite(orig_file.string(), big)); 
        assert(imwrite(hand_file.string(), bodyparts.left_hand.hog_image));
        return false;
    }
    return true;
}

void Capture::run() {
    string image_name;
    for(unsigned int i=0; i < examples.size(); i++) {
        current = examples.at(i);
        image_name = names.at(i);
        while (this->step(image_name)) {
        };
    }
}

int main(int argc, char** argv) {
    Capture cap = Capture(DEVICE);
    cap.run();
    return (EXIT_SUCCESS);
}

