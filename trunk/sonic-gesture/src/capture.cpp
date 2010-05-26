
#include "source.h"
#include "bodypart.h"
#include "skinfinder.h"
#include "combiner.h"
#include "loader.h"
#include "capture.h"
#include "tools.h"

#include <QtCore/QDateTime>

Capture::Capture() {};

Capture::Capture(const Size& size) {
    load(size);
};

void Capture::load(const Size& size) {
    settings = Settings::getInstance();

    skinFinder = new SkinFinder(settings->haarFile, settings->probToBinThresh);
    black = Mat(size, CV_8UC3, Scalar(0, 0, 0));
    
    // do size and scale stuff
    scale = float(settings->cvWorkWinHight) / size.height;
    int small_width = int(size.width * scale);
    small_size = Size(small_width, settings->cvWorkWinHight);
    assert(small_size.width > 0);
    assert(small_size.height > 0);

    // load the examples
    Loader loader = Loader();
    QDir dataSet = QDir(settings-> dataSet);
    assert(dataSet.exists());
    loader.load(dataSet, small_size);
    examples = loader.examples_left;
    
    // what images to show
    combiner = new Combiner(small_size, settings->cvWorkWinInX);
    combiner->add_image(skinFinder->frame);
    combiner->add_image(visuals);
    combiner->add_image(current);
    
    // where to store files
    QDir storePath(dataSet.path() + "/incoming");
    if (!storePath.exists()) {
        assert(dataSet.mkdir("incoming"));
    }

    QString now = QDateTime::currentDateTime().toString("yyyy.MM.dd.hh.mm.ss");
    QDir currentTrainPath(storePath.path() + "/" + now);
    QDir originalPath(currentTrainPath.path() + "/original");

    assert(!currentTrainPath.exists());
    assert(storePath.mkdir("now"));
    assert(currentTrainPath.mkdir("original"));

    counter = 0;
};

bool Capture::step(const Mat& big) {
    double t = (double)getTickCount();

    if (counter >= examples.size())
        return false;

    assert(big.data);
    resize(big, small_, small_size, 0, 0, INTER_NEAREST);
    assert(small_.data);

    current = examples.at(counter);
    
    // find the bodyparts
    contours skins_small = skinFinder->compute(small_);
    contours skins = scale_contours(skins_small, float(1)/scale);
    Point face_center = Point(skinFinder->face_center.x/scale, skinFinder->face_center.y/scale);
    bodyparts.update(skins, face_center, big);

    // draw the stuff
    visuals = bodyparts.draw_in_image();
    combined = this->combiner->render();
    //imshow("Sonic Gesture Capturing train data", combined);

    t = ((double)getTickCount() - t)*1000/getTickFrequency();
    int wait = MIN(40, MAX(40-(int)t, 4)); // Wait max of 40 ms, min of 4;

    int inpoet = waitKey(wait);
    if (inpoet == 27) // escape
        exit(EXIT_FAILURE);
    else if (inpoet == 32) { //space
        if (bodyparts.left_hand.state == NOT_VISIBLE) {
            //std::cout << " NO HAND IN IMAGE!" << std::endl;
            return true;
        }

        QFile handFile(currentTrainPath.path() + "/%1.jpg");
        QFile origFile(originalPath.path() + "/%1.jpg");

        assert(imwrite(currentTrainPath.path().toStdString(), big));
        assert(imwrite(originalPath.path().toStdString() + ".jpg",
                bodyparts.left_hand.sized_hog_image));
        
        counter++;
        return false;
    }
    return true;
}

