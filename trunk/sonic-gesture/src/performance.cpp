
#include <iostream>
#include <fstream>
#include "skinfinder.h"
#include "source.h"
#include "settings.h"
#include "bodypart.h"
#include "tools.h"
#include "matcher.h"
#include "loader.h"
#include <QFileInfo>
#include <QDir>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        std::cout << "usage: " << argv[0] << "<moviefile>" << std::endl;
        return EXIT_FAILURE;
    };

    // Load the files
    QFileInfo movieFile = QFileInfo(argv[1]);

    if (!movieFile.exists()) {
        std::cout << "movie " << movieFile.filePath().toStdString() << " doesnt exists!" << std::endl;
        return EXIT_FAILURE;
    };

    // load settings
    Settings* settings = Settings::getInstance();

    // load movie
    Source source;
    if (!source.open(movieFile.filePath()))
        std::cout << source.error.toStdString() << std::endl;

    source.setLoop(false);

    // initalize other stuff
    SkinFinder skinFinder;
    skinFinder.init();
    float scale = float(settings->cvWorkWinHight) / source.size.height;
    int small_width = int(source.size.width * scale);
    cv::Size small_size = Size(small_width, settings->cvWorkWinHight);
    BodyParts bodyparts;

    // load the examples
    Loader loader = Loader();
    if (!loader.load(settings->dataSet, small_size)) {
        std::cout << loader.error.toStdString() << std::endl;
        return EXIT_FAILURE;
    };

    // load the actual classifier
    Matcher matcher = Matcher(false, loader.labels);

    int hand_index;
    // main loop
    Mat small_;
    int counter = 0;
    while (true) {
        if(!source.grab())
            break;

        hand_index = -1;
        resize(source.frame, small_, small_size, 0, 0);
        if (!skinFinder.compute(small_)) {
            std::cout << skinFinder.error.toStdString() << std::endl;
            return EXIT_FAILURE;
        }
        contours skins_small = skinFinder.contours;
        contours skins = scale_contours(skins_small, float(1)/scale);
        Point face_center = Point(skinFinder.face_center.x/scale, skinFinder.face_center.y/scale);
        bodyparts.update(skins, face_center, source.frame);

        // interpretate the bodyparts
        if (bodyparts.left_hand.state != NOT_VISIBLE)
            hand_index = matcher.match(bodyparts.left_hand.sized_hog_features);

        std::cout << source.getAbsolutePos() << " " << hand_index << std::endl;
    };

    return EXIT_SUCCESS;
}
