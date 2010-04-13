
#include <stdlib.h>
#include "cv.h"
#include "settings.h"
#include "finder.h"

int main(int, char**) {
    Finder finder = Finder(DEVICE);
    //Finder finder = Finder();
    finder.run();
    return EXIT_SUCCESS;
}
