/*
 *  source.cpp
 *  sonic-gesture
 *
 *  Created by Gijs Molenaar on 4/14/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "source.h"


Source::Source(int device) {
    cout << "opening device " << DEVICE << "." << endl;
    cap = VideoCapture(device);
    init();
}

Source::Source(string movie) {
    cout << "opening movie " << movie << "." << endl;
    // TODO: add check if file exists
    cap = VideoCapture(movie);
    init();
}

Source::~Source() {
};

void Finder::init() {
    if(!cap.isOpened()) {
        cout << "couldn't open capture device!\n";
        exit(1);
    }
};

&Mat Finder::grab_frame() {
    cap >> frame;
    if (!frame.data) {
        cout << "end of movie" << endl;
        exit(EXIT_SUCCESS);
    }
    return frame;
}