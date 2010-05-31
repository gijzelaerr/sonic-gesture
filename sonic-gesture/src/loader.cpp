
#include "loader.h"
#include "tools.h"

#include <iostream>
#include <fstream>

#include <QtCore/QDebug>

void Loader::load(QDir location, Size size) {
    if(!location.exists())
        qDebug() << location.path();

    QDir examplesPath(location.path() + "/examples");
    assert(examplesPath.exists());
    load_examples(examplesPath, size);

    QFileInfo labelsPath(location.path() + "/labels.txt");
    assert(labelsPath.exists());
    load_labels(labelsPath);


    assert(labels.size() == examples_left.size());
    assert(labels.size() == examples_right.size());
};

void Loader::load_examples(QDir examples_path, Size size) {
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
    

};

void Loader::load_labels(QFileInfo labels_path) {
    ifstream file;
    string lineread;
    int i;
    file.open(labels_path.filePath().toStdString().c_str(), ifstream::in);
    assert(file);

    while(std::getline(file, lineread)) {
        istringstream myStream(lineread);
        if (myStream>>i) {
            labels.push_back(i);
        } else {
            break;
        }
        
    };
};
