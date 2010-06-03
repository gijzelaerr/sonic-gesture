
#include "loader.h"
#include "tools.h"
#include <fstream>

#include <QtCore/QDebug>
#include <QtDebug>

bool Loader::load(QDir location, Size size) {
    if(!location.exists()) {
        setError(QString("location %1 doesn't exists").arg(location.absolutePath()));
        return false;
    };

    QDir examplesPath(location.path() + "/examples");
    if(!examplesPath.exists()) {
        setError(QString("location %1 doesn't exists").arg(examplesPath.absolutePath()));
        return false;
    };

    QFileInfo labelsPath(location.path() + "/labels.txt");
    if(!labelsPath.exists()) {
        setError(QString("location %1 doesn't exists").arg(labelsPath.absolutePath()));
        return false;
    };

    if(!load_examples(examplesPath, size)) {
        return false;
    };

    if(!load_labels(labelsPath)) {
        return false;
    };

    if (labels.size() != examples_left.size() || labels.size() != examples_right.size()) {
        setError("number of labels is not equal to number of examples!");
        return false;
    };
    return true;
};

bool Loader::load_examples(QDir examples_path, Size size) {
    int i = 0;
    QFileInfo file_path;
    examples_left.clear();
    examples_right.clear();
    while(true) {
        Mat left, right, tmp;
        file_path = QFileInfo(examples_path.path() + QString("/%1.jpg").arg(i++));
        if (!file_path.exists())
            break;
        tmp = imread(file_path.filePath().toStdString());
        assert(tmp.data);
        resize(tmp, left, size);
        flip(left, right, 1);
        examples_left.push_back(left);
        examples_right.push_back(right);
    };
    return true;
};

bool Loader::load_labels(QFileInfo labels_path) {
    if (!labels_path.isReadable()) {
        setError(QString("file %1 is not readable").arg(labels_path.filePath()));
        return false;
    }
    ifstream file;
    string lineread;
    int i;
    file.open(labels_path.filePath().toStdString().c_str(), ifstream::in);

    while(std::getline(file, lineread)) {
        istringstream myStream(lineread);
        if (myStream>>i) {
            labels.push_back(i);
        } else {
            break;
        }
        
    };
    return true;
};

void Loader::setError(QString error) {
    qDebug() << error;
    this->error = error;
}
