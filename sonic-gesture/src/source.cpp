
#include <iostream>
#include <highgui.h>
#include "source.h"
#include "settings.h"

using namespace std;
using std::cout;

Source::Source() {
 
}

Source::Source(const int& device) {
    cout << "opening device " << device << "." << endl;
    cap = VideoCapture(device);
    init();
}

Source::Source(const string& movie) {
    cout << "opening movie " << movie << "." << endl;
    // TODO: add check if file exists
    cap = VideoCapture(movie);
    init();
}

Source::~Source() {
};

void Source::init() {
    if(!cap.isOpened()) {
        cout << "couldn't open capture device!\n";
        exit(1);
    }

    int width = cap.get(CV_CAP_PROP_FRAME_WIDTH);
    int height = cap.get(CV_CAP_PROP_FRAME_HEIGHT);
    size = Size(width, height);
};

Mat Source::grab() {
    cap >> frame;
    if (!frame.data) {
        cout << "end of movie" << endl;
        exit(EXIT_SUCCESS);
    }
    return frame;
}