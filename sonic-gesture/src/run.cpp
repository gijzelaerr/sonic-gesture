
#include "cv.h"

#include "settings.h"

#include "videopipe.h"
#include "source.h"

int main(int, char**) {
    Source source = Source(DEVICE);
    VideoPipe videoPipe = VideoPipe(source);
    videoPipe.run();
    //Finder finder = Finder(DEVICE);
    //Finder finder = Finder();
    //finder.run();
    return EXIT_SUCCESS;
}
