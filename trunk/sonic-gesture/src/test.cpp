
#include "cv.h"


#include "settings.h"
#include "source.h"
#include "skinfinder.h"
#include "bodypart.h"

using namespace cv;

int main(int, char**) {
    Source source = Source(DEVICE);
    SkinFinder skinFinder = SkinFinder();
    BodyParts bodyParts = BodyParts();
    Mat good = imread(DATA_DIR + "/good.jpg");
    vector<vector<Point> > skins = skinFinder.compute(good);
    bodyParts.update(skins, skinFinder.face_center, good);
    Mat visuals = bodyParts.draw_in_image();
    for (;;) {
        imshow("visuals", visuals);
        if (waitKey(0)>0)
            return EXIT_SUCCESS;
    }
}
