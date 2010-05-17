
#include <iostream>
#include <highgui.h>
#include "source.h"

using std::cout;
using std::endl;

Source::Source() {
}

Source::Source(int device) {
    cout << "opening device " << device << "." << endl;
    cap = VideoCapture(device);
    mirror = true;
    init();
}

Source::Source(const string& movie) {
    cout << "opening movie " << movie << "." << endl;
    // TODO: add check if file exists
    cap = VideoCapture(movie);
    mirror = false;
    init();
}

Source::~Source() {
};

void Source::init() {
    if(!cap.isOpened()) {
        cout << "couldn't open capture device!\n";
        exit(EXIT_FAILURE);
    }

    cap >> frame;
    assert(frame.data);
    
    // doesn't work for webcam somehow
    //int width = cap.get(CV_CAP_PROP_FRAME_WIDTH);
    //int height = cap.get(CV_CAP_PROP_FRAME_HEIGHT);
    int width = frame.cols;
    int height = frame.rows;
    
    assert(width > 0);
    assert(height > 0);
    size = Size(width, height);
};

Mat& Source::grab() {
    cap >> frame;
    if (!frame.data) {
        cout << "end of movie" << endl;
        exit(EXIT_SUCCESS);
    }
    //Mat flip;
    if(mirror) {
        flip(frame, frame, 1);

    }
    return frame;
}