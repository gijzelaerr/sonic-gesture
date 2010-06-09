
#include <iostream>
#include <fstream>
#include "skinfinder.h"
#include "source.h"
#include "settings.h"
#include "bodypart.h"
#include "tools.h"
#include <QFileInfo>
#include <QDir>

int main(int argc, char *argv[]) {
    if (argc != 4) {
        std::cout << "usage: " << argv[0] << "<moviefile> <labelfile> <outputfolder>" << std::endl;
        return EXIT_FAILURE;
    };

    // Load the files
    QFileInfo movieFile = QFileInfo(argv[1]);
    QFileInfo labelFile = QFileInfo(argv[2]);
    QDir outputDir = QDir(argv[3]);

    if (!movieFile.exists()) {
        std::cout << "movie " << movieFile.filePath().toStdString() << " doesnt exists!" << std::endl;
        return EXIT_FAILURE;
    };

    if (!labelFile.exists()) {
        std::cout << "label file " << labelFile.filePath().toStdString() << " doesnt exists!" << std::endl;
        return EXIT_FAILURE;
    };

    if (outputDir.exists()) {
        std::cout << outputDir.absolutePath().toStdString() << " already exists!" << std::endl;
        return EXIT_FAILURE;
    };

    std::cout << "creating output directory " << outputDir.absolutePath().toStdString() << std::endl;
    if (!outputDir.mkpath(outputDir.absolutePath())) {
        std::cout << "can't make directory" << outputDir.absolutePath().toStdString() << std::endl;
    };

    // load settings
    Settings* settings = Settings::getInstance();

    // load movie
    Source source;
    if (!source.open(movieFile.filePath()))
        std::cout << source.error.toStdString() << std::endl;

    // initalize other stuff
    SkinFinder skinFinder;
    skinFinder.init();
    float scale = float(settings->cvWorkWinHight) / source.size.height;
    int small_width = int(source.size.width * scale);
    cv::Size small_size = Size(small_width, settings->cvWorkWinHight);
    BodyParts bodyparts;

    // load labels
    vector<int> labels;
    ifstream file;
    string lineread;
    int i;
    file.open(labelFile.filePath().toStdString().c_str(), ifstream::in);
    while(std::getline(file, lineread)) {
        istringstream myStream(lineread);
        if (myStream>>i) {
            labels.push_back(i);
        } else {
            break;
        }
    };

    // main loop
    Mat small_;
    int counter = 0;
    while (true) {
        if(!source.grab())
            break;

        if (counter == labels.size())
            break;

        resize(source.frame, small_, small_size, 0, 0);
        if (!skinFinder.compute(small_)) {
            std::cout << skinFinder.error.toStdString() << std::endl;
            return EXIT_FAILURE;
        }
        contours skins_small = skinFinder.contours;
        contours skins = scale_contours(skins_small, float(1)/scale);
        Point face_center = Point(skinFinder.face_center.x/scale, skinFinder.face_center.y/scale);
        bodyparts.update(skins, face_center, source.frame);

        if (counter >= (labels.size()))
            continue;

        if (source.getAbsolutePos() == labels.at(counter)) {

            QFileInfo store(outputDir.absolutePath() + QString("/%1.jpg").arg(counter));
            std::cout << "writing " << store.filePath().toStdString() << std::endl;
            if (!imwrite(store.filePath().toStdString(), bodyparts.left_hand.sized_hog_image)) {
                std::cout << "can't write image " << store.filePath().toStdString() << endl;
                return EXIT_FAILURE;
            }
            counter++;
        }
    };

    return EXIT_SUCCESS;
}
