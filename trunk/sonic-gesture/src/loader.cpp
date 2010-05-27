
#include "loader.h"
#include "tools.h"

#include <iostream>
#include <fstream>

void Loader::load(QDir location, Size size) {
    assert(location.exists());

    QDir examplesPath(location.absolutePath() + "/examples");
    assert(examplesPath.exists());
    load_examples(examplesPath, size);

    QFileInfo labelsPath(location.absolutePath() + "/labels.txt");
    //std::cout << labelsPath.absolutePath().toStdString() << endl;
    //assert(labelsPath.exists());
    load_labels(labelsPath);


    assert(labels.size() == examples_left.size());
    assert(labels.size() == examples_right.size());
};

void Loader::load_examples(QDir examples_path, Size size) {
    int i = 0;
    QDir file_path;
    examples_left.clear();
    examples_right.clear();
    while(true) {
        Mat left, right, tmp;
        file_path = QDir(examples_path.absolutePath() + QString("/%1.jpg").arg(i++));
        if (!file_path.exists())
            continue;
        tmp = imread(file_path.absolutePath().toStdString());
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
    file.open(labels_path.absolutePath().toStdString().c_str(), ifstream::in);
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