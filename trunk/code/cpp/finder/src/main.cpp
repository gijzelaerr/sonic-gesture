
#include <iostream>

#include "cv.h"
#include "highgui.h"

#include "finder.h"
#include "hand.h"
#include "skin.h"
#include "settings.h"

using namespace cv;
using namespace std;

int main(int, char**) {
    VideoCapture cap(DEVICE);
    Finder finder(cap);
    finder.mainloop();
    return EXIT_SUCCESS;
}