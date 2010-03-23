
#include "boost/filesystem.hpp"
#include "boost/date_time/posix_time/posix_time.hpp"
#include <stdlib.h>
#include "cv.h"
#include "highgui.h"
#include "settings.h"
#include "finder.h"

using namespace std;
using namespace boost;
using namespace cv;
using namespace boost::posix_time;
using namespace boost::gregorian;
namespace fs = boost::filesystem;


class Capture : public Finder {
public:

    Capture(VideoCapture c) : Finder::Finder(c) {}

    void mainloop() {

        string expstr[] = { "00_do.jpg", "01_di.jpg", "02_re.jpg", "03_ri.jpg",
            "04_mi.jpg", "05_fa.jpg", "06_fi.jpg", "07_sol.jpg", "08_si.jpg",
            "09_la.jpg", "10_li.jpg", "11_ti.jpg"};

        vector<string> examples(expstr, expstr + sizeof (expstr)/sizeof (*expstr));

        fs::path examples_path(EXAMPLES_PATH );
        assert(fs::exists(examples_path));

        fs::path train_path(TRAIN_PATH );
        assert(fs::exists(train_path));

        ptime now = second_clock::local_time();
        //Get the date part out of the time
        date today = now.date();
        cout << to_simple_string(today) << endl;
        fs::path store_path = train_path / "gijs";
        assert(!fs::exists(store_path));

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
                if (inpoet == 27) 
                    return;
                else if (inpoet == 32) {
                    fs::path store_file =  store_path / image_file;
                    cout << store_file.string() << endl;
                    //assert(imwrite(image_file, frame));
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

        if (head.contour.size() > 0) {
            vector<vector<Point> > cs;
            cs.push_back(head.contour);
            drawContours(visuals, cs, -1, Scalar(0, 0, 255));
        }

        if (left_hand.contour.size() > 0) {
            vector<vector<Point> > cs;
            cs.push_back(left_hand.contour);
            drawContours(visuals, cs, -1, Scalar(0, 255, 0));
        }

        if (right_hand.contour.size() > 0) {
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
    VideoCapture cap(DEVICE);
    Capture gijs = Capture(cap);
    gijs.mainloop();
    return (EXIT_SUCCESS);
}

