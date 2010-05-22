
#include "common.h"
#include "source.h"
#include "bodypart.h"
#include "skinfinder.h"
#include "combiner.h"
#include "loader.h"
#include "capture.h"

Capture::Capture() {};

Capture::Capture(const Size& size) {

    skinFinder = new SkinFinder();
    black = Mat(size, CV_8UC3, Scalar(0, 0, 0));
    
    // do size and scale stuff
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
    examples = loader.examples_left;
    
    // what images to show
    combiner = new Combiner(small_size, XWINDOWS);
    combiner->add_image(skinFinder->frame);
    combiner->add_image(visuals);
    combiner->add_image(current);
    
    // where to store files
    fs::path store_path = dataset / "incoming";
    if (!fs::exists(store_path)) {
        assert(create_directory(store_path));
    };
 
    //construct new directory name
    ptime now = second_clock::local_time();
    date today = now.date();
    current_train_path = store_path / to_simple_string(now);
    original_path = current_train_path / "original/";
    
    // make sure this directory _doens't_ exists, so we don't overwrite
    assert(!fs::exists(current_train_path));
    
    // create the new directory
    assert(create_directory(current_train_path));
    assert(create_directory(original_path));

    counter = 0;
};

bool Capture::step(const Mat& big) {
    double t = (double)getTickCount();

    if (counter >= examples.size())
        return false;

    assert(big.data);
    resize(big, small_, small_size, 0, 0, INTER_NEAREST);
    assert(small_.data);

    current = examples.at(counter);
    string image_name = int2string(counter);
    
    // find the bodyparts
    contours skins_small = skinFinder->compute(small_);
    contours skins = scale_contours(skins_small, float(1)/scale);
    Point face_center = Point(skinFinder->face_center.x/scale, skinFinder->face_center.y/scale);
    bodyparts.update(skins, face_center, big);

    // draw the stuff
    visuals = bodyparts.draw_in_image();
    combined = this->combiner->render();
    //imshow("Sonic Gesture Capturing train data", combined);

    t = ((double)getTickCount() - t)*1000/getTickFrequency();
    int wait = MIN(40, MAX(40-(int)t, 4)); // Wait max of 40 ms, min of 4;

    int inpoet = waitKey(wait);
    if (inpoet == 27) // escape
        exit(EXIT_FAILURE);
    else if (inpoet == 32) { //space
        if (bodyparts.left_hand.state == NOT_VISIBLE) {
            cout << " NO HAND IN IMAGE!" << endl;
            return true;
        }
        fs::path hand_file =  current_train_path / image_name;
        fs::path orig_file = original_path / image_name;
        cout << "saving " << hand_file.string() << endl;
        cout << "saving " << orig_file.string() << endl;
        assert(imwrite(orig_file.string() + ".jpg", big)); 
        assert(imwrite(hand_file.string() + ".jpg", bodyparts.left_hand.sized_hog_image));
        counter++;
        return false;
    }
    return true;
}

