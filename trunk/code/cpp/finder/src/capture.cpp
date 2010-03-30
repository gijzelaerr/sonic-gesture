
#include <stdlib.h>

#include "cv.h"
#include "highgui.h"
#include "boost/filesystem.hpp"
#include "boost/date_time/posix_time/posix_time.hpp"

#include "settings.h"
#include "finder.h"

using namespace std;
using namespace boost;
using namespace cv;
using namespace boost::posix_time;
using namespace boost::gregorian;
namespace fs = boost::filesystem;


// Inherit from main program, since we want to do almost the same here
class Capture : public Finder {
public:

    Capture(VideoCapture c) : Finder::Finder(c) {}


    void mainloop() {

        // the file names of example and train
        string expstr[] = { "00_do.jpg", "01_di.jpg", "02_re.jpg", "03_ri.jpg",
            "04_mi.jpg", "05_fa.jpg", "06_fi.jpg", "07_sol.jpg", "08_si.jpg",
            "09_la.jpg", "10_li.jpg", "11_ti.jpg"};

        vector<string> examples(expstr, expstr + sizeof (expstr)/sizeof (*expstr));

        fs::path examples_path(EXAMPLES_PATH );
        assert(fs::exists(examples_path));

        fs::path train_path(TRAIN_PATH );
        assert(fs::exists(train_path));

        ptime now = second_clock::local_time();
        date today = now.date();
        fs::path current_train_path = train_path / to_simple_string(now);
        fs::path original_path = current_train_path / "original/";
        
        // make sure this directory _doens't_ exists, so we don't overwrite
        assert(!fs::exists(current_train_path));
        
        assert(create_directory(current_train_path));
        assert(create_directory(original_path));

        for(unsigned int i=0; i < examples.size(); i++) {
            string image_file = examples.at(i);
            fs::path image_path = examples_path / image_file;
            assert(fs::exists(image_path));
            Mat small_hand = imread(image_path.string(), 1);
            resize(small_hand, example_hand, small.size());

            for (;;) {
                double t = (double) getTickCount();

                grab_frame();
                find_face();
                make_histogram();
                make_backproject();
                make_mask();
                find_contours();
                find_limbs();
                visualize();
                imshow("Sonic Gesture", combi);

                t = ((double) getTickCount() - t)*1000 / getTickFrequency();
                int wait = MIN(40, MAX(40 - (int) t, 4)); // Wait max of 40 ms, min of 4;
                int inpoet = waitKey(wait);
                if (inpoet == 27) // escape
                    return;
                else if (inpoet == 32) { //space
                    fs::path hand_file =  current_train_path / image_file;
                    fs::path orig_file = original_path / image_file;
                    cout << "saving " << hand_file.string() << endl;
                    cout << "saving " << orig_file.string() << endl;
                    imshow("left hand", left_hand.get_limb_image());
                    assert(imwrite(orig_file.string(), small));
                    assert(imwrite(hand_file.string(), left_hand.get_limb_image()));
                    break;
                }
            }
        }
    }

    void visualize() {
        small.copyTo(visuals);
        convertScaleAbs(visuals, visuals, 0.2);
        small.copyTo(visuals, mask);
        rectangle(small, face.tl(), face.br(), Scalar(0, 255, 0));

        if (head.data) {
            vector<vector<Point> > cs;
            cs.push_back(head.contour);
            drawContours(visuals, cs, -1, Scalar(0, 0, 255));
        }

        if (left_hand.data) {
            vector<vector<Point> > cs;
            cs.push_back(left_hand.contour);
            drawContours(visuals, cs, -1, Scalar(0, 255, 0));
        }

        if (right_hand.data) {
            vector<vector<Point> > cs;
            cs.push_back(right_hand.contour);
            drawContours(visuals, cs, -1, Scalar(255, 0, 0));
        }


        presentation.clear();
        presentation.push_back(small);
        presentation.push_back(visuals);
        presentation.push_back(example_hand);

        int w = MIN(XWINDOWS, presentation.size()) * small_size.width;
        int h = ceil(float(presentation.size()) / XWINDOWS) * small_size.height;
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
private:
    Mat example_hand;
};


int main(int argc, char** argv) {
    assert(fs::exists(fs::path(DEVICE)));
    VideoCapture cap(DEVICE);
    Capture gijs = Capture(cap);
    gijs.mainloop();
    return (EXIT_SUCCESS);
}

