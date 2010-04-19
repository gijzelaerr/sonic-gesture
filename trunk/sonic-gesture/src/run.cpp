
#include "cv.h"

#include "settings.h"

#include "videopipe.h"
#include "source.h"

int main(int, char**) {
    Source source = Source(DEVICE);
    VideoPipe videoPipe = VideoPipe(source);
    videoPipe.run();
    return EXIT_SUCCESS;
    
    
}
