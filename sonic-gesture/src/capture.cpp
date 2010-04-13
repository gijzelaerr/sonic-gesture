
#include "common.h"
#include "finder.h"

#include "boost/date_time/gregorian/gregorian.hpp"
#include "boost/date_time/posix_time/posix_time.hpp"
using namespace boost::posix_time;
using namespace boost::gregorian;


// Inherit from main program, since we want to do almost the same here
class Capture : public Finder {
public:
    Capture(int device=0);
    Capture(string movie);
    ~Capture();
    void run();
    
private:
    Mat example_hand;
    fs::path current_train_path;
    fs::path original_path;
    vector<Mat> examples;
    vector<string> names;
    
    bool step(string image_file);
    void visualize();
    void init();

};

Capture::Capture(string movie): Finder(movie) {
    init();
};

Capture::Capture(int device): Finder(device) {
    init();
};

Capture::~Capture() {
};
    
void Capture::init() {
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
    
    examples = load_example_hands(small_.size(), false);

};


void Capture::run() {
    for(unsigned int i=0; i < examples.size(); i++) {
        example_hand = examples.at(i);
        string image_file = names.at(i);
        while (this->step(image_file)) {
            imshow("Sonic Gesture", combi);
        };
    }
}

bool Capture::step(string image_file) {
    double t = (double) getTickCount();
    grab_frame();
    prepare_frame();
    find_face();
    make_histogram();
    make_backproject();
    make_mask();
    find_contours();
    find_limbs();
    visualize();
    
    t = ((double) getTickCount() - t)*1000 / getTickFrequency();
    int wait = MIN(40, MAX(40 - (int) t, 4)); // Wait max of 40 ms, min of 4;
    int inpoet = waitKey(wait);
    if (inpoet == 27) // escape
        exit(EXIT_FAILURE);
    else if (inpoet == 32) { //space
        fs::path hand_file =  current_train_path / image_file;
        fs::path orig_file = original_path / image_file;
        cout << "saving " << hand_file.string() << endl;
        cout << "saving " << orig_file.string() << endl;
        assert(imwrite(orig_file.string(), small_));
        assert(imwrite(hand_file.string(), left_hand.get_limb_image()));
        return false;
    }
    return true;
};

void Capture::visualize() {
    small_.copyTo(visuals);
    convertScaleAbs(visuals, visuals, 0.2);
    small_.copyTo(visuals, mask);
    rectangle(small_, face.tl(), face.br(), Scalar(0, 255, 0));
    
    if (head.data) {
        vector<vector<Point> > cs;
        cs.push_back(head.contour_small);
        drawContours(visuals, cs, -1, Scalar(0, 0, 255));
    }
    
    if (left_hand.data) {
        vector<vector<Point> > cs;
        cs.push_back(left_hand.contour_small);
        drawContours(visuals, cs, -1, Scalar(0, 255, 0));
    }
    
    if (right_hand.data) {
        vector<vector<Point> > cs;
        cs.push_back(right_hand.contour_small);
        drawContours(visuals, cs, -1, Scalar(255, 0, 0));
    }
 
    
    presentation.clear();
    presentation.push_back(small_);
    //presentation.push_back(backproj);
    presentation.push_back(visuals);
    presentation.push_back(example_hand);
    
    int w = (int)(MIN(XWINDOWS, presentation.size()) * small_size.width);
    int h = (int)(ceil(float(presentation.size()) / XWINDOWS) * small_size.height);
    combi.create(Size(w, h), CV_8UC3);
    for (unsigned int i = 0; i < presentation.size(); i++) {
        Mat current = presentation.at(i);
        int xoffset = (i % XWINDOWS) * small_size.width;
        int yoffset = (i / XWINDOWS) * small_size.height;
        Mat roi(combi, Rect(xoffset, yoffset, small_size.width, small_size.height));
        if (current.channels() == 3) {
            current.copyTo(roi);
        } else {
            cvtColor(current, roi, CV_GRAY2RGB);
        }
    }
}


int main(int argc, char** argv) {
    Capture cap = Capture(DEVICE);
    cap.run();
    return (EXIT_SUCCESS);
}

