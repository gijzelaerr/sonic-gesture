

#include "loader.h"
#include "tools.h"
#include <iostream>
#include <fstream>

using namespace std;

void Loader::load(path location, Size size) {
    assert(exists(location));
    path examples_path = location / "examples";
    path labels_path = location / "labels.txt";
    assert(exists(examples_path));
    assert(exists(labels_path));
    load_examples(examples_path, size);
    load_labels(labels_path);
    assert(labels.size() == examples_left.size());
    assert(labels.size() == examples_right.size());
};

void Loader::load_examples(path examples_path, Size size) {
    int i = 0;
    Mat left, right;
    path file_path;
    examples_left.clear();
    examples_right.clear();
    while(true) {
        file_path = examples_path / (int2string(i++) + ".jpg");
        if (!exists(file_path)) {
            break;
        }
        left = imread(file_path.string());
        resize(left, left, size);
        flip(left, right, 1);
        examples_left.push_back(left);
        examples_right.push_back(right);
    };
};

void Loader::load_labels(path labels_path) {
    ifstream file;
    string lineread;
    int i;
    file.open(labels_path.string().c_str(), ifstream::in);
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