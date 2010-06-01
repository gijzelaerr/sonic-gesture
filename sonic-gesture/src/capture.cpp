

#include "capture.h"
#include "loader.h"
#include "tools.h"
#include <QtCore/QDateTime>
#include <QtDebug>

Capture::Capture() {
    settings = Settings::getInstance();
};

bool Capture::init(const Size& size) {
    if (!skinFinder.init()){
        qDebug() << QString("cant initialize skinFinder");
        return false;
    };

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
    combiner = Combiner(small_size, settings->cvWorkWinInX);
    combiner.add_image(skinFinder.frame);
    combiner.add_image(visuals);
    combiner.add_image(current);
    
    // where to store files
    QDir storePath(dataSet.path() + "/incoming");
    if (!storePath.exists()) {
        assert(dataSet.mkdir("incoming"));
    }

    QString now = QDateTime::currentDateTime().toString("yyyy.MM.dd.hh.mm.ss");

    QDir currentTrainPath(storePath.path() + "/" + now);

    QDir originalPath(currentTrainPath.path() + "/original");

    assert(!currentTrainPath.exists());
    assert(storePath.mkdir(now));
    assert(currentTrainPath.mkdir("original"));

    counter = 0;

    return true;
};

bool Capture::step(const Mat& big) {
    if (counter >= examples.size())
        return false;

    assert(big.data);
    resize(big, small_, small_size, 0, 0, INTER_NEAREST);
    assert(small_.data);

    current = examples.at(counter);
    
    // find the bodyparts
    if (!skinFinder.compute(small_)) {
        setError(skinFinder.error);
        return false;
    }
    contours skins_small = skinFinder.contours;

    contours skins = scale_contours(skins_small, float(1)/scale);
    Point face_center = Point(skinFinder.face_center.x/scale, skinFinder.face_center.y/scale);
    bodyparts.update(skins, face_center, big);

    // draw the stuff
    visuals = bodyparts.draw_in_image();
    combined = this->combiner.render();
}

bool Capture::saveImage() {
    if (bodyparts.left_hand.state == NOT_VISIBLE) {
        qDebug() << QString("No hand in image!");
        return false;
    }

    QFile handFile(currentTrainPath.path() + "/%1.jpg");
    QFile origFile(originalPath.path() + "/%1.jpg");

    if (!imwrite(currentTrainPath.path().toStdString(), big)) {
        setError("can't write original image");
        return false;
    }

    if (!imwrite(originalPath.path().toStdString() + ".jpg",
                 bodyparts.left_hand.sized_hog_image)) {
        setError("can't write cutout image");
        return false;
    }

    counter++;
    return true;
};

void Capture::setError(QString error) {
    this->error = error;
    qDebug() << error;
}

