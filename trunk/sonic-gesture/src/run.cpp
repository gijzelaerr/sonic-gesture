
#include <stdlib.h>
#include "cv.h"
#include "settings.h"
#include "finder.h"

int main(int, char**) {
    cout << "starting run with device " << DEVICE << "." << endl;
    VideoCapture cap(DEVICE);
    Finder finder = Finder(cap);
    //Finder finder = Finder();
    finder.mainloop();
    return EXIT_SUCCESS;
}
